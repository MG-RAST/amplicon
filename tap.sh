#!/bin/bash

###
# OPTIONS are declared here
###
declare VSEARCH_GLOBAL="--threads 4"

shopt -s globstar
shopt -s extglob

function usage {
  echo "Usage: $0 [-i] [-h help] <FILES>"
  echo "$0 <FILES> assume *.R1.fastq.gz and *.R2.fastq.gz files"
  echo "$0 [-i] switch to ION torrent mode"
  echo "$0 [-t] tidy up, leave only minimal files behind"
}

# get options
while getopts thvi option; do
    case "${option}"
        in
		h) usage; exit;;
    v) verbose=1;;
    t) TIDY=1;;
    i) ION_TORRENT=1;;
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

if [[ ${verbose} ]]
then
  echo "$0 creating input copy of files as *.tap.100.fastq.gz"
  echo "$0 we can only handle compressed fastq as fastq.gz with R1 and R2 in the names e.g.  foo_bar1.R1.fastq.gz"
  echo "$0 foo is e.g. Euka and bar is e.g. forest3 ; assumption is that numerical suffix in bar allows grouping"
  echo "$0 filename: [Euka|Prok].<string><int>.R<int>.fastq.gz"
fi

### 
#   create input files
###
STAGE=0010
for i in $(ls -1 ${FILES}  )
do
  if [[ "${i}" != *tap* ]]
  then
    name=$(basename $i .fastq.gz)
    cp $i ${name}.tap.${STAGE}.fastq.gz
  else
    if [[ "${verbose2}" ]]
    then  
      echo "skipping $i"
    fi 
  fi    
done

###
###
#  add filename as "barcode" to fastq header
###
###
STAGE=0100
if [[ ${verbose} ]]
then
  echo "$0 10->100 removing any existing *.tap.200 files; creating labels inside the fastq files from filenames; saving as *.tap.200.fastq"
fi
# remove any leftovers from the last run
rm -f *.tap.${STAGE}*
# create fastq files with modified header to include barcode labels e.g. "barcodelabel=Euka.forest1;"
for file_name in *.R1.tap.0010.fastq.gz
 do
   name=$(basename "${file_name}" .R1.tap.0010.fastq.gz )
   new_file=$(echo ${name} | awk -F\. '{ print $1}')
   zcat ${file_name} |  awk -v "pat=$name" -F ' ' ' {print (NR%4 == 1) ? $1 ";barcodelabel=" pat  : $0} ' >> "${new_file}".R1.tap.${STAGE}.fastq  
 done


for file_name in *.R2.tap.0010.fastq.gz
 do
   name=$(basename "${file_name}" .R2.tap.0010.fastq.gz )
      new_file=$(echo ${name} | awk -F\. '{ print $1}')
   zcat ${file_name} |  awk -v "pat=$name" -F ' ' ' {print (NR%4 == 1) ? $1 ";barcodelabel=" pat  : $0} ' >> "${new_file}".R2.tap.${STAGE}.fastq
 done

###
# Mate pair merging with PEAR
###
STAGE=0200 
if [[ ${verbose} ]]
then
 echo "$0 100->200 merging mate pairs with PEAR into *.merged.tap.0200.fastq"
fi

declare PEAR_PARAMS="--min-overlap 50 --min-assembly-length 300 "
for file in *R1.tap.0100.fastq
do
  name=$(basename ${file} .R1.tap.0100.fastq)
  cmd="pear ${PEAR_PARAMS} -f  "${name}".R1.tap.0100.fastq  -r "${name}".R2.tap.0100.fastq -o "${name}".merged.tap.${STAGE}.fastq"
  echo ${cmd} >${name}.tap.${STAGE}.log
#  $cmd  >> ${name}.tap.${STAGE}.log
  mv "${name}".merged.tap.${STAGE}.fastq.assembled.fastq "${name}".tap.${STAGE}.fastq
  
  if [[ ${TIDY} ]]
  then
    rm -f ${name}.merged.tap.${STAGE}.fastq.discarded.fastq
    rm -f ${name}.merged.tap.${STAGE}.fastq.unassembled.forward.fastq 
    rm -f ${name}.merged.tap.${STAGE}.fastq.unassembled.reverse.fastq 
  fi
  
done


# PEAR replaces usearch
# declare USEARCH_PARAMS="-fastq_minovlen 50 -fastq_minmergelen 300 -fastq_allowmergestagger"
# mate pair merging, we can use the 32 bit version of the usearch, if we split the files correctly into 1GB chunks
#usearch -fastq_mergepairs 1_P.R1.fastq -reverse 1_P.R2.fastq ${USEARCH_PARAMS} -fastqout 2_P.umerge.fastq -log 2_P.umerge.log
#usearch -fastq_mergepairs 1_E.R1.fastq -reverse 1_E.R2.fastq ${USEARCH_PARAMS} -fastqout 2_E.umerge.fastq -log 2_E.umerge.log

###
# Error correction with Spades and vsearch
###
STAGE=0300
if [[ ${verbose} ]]
then
 echo "$0 200->300 error correcting with Spades into *.300.fastq"
fi
# spades for error correction (spades download http://spades.bioinf.spbau.ru/release3.6.0/SPAdes-3.6.0.tar.gz or http://bioinf.spbau.ru/en/content/spades-download-0)
# used to be
#usearch -fastq_filter 3_P.umerge.bayeshammer/corrected/2_P.umerge.00.0_0.cor.fastq -fastqout 3_P.umerge.bayeshammer.fastq

if [[ ${ION_TORRENT} ]]
then
  declare SPADES_PARAM="--threads 4 --only-error-correction --disable-gzip-output --iontorrent"
else 
  declare SPADES_PARAM="--threads 4 --only-error-correction --disable-gzip-output "
fi

for file in *.tap.0200.fastq
do
  name=$(basename ${file} .tap.0200.fastq) 
  cmd="spades.py ${SPADES_PARAM} -s ${file} -o ${name}.tap.${STAGE}.dir "
  echo ${cmd} > ${name}.tap.${STAGE}.log
#  ${cmd} >> ${name}.tap.${STAGE}.log
 
  cmd="vsearch ${VSEARCH_GLOBAL} \
    -fastq_filter ${name}.tap.${STAGE}.dir/corrected/*.fastq \
    -fastqout ${name}.tap.${STAGE}.fastq" 
  echo ${cmd} >> ${name}.tap.${STAGE}.log
 # $cmd >> ${name}.tap.${STAGE}.log  2>&1
  
  if [[ ${TIDY} ]]
  then
    rm -rf ${name}.tap.${STAGE}.dir
  fi
done

###
# Adapter removal using cutadpt
###
STAGE=0400
if [[ ${verbose} ]]
then
 echo "$0 300->400 removing adapters using cutadpt, creating *.400.fastq [currently disabled]"
fi

# adapter removal (source code @ https://cutadapt.readthedocs.org/en/stable/)
declare CUTADAPT_PARAM="-e 0.06 -f fastq --trimmed-only"

declare ADAPTER1="-g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$ "
declare ADAPTER2="-g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$"


for file in *.tap.0300.fastq
do
  name=$(basename ${file} .tap.0300.fastq) 

  # run both or run one ## how do we decide?
#  cutadapt ${ADAPTER1} ${CUTADAPT_PARAM} ${file}  -o ${name}.tap.${STAGE}.fastq > ${name}.tap.${STAGE}.log
#  cutadapt ${ADAPTER2} ${CUTADAPT_PARAM} ${file}  -o ${name}.tap.${STAGE}.fastq > ${name}.tap.${STAGE}.log
#cutadapt ${ADAPTER2} ${CUTADAPT_PARAM}  3_E.umerge.bayeshammer.fastq -o 4_E.umerge.bayeshammer.cutprim.fastq
  echo "$0 FM:: we need to iterate over all adapters --> check with Martin <--"
done


###
# denoising again with vsearch
###
STAGE=0500
if [[ ${verbose} ]]
then
 echo "$0 300->500 de-noising with vsearch, creating *.600.fastq"
fi
# filter low quality reads?
declare VSEARCH_FILTER_OPTS="${VSEARCH_GLOBAL} -fastq_maxee 1"
for file in *.tap.0300.fastq
do
 name=$(basename ${file} .tap.0300.fastq) 

 cmd="vsearch ${VSEARCH_FILTER_OPTS} \
   -fastq_filter ${file} \
   -fastqout ${name}.tap.${STAGE}.fastq"
 echo ${cmd} > ${name}.tap.${STAGE}.log
# $cmd >> ${name}.tap.${STAGE}.log  2>&1
done

#usearch -fastq_filter 4_P.umerge.bayeshammer.cutprim.fastq -fastqout 5_P.umerge.bayeshammer.cutprim.maxee1.fastq -fastq_maxee 1
#usearch -fastq_filter 4_E.umerge.bayeshammer.cutprim.fastq -fastqout 5_E.umerge.bayeshammer.cutprim.maxee1.fastq -fastq_maxee 1


set -e


###
# dereplicating exactly identical reads
###
STAGE=0600
if [[ ${verbose} ]]
then
 echo "$0 500->600 de-replicating with vsearch, creating *.700.fastq [might need to be optional step]"
fi
declare VSEARCH_DEREP_OPTIONS="${VSEARCH_GLOBAL} -sizeout -minuniquesize 2"

for file in *.tap.0500.fastq
do
  name=$(basename ${file} .tap.0500.fastq) 
 # dereplication of full length identical reads? 
  echo "$0 vsearch --derep :: MARTIN --> SHOULD we use --strand both?"
  cmd="vsearch ${VSEARCH_DEREP_OPTIONS} \
       -derep_fulllength ${file} \
       -output ${name}.tap.${STAGE}.fasta "
  echo $cmd > ${name}.tap.${STAGE}.log 
#  ${cmd} >> ${name}.tap.${STAGE}.log  2>&1

done

###
# OTUclustering
###
STAGE=0700
if [[ ${verbose} ]]
then
 echo "$0 600->700 OTUclustering via vsearch"
fi

declare VSEARCH_OTU_CLUST_PARAMS="${VSEARCH_GLOBAL} -sizein -sizeout --id 0.97  " # removed " -otu_radius_pct 3 "
for file in *.tap.0600.fasta
do
  name=$(basename ${file} .tap.0600.fasta) 
  prefix=$(echo $name | cut -d. -f1 )

  cmd="vsearch ${VSEARCH_OTU_CLUST_PARAMS} \
        -cluster_size ${file} \
        -relabel "OTU${prefix:0:1}_" \
        -centroids ${name}.tap.${STAGE}.fasta \
        --biomout ${name}.tap.${STAGE}.biom "
  echo $cmd > ${name}.tap.${STAGE}.log
  $cmd >> ${name}.tap.${STAGE}.log  2>&1
done

# OTU clustering
# was: usearch -cluster_otus 6_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.fasta -otu_radius_pct 3 -otus 7_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.fasta -uparseout 7_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.up -relabel OTUp_ -sizein -sizeout


###
# Chimera removal 
###
STAGE="0800"
if [[ ${verbose} ]]
then
 echo "$0 700->800 Chimera removal "
fi

declare VSEARCH_SIM_PARAMS="${VSEARCH_GLOBAL}  -strand plus  "
for file in "Pro*.tap.0700.fasta" # Prok.tap.0700.fasta
do
  name=$(basename ${file} .tap.0700.fasta) 
 
  cmd="vsearch ${VSEARCH_SIM_PARAMS} \
       -db uchime_reference.greengenes.fasta \
       -uchime_ref ${name}.tap.0700.fasta   \
       -nonchimeras ${name}.tap.${STAGE}.fasta"
  echo ${cmd} > ${name}.tap.${STAGE}.log
 # $cmd >> ${name}.tap.${STAGE}.log  2>&1
done

for file in "Euk*.tap.0700.fasta"
do
  name=$(basename ${file} .tap.0700.fasta) 
  
  cmd="vsearch ${VSEARCH_SIM_PARAMS} \
       -db uchime_reference.unite.fasta \
       -uchime_ref ${name}.tap.0700.fasta   \
       -nonchimeras ${name}.tap.${STAGE}.fasta"
  echo ${cmd} > ${name}.tap.${STAGE}.log
  #$cmd >> ${name}.tap.${STAGE}.log  2>&1
done

echo "missing:: uchime_reference.greengenes.fasta AND uchime_reference.unite.fasta"
  
# SIM Search open source uchime tool to replace commercial usearch: http://drive5.com/uchime/uchime4.2.40_src.tar.gz
#usearch -uchime_ref 7_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.fasta -db uchime_reference.greengenes.fasta -nonchimeras 8_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.fasta -strand plus
#usearch -uchime_ref 7_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.fasta -db uchime_reference.unite.fasta -nonchimeras 8_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.fasta -strand plus

###
# Prok Taxa determination from SIMs via Metaxa
###
STAGE="0900"
set -xv 
if [[ ${verbose} ]]
then
 echo "$0 800->900 Prok Taxa calling using Metaxa"
fi
# ?? open source metaxa2 http://microbiology.se/sw/Metaxa2_2.0.2.tar.gz
declare METAXA_PARMS="-t a,b --complement F --cpu 4"

echo "Using stage 0700 instead of 0800 as we are missing reference DBs for stage 0800 for now"


for file in Prok*.tap.0700.fasta
do
  name=$(basename "${file}" .tap.0700.fasta) 

  cmd="metaxa2_x ${METAXA_PARMS} -i ${file}  -o ${name}.tap.${STAGE}.metaxa "
  echo $cmd > ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log 2>&1
  
  # remove the comments added by metaxa
  cut -d"|" -f1 ${name}.tap.${STAGE}.metaxa.extraction.fasta  > ${name}.tap.${STAGE}.fasta
  
  if [[ ${TIDY} ]]
    then
      rm -rf ${name}.tap.${STAGE}.metaxa.*
    fi
done 
#was :: metaxa2_x -i 8_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.fasta -o 9_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa -t a,b --complement F --cpu 4


###
# ITS using ITSx
###
if [[ ${verbose} ]]
then
 echo "$0 800->0900 Euk Taxa calling using ITSx"
fi
declare ITSx_PARMS="--complement F --cpu 4 --preserve T --only_full "

for file in Euk*.tap.0800.fasta
do
 
  name=$(basename ${file} .tap.0800.fasta) 
  cmd="/root/ITSx/ITSx ${ITSx_PARMS} -i ${file} -o ${name}.tap.${STAGE}.itsx"
  echo ${cmd} > ${name}.tap.${STAGE}.log 
  ${cmd} >> ${name}.tap.${STAGE}.log2>&1
  
  cmd2="awk '/^>/{sub(">","",$1);print $1}' ${name}.tap.${STAGE}.itsx.ITS2.fasta > ${name}.tap.${STAGE}.list "
  mv ${name}.tap.${STAGE}.itsx.ITS2.fasta > ${name}.tap.${STAGE}.fasta

  if [[ ${TIDY} ]]
    then
      rm -rf ${name}.tap.${STAGE}.itsx.*
    fi
done

#awk '/^>/{sub(">","",$1);print $1}' 9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.ITS2.fasta > 9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.ITS2.list

exit

###
# 16s DB search 
###
STAGE="1000"
if [[ ${verbose} ]]
then
 echo "$0 900->1000 16s DB search"
fi
declare VSEARCH_DB_SEARCH_PARAMS="${VSEARCH_GLOBAL} -strand plus -id 0.97 -maxaccepts0 -top_hit_only -maxrejects 0 "
for file in Prok*.tap.0900.fasta
do
  name=$(basename ${file} .tap.0900.fasta) 
  cmd="vsearch ${VSEARCH_DB_SEARCH_PARAMS} \
      -usearch_global ${name}.tap.0500.fastq \
      -db ${name}.tap.0900.fasta \
      -uc ${name}.tap.${STAGE}.uc \
      -matched ${name}.tap.${STAGE}.mappedseqs.fasta"
  echo ${cmd} > ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log  2>&1

done
# Search for one (default) or a few high-identity hits to a database ==> the next calls can be replaced with vsearch (@ https://github.com/torognes/vsearch)
#usearch -usearch_global 5_P.umerge.bayeshammer.cutprim.maxee1.fastq -db 9_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.fasta -strand plus -id 0.97 -maxaccepts0 -top_hit_only -maxrejects 0 -uc 10_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.mappedseqs.uc -matched 10_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.mappedseqs.fasta


###
# search for hits  ITS DB
###
if [[ ${verbose} ]]
then
 echo "$0 950->1050 Euk ITS extraction using vsearch"
fi
for file in Euka*.tap.0950.fasta
do
  name=$(basename ${file} .tap.0950.fasta) 
  
  cmd="vsearch ${VSEARCH_GLOBAL} -fastx_getseqs ${name}.tap.0800.fasta \
        -labels ${name}.tap.0900.list \
        -fastaout ${name}.tap.${STAGE}.fasta "
  echo ${cmd} > ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log  2>&1

done

#Extract sequences from a FASTA or FASTQ file.
#usearch -fastx_getseqs 8_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.fasta -labels 9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.ITS2.list -fastaout 9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.clean.fasta


###
# ITS DB search 
###
STAGE="1100"
if [[ ${verbose} ]]
then
 echo "$0 10?0->1100 format conversion "
fi
declare VSEARCH_DB_SEARCH_PARAMS="${VSEARCH_GLOBAL} -strand plus -id 0.97 -maxaccepts0 -top_hit_only -maxrejects 0 "
for file in *.tap.0950.fasta
do
  name=$(basename ${file} .tap.0950.fasta) 
  cmd="vsearch ${VSEARCH_DB_SEARCH_PARAMS} \
      -usearch_global ${name}.tap.0500.fastq \
      -db ${name}.tap.0900.fasta \
      -uc ${name}.tap.${STAGE}.uc \
      -matched ${name}.tap.${STAGE}.mappedseqs.fasta"
   
  echo ${cmd} > ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log  2>&1
done

#usearch -usearch_global 5_E.umerge.bayeshammer.cutprim.maxee1.fastq -db 9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.clean.fasta -strand plus -id 0.97 -maxaccepts 0 -top_hit_only -maxrejects 0 -uc 10_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.clean.mappedseqs.uc -matched 10_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.clean.mappedseqs.fasta

###
# format conversion
###
STAGE="1200"
if [[ ${verbose} ]]
then
 echo "$0 1100->1200 format conversion "
fi

# format conversion from http://drive5.com/python/python_scripts.tar.gz
for file in *.tap.11?0.uc
do
  name=$(basename ${file} .tap.11?0.fasta) 
  cmd="uc2otutab.py  ${file} > ${name}.tap.${STAGE}.otus "
  echo ${cmd} > ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log
done

# METAXA
#uc2otutab.py 10_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.mappedseqs.uc > 10_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.mappedseqs.otu
# ITSx
# /local/bin/uc2otutab.py 10_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.clean.mappedseqs.uc > 10_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.clean.mappedseqs.otu


#cp 9_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.fasta ../3_taxonomy && cp 9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.ITS2.fasta ../3_taxonomy && cd ../3_taxonomy


echo "$0 FM: Where do the DB files and templates come from"
echo "$0 missing ITS2.itsx.unite.fasta, IITS2.itsx.unite.tax, ITS2.itsx.ncbi.fasta, ITS2.itsx.ncbi.tax, SSUv34.ipcr.silva.fasta, SSUv34.ipcr.silva.tax"

# from Mothur download pages

# SILVA
# https://www.mothur.org/w/images/b/b4/Silva.nr_v128.tgz
# template for chimera slayer
# https://www.mothur.org/w/images/f/f1/Silva.gold.bacteria.zip


# ITS
# https://www.mothur.org/w/images/2/27/Unite_ITS_s_02.zip
# 
# https://www.mothur.org/w/images/4/49/Unite_ITS_02.zip



exit
###
# classification using mothur 
###
STAGE="1300"
MOTHUR_PARAMS="cutoff=60"
if [[ ${verbose} ]]
then
 echo "$0 12?0->1300 classification using mothur "
fi
for file in Euka*.tap.11?0.uc
do
  name=$(basename ${file} .tap.0950.fasta) 

  mothur_cmd="#classify.seqs(fasta=${name}.tap.01?0.fastq, \
    template=ITS2.itsx.ncbi.fasta, \
    taxonomy=ITS2.itsx.ncbi.tax, \
    ${MOTHUR_PARAMS})"
  cmd="mothur ${mothur_cmd}"
  echo ${cmd} > ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log

  mothur_cmd="#classify.seqs(fasta=${name}.tap.01?0.fastq, \
    template=ITS2.itsx.unite.fasta, \
    taxonomy=IITS2.itsx.unite.tax, \
    ${MOTHUR_PARAMS})"
  cmd="mothur ${mothur_cmd}"
  echo ${cmd} >> ${name}.tap.${STAGE}.log
  ${cmd} >> ${name}.tap.${STAGE}.log
done

for file in Prok*.tap.11?0.uc
do
name=$(basename ${file} .tap.0950.fasta) 
mothur_cmd="#classify.seqs(fasta=${name}.tap.01?0.fastq, \
  template=SSUv34.ipcr.silva.fasta, \
  taxonomy=SSUv34.ipcr.silva.tax, \
  ${MOTHUR_PARAMS})"
cmd="mothur ${mothur_cmd}"

echo ${cmd} > ${name}.tap.${STAGE}.log
${cmd} >> ${name}.tap.${STAGE}.log
done

# classification of OTUs (mothur download @ http://www.mothur.org/wiki/Download_mothur)
#mothur "#classify.seqs(fasta=9_P.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.metaxa.extraction.clean.fasta, template=SSUv34.ipcr.silva.fasta, taxonomy=SSUv34.ipcr.silva.tax, cutoff=60)”
#mothur 
#"#classify.seqs(fasta=9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.ITS2.fasta, template=ITS2.itsx.ncbi.fasta, taxonomy=ITS2.itsx.ncbi.tax, cutoff=60)”
#mothur "#classify.seqs(fasta=9_E.umerge.bayeshammer.cutprim.maxee1.derep.min2.otu97.uchimeref.ITSx.ITS2.fasta, template=ITS2.itsx.unite.fasta, taxonomy=ITS2.itsx.unite.tax, cutoff=60)"

