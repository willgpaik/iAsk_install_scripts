# Script written by Ghanghoon Paik (gip5038@psu.edu)
# Date created: 5/5/2020

# Script to submit multiple jobs automatically to replace "array job"

# List of files:
1) submit.sh: Automatic submission script with array input
2) testjob.pbs: PBS script for the test job with "input" from list
3) test.py: Sample Python script for test case

# Usage:
$ chmod +x submit.sh
$ ./submit.sh

# In order to change array size or order, edit
submit.sh:
	line 4, change numbers inside curly bracket {1..5} as needed
	ex1) for i in {1..5} -> for 1-5 in sequence (1, 2, 3, 4, 5)
	ex2) for i in {1..20..5} -> for 1-20 with increment of 5 (1, 6, 11, 16)
	ex3) for i in 1 2 5 8 12 -> for 1, 2, 5, 8, 12 (1, 2, 5, 8, 12)
