program pruns
!===================================================================
!  MPI FOTRAN code to run several jobs in parallel
!===================================================================
! Author:  Ruben Meana-Paneda
! Date:    July 10, 2014
! Updated: December 28, 2015
! Version: 3.0
!
implicit none
include 'mpif.h'
character*80,allocatable :: fname(:)
character*80 :: proc_name,scrdir
character*1000,allocatable :: runcode(:)
integer, allocatable :: t1(:),t2(:)
double precision :: ti,tf
integer :: i,irank,ierror,nproc,ntasks,ierr,leng,count_rate
!
call MPI_INIT(ierror)
call MPI_COMM_SIZE (MPI_COMM_WORLD, nproc, ierror)
call MPI_COMM_RANK (MPI_COMM_WORLD, irank, ierror)
call MPI_GET_PROCESSOR_NAME(proc_name,leng, ierror)
ti=MPI_Wtime()
!
if(irank.eq.0)then
 open(unit=20,file='jobslist.txt')                                      ! Open file with the number and the names of the input files
 read(20,*) ntasks
 if (nproc.gt.ntasks) then                                              ! Check number of processors and number of tasks 
   write(6,*) "Error: The number of requested nodes is greater than the number of jobs."
   write(6,*) "The number of jobs must be equal or greater than the number of nodes."
   call MPI_ABORT(MPI_COMM_WORLD,ierror)
   stop
 endif
endif
call mpi_bcast(ntasks,1,mpi_integer,0,mpi_comm_world,ierr)
allocate(runcode(ntasks),t1(ntasks),t2(ntasks),fname(ntasks))
if(irank.eq.0)then
 do i = 1, ntasks
   read(20,*) fname(i)                                                  ! Read the names of the input files 

   runcode(i)  = "g09 "//trim(adjustl(fname(i)))                        ! Code exectution sentence (Gaussian09)

!   runcode(i)  = "g09"//" < "//trim(adjustl(fname(i)))//".com > " &     ! Code execution sentence (including file extensions)
!   &                         //trim(adjustl(fname(i)))//".out"          

!! Codes that needs a work directory for each job
!   runcode(i) = &
!   &  "mkdir -p scratch-"//trim(adjustl(fname(i)))// &                                    ! Create work directory
!   & ";mkdir -p /scratch/meanapan" // &                                                   ! Create scratch directory if needed 
!   & ";/bin/cp "//trim(adjustl(fname(i)))//".com scratch-"//trim(adjustl(fname(i)))// &   ! Copy input file in the work directory
!   & ";cd scratch-"//trim(adjustl(fname(i)))// &                                          ! Change to the work directory 
!   & ";g09 < " //trim(adjustl(fname(i)))//".com > "//trim(adjustl(fname(i)))//".out "// & ! Run code 
!   & "; rm -f *scratchfiles* "// &                                                        ! Remove scratch files if needed
!   & "; cd .."                                                                            ! Change to home work directory

 enddo
 close(20)                                                             ! Close file with the number and input file names
endif
call mpi_bcast(fname,80*ntasks,mpi_character,0,mpi_comm_world,ierr)
call mpi_bcast(runcode,1000*ntasks,mpi_character,0,mpi_comm_world,ierr)
scrdir     = "mkdir -p /scratch/meanapan"                              ! Scratch directory if needed
!
do i=irank+1,ntasks,nproc
 call system(scrdir)                                                   ! Create scratch directory if needed
 call system_clock(t1(i),count_rate)                                   ! Start time
 call system(runcode(i))                                               ! Run code 
 call system_clock(t2(i))                                              ! End time
 write(6,'(A4,A20,A13,A10,A7,I4,A14,f20.3,A9)') "Job ",fname(i)," executed in ",&
 &proc_name," irank ",irank," completed in ",real(t2(i)-t1(i))/real(count_rate), " seconds."
enddo
tf=MPI_Wtime()
write(6,'(A14,A10,f20.3,A9)') "Total time in ",proc_name,tf-ti," seconds."
call MPI_FINALIZE(ierror)
end
