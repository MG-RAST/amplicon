# Amplicon Pipeline

Run the amplicon pipeline with all tools installed inside a Docker container. Your data and the reference databases live outside the container in a directory that is "mounted" into the container at execution time. The pipeline is implemented with Common Workflow Language (CWL), allowing execution with a variety of execution platforms (see http://commonwl.org).

## Requirements
- docker

To obtain docker got to https://docs.docker.com/engine/installation/

## Setup and run example

1. `git clone https://github.com/MG-RAST/amplicon.git`

Change into cloned repository:

2. `cd amplicon`

Download reference databases:

3. `./setup.sh`

or from within the container

`docker run -v `pwd`:/amplicon -ti --rm --entrypoint bash  --workdir /amplicon mgrast/amplicon:latest setup.sh`

Change into the newly created Data directory:

4. `cd Data`

This will be your working directory. Copy or move your sequence files into this directory and rename them to R1.fastq.gz and R2.fastq.gz For example:

5. ` cp your_path/ your_sequence_files.R1.fastq.gz > R1.fastq.gz`
5. `cp your_path/ your_sequence_files.R2.fastq.gz > R2.fastq.gz`

 
6. `docker run -v `pwd`:/Data mgrast/tap:latest `
