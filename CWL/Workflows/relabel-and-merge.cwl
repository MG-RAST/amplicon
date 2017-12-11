cwlVersion: v1.0
class: Workflow

label: TAP 0.9
doc:  todo

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement


inputs:
  sequence_files:
    type: File[]
    format: fasta
    
outputs:
 concatenated:
   type: File
   outputSource: concatenate/concatenated
 
steps:
  
  # Add filname prefix to sequence header
  relabel:
    label: Relabel
    doc: regexp tool
    run: ../Tools/regexp.tool.cwl
    scatter: [input]
    in:
      regexp:
        default: 's/\(^.*\)|.*/\1barcodelabel=test;/g'
        # var regexp = 's/^\u005c(>.*\u005c)|.*/\u005c\u0031' + 'barcodelabel=' + name + ';/g' ;
        valueFrom: |
            ${
               var name   = inputs.input.basename.replace(/\.(tap)?.*/ , "") ;
               var regexp = 's/^\u005c(>.*\u005c)/\u005c\u0031;' + 'barcodelabel=' + name + ';/g' ;
               return regexp  ;
              }
      input: sequence_files
      output:
        default: test.output.txt
        valueFrom: |
            ${
              return inputs.input.basename.replace(/\.?tap.*/ , "") + ".tap.relabeled.fasta" ;
            }
    out: [modified]
    
  concatenate:
    label: Concatenation
    doc: Merge files into one 
    run:
      class:  CommandLineTool
      stdout: |
            ${ 
              var time = new Date().valueOf() ;
              return 'merged.' + time + '.fasta' ;
            }  
      inputs:
        files:
          type: File[]
          inputBinding:
            position: 1
      outputs:
        concatenated: 
          type: File
          format: fasta
          outputBinding: 
            glob: merged.*.fasta
          # type: stdout
      baseCommand: [cat] 
    in: 
      files: relabel/modified
    out: [concatenated]          
