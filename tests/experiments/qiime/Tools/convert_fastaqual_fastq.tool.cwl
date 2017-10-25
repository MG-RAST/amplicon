cwlVersion: v1.0
class: CommandLineTool

label: convert_fastaqual_fastq
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
    
requirements:
  
stdout: convert_fastaqual_fastq.out
    
stderr: convert_fastaqual_fastq.error


convert_fastaqual_fastq.py  -f $^ -c fastq_to_fastaqual

inputs:
  sequences:
    type: File
    format:
      - fastq
    doc: fastq file
    inputBinding:
      prefix: -f
  
    
arguments:
  - -c fastq_to_fastaqual       
          
baseCommand: [convert_fastaqual_fastq.py]

   
outputs: 
  info:
    type: stdout
  error: 
    type: stderr
  fasta:
    type: File
    format: fasta
    outputBinding: 
      glob: *.fna
  quality:
    type: File
    format: qualq
    outputBinding:
      glob: *.qual   
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"