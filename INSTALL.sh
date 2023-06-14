!#/bin/bash
program=$ARG[0]
awk sed $program >> mpiq .f90
mpifort -o mpiq.exe mpiq.f90
