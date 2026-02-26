#!/bin/bash
#SBATCH --account=def-deborahh
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8
#SBATCH --time=12:00:00
#SBATCH --job-name=sbi-tutorial-10m
#SBATCH --gpus=nvidia_h100_80gb_hbm3_2g.20gb:1
#Setup env

# Parse arguments
if [ $# -lt 3 ]; then
    echo "Usage: train_sbi.sh <data_folder> <models_folder> <sbi_logs_folder>"
    exit 1
fi

data_folder="$1"
models_folder="$2"
sbi_logs_folder="$3"

mkdir -p "${models_folder}" "${sbi_logs_folder}"

module restore

fit_label=initial_training
model_label=tutorial_1M.ts

# Create model directory
model="${models_folder}/${fit_label}"
mkdir -p "${model}"

# check for existing model file to resume
resume_arg=""
if [ -f "${model}/${model_label}" ]; then
    echo "Existing model found, will resume using ${model}/${model_label}"
    resume_arg="--inference-file ${model}/${model_label}"
fi

# Tutorial Variable
mach3_type=Tutorial
config_file=/home/henryi/sft/MaCh3Tutorial/TutorialConfigs/FitterConfig.yaml

# Environment
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
source ~/scratch/venvs/.venv_sbi/bin/activate
source ~/scratch/venvs/.venv_sbi/bin/setup.MaCh3.sh
source ~/scratch/venvs/.venv_sbi/bin/setup.MaCh3Tutorial.sh


build_posterior --mach3-type ${mach3_type} \
                --config-file ${config_file} \
                --mach3-dataset ${data_folder} \
                --save-file ${model}/${model_label} \
                ${resume_arg} \
                --hidden-features 256 \
                --num-transforms  15\
                --batch-size 8192 \
                --learning-rate 5e-5 \
                --num-workers ${SLURM_CPUS_PER_TASK} \
                --cyclical-pars 'delta_cp' \
                --tensorboard-dir ${sbi_logs_folder}/${fit_label} \
                --stop-after-epochs 100\
                --max-epochs 60000

echo "Job finished"
