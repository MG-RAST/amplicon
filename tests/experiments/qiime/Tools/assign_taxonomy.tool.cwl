cwlVersion: v1.0
class: CommandLineTool

label: assign_taxonomy
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
    
requirements:
  
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
  - -o $(runtime.tmpdir)
          
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
      glob: $(runtime.tmpdir)/*assignments.log
  assigmnents:
    type: File
    format: txt
    outputBinding: 
      glob: $(runtime.tmpdir)/*assignments.txt
  
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"