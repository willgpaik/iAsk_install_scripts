#!/bin/bash
# In progress

BASE=$PWD

mkdir CFDEM
mkdir LIGGGHTS
cd CFDEM
git clone git://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
cd $BASE
cd LIGGGHTS
git clone git://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git
git clone git://github.com/CFDEMproject/LPP.git lpp

cd CFDEM
# Add OpenFOAM version at the end
mv ./CFDEMcoupling-PUBLIC ./CFDEMcoupling-PUBLIC-5.0
cd CFDEMcoupling-PUBLIC-5.0/src/lagrangian/cfdemParticle/etc
mv ./addLibs_universal ./addLibs_universal_5.0
