cwlVersion: v1.0
class: CommandLineTool

label: cutadapt
doc: none

hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon
    # dockerPull: mgrast/cutadapt:1.0




requirements:
  - class: InlineJavascriptRequirement
  # - class: InitialWorkDirRequirement
  
  
stdout: cutadapt.log
stderr: cutadapt.error



 # -g ${prok_forward} \
#            -a ${prok_reverse} \
#            ${CUTADAPT_PARAM} \
#            /usr/local/share/db/SILVA*.fasta \
#            -o db/SILVA.${prok_forward}.${prok_reverse}

inputs:
  five_prime_adapter:
    label: prok_forward
    doc: 5’ adapter 
    type: string
    inputBinding:
      prefix: -g
  three_prime_adapter:
    label: prok_reverse
    doc: 3’ adapter  
    type: string                        
    inputBinding:
      prefix: -a
  format:
    doc:  <fasta|fastq|sra-fastq>  # candidate for becoming an enum
    type: string                        
    inputBinding:
      prefix: -f    
  error:
    label:  Maximum allowed error rate  
    type: string  # really?
    inputBinding:
      prefix: -e    
  discard-untrimmed:
    doc: Discard reads that do not contain the adapter
    type: boolean?                        
    inputBinding:
      prefix: --discard-untrimmed
  trimmed-only:
    doc: FIXME
    type: boolean?
    inputBinding:
      prefix: --trimmed-only          
  output:
    doc:  Write reads to OUTPUT
    type: string
    inputBinding:
      prefix: -o
  sequences:
    doc: input sequences
    type: File
    inputBinding:
      position: 5    
                    
baseCommand: [cutadapt]                    
                    
outputs:
  processed:
    type: File
    outputBinding:
      glob: $(inputs.output)    
  log:
    type: stdout
  err: 
    type: stderr  
    

