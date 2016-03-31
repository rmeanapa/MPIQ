# MPIQ
MPI/Fortran90 code that runs a bunch of jobs in parallel.

  MPI FORTRAN code to run several jobs in parallel
  -------------------------------------------------

Author:  Ruben Meana-Paneda
Date:    July 10, 2014
Updated: December 16, 2015
Version: 3.0

Version 2.0: This version of the code allows user to input a number of jobs greater than the number of nodes, i.e. 
a better load balancing is achieved. 
 
Version 3.0: This version can run jobs on an independent directory where each job is run. It makes the use of the
GNU parallel command.

== Files ==

mpiq.f90       MPI-FORTRAN90 code to run several jobs in parallel.
jobslist.txt   This file contains the number of jobs and the names of the input files (without extension).
mpiq.pbs       PBS script to submit the job.

== Installation ==

1. Open the mpiq.f90 file and uncomment/modify the following lines:

   1.1  The runcode variable defines the bash shell commands/program that are going to be run by each job.
        Several options are already included in the present code.

       a) The name of the code that is going to be run and the input file without extension.
          For instance to run Gaussian09:

         runcode(i)  = "g09 "//fname         ! Gaussian execution sentence
 
       b) The code to be run and the name of the input/ouput files with their extensions. 
          For instance to run Gaussian09:

         runcode(i)  = "g09"//" < "//adjustl(trim(fname(i)))//".gjf > " &     ! Code execution sentence (including file extensions)
         &                         //adjustl(trim(fname(i)))//".out"          

          To run MOPAC:

         runcode(i)  = "/usr/soft/mopac/mopac.exe"//" < "//adjustl(trim(fname(i)))//".gjf > " &     ! Code execution sentence (including file extensions)
         &                         //adjustl(trim(fname(i)))//".out"          

       c) If the jobs require a work directory, and other extra steps: 

         runcode(i) = &
         &  "mkdir -p scratch-"//adjustl(trim(fname(i)))// &                                    ! Create work directory
     !   & ";mkdir -p /scratch/meanapan" // &                                                   ! Create scratch directory if needed 
         & ";/bin/cp "//adjustl(trim(fname(i)))//".com scratch-"//adjustl(trim(fname(i)))// &   ! Copy input file in the work directory
         & ";cd scratch-"//adjustl(trim(fname(i)))// &                                          ! Change to the work directory 
         & ";g09 < " //adjustl(trim(fname(i)))//".com > "//adjustl(trim(fname(i)))//".out "// & ! Run code 
         & "; rm -f *scratchfiles* "// &                                                        ! Remove scratch files if needed
         & "; cd .."                                                                            ! Change to home work directory

         For instance to run ANT:

         runcode(i) = &
         &  "mkdir -p scratch-"//adjustl(trim(fname(i)))// &                                    ! Create work directory
         & ";/bin/cp "//adjustl(trim(fname(i)))//".inp scratch-"//adjustl(trim(fname(i)))// &   ! Copy input file in the work directory
         & ";cd scratch-"//adjustl(trim(fname(i)))// &                                          ! Change to the work directory 
         & "; ANT.exe  < " //adjustl(trim(fname(i)))//".inp > "//adjustl(trim(fname(i)))//".out "// & ! Run code 
         & "; cd .."                                                                            ! Change to home work directory

   1.2  Modify the location of the scratch directory used by the program for temporary files in each node:

        scrdir     = "mkdir -p /scratch/meanapan"                              ! Scratch directory if needed


2. Compile the code by executing:

   module load ompi 
   mpif90 -o mpiq.exe mpiq.f90

 or, if the Intel MPI compiler is available:

   module load impi 
   mpif90 -o mpiq.exe mpiq.f90

3. Create the file "jobslist.txt" with the number of jobs and the names of the input files without extension. For instance:
   
    2
    1 
    2

Note that the jobs should be written in order of time priority to get full advantage of this script 
(i.e. jobs that take longer time should be written first).

4. Open the PBS file (mpiq.pbs), change the directory scratch location and the location of the file "mpiq.exe" and 
input the number of nodes. Remember that the number of nodes has to be equal or lower than the number of jobs.

For instance to run two Gaussian jobs at the same time, where each job uses 8 cores of one node, using OpenMPI:

#!/bin/bash -l
#
# Job:  Example
#
#
# To submit this script to the queue type:
#    qsub mpiq.pbs
#
#PBS -m n
#PBS -l nodes=2:ppn=8
#PBS -l walltime=24:00:00
#PBS -l pmem=2000mb
#PBS -e err.e
#PBS -o err.o
#PBS -q batch
#
cd $PBS_O_WORKDIR

module load parallel
parallel "mkdir -p /scratch/meanapan"
module load ompi/1.8.5/intel-2015-update3 
module load gaussian
export GAUSS_SCRDIR=/scratch/meanapan
mpirun -np 2 --map-by node $HOME/soft/bin/mpiq.exe > logfile


== How to submit the job ==

To submit the PBS script (mqiq.pbs) to the queue, type:

qsub mpiq.pbs


== Logfile ==

The file "logfile" contains information of the succesfully executed jobs.


== Test run ==

The directory testrun includes an example that run 16 Gaussian09 jobs in total
by using 4 nodes and 8 cores per node.



 
