#!/usr/bin/env python

import argparse
import os
import re
import sys


def parse(file):
  """docstring for main"""
  
  logfile = open(file , 'r') 
  log = logfile.read()
  
  pattern = re.compile('\[job (\w+)\]([^\[]+)\[job \w+\] completed (\w+)',  re.DOTALL)
  
  print(log)
  jobs = pattern.findall(log)
  
  # print(jobs)
  # print("LIST")
  for entry in jobs:
    
    # print(entry)
    command = re.sub(r'\\\n', ' ', entry[1])
    command = re.sub(r'\/[\w\/]+\$' , '' , command )
    command = re.sub(r'^\W+' , '' , command )
    command = re.sub(r'\s+' , ' ' , command )
    
    print("# " + entry[0])
    if (args.no_strip_dir) :
      print(command)
    else:  
      short = re.sub(r'\/[\w\/-]+\/' , '.../' , command )
      print(short)
    print()




def main():
  """docstring for main"""
  
  if (not os.path.exists(args.cwl_run_log)) :
    print("No file" + args.cwl_run_log + "\n" , file=sys.stderr)
        
  steps = parse(args.cwl_run_log)  
 
  





# Setup
parser = argparse.ArgumentParser()
parser.add_argument("cwl_run_log", type=str , help="log file from cwl-run")
parser.add_argument("-v" , "--verbose", action="store_true", help="increase output verbosity")
parser.add_argument("-n" , "--no-strip-dir", action="store_true", help="increase output verbosity")
args = parser.parse_args()




if __name__ == "__main__":
  main()
 