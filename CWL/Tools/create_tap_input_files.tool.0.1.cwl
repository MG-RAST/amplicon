cwlVersion: v1.0
class: CommandLineTool

label: create input files
doc:  |
    STAGE:0010 Takes fastq.gz files and uncompresses files, 
    renames file to ${name}.tap.${STAGE}.fastq
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
    
requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}
 
  
stdout: |
    ${
      if (!inputs.sequences.basename.match(/\.tap\./) ) {
          var prefix = inputs.sequences.basename;
          prefix = prefix.replace( /\.fastq.gz$/ , '');
          return prefix + ".tap." + inputs.stage + ".fastq";
      } else if (inputs.sequences.basename.match(/\.gz$/) ) {
          return inputs.sequences.basename.replace(/\.gz$/ , '') ; 
      } else {
          return inputs.sequences.basename ;
      }      
    }
    

stderr: create_tap_input_files.error


inputs:
  sequences:
    type:
      type: array
      items: 
    type: File
    doc: Compressed fastq file
    format:
      - fastq.gz
    inputBinding:
      position: 2
  stage:
    type: string?
    default: "0010"    
  
      
baseCommand: [gzip]

arguments:
  - -d
  - -c
  
 

 
outputs:
  uncompressed:
    type: stdout
  error: 
    type: stderr  
  

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"