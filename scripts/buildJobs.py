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




reference_database = {
  'class': 'File' ,
  'path': '/amplicon/CWL/Data/Inputs/DBs/silva_v128NR.341F816R.fasta' ,
  'format': 'fasta'
  }

reference_taxonomy = {
  'class': 'File' ,
  'path': '/amplicon/CWL/Data/Inputs/DBs/silva_v128NR.341F816R.tax'
  }
  
indexDir  = {
  'class': 'Directory',
  'path':  '/amplicon/CWL/Data/Inputs/DBs/PhiX'
  }
  
primer = {
  'forward': 'CCTAYGGGDBGCWSCAG' ,
  'reverse': 'ATTAGADACCCBNGTAGTCC'
  }
  
mate_pair = {
  'forward': {
    'class': 'File',
    'path': '/amplicon/CWL/Data/Inputs/Prok.forest1.R1.fastq.gz',
    'format': 'fastq.gz'
    },
  'reverse': {
    'class': 'File',
    'path': '/amplicon/CWL/Data/Inputs/Prok.forest1.R2.fastq.gz',
    'format': 'fastq.gz'
    }
  }


params = {
  'merging' : {} ,
  'dereplication': {} ,
  'clustering' : {} ,
}


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
  logger.info("Parsing options")
  (opts, args) = parser.parse_args()
  

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
   
  for percent_identity in cluster_id:
  
    fo_json = open(opts.outdir + "/cluster-" + str(percent_identity) + ".job.json" , "w")
    fo_yaml = open(opts.outdir + "/cluster-" + str(percent_identity) + ".job.yaml" , "w")
    params['clustering']['percent_identity'] = str(percent_identity)
  
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
    
    fo_yaml.write( yaml.dump(job) )
    fo_yaml.close
  
if __name__ == "__main__":
  logger.info("Starting program")
  sys.exit( main(sys.argv) )
  