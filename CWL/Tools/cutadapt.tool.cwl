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
  g:
    label: prok_forward
    doc: 5' adapter 
    type: string?
    inputBinding:
      prefix: -g
  a:
    label: prok_reverse
    doc: 3' adapter  
    type: string?                        
    inputBinding:
      prefix: -a
  format:
    label: format
    doc:  <fasta|fastq|sra-fastq>
    type: string                        
    inputBinding:
      prefix: -f    
  error:
    label: error_rate
    doc:  Maximum allowed error rate  
    type: float                        
    inputBinding:
      prefix: -e    
  discard-untrimmed:
    label: discard-untrimmed
    doc: Discard reads that do not contain the adapter
    type: boolean?                        
    inputBinding:
      prefix: --discard-untrimmed
  trimmed-only:
    label: trimmed-only
    doc: .
    type: boolean?
    inputBinding:
      prefix: --trimmed-only          
  output:
    label: output
    doc:  Write reads to OUTPUT
    type: string
    inputBinding:
      prefix: -o
  sequences:
    label: 
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
    

