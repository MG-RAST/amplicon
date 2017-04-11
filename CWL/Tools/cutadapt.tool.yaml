cwlVersion: v1.0
class: CommandLineTool
baseCommand: [cutadapt]


requirements:
  - class: InlineJavascriptRequirement
  # - class: InitialWorkDirRequirement
  
stdout: ls.log
stderr: error.log

 # -g ${prok_forward} \
#            -a ${prok_reverse} \
#            ${CUTADAPT_PARAM} \
#            /usr/local/share/db/SILVA*.fasta \
#            -o db/SILVA.${prok_forward}.${prok_reverse}

inputs:
  g:
    label: prok_forward
    doc: 5’ adapter 
    type: string
    inputBinding:
      prefix: -g
  a:
    label: prok_reverse
    doc: 3’ adapter  
    type: string                        
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
    type: string                        
    inputBinding:
      prefix: -e    
  discard-untrimmed:
    label: discard-untrimmed
    doc: Discard reads that do not contain the adapter
    type: boolean?                        
    inputBinding:
      prefix: --discard-untrimmed      
  reads:
    label: 
    doc: input sequences
    type: File
    inputBinding:
      position: 3
  output:
    label: output
    doc:  Write trimmed reads to OUTPUT
    type: string
    inputBinding:
      prefix: -o
                    
outputs:
  readsFile:
    type: File
    outputBinding:
      glob: $(inputs.o)    
  log:
    type: stdout
  err: 
    type: stderr  
    

