#!/bin/bash
#SBATCH --account=def-deborahh
#SBATCH --mem-per-cpu=10GB
#SBATCH --cpus-per-task=8
#SBATCH --time=0:30:00
#SBATCH --array=0-99
#SBATCH --job-name=sbi-tutorial-sampler

# Parse data folder argument
if [ $# -lt 2 ]; then
    echo "Usage: generate_data.sh <data_folder> <n_samples>"
    exit 1
fi

data_folder="$1"
n_samples="$2"
mkdir -p "${data_folder}"

#Setup env
module load arrow
export OMP_NUM_THREADS=8
source ~/scratch/venvs/.venv_sbi/bin/activate
source ~/scratch/venvs/.venv_sbi/bin/setup.MaCh3.sh
source ~/scratch/venvs/.venv_sbi/bin/setup.MaCh3Tutorial.sh

# Fit variables
mach3_type=Tutorial
config_file=/home/henryi/sft/MaCh3Tutorial/TutorialConfigs/FitterConfig.yaml

sample_mach3 --mach3-type ${mach3_type} \
             --config-file ${config_file} \
             --n-samples ${n_samples} \
             --output-file ${data_folder}/tutorial_data_${SLURM_ARRAY_TASK_ID}.feather \
             --cyclical-pars 'delta_cp' 

echo "Job finished"
