# Amplicon Pipeline

## Requirements:

You need:

- python
- cwl-runner
- docker

To obtain docker got to https://docs.docker.com/engine/installation/[https://docs.docker.com/engine/installation/

## Setup and run example

Clone the repository and initialize the data directory. This will download some reference databases required by some workflows.

1. git clone https://github.com/MG-RAST/amplicon.git
2. #./setup.sh
3. #cwl-runner Workflow Job



## Building and executing your own docker container
1. docker build -t mgrast/tap .
2. docker run -ti mgrast/tap bash
