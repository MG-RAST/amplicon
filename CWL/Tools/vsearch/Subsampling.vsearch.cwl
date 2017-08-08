
cwlVersion: v1.0
class: CommandLineTool

label: Subsampling
doc:  |
    Subsampling

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Subsampling.log
stderr: Subsampling.error
inputs:

    fastq_qmax:
      type: int?
      doc: maximum base quality value for FASTQ input (41)
      inputBinding:
        prefix: --fastq_qmax

    fastaout:
      type: string?
      doc: output subsampled sequences to FASTA file
      inputBinding:
        prefix: --fastaout

    xsize:
      type: boolean?
      doc: strip abundance information in output
      inputBinding:
        prefix: --xsize

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    fastqout_discarded:
      type: boolean?
      doc: output non-subsampled sequences to FASTQ file
      inputBinding:
        prefix: --fastqout_discarded

    relabel_sha1:
      type: boolean?
      doc: relabel with sha1 digest of normalized sequence
      inputBinding:
        prefix: --relabel_sha1

    fastaout_discarded:
      type: string?
      doc: output non-subsampled sequences to FASTA file
      inputBinding:
        prefix: --fastaout_discarded

    relabel_md5:
      type: boolean?
      doc: relabel with md5 digest of normalized sequence
      inputBinding:
        prefix: --relabel_md5

    fastqout:
      type: string?
      doc: output subsampled sequences to FASTQ file
      inputBinding:
        prefix: --fastqout

    fastx_subsample:
      type: File?
      doc: subsample sequences from given FASTA/FASTQ file
      inputBinding:
        prefix: --fastx_subsample

    sizeout:
      type: boolean?
      doc: update abundance information in output
      inputBinding:
        prefix: --sizeout

    sample_pct:
      type: float?
      doc: sampling percentage between 0.0 and 100.0
      inputBinding:
        prefix: --sample_pct

    fastq_qmin:
      type: int?
      doc: minimum base quality value for FASTQ input (0)
      inputBinding:
        prefix: --fastq_qmin

    sample_size:
      type: int?
      doc: sampling size
      inputBinding:
        prefix: --sample_size

    randseed:
      type: int?
      doc: seed for PRNG, zero to use random data source (0)
      inputBinding:
        prefix: --randseed

    relabel:
      type: string?
      doc: relabel sequences with this prefix string
      inputBinding:
        prefix: --relabel

    sizein:
      type: boolean?
      doc: consider abundance info from input, do not ignore
      inputBinding:
        prefix: --sizein

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
  