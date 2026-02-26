#!/bin/bash

# Get the absolute path to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Usage: run_analysis.sh <analysis_name> n_simulations/100 [n_array]"
    echo "Example: run_analysis.sh my_analysis 1000 3"
    echo "n_simulations/100 controls the number of simulations per array job for data generation (e.g. 1000 means 100,000 simulations per job)"
    echo "n_array defaults to 1 and controls sbatch --array size for the training job"
    return
fi

analysis_name="$1"
n_sim_per_job="${2:-1000}"  # number of simulations per array job for data generation (default: 100,000 simulations per job)
n_array="${3:-1}"  # number of array tasks when submitting training job

# Get absolute path and create analysis directory structure
base_path="$(pwd)/analyses/${analysis_name}"
data_folder="${base_path}/data"
models_folder="${base_path}/models"
logs_folder="${base_path}/logs"

data_logs_folder="${logs_folder}/data-logs"
model_logs_folder="${logs_folder}/model-logs"

sbi_logs_folder="${base_path}/sbi-logs"
scripts_folder="${base_path}/scripts"

mkdir -p "${data_folder}" "${models_folder}" "${logs_folder}" "${sbi_logs_folder}" "${data_logs_folder}" "${model_logs_folder}" "${scripts_folder}"

echo "Starting analysis: ${analysis_name}"
echo "Directories created at: ${base_path}"

# Keep a copy of the scripts used for this analysis
cp ${SCRIPT_DIR}/scripts/generate_data.sh "${scripts_folder}/"
cp ${SCRIPT_DIR}/scripts/train_sbi.sh "${scripts_folder}/"

# Submit generate_data job
echo "Submitting data generation..."
DATAGEN_JOB_ID=$(sbatch --output="${data_logs_folder}/datagen_%x_%A_%a.out" \
                         --error="${data_logs_folder}/datagen_%x_%A_%a.err" \
                         "${SCRIPT_DIR}/scripts/generate_data.sh" "${data_folder}" "${n_sim_per_job}" | awk '{print $4}')
echo "Data generation job ID: ${DATAGEN_JOB_ID}"

# Submit training job which will self-resume if a model file exists
echo "Submitting training job (array size ${n_array})..."
TRAIN_JOB_ID=$(sbatch --dependency=afterok:${DATAGEN_JOB_ID} \
                       --array=1-${n_array}%1 \
                       --output="${model_logs_folder}/sbi_model_%x_%A_%a.out" \
                       --error="${model_logs_folder}/sbi_model_%x_%A_%a.err" \
                       "${SCRIPT_DIR}/scripts/train_sbi.sh" \
                       "${data_folder}" "${models_folder}" "${sbi_logs_folder}" | awk '{print $4}')
echo "Training job ID: ${TRAIN_JOB_ID} (array jobs 1-${n_array})"

echo "Analysis workflow submitted successfully!"
