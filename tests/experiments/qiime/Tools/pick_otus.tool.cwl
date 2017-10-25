cwlVersion: v1.0
class: CommandLineTool

label: pick_otus
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
    
requirements:
  
stdout: pick_otus.out
    
stderr: pick_otus.error


pick_otus.py -i $^ -o $*_uclust_picked_otus

inputs:
  sequences:
    type: File
    format:
      - fasta
    doc: fasta file
    inputBinding:
      prefix: -i
  
    
arguments:
  - -o $(runtime.tmpdir)       
          
baseCommand: [pick_otus.py]

   
outputs: 
  info:
    type: stdout
  error: 
    type: stderr
  uc:
    type: File
    format: uc
    outputBinding: 
      glob: *.uc
  log:
    type: File
    format: txt
    outputBinding:
      glob: *.log
  otus:
    type: File
    format: txt
    outputBinding:
      glob: *.txt     
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"