# SBISubmitScripts
Simple library to submit SBI jobs within a simplified frame work

## Scripts
### `generate_data.sh`
Runs the simulations to build a training set for MaCh3-SBI analyses

__Usage__:
```
./generate_data /path/to/data/folder n_sims
```

Builds the SBI data set. Note it will generate submit 100*n_sims simuatlions

### `train_sbi.sh`
Trains the SBI
__Usage__
```
./train_sbi /path/to/data/models_folder /path/to/tensorboard/log/folder
```
CLI args used can be found in the MaCh3SBITools package!

### `run_analysis.sh`
Runs the full analysis chain from start to finish

__Usage__
```
./train_sbi analysis_name n_sims n_training_jobs
```
Runs the combined generate_data->train_sbi chain. Will generate `n_sims*100` sims and then train SBI on it. SBI will be resubmitted `n_training_jobs` times.