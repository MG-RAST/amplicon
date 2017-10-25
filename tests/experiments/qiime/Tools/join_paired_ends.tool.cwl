cwlVersion: v1.0
class: CommandLineTool

label: join_paired_ends
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    # dockerPull: mgrast/amplicon:1.0
    dockerPull: mgrast/qiime:1.0
    
requirements:
  
stdout: join_paired_ends.out
    
stderr: join_paired_ends.error


inputs:
  forward:
    type: File
    format:
      - fastq
    doc: forward fasrq sequence file
    inputBinding:
      prefix: -f
  reverse:
    type: File
    format:
      - fastq
    doc: forward fastq sequence file
    inputBinding:
      prefix: -r
  # output:
 #    type: File
 #    format:
 #      - fastq
 #    doc: output file name
 #    inputBinding:
 #      prefix: -o  
    
arguments:
  - -o $(runtime.outdir)        
          
baseCommand: [join_paired_ends.py]

   
outputs: 
  info:
    type: stdout
  error: 
    type: stderr
  joined:
    type: File
    format: fasta
    outputBinding: 
      glob: $(runtime.outdir)/fastqjoin.join.fastq
  unpaired:
    type: File[]
    outputBinding:
      glob: $(runtime.outdir)/*.un*.fastq    
  

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"