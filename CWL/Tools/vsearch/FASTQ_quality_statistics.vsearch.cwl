
cwlVersion: v1.0
class: CommandLineTool

label: FASTQ_quality_statistics
doc:  |
    FASTQ quality statistics

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: FASTQ_quality_statistics.log
stderr: FASTQ_quality_statistics.error
inputs:

    log:
      type: string?
      doc: output file for statistics with --fastq_stats
      inputBinding:
        prefix: --log

    fastq_eestats:
      type: File?
      doc: quality score and expected error statistics
      inputBinding:
        prefix: --fastq_eestats

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

    fastq_stats:
      type: File?
      doc: report statistics on FASTQ file
      inputBinding:
        prefix: --fastq_stats

    output:
      type: string?
      doc: output file for statistics with --fastq_eestats
      inputBinding:
        prefix: --output

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
  