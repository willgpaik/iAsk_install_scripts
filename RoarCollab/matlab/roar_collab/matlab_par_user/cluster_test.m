clc,clear

Cluster=parcluster('roarcollab');
% Requesting resources: 1 node, 20 procs, 10 minutes, and 4gb/proc
Cluster.ResourceTemplate = '-q open -N 1 -n 20 -t 10:00 --mem-per-cpu=4gb';
% for matlab R2024 or later, use this:
%Cluster.SubmitArguments = '-q open -N 1 -n 20 -t 10:00 --mem-per-cpu=4gb';

% Submit your MATLAB script here:
jj = batch(Cluster, 'testpar','pool',19);

wait(jj)

% pick either method:
% 1) save command line output as a file
diary(jj, 'OutputFile.txt')

% 2) check from Job Monitor
% diary(jj)
% load(jj)


