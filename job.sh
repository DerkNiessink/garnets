#!/bin/bash
#Set job requirements
#SBATCH -N 1
#SBATCH --mem=60G

#Load required modules
#module load openmpi
#module load mpicopy
module load 2022
module load 2023
module load foss/2023a
#Copy input to the scratch disk ("$TMPDIR") of each of the nodes. 
#cp -r . "$TMPDIR"

#Execute MPI programs located in $HOME, with the big_input_file located on each of the scratch disks.
cd sim/run_1
srun DLPOLY.Z
