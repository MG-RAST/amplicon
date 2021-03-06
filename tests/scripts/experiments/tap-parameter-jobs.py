#!/usr/bin/env python

import cStringIO
import json
import yaml
import logging
from operator import itemgetter
from optparse import OptionParser
import os
import re
import sys
import time
import urllib2






logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('Main')
logger.setLevel(logging.INFO)




NCBI_URL = "ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy"

TAXA_RANKS = ['superkingdom' , ]



def main(args):

  logger.info("Parsing command line")
  global NCBI_URL
  OptionParser.format_description = lambda self, formatter: self.description
  OptionParser.format_epilog = lambda self, formatter: self.epilog
  parser = OptionParser(usage='', description='', epilog='Done\n')

  parser.add_option( "--settings", dest="help", action="store_true" , default=False , help="")
  parser.add_option( "--outdir",   dest="outdir" , default="./", help="")
  parser.add_option( "--cwldir",  dest="cwldir" ,default="./", help="absolute path to directory containing CWL dir")
  parser.add_option( "--datadir",  dest="datadir" ,default="./", help="absolute path to data dir")
  logger.info("Parsing options")
  (opts, args) = parser.parse_args()
  

  # Add checks for data dir and db dir
  # missing


  reference_database = {
    'class': 'File' ,
    'path': opts.datadir + '/DBs/silva_v128NR.341F816R.fasta' ,
    'format': 'fasta'
    }

  reference_taxonomy = {
    'class': 'File' ,
    'path':  opts.datadir + '/DBs/silva_v128NR.341F816R.tax'
    }
  
  indexDir  = {
    'class': 'Directory',
    'path':  opts.datadir + '/DBs/PhiX'
    }
  
  primer = {
    'forward': 'CCTAYGGGDBGCWSCAG' ,
    'reverse': 'ATTAGADACCCBNGTAGTCC'
    }
  
  mate_pair = {
    'forward': {
      'class': 'File',
      'path':  opts.datadir + '/Prok.forest1.R1.fastq.gz',
      'format': 'fastq.gz'
      },
    'reverse': {
      'class': 'File',
      'path':  opts.datadir + '/Prok.forest1.R2.fastq.gz',
      'format': 'fastq.gz'
      }
    }

  classification = {
    'cutoff' : 60 ,
  }

  params = {
    'merging' : {} ,
    'primer_trimming' : {
       'error': 0.06
    } ,
    'filter_reads' : {
      'max_expected_error': 1
    } ,
    'dereplication': {} ,
    'clustering' : {} ,
    'classify' : {} ,
    'read_mapping' : {
      'percent_identity': 0.97
    } ,
  }
  


  # reference_database:
 #    class: File
 #    path: ../Data/Inputs/DBs/silva_v128NR.341F816R.fasta
 #    format: fasta
 #
 #  reference_taxonomy:
 #    class: File
 #    path: ../Data/Inputs/DBs/silva_v128NR.341F816R.tax
 #
 #  indexDir:
 #    class: Directory
 #    path:  ../Data/Inputs/DBs/PhiX
 #
 #  primer:
 #    forward: CCTAYGGGDBGCWSCAG
 #    reverse: ATTAGADACCCBNGTAGTCC
 #
 #  mate_pair:
 #    forward:
 #      class: File
 #      path: ../Data/Inputs/Prok.forest1.R1.fastq.gz
 #      format: fastq.gz
 #    reverse:
 #      class: File
 #      path: ../Data/Inputs/Prok.forest1.R2.fastq.gz
 #      format: fastq.gz
  
  
  cluster_id = [0.90 , 0.95 , 0.97 , 0.99]
  classification_cutoff = [ 60 , 65 , 70 , 75 , 80 , 85 , 90]
   
  for percent_identity in cluster_id:
    for cutoff in classification_cutoff:
      
      fo_json = open(opts.outdir + "/cluster-" + str(percent_identity) + ".classification-" + str(cutoff) + ".job.json" , "w")
      # fo_yaml = open(opts.outdir + "/cluster-" + str(percent_identity) + ".classification-" + str(cutoff) + ".job.yaml" , "w")
      
      params['clustering']['percent_identity'] = percent_identity
      params['classify']['cutoff'] = cutoff
  
      job = { 
        'reference_database' : reference_database ,
        'reference_taxonomy' : reference_taxonomy ,
        'indexDir' : indexDir ,
        'primer' : primer ,
        'mate_pair' : mate_pair,
        'pipeline_options': params
        }
  
      fo_json.write( json.dumps(job) )
      fo_json.close
    
      # fo_yaml.write( yaml.dump(job) )
#       fo_yaml.close
  
if __name__ == "__main__":
  logger.info("Starting program")
  sys.exit( main(sys.argv) )
  