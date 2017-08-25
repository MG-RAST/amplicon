cwlVersion: v1.0
class: CommandLineTool

label: uc2otu
doc:  |
  n/a
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/metaxa:1.0
    
requirements:
  InlineJavascriptRequirement: {}
  
     
baseCommand: [uc2otu.pl]
  
stdout: $(inputs.output)
stderr: uc2otu.error




inputs:
      
  input:
    type: File
    doc: uclast like input file
    inputBinding:
      position: -1
  output:
    type: string?
    default: $(inputs.input.nameroot).otu
 

outputs:
  otu:
    type: stdout
  error: 
    type: stderr  
  

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"