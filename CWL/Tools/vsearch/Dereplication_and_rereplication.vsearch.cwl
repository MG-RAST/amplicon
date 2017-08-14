
cwlVersion: v1.0
class: CommandLineTool

label: Dereplication_and_rereplication
doc:  |
    Dereplication and rereplication

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Dereplication_and_rereplication.log
stderr: Dereplication_and_rereplication.error
inputs:
  
    maxuniquesize:
      type: int?
      doc: maximum abundance for output from dereplication
      inputBinding:
        prefix: --maxuniquesize

    relabel:
      type: string?
      doc: relabel with this prefix string
      inputBinding:
        prefix: --relabel

    sizein:
      type: boolean?
      doc: propagate abundance annotation from input
      inputBinding:
        prefix: --sizein

    xsize:
      type: boolean?
      doc: strip abundance information in derep output
      inputBinding:
        prefix: --xsize

    derep_prefix:
      type: File?
      doc: dereplicate sequences in file based on prefixes
      inputBinding:
        prefix: --derep_prefix

    minuniquesize:
      type: int?
      doc: minimum abundance for output from dereplication
      inputBinding:
        prefix: --minuniquesize

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    derep_fulllength:
      type: File?
      doc: dereplicate sequences in the given FASTA file
      inputBinding:
        prefix: --derep_fulllength

    relabel_md5:
      type: boolean?
      doc: relabel with md5 digest of normalized sequence
      inputBinding:
        prefix: --relabel_md5

    relabel_sha1:
      type: boolean?
      doc: relabel with sha1 digest of normalized sequence
      inputBinding:
        prefix: --relabel_sha1

    strand:
      type: string?
      doc: dereplicate plus or both strands (plus)
      inputBinding:
        prefix: --strand

    rereplicate:
      type: File?
      doc: rereplicate sequences in the given FASTA file
      inputBinding:
        prefix: --rereplicate

    output:
      type: string?
      doc: output FASTA file
      inputBinding:
        prefix: --output

    sizeout:
      type: boolean?
      doc: write abundance annotation to output
      inputBinding:
        prefix: --sizeout

    uc:
      type: string?
      doc: filename for UCLUST-like dereplication output
      inputBinding:
        prefix: --uc

    topn:
      type: int?
      doc: output only n most abundant sequences after derep
      inputBinding:
        prefix: --topn

arguments:
  - prefix: --threads
    valueFrom: $(runtime.cores)



outputs:
  info:
    type: stdout
  error: 
    type: stderr
  fasta:
    type: File?
    outputBinding:
      glob: $(inputs.output)
  uc:
    type: File?
    outputBinding:
      glob: $(inputs.uc)        
  