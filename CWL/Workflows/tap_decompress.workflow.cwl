cwlVersion: v1.0
class: Workflow

label: Decompress
doc: Decompress mate pair fastq files

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  mate_pair:
      type:
        type: record
        label: mate_pair
        fields:
          forward:
            type: File
          reverse:
            type: File
  stage:
    type: string
    default: "0010"        
  
      

outputs:
  uncompressed:
    outputSource: [decompress_forward/decompressed , decompress_reverse/decompressed]
    outputBinding: 
        outputEval: |
            ${

              return { a : self[1] ,
              b : self[0] } ;

            }
    type: string
      # type:
      #   type: record
      #   label: none
      #   fields:
      #     forward:
      #       type: string
      #       outputBinding:
      #         outputEval: |
      #            ${ return self.basename }
      #     reverse:
      #       type: string
      #       outputBinding:
      #         outputEval: |
      #            ${ return self.basename }

  
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

