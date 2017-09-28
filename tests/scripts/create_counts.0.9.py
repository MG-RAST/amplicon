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
import fnmatch
from pprint import pprint
from Bio import SeqIO







logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('Main')
logger.setLevel(logging.INFO)


logger.info("Parsing command line")
global NCBI_URL
OptionParser.format_description = lambda self, formatter: self.description
OptionParser.format_epilog = lambda self, formatter: self.epilog
parser = OptionParser(usage='', description='', epilog='Done\n')

parser.add_option( "--settings", dest="help", action="store_true" , default=False , help="")
parser.add_option( "--outdir",   dest="outdir" , default="./", help="")
parser.add_option( "--basedir",  dest="basedir" ,default="./", help="absolute path to CWL dir")
logger.info("Parsing options")
(opts, args) = parser.parse_args()

stage = { 
  'output' : "raw" ,
  'id' : '' ,
  'label' : 'reads'
}

stages = [ 
  { 
    'output' : "raw" ,
    'id' : '' ,
    'label' : 'reads'
  },
  { 
    'output' : "merged" ,
    'id' : '' ,
    'label' : 'mate pair merging'
  },
  { 
    'output' : "noPHIX" ,
    'id' : '' ,
    'label' : 'remove PHIX'
  },
  { 
    'output' : "noPrimer" ,
    'id' : '' ,
    'label' : 'remove primer'
  },
  { 
    'output' : "dereplicated" ,
    'id' : '' ,
    'label' : 'dereplicate'
  },
  { 
    'output' : "clustered" ,
    'id' : '' ,
    'label' : 'cluster'
  },
  { 
    'output' : "features" ,
    'id' : '' ,
    'label' : 'features'
  },
  { 
    'output' : "relabeled" ,
    'id' : '' ,
    'label' : 'labeled'
  },
  { 
    'output' : "mappedReads" ,
    'id' : '' ,
    'label' : 'mapped reads to cluster representative'
  },
  { 
    'output' : "OTUs" ,
    'id' : '' ,
    'label' : 'OTUs'
  },
  { 
    'output' : "Classified" ,
    'id' : '' ,
    'label' : 'classified cluster'
  }
]
  
counts = {}
  
  
def count_otus(otu_file):
  logger.info("Counting  otu summary: " + otu_file)
  
  genera = {} ;
  
  nr_genera = 0
  nr_otus   = 0
  
  OTU = open(otu_file , 'r') 
  
  
  regexp_match  = re.compile(r"(^[^\s]+);size=(\d+);\t+(.+)")
  
  for line in OTU :
      
    m = regexp_match.match(line)
    if m :
      nr_otus += 1
  
  logger.info("Found " + str(nr_otus) + " OTUs")

  return nr_otus 
  
  
  
  
def count_mothur_taxonomy(taxonomy_file):
  logger.info("Counting mothy summary: " + taxonomy_file)
  
  genera = {} ;
  
  nr_genera = 0
  nr_otus   = 0
  
  TAX = open(taxonomy_file , 'r') 
  
  regex_replace = re.compile(r"\(\d+\)")
  regexp_match  = re.compile(r"(^[^\s]+);size=(\d+);\t+(.+)")
  
  for line in TAX :
    
    
    m = regexp_match.match(line)
    if m :
      # found entry
      nr_otus += 1
      # unify taxa strings
      replaced =  re.sub(  "\(\d+\)" , '', m.group(3) )
 
      if replaced in genera :
        genera[replaced] += 1
      else :
        genera[replaced] = 1
    else:
      pass  
     
  nr_genera = len(genera.items())
  
  logger.info("Found " + str(nr_otus) + " annotated OTUs")
  logger.info("Found " + str(nr_genera) + " unique genera")
  return nr_otus , nr_genera 


def count_fasta(fasta):
  logger.info("Counting fasta: " + fasta)
  nr_seqs = 0
  
  for record in SeqIO.parse(fasta, "fasta") :
    # print record.id
    nr_seqs = nr_seqs + 1
  
  logger.info("Found " + str(nr_seqs) + " entries")
  return nr_seqs

  
def count_fastq(fastq):
  
  logger.info("Counting fastq: " + fastq)
  nr_seqs = 0
  
  try:
    for record in SeqIO.parse(fastq, "fastq") :
      # print record.id
      nr_seqs = nr_seqs + 1
  except Exception as inst:
    logger.warning("Error in " + fastq + " entries: " + str(nr_seqs)  )
    logger.warning( inst )
        
  
  logger.info("Found " + str(nr_seqs) + " entries")
  return nr_seqs
  
  
  # file = open(fastq, "r")
 #
 #  for line in file.readlines():
 #
 #     m = re.match( '(+_', line)
 #     if m :
 #       print m.groups(0)
 #       print line
 #

def find(pattern, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result


def export_counts(counts):
  
  stats = open( opts.outdir + "/summary.tsv" , 'w')  
  stats.write("\t")
   
  for stage in stages:
    stats.write(stage['label'] + "\t")
  
  stats.write("\n")
  
  for key in counts:
    stats.write(key + "\t")
    for step in counts[key] :
      for name in step:
        stats.write( str(step[name]) + "\t")
    stats.write("\n")
  
  stats.close()


def main(args):
  receipts = find('receipt.json', opts.basedir )
  

  for path in receipts:
    print os.path.dirname(path)
    dir_name  = os.path.basename( os.path.dirname(path) )
    counts[dir_name] = []
    
    print dir_name

    if  os.path.getsize(path) == 0:
      logger.warning( "File is empty: " + path  )
      continue
      
    with open(path) as data_file:    
        data = json.load(data_file)
    #pprint(data)

    # initialize
    for stage in stages:
      counts[dir_name].append({ stage['label'] : 0})
      
    # for stage in stages:
    for index in range(len(stages)):  
  
      stage = stages[index]
      out_name = stage['output']
      # print out_name , data[ out_name ]
      logger.info("Stage:" + out_name )
      
      if stage['output'] == "raw" and data[out_name]  is not None:
        nr_entries = count_fastq(data[ out_name ]['forward']['path']) + count_fastq(data[ out_name ]['reverse']['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}
      
      if out_name == "merged" and data[out_name]  is not None:
        nr_entries = count_fastq(data[ out_name ][2]['path']) 
        counts[dir_name][index]={ stage['label'] : nr_entries}
        
      if out_name ==  "noPHIX" and data[out_name] is not None:
        nr_entries = count_fastq(data[ out_name ]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}
        
      if out_name ==  "noPrimer" and data[out_name] is not None:
        nr_entries = count_fastq(data[ out_name ][2]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries} 
        # Count old version too (forward and reverse in one call)
        nr_entries = count_fastq(data[ out_name ][0]['path'])
        counts[dir_name].append( { stage['label'] : nr_entries}  )
      
      if out_name ==  "dereplicated" and data[out_name] is not None:
        nr_entries = count_fasta(data[ out_name ]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}  


      if out_name ==  "clustered" and data[out_name] is not None:
        nr_entries = count_fasta(data[ out_name ]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}


      if out_name ==  "features" and data[out_name] is not None:
        nr_entries = count_fasta(data[ out_name ][0]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}
        
      if out_name ==  "relabeled" and data[out_name] is not None:
        nr_entries = count_fasta(data[ out_name ][0]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}  
        
      if out_name ==  "mappedReads" and data[out_name] is not None:
        nr_entries = count_fasta(data[ out_name ][1]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}  

      if out_name ==  "OTUs" and data[out_name] is not None:
        nr_entries = count_otus(data[ out_name ]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}
 
 
      if out_name ==  "Classified" and data[out_name] is not None:
        (nr_entries , nr_genera)  = count_mothur_taxonomy(data[ out_name ][4]['path'])
        counts[dir_name][index]={ stage['label'] : nr_entries}
        counts[dir_name][index]={ "unique genera" : nr_genera}
 
 


  pprint(counts)
  
  export_counts(counts)
 
 
  
if __name__ == "__main__":
  logger.info("Starting program")
  sys.exit( main(sys.argv) )
  