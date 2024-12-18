#!/bin/bash
for i in {1..10};
do

sbatch <<EOF
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=10:00
#SBATCH --partition=open

echo 'job ${i}'

EOF

done
