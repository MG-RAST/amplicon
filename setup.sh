#!/usr/bin/env bash

# Get reference databases 
echo Download reference databases
pushd ./
cd CWL/Data/Inputs/DBs/ 
./get_databases.sh .
popd

# Create working directory and link reference dbs
# This directory is intended to be mounted into the tap:1.0 docker container
echo Create input-output directory
mkdir -p Data
cd Data
# ln -s ../CWL/Data/Inputs/DBs/silva_v128NR.341F816R.fasta silva_v128NR.341F816R.fasta
# ln -s ../CWL/Data/Inputs/DBs/silva_v128NR.341F816R.tax silva_v128NR.341F816R.tax
# ln -s ../CWL/Data/Inputs/DBs/PhiX PhiX

cp ../CWL/Data/Inputs/DBs/silva_v128NR.341F816R.fasta silva_v128NR.341F816R.fasta
cp ../CWL/Data/Inputs/DBs/silva_v128NR.341F816R.tax silva_v128NR.341F816R.tax 
cp -R ../CWL/Data/Inputs/DBs/PhiX PhiX
cp ../CWL/Workflows/simple-job.template.yaml tap-default-job.yaml

cd ..

