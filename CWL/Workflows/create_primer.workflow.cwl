cwlVersion: v1.0
class: Workflow

label: Create ePCR version for primers
doc: prepare UNITE and SIVLA fasta database files and taxonomy tables using cutadapt 

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  euka_sequences:
    # /usr/local/share/db/UNITE*.fasta   # MRC: One, or many files?
    type: File
    format: edam:format_1929  # FASTA
  euka_forward: string
  euka_reverse: string
  prok_sequences:
    # /usr/local/share/db/SILVA*.fasta   # MRC: One, or many files?
    type: File
    format: edam:format_1929  # FASTA
  prok_forward: string   # Is this barcode?
  prok_reverse: string
  error:
    type: string?
    default: "0.06"
      

outputs:
  classified_euk:
    type: File
    outputSource: euk/processed
    # format: # ???
  classified_prok:
    type: File
    outputSource: prok/processed  
    # format: # ???
 
 
  
steps:
  
  euk:  
    label: STAGE:0001.1    
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: euka_sequences
     format:
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

$namespaces:
  - edam: http://edamontology.org/
  - s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "FIXME"
