#!/bin/bash
#SBATCH --job-name=NameExpe
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-node=1
#SBATCH --mem=2G
#SBATCH --time=0:02:00


echo "AdditionVecteur!"
#Programme : ./addVec
time ./addVec