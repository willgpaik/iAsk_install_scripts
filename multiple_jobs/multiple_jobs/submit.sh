#!/bin/bash

# change number of jobs you want to submit with this script (i.e. {1..5} for 5 jobs)
for i in {1..5}
do
	# edit below to change "INPUT" section on PBS script (if not needed, remove it)
	sed "s/INPUT/$i/g" testjob.pbs > TMP.pbs
	qsub TMP.pbs
	rm TMP.pbs
done

