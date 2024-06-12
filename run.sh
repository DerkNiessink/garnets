#!/bin/bash
#SBATCH -J garnets
#SBATCH -t 1:30:00
#SBATCH -N 1
#SBATCH --tasks-per-node 15
#SBATCH --mem=60G

cd dl-poly-5.1.0/execute

module load 2022
module load 2023
module load foss/2023a
module load OpenMPI/4.1.5-GCC-12.3.0
module load GCC/12.3.0

echo "Running DLPOLY..."
srun DLPOLY.Z

echo -e "\nSaving output files..."

current_date_time=$(date '+%Y-%m-%d_%H-%M-%S')
./store "${current_date_time}" 2>/dev/null
./cleanup 2>/dev/null

echo "Finished"