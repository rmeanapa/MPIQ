# MPIQ

A MPI Fortran wrapper code for parallel jobs.

### Files 

``` mpiq.f90 ```        MPI/Fortran code to run several jobs in parallel.                           
``` jobslist.txt ```    File with number of jobs and names of the input files (without extension).                         
``` mpiq.pbs ```        PBS submission script.                                                    
``` mpiq.slurm ```      Slurm submission script.                                                         

### Installation

1. Open the mpiq.f90 file and uncomment/modify the following lines:

   1.1  The runcode variable defines the bash shell commands/program that are going to be run by each job.
        Several options are already included in the present code.

       a) The name of the code that is going to be run and the input file without extension.
          For instance to run Gaussian09:

   ```Fortran
         runcode(i)  = "g09 "//fname         ! Gaussian execution sentence 
   ```
 
       b) The code to be run and the name of the input/ouput files with their extensions. 
          For instance to run Gaussian09:

   ```Fortran
         runcode(i)  = "g09"//" < "//adjustl(trim(fname(i)))//".gjf > " &     ! Code execution sentence (including file extensions)
         &                         //adjustl(trim(fname(i)))//".out"          
   ```

         E.g. to run MOPAC:

   ```Fortran
         runcode(i)  = "/usr/soft/mopac/mopac.exe"//" < "//adjustl(trim(fname(i)))//".gjf > " &     ! Code execution sentence (including file extensions)
         &                         //adjustl(trim(fname(i)))//".out"          
   ```

       c) If the jobs require a work directory, or other extra steps: 

   ```bash
         runcode(i) = &
         &  "mkdir -p scratch-"//adjustl(trim(fname(i)))// &                                    ! Create work directory
     !   & ";mkdir -p /scratch/meanapan" // &                                                   ! Create scratch directory if needed 
         & ";/bin/cp "//adjustl(trim(fname(i)))//".com scratch-"//adjustl(trim(fname(i)))// &   ! Copy input file in the work directory
         & ";cd scratch-"//adjustl(trim(fname(i)))// &                                          ! Change to the work directory 
         & ";g09 < " //adjustl(trim(fname(i)))//".com > "//adjustl(trim(fname(i)))//".out "// & ! Run code 
         & "; rm -f *scratchfiles* "// &                                                        ! Remove scratch files if needed
         & "; cd .."                                                                            ! Change to home work directory   ```
   ```

         For instance to run ANT:

   ```Fortran
         runcode(i) = &
         &  "mkdir -p scratch-"//adjustl(trim(fname(i)))// &                                    ! Create work directory
         & ";/bin/cp "//adjustl(trim(fname(i)))//".inp scratch-"//adjustl(trim(fname(i)))// &   ! Copy input file in the work directory
         & ";cd scratch-"//adjustl(trim(fname(i)))// &                                          ! Change to the work directory 
         & "; ANT.exe  < " //adjustl(trim(fname(i)))//".inp > "//adjustl(trim(fname(i)))//".out "// & ! Run code 
         & "; cd .."                                                                            ! Change to home work directory 
   ```

   1.2  Modify the location of the scratch directory used by the program for temporary files in each node:

   ```bash
        scrdir     = "mkdir -p /scratch/meanapan"                              ! Scratch directory if needed
   ```


2. Compile the code using the Fortran/MPI compilers. 

   ```bash
   module load ompi 
   mpifort -o mpiq.exe mpiq.f90 
   ```

 or, if the Intel MPI compiler is available:

   ```bash
   module load impi 
   mpifort -o mpiq.exe mpiq.f90 
   ``` 

3. Create the file "jobslist.txt" with the number of jobs and the names of the input files without extension. For instance:
    ```bash 
    2 ! number of jobs
    1 ! input filename
    2 ! input filename
    ``` 

Note that the jobs should be written in order of time priority to get full advantage of this script 
(i.e. jobs that take longer time should be written first).

4. Open the Slurm/PBS file (mpiq.slurm or mpiq.pbs), change the directory scratch location and the location of the file "mpiq.exe" and 
input the number of nodes. Remember that the number of nodes has to be equal or lower than the number of jobs.

For instance to run two Gaussian jobs at the same time, where each job uses 8 cores of one node, using OpenMPI:

```bash
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
```

### How to submit the job 

To submit the Slurm script (mqiq.slurm) to the queue, type:
```bash
slurm mpiq.slurm
```
To submit the PBS script (mqiq.pbs) to the queue, type:
```bash
qsub mpiq.pbs
```

### Logfile 

The file "logfile" contains information of the succesfully executed jobs.

### Test run 

The directory testrun includes an example that run 16 Gaussian09 jobs in total
by using 4 nodes and 8 cores per node.




