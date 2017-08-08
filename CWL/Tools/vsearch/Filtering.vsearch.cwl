
cwlVersion: v1.0
class: CommandLineTool

label: Filtering
doc:  |
    Filtering

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Filtering.log
stderr: Filtering.error
inputs:

    fastq_maxns:
      type: int?
      doc: maximum number of N's for filter
      inputBinding:
        prefix: --fastq_maxns

    fastqout_discarded:
      type: string?
      doc: FASTQ filename for discarded sequences
      inputBinding:
        prefix: --fastqout_discarded

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    fastq_truncqual:
      type: int?
      doc: minimum base quality value for truncation
      inputBinding:
        prefix: --fastq_truncqual

    fastq_minlen:
      type: int?
      doc: minimum length of sequence for filter
      inputBinding:
        prefix: --fastq_minlen

    fastaout:
      type: string?
      doc: FASTA output filename for passed sequences
      inputBinding:
        prefix: --fastaout

    fastq_qmax:
      type: int?
      doc: maximum base quality value for FASTQ input (41)
      inputBinding:
        prefix: --fastq_qmax

    fastq_maxee:
      type: float?
      doc: maximum expected error value for filter
      inputBinding:
        prefix: --fastq_maxee

    fastx_filter:
      type: File?
      doc: filter and truncate sequences in FASTA/FASTQ file
      inputBinding:
        prefix: --fastx_filter

    xsize:
      type: boolean?
      doc: strip abundance information in output
      inputBinding:
        prefix: --xsize

    fastq_maxee_rate:
      type: float?
      doc: maximum expected error rate for filter
      inputBinding:
        prefix: --fastq_maxee_rate

    sizeout:
      type: boolean?
      doc: include abundance information when relabelling
      inputBinding:
        prefix: --sizeout

    eeout:
      type: boolean?
      doc: include expected errors in output
      inputBinding:
        prefix: --eeout

    fastqout:
      type: string?
      doc: FASTQ output filename for passed sequences
      inputBinding:
        prefix: --fastqout

    relabel_sha1:
      type: boolean?
      doc: relabel filtered sequences with sha1 digest
      inputBinding:
        prefix: --relabel_sha1

    fastq_stripleft:
      type: int?
      doc: bases on the left to delete
      inputBinding:
        prefix: --fastq_stripleft

    relabel_md5:
      type: boolean?
      doc: relabel filtered sequences with md5 digest
      inputBinding:
        prefix: --relabel_md5

    fastaout_discarded:
      type: string?
      doc: FASTA filename for discarded sequences
      inputBinding:
        prefix: --fastaout_discarded

    fastq_truncee:
      type: float?
      doc: maximum total expected error for truncation
      inputBinding:
        prefix: --fastq_truncee

    fastq_qmin:
      type: int?
      doc: minimum base quality value for FASTQ input (0)
      inputBinding:
        prefix: --fastq_qmin

    fastq_trunclen:
      type: int?
      doc: read length for sequence truncation
      inputBinding:
        prefix: --fastq_trunclen

    fastq_ascii:
      type: int?
      doc: FASTQ input quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_ascii

    fastq_maxlen:
      type: int?
      doc: maximum length of sequence for filter
      inputBinding:
        prefix: --fastq_maxlen

    fastq_filter:
      type: File?
      doc: filter and truncate sequences in FASTQ file
      inputBinding:
        prefix: --fastq_filter

    relabel:
      type: string?
      doc: relabel filtered sequences with given prefix
      inputBinding:
        prefix: --relabel
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  