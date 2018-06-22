cwlVersion: v1.0
class: Workflow

label: Create ePCR version for primers
doc: prepare UNITE and SIVLA fasta database files and taxonomy tables using cutadapt 

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  euka_sequences:
    # /usr/local/share/db/UNITE*.fasta
    type: File
    # format:
    #   - fasta
  euka_forward: string
  euka_reverse: string
  prok_sequences:
    # /usr/local/share/db/SILVA*.fasta 
    type: File
    # format:
    #   - fasta
  prok_forward: string
  prok_reverse: string
  error:
    type: string?
    default: "0.06"
      

outputs:
  classified_euk:
    type: File
    outputSource: euk/processed
  classified_prok:
    type: File
    outputSource: prok/processed  
 

steps:
  
  euk:  
    label: STAGE:0001.1    
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: euka_sequences
     format:
       default: fasta
       source: euka_sequences
       valueFrom: |
         ${
            return self.format.split("/").slice(-1)[0]
           }
     g: euka_forward
     a: euka_reverse
     error: error
     discard-untrimmed: 
       default: true
     output: 
       source: [euka_sequences , euka_forward , euka_reverse]
       valueFrom: $(self[0].basename).$(self[1]).$(self[2])
         
    out: [processed]
    
  prok:
    label: STAGE:0001.2
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: prok_sequences
     format:
       source: prok_sequences
       valueFrom: |
         ${
            return self.format.split("/").slice(-1)[0]
           }
     g: prok_forward
     a: prok_reverse
     error: error
     discard-untrimmed: 
       default: true
     output: 
       source: [prok_sequences , prok_forward , prok_reverse]
       valueFrom: $(self[0].basename).$(self[1]).$(self[2])
    out: [processed]
