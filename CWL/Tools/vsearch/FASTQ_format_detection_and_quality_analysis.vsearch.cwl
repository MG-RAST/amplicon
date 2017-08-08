
cwlVersion: v1.0
class: CommandLineTool

label: FASTQ_format_detection_and_quality_analysis
doc:  |
    FASTQ format detection and quality analysis

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: FASTQ_format_detection_and_quality_analysis.log
stderr: FASTQ_format_detection_and_quality_analysis.error
inputs:

    fastq_chars:
      type: File?
      doc: analyse FASTQ file for version and quality range
      inputBinding:
        prefix: --fastq_chars

    fastq_tail:
      type: int?
      doc: min length of tails to count for fastq_chars (4)
      inputBinding:
        prefix: --fastq_tail
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  