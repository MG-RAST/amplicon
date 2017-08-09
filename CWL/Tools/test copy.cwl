cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: mgrast/pipeline:4.03
 

requirements:
  InlineJavascriptRequirement: {}

stdout: dummy.log
stderr: dummy.error

inputs:
  sequences:
    type: string
    doc: string input
    inputBinding:
      prefix: --input
  
baseCommand: [echo]


 
outputs:
  output:
    type: stdout
  error: 
    type: stderr  
 