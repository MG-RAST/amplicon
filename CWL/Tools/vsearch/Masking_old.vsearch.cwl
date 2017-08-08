
cwlVersion: v1.0
class: CommandLineTool

label: Masking_old
doc:  |
    Masking (old)

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Masking_old.log
stderr: Masking_old.error
inputs:

    output:
      type: string?
      doc: output to specified FASTA file
      inputBinding:
        prefix: --output

    maskfasta:
      type: File?
      doc: mask sequences in the given FASTA file
      inputBinding:
        prefix: --maskfasta

    qmask:
      type: string?
      doc: mask seqs with dust, soft or no method (dust)
      inputBinding:
        prefix: --qmask

    hardmask:
      type: boolean?
      doc: mask by replacing with N instead of lower case
      inputBinding:
        prefix: --hardmask
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  