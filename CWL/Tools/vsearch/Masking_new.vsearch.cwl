
cwlVersion: v1.0
class: CommandLineTool

label: Masking_new
doc:  |
    Masking (new)

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Masking_new.log
stderr: Masking_new.error
inputs:

    fastx_mask:
      type: File?
      doc: mask sequences in the given FASTA or FASTQ file
      inputBinding:
        prefix: --fastx_mask

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

    fastaout:
      type: string?
      doc: output to specified FASTA file
      inputBinding:
        prefix: --fastaout

    qmask:
      type: string?
      doc: mask seqs with dust, soft or no method (dust)
      inputBinding:
        prefix: --qmask

    max_unmasked_pct:
      type: boolean?
      doc: max unmasked % of sequences to keep (100.0)
      inputBinding:
        prefix: --max_unmasked_pct

    min_unmasked_pct:
      type: boolean?
      doc: min unmasked % of sequences to keep (0.0)
      inputBinding:
        prefix: --min_unmasked_pct

    fastq_ascii:
      type: int?
      doc: FASTQ input quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_ascii

    hardmask:
      type: boolean?
      doc: mask by replacing with N instead of lower case
      inputBinding:
        prefix: --hardmask

    fastqout:
      type: string?
      doc: output to specified FASTQ file
      inputBinding:
        prefix: --fastqout
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  