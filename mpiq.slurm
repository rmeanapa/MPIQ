#!/bin/bash -l
#
# Job: Example
#
# To submit this script to the queue type:
#    qsub mpiq.pbs
#
#SBATCH --job-name MyJob
#SBATCH --time=1:00:00
#SBATCH --nodes=1 
#SBATCH --ntasks=16
#SBATCH --ntasks-per-core=1 
#SBATCH --account=rmeanapa
#SBATCH --partition=norm

cd $SLURM_SUBMIT_DIR

module load gaussian/g09.a02
export GAUSS_SCRDIR=/scratch/meanapan
mkdir -p /scratch/meanapan

# Load modules
#module load intel impi
#module load gcc openmpi 

# Each job in one node
mpirun -np 2 --map-by node $HOME/soft/bin/mpicola.exe > logfile 
#mpirun -np 2 $HOME/soft/bin/mpicola.exe > logfile 


