cwlVersion: v1.0
class: CommandLineTool

label: sed
doc:  |
  n/a
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/metaxa:1.0
    
requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  
     
baseCommand: [cat]
  
stdout: $(inputs.output)
stderr: sed.error




inputs:
  
  regexp:
    type: string
    doc: add the script to the commands to be executed  
    inputBinding:
      position: 4
      
  input:
    type: File
    doc: input file
    inputBinding:
      position: 1
 
  output:
    type: string

arguments:
  - valueFrom: "|"
    position: 2
  - valueFrom: sed
    position: 3
    

outputs:
  modified:
    type: stdout
  error: 
    type: stderr  
  

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"