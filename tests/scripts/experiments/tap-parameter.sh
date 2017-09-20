#!/usr/bin/env bash

# Run parameter sweep withtap 0.8.1 pipeline 
# jobs are in the amplicon repository in TESTS/experiments/parameter-tap/

# from within the amplicon dir $SOME_PATH/amplicon



# Set env
amplicon_dir=`pwd` 
jobdir=${amplicon_dir}/tests/experiments/parameter-tap/
workflowdir=${amplicon_dir}/CWL/Workflows
outdir=${amplicon_dir}/CWL/Data/Outputs/Experiment-Forest1/
scriptdir=`dirname $0`
container_option=''  # or '--no-container'
archivedir=${amplicon_dir}/archive


# Create dirs if not exists
mkdir -p $jobdir
mkdir -p $outdir
mkdir -p $archivedir

# Create jobs from scratch?
# assuming data is in $amplicondir/CWL/Data/Inputs
python $scriptdir/tap-parameter-jobs.py  --outdir $jobdir --datadir $amplicon_dir/CWL/Data/Inputs

cd $workflowdir
for job in ${jobdir}/*.json 
do 
  tmp=`basename $job .job.json` 
  echo $outdir/$tmp 
  mkdir -p $outdir/$tmp 
  time cwl-runner ${container_option} --outdir $outdir/$tmp  ${workflowdir}/tap.prok.short.0.8.1.cwl $job \
    1> $outdir/$tmp/receipt.json \
    2> $outdir/$tmp/wf.error.log
done 

# Create summary counts
time python $scriptdir/../create_counts.py --outdir ${outdir} --basedir ${outdir}  2> $outdir/error.counts.log

# Archive run
id=`date +%F-%H-%M-%S-%s` 
cd $outdir/..
time tar -cf ${archivedir}/tap-parameter.${id}.tar  Experiment-Forest1/

# upload to archive server, e.g. shock
# missing
