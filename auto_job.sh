for value in {1..5}
do
    sed "s/input.txt/input${value}.txt/g" jobscript.pbs > jobscript${value}.pbs
    qsub jobscript${value}.pbs
done
