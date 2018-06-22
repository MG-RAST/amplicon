cwlVersion: v1.0
class: Workflow

label: QIIME
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
  paired:
    type: File
    outputSource: [paired_end_joining/joined]
  plain:
    type: File
    outputSource: [fastq_to_fasta/fasta]
  predicted_otus:
    type: File
    outputSource: [pick_otus/otus] 
  representatives_sequences:
    type: File
    outputSource: [pick_representative_set/representatives]
  taxonomy:
    type: File[]
    outputSource: [assign_taxonomy/assignments , assign_taxonomy/log , assign_taxonomy/error]
  otus:
    type: File
    outputSource: [make_otu_table/table]  
  
steps:
  
  paired_end_joining:
    label:
    doc: 
    run: Tools/join_paired_ends.tool.cwl
    in:
      forward:
        source: mate_pair
        valueFrom: $(self.forward)
      reverse:
        source: mate_pair
        valueFrom: $(self.forward)
    out: [joined]
  
  fastq_to_fasta:
    label:
    doc:
    run: Tools/convert_fastaqual_fastq.tool.cwl
    in:
      sequences: paired_end_joining/joined

    out: [fasta]
 
  pick_otus:
    label:
    doc:
    run: Tools/pick_otus.tool.cwl
    in:
      sequences: fastq_to_fasta/fasta
    out: [otus]

  pick_representative_set:
    label:
    doc:
    run: Tools/pick_representative_set.tool.cwl
    in:
      summary: pick_otus/otus
      reads:  fastq_to_fasta/fasta
    out: [representatives]
 
  assign_taxonomy:
    label:
    doc:
    run: Tools/assign_taxonomy.tool.cwl
    in:
      sequences: pick_representative_set/representatives
    out: [assignments , log , error]
 
  make_otu_table:
    label:
    doc:
    run: Tools/make_otu_table.tool.cwl
    in:
      otus: pick_otus/otus
      taxonomy: assign_taxonomy/assignments
    out: [table]