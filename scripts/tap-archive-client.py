#!/usr/bin/env python

import  argparse
#import http.client
import  datetime
import  hashlib
import  json
import  logging
import  os
from    pprint import pprint
import  re
import  requests
import  time
from    types import *
# import  urllib.request
import urllib
import  sys
import yaml

# Setup command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("-archive","--archive",   action="store_true" , help="upload results from cwl-run")
parser.add_argument("-download","--download", action="store_true", help="download results from cwl-run")
parser.add_argument("-list","--list",     action="store_true" , help="list archived cwl-runs")
parser.add_argument("-l","--log",             default='',type=str , help="log file from cwl-run")
parser.add_argument("-id","--id",             default=time.time() ,type=str , help="run/submission id, default current timestamp")
parser.add_argument("-r","--receipt",         type=str , help="cwl return object/file")
parser.add_argument("-v" , "--verbose",       action="store_true", help="increase output verbosity")
parser.add_argument("-n" , "--no-strip-dir",    action="store_true", help="increase output verbosity")
parser.add_argument("-url" , "--shock_api_url", default="http://shock:8001/shock/api/node/" , help="URI to API including node resource")
parser.add_argument("-job" , "--cwl_job_file",  default=None, help="CWL job file, input for workflow")
parser.add_argument("-workflow" , "--cwl_workflow_file", default=None, help="CWL workflow file")
args = parser.parse_args()


# Setup logger
logger = logging.getLogger('TAP')
logger.setLevel(logging.DEBUG)
# create file handler which logs even debug messages
fh = logging.FileHandler('error.log')
fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add the handlers to the logger
logger.addHandler(fh)
logger.addHandler(ch)



token='1234'
shock="http://shock:8001/shock/api/node/"
  
def download():
  """Download all files from a summary"""
  
  id = None
  if(args.id):
    id = args.id
  
  logger.debug('Trying as summary id:' + id)  
  r = requests.get(shock + "?query&" + "type=summary"   + "&id=" + id  , headers=headers)    
  response = r.json()

  if (response['status'] == 200 and response['total_count'] == 1) :
    get_files_from_summary(response['data'][0])
  elif  (response['status'] != 200) : 
    logger.error(response['error']) 

  else:
    logger.debug('Trying as shock id')
    r = requests.get(shock + "/" + id  , headers=headers)    
    response = r.json()
    
    if (response['status'] == 200 ) :
      get_files_from_summary(response['data'])
    else:
      logger.error('Neither shock nor summary id: ('+ id +')')
      logger.error(response['error'])   
    
   
  return True 
    
    
def get_files_from_summary(summary):
  logger.info('Downloading files')
  # pprint(summary['attributes']['files'])
  for fo in summary['attributes']['files']:
    print(fo['basename'])
    url = fo['location'] + "?download"
    
    local_filename = fo['basename']
    r = requests.get(url, stream=True , headers=headers)
    logger.info('Downloading '+ local_filename)
    with open(local_filename, 'wb') as f:
       for chunk in r.iter_content(chunk_size=1024): 
           if chunk: # filter out keep-alive new chunks
               f.write(chunk)
    r.close()             
    
    wf = open("workflow.cwl" ,'wb')
    json.dump(summary['attributes']['workflow']['data'], wf )
    wf.close()
    
    jf = open("job.json" ,'wb') 
    json.dump(summary['attributes']['job']['data'] , jf) 
    jf.close()
    
    rf = open("receipt.json" ,'wb')
    json.dump(summary['attributes']['receipt'] , rf) 
    rf.close()
    
    # subprocess.call(["curl", "-l"])
    
  
  
  
def upload():
  receipt = None
  if (args.receipt and os.path.exists(args.receipt)) :
    receipt = json.load(open(args.receipt))
  else:
    logger.error("Missing receipt file")
    sys.exit("Missing receipt file")  
  
  if args.shock_api_url :
    shock = args.shock_api_url
  
  # pprint(receipt)

  files=[]

  # Read receipt and get list of files
  check_for_files(receipt, files)
  logger.debug(files)
  
  for f in files :
    f['checksum']['md5'] = md5sum( f['path'] )
    # print( f['basename'] + ":\t" + f['checksum']['md5'] + "\t" + f['checksum']['sha1'])
    node = upload_file(f)
    f['location'] = shock + "/" + node
    
  #pprint(files)  

  upload_summary(receipt , files)


def upload_summary(receipt , fs):
  
  # set metadata 

  attributes = metadata
  attributes['type'] = "summary"
  attributes['files'] = fs
  attributes['receipt'] = receipt
        
  if attributes['workflow']['name'] and os.path.exists(args.cwl_workflow_file) :
    try:
      attributes['workflow']['data'] = json.load(open(args.cwl_workflow_file))
    except:
      try:
        attributes['workflow']['data'] = yaml.load(open(args.cwl_workflow_file))
      except:
        sys.exit("No known format")
            
  if attributes['job']['name'] and os.path.exists(args.cwl_job_file) :
    # attributes['job']['data'] = json.load(open(args.cwl_job_file))
    try:
      attributes['job']['data'] = json.load(open(args.cwl_job_file))
    except:
      try:
        attributes['job']['data'] = yaml.load(open(args.cwl_job_file))
      except:
        sys.exit("No known format")
          

  headers = {'user-agent': 'TAP-Client/0.0.1' ,
             'Authorization' : 'oauth 1234'
            }

  files = {
            'attributes' : ('attributes.json' , json.dumps(attributes) ) #json.dumps(f) 
          }

  logger.debug(attributes)
  

  # check if file exists - asssuming same name and checksum    
  r = requests.get(shock + "?query&" + "type=summary"   + "&id=" + str(attributes['id']) , headers=headers)    
  # r = requests.get(shock + "?querynode&" + "file.name=" + f['basename'] + "&file.checksum.md5=" + f['checksum']['md5'] , headers=headers)
  response = r.json()
  
  if (response['status'] == 200 and response['total_count'] ==1) :
    logger.info("Summary already uploaded")
    return response['data'][0]['id']
  
  else:  
    r = requests.post(shock, files=files , headers=headers)
    response = r.json()
    if response['status'] == 200 :
      return response['data']['id']
    else:
      # ERROR   
      logger.debug(response)
      logger.error("Upload error for summary: " + response['error'])
      sys.exit("Upload error: " + response['error'])
  

def upload_file(f) :
  
  # set metadata 

  attributes = metadata
  attributes['type'] = "file"
  attributes['file'] = f
        

  headers = {'user-agent': 'TAP-Client/0.0.1' ,
             'Authorization' : 'oauth 1234'
            }

  files = {
            'upload': ( f['basename'] , open(f['path'], 'rb') ) ,
            'attributes' : ('attributes.json' , json.dumps(attributes) ) #json.dumps(f) 
          }

  logger.debug(attributes)
  
  # check if file exists - asssuming same name and checksum    
  r = requests.get(shock + "?querynode&" + "file.name=" + f['basename'] + "&file.checksum.md5=" + f['checksum']['md5'] , headers=headers)    
  response = r.json()
  
  if (response['status'] == 200 and response['total_count'] >=1) :
    logger.info("File " + f['basename'] +" already uploaded")
    return response['data'][0]['id']
  
  else:  
    r = requests.post(shock, files=files , headers=headers)
    response = r.json()
    if response['status'] == 200 :
      return response['data']['id']
    else:
      # ERROR   
      logger.debug(response)
      logger.debug(r.url)
      logger.error("Upload error for results file: " + response['error'])
      sys.exit("Upload error: " + response['error'])
    


    
def get_file(dictionary):
  
  f =  { "format": None,
        "checksum": {},
        "basename": None,
        "location": None,
        "path": None,
        "class": "File",
        "size": None
        }
  
  if (f['class'] != dictionary['class']) :
    sys.exit("Wrong object, expected file object")
  
  f['checksum']['sha1'] = dictionary['checksum']
  f['basename'] = dictionary['basename']
  f['location'] = dictionary['location']
  f['path'] = dictionary['path']
  f['size'] = dictionary['size']
  f['format'] = dictionary['format'] if 'format' in dictionary else None
              
  return f      
      
def check_for_files(data , files=[]) :
  
  if isinstance(data, dict)  :
    if 'class' in data:
      files.append( get_file(data) )
    else:
      for entry in data:
        # print( entry + ":\t" + str(type(data[entry])) )
       #  print(type(data[entry]))
        if isinstance(data[entry], list) or isinstance(data[entry], dict) :
          check_for_files(data[entry] , files)
        else:
          pass
          # print(type(data[entry]))
            
  elif isinstance(data, list) :
    for entry in data:
      if entry :
        check_for_files(entry , files)
      else :
        logger.warning( "Unsopported type: " + type(entry).__name__ )  
  elif isinstance(data, str) :
   pass
  else:
    logger.debug(data + "\t" + str( type(data) )) 
    logger.error("Can't walk through data structure, unsupported type.")              
    sys.exit("Neither dict,list or str")
    

# def check_dict(dictionary , parent) :
#
#   if isinstance(dictionary, dict)  :
#     for entry in dictionary:
#       print( parent + ":\t" + entry)
#       print(type(dictionary[entry]))
#   else:
#     sys.exit("Not a dictionary")
#   pass
#
# def check_list(list):
#   pass



def md5sum(filename, blocksize=65536):
    hash = hashlib.md5()
    with open(filename, "rb") as f:
        for block in iter(lambda: f.read(blocksize), b""):
            hash.update(block)
    return hash.hexdigest()



     
 

def setup():
  
  global_metadata = {
    "id" : str(args.id) ,
    "pipeline" : "TAP" ,
    "version" : None ,
    "workflow" : { 
                  "name" : None ,
                  "format" : None ,
                  "data" : None ,
               } ,
    "job" : { 
                  "name" : None ,
                  "format" : None ,
                  "data" : None 
               }  ,
    "step" : None ,
  }
  
  if args.cwl_job_file :
    global_metadata['job']['name'] = os.path.basename(args.cwl_job_file)
  else:
    pass  
  if args.cwl_workflow_file :  
    global_metadata['workflow']['name'] = os.path.basename(args.cwl_workflow_file)
  else:
    pass  
    
  headers = {'user-agent': 'TAP-Client/0.0.1' ,
             'Authorization' : 'oauth 1234'
            }  
    
  return( global_metadata , headers)  


def list_tap_runs() :
  
  r = requests.get(shock + "?query&" + "type=summary"   + "&pipeline=TAP"  , headers=headers)    
  # r = requests.get(shock + "?querynode&" + "file.name=" + f['basename'] + "&file.checksum.md5=" + f['checksum']['md5'] , headers=headers)
  response = r.json()

  if (response['status'] == 200 ) :

    
    for run in response['data'] :
      print("IDs:\t" + run['attributes']['id'] + "\t" + run['id'] + "\t" + run['attributes']['workflow']['name'])
    
    
    return response['data'][0]['id']
  else:
    pprint(response)
    logger.error("Request failed: " + "\n".join(response['error']) )  
  
  return True 

def main() :
  
  shock="http://shock:8001/shock/api/node/"
     
  if (args.archive) : 
    upload()
  elif (args.download) :
    download()
  elif (args.list) :
    list_tap_runs()
  else:
    logger.warning('Missing command line option. One of -archive , -download , -list')                
     

if __name__ == "__main__":
  
  
  (metadata, headers) = setup()
  main()