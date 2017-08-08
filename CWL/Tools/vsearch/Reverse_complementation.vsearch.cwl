
cwlVersion: v1.0
class: CommandLineTool

label: Reverse_complementation
doc:  |
    Reverse complementation

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Reverse_complementation.log
stderr: Reverse_complementation.error
inputs:

    fastaout:
      type: string?
      doc: FASTA output filename
      inputBinding:
        prefix: --fastaout

    fastq_qmax:
      type: int?
      doc: maximum base quality value for FASTQ input (41)
      inputBinding:
        prefix: --fastq_qmax

    fastq_qmin:
      type: int?
      doc: minimum base quality value for FASTQ input (0)
      inputBinding:
        prefix: --fastq_qmin

    fastqout:
      type: string?
      doc: FASTQ output filename
      inputBinding:
        prefix: --fastqout

    fastx_revcomp:
      type: File?
      doc: Reverse-complement seqs in FASTA or FASTQ file
      inputBinding:
        prefix: --fastx_revcomp

    label_suffix:
      type: string?
      doc: Label to append to identifier in the output
      inputBinding:
        prefix: --label_suffix

    fastq_ascii:
      type: int?
      doc: FASTQ input quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_ascii
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  