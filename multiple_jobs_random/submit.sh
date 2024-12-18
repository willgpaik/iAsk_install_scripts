#!/bin/bash

for i in {1..5}
do
	rand=$(( RANDOM%5000+1 ))
	sed "s/INPUT/$rand/g" testjob.pbs > TMP.pbs
	qsub TMP.pbs
done

rm TMP.pbs
