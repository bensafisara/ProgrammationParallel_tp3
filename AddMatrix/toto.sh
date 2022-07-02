#!/bin/bash
#SBATCH --job-name=addMtx
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-node=1
#SBATCH --mem=2G
#SBATCH --time=0:05:00


echo "AdditionMatrice!"
#Programme : ./addMtx
time ./addMtx