#!/bin/bash 
#deltest.sh 1.0

qm destroy 9000 --destroy-unreferenced-disks 1 --purge 1 --skiplock 0
qm destroy 5001 --destroy-unreferenced-disks 1 --purge 1 --skiplock 0
qm destroy 5002 --destroy-unreferenced-disks 1 --purge 1 --skiplock 0
qm destroy 5003 --destroy-unreferenced-disks 1 --purge 1 --skiplock 0
