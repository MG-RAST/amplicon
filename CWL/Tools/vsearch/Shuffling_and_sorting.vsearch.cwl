
cwlVersion: v1.0
class: CommandLineTool

label: Shuffling_and_sorting
doc:  |
    Shuffling and sorting

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Shuffling_and_sorting.log
stderr: Shuffling_and_sorting.error
inputs:

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    shuffle:
      type: File?
      doc: shuffle order of sequences in FASTA file randomly
      inputBinding:
        prefix: --shuffle

    randseed:
      type: int?
      doc: seed for PRNG, zero to use random data source (0)
      inputBinding:
        prefix: --randseed

    sortbylength:
      type: File?
      doc: sort sequences by length in given FASTA file
      inputBinding:
        prefix: --sortbylength

    xsize:
      type: boolean?
      doc: strip abundance information in output
      inputBinding:
        prefix: --xsize

    maxsize:
      type: int?
      doc: maximum abundance for sortbysize
      inputBinding:
        prefix: --maxsize

    output:
      type: string?
      doc: output to specified FASTA file
      inputBinding:
        prefix: --output

    sizeout:
      type: boolean?
      doc: include abundance information when relabelling
      inputBinding:
        prefix: --sizeout

    topn:
      type: int?
      doc: output just first n sequences
      inputBinding:
        prefix: --topn

    minsize:
      type: int?
      doc: minimum abundance for sortbysize
      inputBinding:
        prefix: --minsize

    relabel_sha1:
      type: boolean?
      doc: relabel with sha1 digest of normalized sequence
      inputBinding:
        prefix: --relabel_sha1

    relabel_md5:
      type: boolean?
      doc: relabel with md5 digest of normalized sequence
      inputBinding:
        prefix: --relabel_md5

    sortbysize:
      type: File?
      doc: abundance sort sequences in given FASTA file
      inputBinding:
        prefix: --sortbysize

    relabel:
      type: string?
      doc: relabel sequences with this prefix string
      inputBinding:
        prefix: --relabel

    sizein:
      type: boolean?
      doc: propagate abundance annotation from input
      inputBinding:
        prefix: --sizein
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  