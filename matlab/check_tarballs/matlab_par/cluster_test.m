clc,clear

setenv LD_LIBRARY_PATH /usr/lib64:LD_LIBRARY_PATH

Cluster=parcluster('ACI'); 
Cluster.ResourceTemplate= '-A open -l nodes=1:ppn=20 -l walltime=2:00:00 -l pmem=1gb';
jj = batch(Cluster, 'testpar','pool',19);

%jj = batch(Cluster, 'testpar');

wait(jj)

% pick either method:
% 1) save command line output as a file
diary(jj, 'OutputFile.txt')

% 2) check from Job Monitor
% diary(jj)
% load(jj)


