
cwlVersion: v1.0
class: CommandLineTool

label: FASTQ_format_conversion
doc:  |
    FASTQ format conversion

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: FASTQ_format_conversion.log
stderr: FASTQ_format_conversion.error
inputs:

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

    fastq_qmaxout:
      type: int?
      doc: maximum base quality value for FASTQ output (41)
      inputBinding:
        prefix: --fastq_qmaxout

    fastq_asciiout:
      type: int?
      doc: FASTQ output quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_asciiout

    fastq_qminout:
      type: int?
      doc: minimum base quality value for FASTQ output (0)
      inputBinding:
        prefix: --fastq_qminout

    fastq_convert:
      type: File?
      doc: convert between FASTQ file formats
      inputBinding:
        prefix: --fastq_convert

    fastqout:
      type: string?
      doc: FASTQ output filename for converted sequences
      inputBinding:
        prefix: --fastqout

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
  