cwlVersion: v1.0
class: CommandLineTool

label: merge_mate_pairs
doc:  |
    STAGE:0050 Mate pair merging 
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
    
requirements:
  InlineJavascriptRequirement: {}

 
  
stdout: merge_mate_pairs.log
stderr: merge_mate_pairs.error


inputs:
  mate_pair:
    type:
      type: record
      fields:
        forward:
          doc: R1.fastq
          type: File
          # format:
          #   - fastq.gz
        reverse:
          doc: R2.fastq
          type: File
            # format:
            #   - fastq.gz
  fastqout:
    type: string
    doc: output file name
    inputBinding:
      prefix: --fastqout 
  
      
baseCommand: [vsearch]

arguments:
  - prefix: --fastq_mergepairs
    valueFrom: $(inputs.mate_pair.forward.path)     
  - prefix: --reverse
    valueFrom: $(inputs.mate_pair.reverse.path)
  - prefix: --threads 
    valueFrom: $(runtime.cores)   
  # - prefix: ''
  #   valueFrom: |
  #       ${
  #             var decompress='' ;
  #             if (inputs.mate_pair.forward.hasOwnProperty('format') {
  #                if (inputs.mate_pair.forward.format.match(/\.gz$/) ) {
  #                  decompress = "--gzip_decompres" ;
  #                }  
  #              }
  #              else if (inputs.mate_pair.forward.basename.match(/\.gz$/)) {
  #                decompress = "--gzip_decompres" ;
  #              }
  #              return decompress ;
  #       }
  
 

 
outputs:
  merged:
    type: File
    format: fastq
    outputBinding:
      glob: $(inputs.fastqout)
  log:
    type: stdout
  error: 
    type: stderr  
  

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"