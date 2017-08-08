
cwlVersion: v1.0
class: CommandLineTool

label: Chimera_detection
doc:  |
    Chimera detection

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Chimera_detection.log
stderr: Chimera_detection.error
inputs:

    sizein:
      type: boolean?
      doc: propagate abundance annotation from input
      inputBinding:
        prefix: --sizein

    relabel:
      type: string?
      doc: relabel nonchimeras with this prefix string
      inputBinding:
        prefix: --relabel

    mindiv:
      type: float?
      doc: minimum divergence from closest parent (0.8)
      inputBinding:
        prefix: --mindiv

    selfid:
      type: boolean?
      doc: exclude identical sequences for --uchime_ref
      inputBinding:
        prefix: --selfid

    borderline:
      type: string?
      doc: output borderline chimeric sequences to file
      inputBinding:
        prefix: --borderline

    db:
      type: File?
      doc: reference database for --uchime_ref
      inputBinding:
        prefix: --db

    uchimealns:
      type: string?
      doc: output chimera alignments to file
      inputBinding:
        prefix: --uchimealns

    nonchimeras:
      type: string?
      doc: output non-chimeric sequences to file
      inputBinding:
        prefix: --nonchimeras

    fasta_score:
      type: boolean?
      doc: include chimera score in fasta output
      inputBinding:
        prefix: --fasta_score

    dn:
      type: boolean?
      doc: REAL                   'no' vote pseudo-count (1.4)
      inputBinding:
        prefix: --dn

    self:
      type: boolean?
      doc: exclude identical labels for --uchime_ref
      inputBinding:
        prefix: --self

    mindiffs:
      type: int?
      doc: minimum number of differences in segment (3)
      inputBinding:
        prefix: --mindiffs

    relabel_md5:
      type: boolean?
      doc: relabel with md5 digest of normalized sequence
      inputBinding:
        prefix: --relabel_md5

    xn:
      type: boolean?
      doc: REAL                   'no' vote weight (8.0)
      inputBinding:
        prefix: --xn

    relabel_sha1:
      type: boolean?
      doc: relabel with sha1 digest of normalized sequence
      inputBinding:
        prefix: --relabel_sha1

    chimeras:
      type: string?
      doc: output chimeric sequences to file
      inputBinding:
        prefix: --chimeras

    uchime_denovo:
      type: File?
      doc: detect chimeras de novo
      inputBinding:
        prefix: --uchime_denovo

    uchime_ref:
      type: File?
      doc: detect chimeras using a reference database
      inputBinding:
        prefix: --uchime_ref

    sizeout:
      type: boolean?
      doc: include abundance information when relabelling
      inputBinding:
        prefix: --sizeout

    uchimeout5:
      type: boolean?
      doc: make output compatible with uchime version 5
      inputBinding:
        prefix: --uchimeout5

    uchimeout:
      type: string?
      doc: output to chimera info to tab-separated file
      inputBinding:
        prefix: --uchimeout

    xsize:
      type: boolean?
      doc: strip abundance information in output
      inputBinding:
        prefix: --xsize

    abskew:
      type: float?
      doc: min abundance ratio of parent vs chimera (2.0)
      inputBinding:
        prefix: --abskew

    alignwidth:
      type: int?
      doc: width of alignment in uchimealn output (80)
      inputBinding:
        prefix: --alignwidth

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    minh:
      type: float?
      doc: minimum score (0.28)
      inputBinding:
        prefix: --minh
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  