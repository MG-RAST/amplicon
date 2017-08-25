#!/bin/bash


###
# OPTIONS are declared here
###
declare THREADS=4  # use 4 THREADS whereever possible
declare VSEARCH_GLOBAL="--threads ${THREADS}"

shopt -s globstar
shopt -s extglob
set -e

######################################################################################
######################################################################################
######################################################################################
# STAGE=0001    prepare UNITE and SIVLA fasta database files and taxonomy tables
# STAGE=0050    Mate pair merging 
# STAGE=0055    barcode label into fastq header
# STAGE=0060    PHIX removal using bowtie2 with Illumina RTA genome and Illumina built indeces
# STAGE=0100    target specific primer removal using cutadpt
# STAGE=0200    dereplicating exactly identical reads
# STAGE=0300    OTUclustering
# STAGE=0400    16s ribosomal feature extraction via Metaxa [PROK]
#               ITS feature extraction via ITSx [EUK]
# STAGE=0500    map cleaned reads against centroid sequences (vsearch -userarch_global) [PROK]
#               map cleaned reads against centroid sequences (vsearch -fastx_getseqs) [EUK]
# 
# STAGE=0600    format conversion to .otu files
# STAGE=0700    classification using mothur 



#################
#
function usage {
  echo "Usage: $0 [-i] [-h help] <FILES>"
  echo "$0 <FILES> assume *.R1.fastq.gz and *.R2.fastq.gz files"
  echo "$0 [-i] switch to ION torrent mode"
  echo "$0 [-t] tidy up, leave only minimal files behind"
  echo "$0 -e <primer> -- the Eukaryote primer pair e.g. \"-g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$ \" "
  echo "$0 -p <primer> -- the Prokaryote primer pair e.g. \"-g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$\" "
  echo "$0 using cutadapt syntax, primers have to be anchored with ^ and $"
}

################
#
# get options
while getopts e:p:thvi option; do
    case "${option}"
        in
		h) usage; exit;;
    v) verbose=1;;
    t) TIDY=1;;
    i) ION_TORRENT=1;;
    p) EUKARYOTE_PRIMER_PAIR=${OPTARG} ;;
    e) PROKARYOTE_PRIMER_PAIR=${OPTARG} ;;
		*)
		usage
		;;
    esac
done

shift $((OPTIND-1))

FILES=$@

# make sure we have at least a run folder name
if [[ -z ${FILES} ]]
then
  usage
  exit 1
fi

# use default primer sequences 
if [[ ! ${EUKARYOTE_PRIMER_PAIR} ]]
then
  if [[ ${verbose} ]]
  then
    echo "$0 -- using default primer sequences for Eukaryotes"
  fi
  declare EUKARYOTE_PRIMER_PAIR="-g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$"
  
 
fi
# use default primer sequences 
if [[ ! ${PROKARYOTE_PRIMER_PAIR} ]]
then
  if [[ ${verbose} ]]
  then
    echo "$0 -- using default primer sequences for Prokaryotes"
  fi
  declare PROKARYOTE_PRIMER_PAIR="-g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$ "
fi


if [[ ${verbose} ]]
then
  echo "$0 creating input copy of files as *.tap.100.fastq.gz"
  echo "$0 we can only handle compressed fastq as fastq.gz with R1 and R2 in the names e.g.  foo_bar1.R1.fastq.gz"
  echo "$0 foo is e.g. Euka and bar is e.g. forest3 ; assumption is that numerical suffix in bar allows grouping"
  echo "$0 filename: [Euka|Prok].<string><int>.R<int>.fastq.gz, e.g. Euka.forest3.R1.fastq.gz"
fi

###
# prepare UNITE and SIVLA fasta database files and taxonomy tables
###
STAGE=0001
if [[ ${verbose} ]]
then
 echo "$0 0012 prepare UNITE and SIVLA fasta database files and taxonomy tables using cutadapt"
fi
rm -f ${STAGE}.log

# adapter removal (source code @ https://cutadapt.readthedocs.org/en/stable/)
declare CUTADAPT_PARAM="-e 0.06 -f fasta " #"--discard-untrimmed"

# create "clean" version of primer strings
prok_forward=$(echo ${PROKARYOTE_PRIMER_PAIR} | awk -F^ ' { print $2 }' | cut -f1 -d\  )
prok_reverse=$(echo ${PROKARYOTE_PRIMER_PAIR} | awk -F^ ' { print $2 }' | cut -f2 -d- | cut -f2 -d\  | tr -d '$')

# local DB directory, this might be better stored in SHOCK in the long run as a global thingy
mkdir -p db

# if there is no primer pair specific version of SILVA, create one
if [[ ! -e db/SILVA.${prok_forward}.${prok_reverse} ]]
then
  
  if [[ ${verbose} ]]
  then
   echo "$0 creating a new SILVA ePCR version for the primers"
  fi
  
  cmd="cutadapt -g ${prok_forward} \
           -a ${prok_reverse} \
           ${CUTADAPT_PARAM} \
           /usr/local/share/db/SILVA*.fasta \
           -o db/SILVA.${prok_forward}.${prok_reverse} "
  
  ${cmd} >> ${STAGE}.log
fi

echo "$0 FM--> Martin:: do we need to run this again and trim reverse complement and then also use --discard-untrimmed"
# create "clean" version of primer strings
euka_forward=$(echo ${EUKARYOTE_PRIMER_PAIR} | awk -F^ ' { print $2 }' | cut -f1 -d\  )
euka_reverse=$(echo ${EUKARYOTE_PRIMER_PAIR} | awk -F^ ' { print $2 }' | cut -f2 -d- | cut -f2 -d\  | tr -d '$')

# if there is no primer pair specific version of SILVA, create one
if [[ ! -e db/UNITE.${euka_forward}.${euka_reverse} ]]
then
  
  if [[ ${verbose} ]]
  then
   echo "$0 creating a new SILVA ePCR version for the primers"
  fi
  
  cmd="cutadapt -g ${euka_forward} \
           -a ${euka_reverse} \
           ${CUTADAPT_PARAM} \
            --discard-untrimmed \
           /usr/local/share/db/UNITE*.fasta \
           -o db/UNITE.${euka_forward}.${euka_reverse}"

  ${cmd} >> ${STAGE}.log

fi

#grab only IDs for matchign sequences from taxonomy file, mothur requires 1=1 mapping 
echo "$0 still need to prune the UNIT taxonomy "

### 
#   create input files
###
STAGE=0010
for file in $(ls -1 ${FILES}  )
do
  if [[ "${file}" != *tap* ]] 
    then 
      name=$(basename ${file} .fastq.gz)
      out_file=${name}.tap.${STAGE}.fastq
      echo Processing $out_file
      if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
        then
          if [[ $verbose ]]
          then
            echo "skipping $file";
          fi
        else
          cmd="gzip -d -c ${file}" #"> ${out_file}"
          echo $cmd
          $cmd > ${out_file}
          #(${cmd}) | tee ${out_file}
        fi
  fi    
done


 
 ###
 # Mate pair merging 
 ###
 STAGE=0050 
 if [[ ${verbose} ]]
 then
  echo "$0 ${STAGE} merging mate pairs with vsearch "
 fi
 rm -f ${STAGE}.log

 for file in *R1.tap.0010.fastq
 do
   echo Processing $file 
   name=$(basename ${file} .R1.tap.0010.fastq)
   out_file=${name}.tap.${STAGE}.fastq
   echo Writing to $name: ${name}.tap.${STAGE}.fastq
  
   if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
   then 
     if [[ $verbose ]]
     then
       echo "$0 skipping $out_file, already exists"
     fi
   else
     cmd="vsearch ${VSEARCH_GLOBAL} \
          --fastq_mergepairs  ${name}.R1.tap.0010.fastq  \
          --reverse ${name}.R2.tap.0010.fastq \
          --fastqout ${out_file} "
     ${cmd} >> ${STAGE}.log 2>&1
   fi
 done
 

 
 ###
 # PHIX removal using bowtie2 with Illumina RTA genome and Illumina built indeces
 ###
 STAGE=0060
 if [[ ${verbose} ]]
 then
  echo "$0 ${STAGE} remove PhiX contaminants using bowtie2"
 fi
 rm -f ${STAGE}.log
 
 export BOWTIE2_INDEXES=/usr/local/share/db/bowtie2
 for file_name in *.tap.0050.fastq
  do
    name=$(basename "${file_name}" .tap.0050.fastq )
    out_file=${name}.tap.${STAGE}.fastq
   
    # there is no output file, create one
      if [ -f ${out_file} ] || [ ${file_name} -ot ${out_file} ]
      then 
        if [[ $verbose ]]
        then
          echo "$0 skipping $out_file, already exists"
        fi
      else
        cmd="bowtie2 -p ${THREADS} -x genome --un ${out_file} -U ${file_name} -S /dev/null"
        echo ${cmd} >> ${STAGE}.log
        ${cmd} >> ${STAGE}.log  2>&1
      fi

  done

###
# remove specified primer in input sequences using cutadpt
###
STAGE=0100
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} "
fi
rm -f ${STAGE}.log

# adapter removal (source code @ https://cutadapt.readthedocs.org/en/stable/)
declare CUTADAPT_PARAM="-e 0.06 -f fastq --trimmed-only"

for file in Euka*.tap.0060.fastq
do 
  name=$(basename ${file} .tap.0060.fastq) 
  out_file=${name}.tap.${STAGE}.fastq
  if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else
      cmd="cutadapt ${EUKARYOTE_PRIMER_PAIR}  ${CUTADAPT_PARAM} ${file} -o ${out_file} "
      ${cmd} >> ${STAGE}.log
    fi
done

for file in Prok*.tap.0060.fastq
do
  name=$(basename ${file} .tap.0060.fastq) 
  out_file=${name}.tap.${STAGE}.fastq
  if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else
      cmd="cutadapt  ${PROKARYOTE_PRIMER_PAIR}  ${CUTADAPT_PARAM} ${file} -o ${out_file} "
      ${cmd} >> ${STAGE}.log  
    fi
done

echo "$0 FM---> Martin remind me why should I run this twice? # run twice to get forward and reverse adapters"

###
# dereplicating exactly identical reads
###
STAGE=0200
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} de-replicating with vsearch"
fi

rm -f ${STAGE}.log
declare VSEARCH_DEREP_OPTIONS="${VSEARCH_GLOBAL} -sizeout -minuniquesize 2"
echo "$0 vsearch --derep :: MARTIN --> SHOULD we use --strand both?"

for file in *.tap.0100.fastq
do
   name=$(basename ${file} .tap.0100.fastq) 
   # dereplication of full length identical reads? 
   out_file=${name}.tap.${STAGE}.fastq
   if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
   then 
     if [[ $verbose ]]
     then
       echo "$0 skipping $out_file, already exists"
     fi
     else
        cmd="vsearch ${VSEARCH_DEREP_OPTIONS} \
             -derep_fulllength ${file} \
             -output ${name}.tap.${STAGE}.fasta "
        echo $cmd >> ${STAGE}.log 
        ${cmd} >> ${stage}.log  2>&1
    fi  
done

###
# OTUclustering
###
STAGE=0300
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} OTUclustering via vsearch"
fi

rm -f ${STAGE}.log

declare VSEARCH_OTU_CLUST_PARAMS="${VSEARCH_GLOBAL} -sizein -sizeout --id 0.97  " # removed " -otu_radius_pct 3 "

for file in *.tap.0200.fasta
do
  name=$(basename ${file} .tap.0200.fasta) 
  prefix=$(echo $name | cut -d. -f1 )

  out_file=${name}.tap.${STAGE}.fastq
  if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else #             -relabel "OTU${prefix:0:1}_" \
      cmd="vsearch ${VSEARCH_OTU_CLUST_PARAMS} \
            -cluster_size ${file} \
            -relabel "OTU${prefix:0:1}_" \
            -centroids ${name}.tap.${STAGE}.fasta " # "\
           # --biomout ${name}.tap.${STAGE}.biom "
      echo $cmd >> ${STAGE}.log
      $cmd >> ${STAGE}.log  2>&1
    fi
done



###
# 16s ribosomal feature extraction via Metaxa
###
STAGE="0400"

if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} 16s ribosomal read extraction via Metaxa"
fi
rm -f ${STAGE}.log

declare METAXA_PARMS="-t a,b --complement F --cpu 4"

for file in Prok*.tap.0300.fasta
do
  name=$(basename ${file} .tap.0300.fasta) 
  out_file=${name}.tap.${STAGE}.fasta
  out_prefix=${name}.tap.${STAGE}.metaxa

  if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else 

        cmd="metaxa2_x ${METAXA_PARMS} -i ${file}  -o ${out_prefix}"
        echo $cmd >> ${STAGE}.log
        ${cmd} >> ${STAGE}.log 2>&1
  
        # remove the comments added by metaxa
        cat ${out_prefix}.extraction.fasta | sed " s/\(^.*\)|.*/\1barcodelabel=${name};/g" > ${out_file}
        
      fi
      
  if [[ ${TIDY} ]]
    then
      rm -rf ${out_prefix}*
    fi
done 

###
# ITS feature extraction via ITSx
###
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} ITS read extraction via ITSx"
fi

declare ITSx_PARMS="--complement F --cpu 4 --preserve T --only_full --reset "

for file in Euk*.tap.0300.fasta
do
  name=$(basename ${file} .tap.0300.fasta) 
  out_file=${name}.tap.${STAGE}.fasta
  out_prefix=${name}.tap.${STAGE}.itsx

  if [ -f ${out_file} ] || [ ${file} -ot ${out_file}  ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else # create a .list file with valid features  
      cmd="ITSx ${ITSx_PARMS} -i ${file} -o ${out_prefix}"
      echo ${cmd} >> ${STAGE}.log 
      ${cmd} >> ${STAGE}.log 2>&1

     # add barcode label to the fasta header
     cat ${out_prefix}.ITS2.fasta  |  sed " s/^>\(.*\)$/>\1barcodelabel=${name};/g" > ${out_file}

       if [[ ${STIDY} ]]
         then 
         rm -rf ${out_prefix}/*
       fi 
    fi
  done

###
# map cleaned reads against centroid sequences
###
STAGE="0500"
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} map cleaned reads against centroid sequences"
fi

rm -f ${STAGE}.log

for file in *.tap.0400.fasta
do
  name=$(basename ${file} .tap.0400.fasta) 
  out_file=${name}.tap.${STAGE}.fastq
  
  if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else 
       cmd="vsearch ${VSEARCH_GLOBAL}  \
          -strand plus \
          -id 0.97 \
          -maxaccepts 0 \
          -top_hits_only \
          -maxrejects 0
          -usearch_global ${name}.tap.0300.fasta \
          -db ${name}.tap.0400.fasta \
          -uc ${name}.tap.${STAGE}.uc \
          -matched ${out_file}"
      echo ${cmd} >> ${STAGE}.log
      ${cmd} >> ${STAGE}.log  2>&1
    fi
done

###
# convert .uc to .otu files
###
STAGE="0600"
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} format conversion "
fi

rm -f ${STAGE}.log
for file in *.tap.0500.uc
do
  name=$(basename ${file} .tap.0500.uc) 
  out_file=${name}.tap.${STAGE}.otu

  ###
  # add labels to header for uc file
  ###
  if [ -f ${out_file} ] || [ ${file} -ot ${out_file} ]
  then 
    if [[ $verbose ]]
    then
      echo "$0 skipping $out_file, already exists"
    fi
    else 
      cmd="uc2otu.pl  ${file}  "
      echo ${cmd} >> ${STAGE}.log
      ${cmd} > ${out_file}
    fi
done


exit

###
# classification using mothur 
###
STAGE="0700"
MOTHUR_PARAMS="cutoff=60"
if [[ ${verbose} ]]
then
 echo "$0 ${STAGE} classification using mothur "
fi

rm -f ${STAGE}.log
for file in Euka*.tap.0300.fasta
do
  name=$(basename ${file} .tap.0300.fasta) 

# UNITE TAX + FASTA
  mothur_cmd="#classify.seqs(fasta=${file}, \
     template=/usr/local/share/db/UNITEv6_sh_dynamic_s.fasta,  \
     taxonomy=/usr/local/share/db/UNITEv6_sh_dynamic_s.tax, \

     ${MOTHUR_PARAMS})"
  cmd="mothur ${mothur_cmd}"
  echo ${cmd} >> ${STAGE}.log
  ${cmd} >> ${STAGE}.log

  # what about ncbi taxonomy?
    #taxonomy=ITS2.itsx.ncbi.tax, \

# UNITE FASTA + NCBI TAX      
#  mothur_cmd="#classify.seqs(fasta=${file}, \
#    template=ITS2.itsx.unite.fasta, \
#    taxonomy=ITS2.itsx.ncbi.tax, \
#    ${MOTHUR_PARAMS})"
#  cmd="mothur ${mothur_cmd}"
#  echo ${cmd} >> ${name}.tap.${STAGE}.log
#  ${cmd} #>> ${name}.tap.${STAGE}.log
#done

for file in Prok*.tap.1100.uc
do
name=$(basename ${file} .tap.0900.fasta) 
mothur_cmd="#classify.seqs(fasta=${name}.tap.01?0.fastq, \
  template=/usr/local/share/db/SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta, \
  taxonomy=SSUv34.ipcr.silva.tax, \
  ${MOTHUR_PARAMS})"
cmd="mothur ${mothur_cmd}"

echo ${cmd} > ${name}.tap.${STAGE}.log
${cmd} >> ${name}.tap.${STAGE}.log
done



