cwlVersion: v1.0
class: CommandLineTool

label: pick_representative_set
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
    
  
stdout: pick_representative_set.out    
stderr: pick_representative_set.error


inputs:
  summary:
    type: File
    format:
      - txt
    doc: summary file
    inputBinding:
      prefix: -i
  reads:
    type: File
    format:
      - fasta
    doc: nucleotide fasta file
    inputBinding:
      prefix: -f    
  
    
arguments:
  - prefix: -o 
    valueFrom: representative_set.fasta       
          
baseCommand: [pick_rep_set.py]

   
outputs: 
  info:
    type: stdout
  error: 
    type: stderr
  representatives:
    type: File
    format: fasta
    outputBinding: 
      glob: representative_set.fasta
  
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"