#!/bin/bash
for i in {1..10};
do

jobID=$(printf "%02d" $i)

if [[ ! -e job-${jobID} ]]; then

sbatch <<EOF
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=10:00
#SBATCH --output=job-${jobID}
#SBATCH --partition=open

echo 'job ${jobID}'

EOF

else
	echo "job-${jobID} exists"

done
