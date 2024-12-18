#!/bin/bash
jobname=$1
myusername=$2

##Main while loop, condition1=false when convergence is met
condition1=true
mainiteration=1
while $condition1;
do
  echo "Main while loop iteration: $mainiteration" >> main_log
  ##submit initial batch of jobs
  for counter in {1..10};
  do
    qsub -N ${jobname}_${counter}_${mainiteration} -v JOBCOUNT=$counter testjob.pbs
  done
  echo "batch of jobs submitted" >> main_log
  #initial wait in seconds before checking if all initial jobs are completed (adjust accordingly)
  sleep 60
  
  #Second while loop, condition2=false when all initial jobs are completed
  condition2=true
  subiteration1=1
  while $condition2;
  do
    condition2=true
    qactivejobs1=`qstat -u $myusername| grep $jobname | awk '{print $10}' | grep R`
    echo "checking if batch is done..$subiteration1" >> main_log
    if [ -z "$qactivejobs1"];
    then
      qsub convergence_check.pbs
      condition2=false
      echo "batch of jobs done" >> main_log
      echo "convergence job submitted" >> main_log
    fi
    subiteration1=$(($subiteration1+1))
    sleep 60
  done

  #initial wait in seconds before checking if convergence job is completed (adjust accordingly)
  sleep 60

  #Third while loop, condition3=false when convergence job is completed
  condition3=true
  subiteration2=1
  while $condition3;
  do
    condition2=true
    qactivejobs2=`qstat -u $myusername | grep convergence_ch | awk '{print $10}' | grep R`
    echo "checking if convergence job is done..$subiteration2" >> main_log
    if [ -z "$qactivejobs2"];
    then
      condition3=false
      echo "convergence job complete" >> main_log
    fi
    subiteration2=$(($subiteration2+1))
    sleep 60
  done
  
  #test if convergence is met, here the convergence job creates an output file in the submission directory which is used as the check
  echo "checking convergence test" >> main_log
  if grep -q True $PWD/outfile; then
    condition1=false
    echo "convergence reached!" >> main_log
  fi
mainiteration=$(($mainiteration+1))
done

