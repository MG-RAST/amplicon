cwlVersion: v1.0
class: CommandLineTool

label: dereplicate
doc:  |
    de-replicating with vsearch
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
    
requirements:
  InlineJavascriptRequirement: {}

 
  
stdout: dereplicate.log
stderr: dereplicate.error


inputs:
  sequences:
    type: File
    format: 
      - fasta
      - fastq
    inputBinding:
      prefix: --derep_fulllength  
  output:
    type: string
    doc: output file name
    inputBinding:
      prefix: --output
  
      
baseCommand: [vsearch]

arguments:

  - prefix: --threads 
    valueFrom: $(runtime.cores)   
  
  
 

 
outputs:
  dereplicated:
    type: File
    format: fasta
    outputBinding:
      glob: $(inputs.output)
  log:
    type: stdout
  error: 
    type: stderr  
  

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"