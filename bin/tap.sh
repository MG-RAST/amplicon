#!/usr/bin/env bash

set -e

workflow_prok=tap.prok.0.9.cwl #tap.prok.short.0.8.1.cwl
job_prok=tap-default-job.yaml

# Check memory
mem=`grep MemTotal /proc/meminfo | sed -r 's/MemTotal:\s+//' | cut -f1 -d " "`
if [ ${mem} -le 8000000 ] ; then
  echo "Warning, you might have not enough free memory ( ${mem} )" 
fi  
         

write2log="> >(tee receipt.json) 2> >(tee log.txt >&2)"

# workflow_euk=
# job_euk=

if [ `which docker` ]; then
  # echo Found Docker
  container_option=''
else
  # echo No Docker
  container_option='--no-container'
fi
    

if [ "$1" = 'prok' ]; then
    echo Running prok pipeline
    shift

    if [ $1 ] ; then
      exec "cwl-runner ${container_option} ${WORKFLOWDIR}/${workflow_prok} $1"
    else 
      echo $PATH
      echo "cwl-runner ${container_option} ${WORKFLOWDIR}/${workflow_prok} ${JOBDIR}/${job_prok} ${write2log}"
      
      # Not working 
      # exec "cwl-runner ${container_option} ${WORKFLOWDIR}/${workflow_prok} ${JOBDIR}/${job_prok}"
      # exec cwl-runner ${container_option} ${WORKFLOWDIR}/${workflow_prok} ${JOBDIR}/${job_prok} ${write2log}
       
      exec cwl-runner ${container_option} ${WORKFLOWDIR}/${workflow_prok} ${JOBDIR}/${job_prok} 1> >(tee receipt.json >&1) 2> >(tee log.txt >&2)
      
    fi
      
    #exec cwl-runner "$@"
elif [ "$1" = 'euk' ]; then
  echo Euk pipeline not enabled   
  shift

  if [ $1 ] ; then
    echo cwl-runner $WORKFLOWDIR/euk-workflow $1
  else 
    echo cwl-runner euk-workflow euk-job  
  fi
  
elif [ "$1" = 'help' ]; then
  
  echo "Options:
  help                this help
  prok  [JOB]         prokaryotic pipeline, if job is provided
                      running pipeine with job otherwise default
  euk   [JOB]         eukaryotic pipeline, if no job is provided 
                      using default job
  run WORKFLOW JOB    executing workflow and job
  CMD                 executing CMD   
                "
  
elif [ "$1" = 'run' ]; then  
  echo Running your workflow and job
  cwl-runner ${container_option} $2 $3
  
elif [ "$1" = 'debug' ]; then   
  exec "cwl-runner ${container_option} --debug $2 $3" 
else
  #echo "$@" 
  exec "$@"    
fi



