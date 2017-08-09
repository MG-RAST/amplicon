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
  
     
baseCommand: [sed]
  
stdout: sed.log
stderr: sed.error




inputs:
  
  regexp:
    type: string[]?
    doc: add the script to the commands to be executed  
    inputBinding:
      prefix: -e
      
  input:
    type: File
    doc: input file
    inputBinding:
      position: -1
 

outputs:
  output:
    type: stdout
  error: 
    type: stderr  
  

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"