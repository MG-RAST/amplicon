cwlVersion: v1.0
class: CommandLineTool

label: make_otu_table
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
    
  
stdout: make_otu_table.out    
stderr: make_otu_table.error

# make_otu_table.py -i  $*.join_otus.txt   -o $*.biom -t $*.join_rep_set_tax_assignments.txt

inputs:
  otus:
    type: File
    doc:  otu file
    inputBinding:
      prefix: -i   
  taxonomy:
    type: File 
    doc:  taxonomic assignment file
    inputBinding:
      prefix: -t     
  
    
arguments:
  - prefix: -o 
    valueFrom: table.biom
          
baseCommand: [make_otu_table.py]

   
outputs: 
  info:
    type: stdout
  error: 
    type: stderr
  table:
    type: File
    outputBinding: 
      glob: "table.biom"
  
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"