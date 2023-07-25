#!/bin/bash
runcode=$1; scratch=$2
echo "Set run program : "$runcode
echo "Set scratch     : "$scratch
sed -s 's/\$RUNPROGRAM/$runcode/g' mpiq.f90 > tmp.f90 
sed -s 's/\$SCRATCH/$scratch/g' tmp.f90 > tmp1.f90
mpifort -o mpiq.exe tmp1.f90
rm -f tmp.f90 tmp1.f90
#mpifort -o mpiq.exe mpiq.f90
