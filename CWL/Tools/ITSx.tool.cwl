cwlVersion: v1.0
class: CommandLineTool

label: ITSx
doc:  |
  n/a
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/metaxa:1.0
    
requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ITSx-profile.yaml
  
     
baseCommand: [ITSx]
  
stdout: ITSx.log
stderr: ITSx.error


inputs:
  
  input:
    type: File
    format:
      - fasta
    doc: DNA FASTA input file to investigate  
    inputBinding:
      prefix: -i
      
  prefix:
    type: string
    doc: Base for the names of output file(s)
    inputBinding:
      prefix: -o
  
  hmmdir:
    type: Directory?
    label: HMM profile directory
    doc: Path to a directory of HMM-profile collections representing ITS conserved region.
    inputBinding:
      prefix: -p 
      
  profile:
    type: ITSx-profile.yaml#profileITSx[]
    label: Profile set to use for the search
    #default: [all]
    inputBinding:
      itemSeparator: ','
      prefix: -t
    
  complement:
    type: 
      type: enum
      symbols:
        - T
        - F
    doc: |
      Checks both DNA strands against the database, 
      creating reverse complements, on (T) by default 
    default: T
    inputBinding:
      prefix: --complement 
      
  preserve:
    doc: | 
      Preserve sequence headers in input file 
      instead of printing out ITSx headers, 
      off (F) by default
    type:
      type: enum
      symbols:
        - T
        - F
    default: F
    inputBinding:
      prefix: --preserve
          
  only_full:
    type:
      type: enum
      symbols:
        - T
        - F
    default: F
    inputBinding:
      prefix: --only_full
  reset: 
    doc: |
       Re-creates the HMM-database before ITSx is run, off (F) by default
    type:
      type: enum
      symbols:
        - T
        - F
    default: F
    inputBinding:
      prefix: --reset
      
                
arguments:   
  - prefix: --cpu
    valueFrom: $(runtime.cores)  
 

outputs:
  summary:
    type: File
    outputBinding:
      glob: $(inputs.prefix).summary.txt
  graph:
    type: File
    outputBinding:
      glob: $(inputs.prefix).graph
  positions:
    type: File
    outputBinding:
      glob: $(inputs.prefix).positions.txt
  undetected:
    type: File
    outputBinding:
      glob: $(inputs.prefix)_no_detections.fasta           
  full:
    type: File
    outputBinding:
      glob: $(inputs.prefix).full.fasta
  ITS1:
    type: File
    outputBinding:
      glob: $(inputs.prefix).ITS1.fasta    
  ITS2:
    type: File
    outputBinding:
      glob: $(inputs.prefix).ITS2.fasta           
  log:
    type: stdout
  error: 
    type: stderr
  

$namespaces:
  Profiles: ITSx-profile.yaml
  
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"
