cwlVersion: v1.0
class: Workflow

label: Decompress
doc: Decompress mate pair fastq files

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../mate_pair.yml
  

inputs:
  mate_pair: mate_pair
  stage:
    type: string
    default: "0010"        
  
      

outputs:
  mate_pair_files:
    type: File[]
    outputSource: [decompress_forward/decompressed , decompress_reverse/decompressed]
  mate_pair_decompressed: 
    outputSource: make_return/mate_pair
    type: ../mate_pair.yml#mate_pair
   
  
steps:

  decompress_forward:  
    label: STAGE:0010  
    run: ../Tools/decompress.tool.cwl
    in:
     file: 
       source: mate_pair
       valueFrom: |
         ${ return self.forward }
     output:
       source: mate_pair
       valueFrom:   |
           ${
               if (!self.forward.basename.match(/\.tap\./) ) {
                   var prefix = self.forward.basename;
                   prefix = prefix.replace( /\.fastq.gz$/ , '');
                   return prefix + ".tap." + inputs.stage + ".fastq";
               } else if (self.forward.basename.match(/\.gz$/) ) {
                   return self.forward.basename.replace(/\.gz$/ , '') ;
               } else {
                   return self.forward.basename ;
               }
            }      
    out: [decompressed]
    
  decompress_reverse:  
    label: STAGE:0010  
    run: ../Tools/decompress.tool.cwl
    in:
     file: 
       source: mate_pair
       valueFrom: |
         ${ return self.reverse }
     output:
       source: mate_pair
       valueFrom: |
         ${
             if (!self.reverse.basename.match(/\.tap\./) ) {
                 var prefix = self.reverse.basename;
                 prefix = prefix.replace( /\.fastq.gz$/ , '');
                 return prefix + ".tap." + inputs.stage + ".fastq";
             } else if (self.reverse.basename.match(/\.gz$/) ) {
                 return self.reverse.basename.replace(/\.gz$/ , '') ;
             } else {
                 return self.reverse.basename ;
             }
          }      
    out: [decompressed]
    
  make_return:
    run:
      cwlVersion: v1.0
      class: ExpressionTool
      inputs:
        forward:
          type: File
        reverse:
          type: File
      outputs:
        mate_pair:
          type: ../mate_paire.yml#mate_pair
      expression: |
                ${
                  var mate_pair = {
                    "forward" : inputs.forward ,
                    "reverse" : inputs.reverse
                  };
                  return { 'mate_pair' : mate_pair} ;
                }

    in:
      forward: decompress_forward/decompressed
      reverse: decompress_reverse/decompressed
    out: [mate_pair]

    
     

