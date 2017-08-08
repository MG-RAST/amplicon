
cwlVersion: v1.0
class: CommandLineTool

label: General_options
doc:  |
    General options

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: General_options.log
stderr: General_options.error
inputs:

    quiet:
      type: boolean?
      doc: output just warnings and fatal errors to stderr
      inputBinding:
        prefix: --quiet

    log:
      type: File?
      doc: write messages, timing and memory info to file
      inputBinding:
        prefix: --log

    threads:
      type: int?
      doc: number of threads to use, zero for all cores (0)
      inputBinding:
        prefix: --threads

    gzip_decompress:
      type: boolean?
      doc: decompress input with gzip (required if pipe)
      inputBinding:
        prefix: --gzip_decompress

    notrunclabels:
      type: boolean?
      doc: do not truncate labels at first space
      inputBinding:
        prefix: --notrunclabels

    fasta_width:
      type: int?
      doc: width of FASTA seq lines, 0 for no wrap (80)
      inputBinding:
        prefix: --fasta_width

    help:
      type: boolean?
      doc: display help information
      inputBinding:
        prefix: --help

    version:
      type: boolean?
      doc: display version information
      inputBinding:
        prefix: --version

    bzip2_decompress:
      type: boolean?
      doc: decompress input with bzip2 (required if pipe)
      inputBinding:
        prefix: --bzip2_decompress

    maxseqlength:
      type: int?
      doc: maximum sequence length (50000)
      inputBinding:
        prefix: --maxseqlength

    minseqlength:
      type: int?
      doc: min seq length (clust/derep/search: 32, other:1)
      inputBinding:
        prefix: --minseqlength
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  