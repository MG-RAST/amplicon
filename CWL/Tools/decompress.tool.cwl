cwlVersion: v1.0
class: CommandLineTool

label: decompress
doc:  |
    Decompress gz input files with gzip
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/gzip:1.0
    
requirements:
  InlineJavascriptRequirement: {}
 
  
stdout: |
    ${
        if (inputs.output.length){
          return inputs.output
        }
        else{
           return inputs.file.basename.replace(/\.gz$/ , '') ;
        }
      
    }
    
stderr: decompress.error


inputs:
  file:
    doc: gziped file
    type: File
    # format:
    #   - file:gz
    inputBinding:
      position: 3  
  output:
    type: string?
    default: ''        
          
baseCommand: [gzip]

arguments:
  - -c
  - -d

   
outputs:
 
  decompressed:
    type: stdout
  error: 
    type: stderr  
  


# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"
