cwlVersion: v1.0
class: CommandLineTool

label: assign_taxonomy
doc:  |
    Assign taxonomy
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
  
stdout: assign_taxonomy.out    
stderr: assign_taxonomy.error


inputs:
  sequences:
    type: File
    format:
      - fasta
    doc:  fasta file
    inputBinding:
      prefix: -i    
  
    
arguments:
  - prefix: -o 
    valueFrom: ./
          
baseCommand: [assign_taxonomy.py]

   
outputs: 
  info:
    type: stdout
  error: 
    type: stderr
  log:
    type: File
    format: txt
    outputBinding: 
      glob: "*assignments.log"
  assignments:
    type: File
    format: txt
    outputBinding: 
      glob: "*assignments.txt"
  
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"