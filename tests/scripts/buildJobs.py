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
  parser.add_option( "--cwldir",  dest="cwldir" ,default="./", help="absolute path to CWL dir")
  parser.add_option( "--datadir",  dest="datadir" ,default="./Data/Inputs/", help="absolute path to data dir")
  parser.add_option( "--yaml", dest="yaml", action="store_true" , default=False , help="Create yaml job file")
  logger.info("Parsing options")
  (opts, args) = parser.parse_args()
  




  reference_database = {
    'class': 'File' ,
    'path': opts.cwldir + '/CWL/Data/Inputs/DBs/silva_v128NR.341F816R.fasta' ,
    'format': 'fasta'
    }

  reference_taxonomy = {
    'class': 'File' ,
    'path':  opts.cwldir + '/CWL/Data/Inputs/DBs/silva_v128NR.341F816R.tax'
    }
  
  indexDir  = {
    'class': 'Directory',
    'path':  opts.cwldir + '/CWL/Data/Inputs/DBs/PhiX'
    }
  
  primer = {
    'forward': 'CCTAYGGGDBGCWSCAG' ,
    'reverse': 'ATTAGADACCCBNGTAGTCC'
    }
  
  mate_pairs = [
                {
                'forward': {
                  'class': 'File',
                  'path':  opts.cwldir + '/CWL/Data/Inputs/Prok.forest1.R1.fastq.gz',
                  'format': 'fastq.gz'
                  },
                'reverse': {
                  'class': 'File',
                  'path':  opts.cwldir + '/CWL/Data/Inputs/Prok.forest1.R2.fastq.gz',
                  'format': 'fastq.gz'
                  }
                }
              ]

  classification = {
    'cutoff' : 60 ,
  }

  params = {
    'merging' : {} ,
    'dereplication': {} ,
    'clustering' : {} ,
    'classify' : {} 
  }
  

# ####
# reference_database:
#   class: File
#   path: ../Data/Inputs/DBs/silva_v128NR.341F816R.fasta
#   format: fasta
#
# reference_taxonomy:
#   class: File
#   path: ../Data/Inputs/DBs/silva_v128NR.341F816R.tax
#
# indexDir:
#   class: Directory
#   path:  ../Data/Inputs/DBs/PhiX
#
# primer:
#   forward: CCTAYGGGDBGCWSCAG
#   reverse: ATTAGADACCCBNGTAGTCC
#
# mate_pairs:
#   - forward:
#       class: File
#       path: /amplicon/CWL/Data/Inputs/Prok.forest1.R1.fastq.gz
#       format: fastq.gz
#     reverse:
#       class: File
#       path: /amplicon/CWL/Data/Inputs/Prok.forest1.R2.fastq.gz
#       format: fastq.gz
#   - forward:
#       class: File
#       path: /amplicon/CWL/Data/Inputs/Prok.forest2.R1.fastq.gz
#       format: fastq.gz
#     reverse:
#       class: File
#       path: /amplicon/CWL/Data/Inputs/Prok.forest2.R2.fastq.gz
#       format: fastq.gz
#
#

      

   

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
      fo_yaml = open(opts.outdir + "/cluster-" + str(percent_identity) + ".classification-" + str(cutoff) + ".job.yaml" , "w")
      
      params['clustering']['percent_identity'] = str(percent_identity)
      params['classify']['cutoff'] = str(cutoff)
  
      params['merging']['fastq_maxdiffs']     = 30
      params['merging']['fastq_minovlen']     = 30
      params['merging']['fastq_minmergelen']  = 300
      params['primer_trimming']['error']      = 0.06
      params['filter_reads']['max_expected_error'] = 1
      params['read_mapping']['percent_identity'] = 0.97 
      params['dereplication'] = {}
  
  
  
      job = { 
        'reference_database' : reference_database ,
        'reference_taxonomy' : reference_taxonomy ,
        'indexDir' : indexDir ,
        'primer' : primer ,
        'mate_pairs' : mate_pairs,
        'pipeline_options': params
        }
  
      fo_json.write( json.dumps(job) )
      fo_json.close

      if opts.yaml :
        fo_yaml.write( yaml.dump(job) )
        fo_yaml.close
  
if __name__ == "__main__":
  logger.info("Starting program")
  sys.exit( main(sys.argv) )
  