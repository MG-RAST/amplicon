cwlVersion: v1.0
class: Workflow

label: TAP 0.9
doc:  

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  # Input sequences
  mate_pair: 
    doc: List of forward and reverse compressed fastq file records
    type:
      name: mate_pair_type
      type: record
      fields:
        - name: forward
          doc: R1.fastq 
          type: File
          # format: fastq
        - name: reverse
          doc: R2.fastq
          type: File
          # format: fastq
          
outputs:
  
steps:
  
  paired_end_joining:
    label:
    doc: 
    run: Tools/qiime/join_paired_ends.tool.cwl
    in:
      paired_
    out: 
  
  fastq_to_fasta:
    label:
    doc: 
    run: Tools/qiime/convert_fastaqual_fastq.tool.cwl
    in:
    out:   
    
  pick_otus:
    label:
    doc: 
    run: Tools/qiime/pick_otus.tool.cwl
    in:
    out:   
    
  pick_representative_set:
    label:
    doc: 
    run: Tools/qiime/pick_rep_set.tool.cwl
    in:
    out:  
    
  assigne_taxonomy:
    label:
    doc: 
    run: Tools/qiime/assign_taxonomy.tool.cwl
    in:
    out: 
      
  make_otu_table:
    label:
    doc: 
    run: Tools/qiime/make_otu_table.tool.cwl
    in:
    out: 