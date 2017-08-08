
cwlVersion: v1.0
class: CommandLineTool

label: Pairwise_alignment
doc:  |
    Pairwise alignment

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Pairwise_alignment.log
stderr: Pairwise_alignment.error
inputs:

    alnout:
      type: string?
      doc: filename for human-readable alignment output
      inputBinding:
        prefix: --alnout

    allpairs_global:
      type: File?
      doc: perform global alignment of all sequence pairs
      inputBinding:
        prefix: --allpairs_global

    acceptall:
      type: boolean?
      doc: output all pairwise alignments
      inputBinding:
        prefix: --acceptall
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  