cwlVersion: v1.0
class: Workflow

label: Remove primers
doc: remove specified primer in input sequences using cutadpt

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../primer-pair.yml

inputs:
  sequences:
    type: File
    format: edam:formate_1929  # FASTA
  primer:
    doc: Euk and Prokaryote primer
    type:
      type: record
      name: primer
      fields:
        - name: eukaryote
          doc: Eukaryote primer pair
          type: ../primer_pair.yml#primer_pair
        - name: prokaryote
          doc: Prokaryote primer pair
          type: ../primer_pair.yml#primer_pair
  error:
    type: string?
    default: "0.06"
      

outputs:
  trimmed_sequences:
    type: File
    outputSource: merge/merged 

  
 
 
  
steps:
  
  euk:  
    label: STAGE:0100.1    
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: sequences
     format:
       source: sequences
       valueFrom: $(self.nameext.split(".").pop())
     g: 
       source: primer
       valueFrom: ^$(self.eukaryote.forward)
     a: 
       source: primer
       valueFrom: $(self.eukaryote.reverse)'$'
     trimmed-only: 
       default: true   
     error: error
     output: 
       source: sequences
       valueFrom:  $(self.basename.split(".")[0]).tap.0100.$(self.nameext.split(".").pop())       
    out: [processed]
    
  prok:
    label: STAGE:0100.2
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: sequences
     format:
       source: euk/processed
       valueFrom: $(self.nameext.split(".").pop())
     g: 
       source: primer
       valueFrom: ^$(self.prokaryote.forward)
     a:
       source: primer
       valueFrom: $(self.prokaryote.reverse + '$') 
     trimmed-only: 
       default: true      
     error: error
     output: 
       source: euk/processed
       valueFrom:  $(self.basename.split(".")[0]).tap.0100.$(self.nameext.split(".").pop())  
    out: [processed]

  merge:
    label: STAGE:0100.3
    doc: Merge output from last two steps
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      stdout: $(inputs.files[0].basename.split(".")[0]).tap.0100.$(inputs.files[0].nameext.split(".").pop()) 
      baseCommand: cat  
      stderr: merge.error
      inputs:
        files:
          type: File[]
          inputBinding:
            position: 1
      outputs:
        merged:
          type: stdout 
    in: 
      files: [euk/processed , prok/processed]
    out: [merged]    
            

