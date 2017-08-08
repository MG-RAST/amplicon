cwlVersion: v1.0
class: Workflow

label: TAP
doc:  

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  files: 
    type: File[]
    format:
      - R1.fastq.gz 
      - R2.fastq.gz 
  ion_torrent: 
    type: boolean
    default: False
  tidy_up: 
    type: boolean
    default: False
  primer_euk: 
    type: string
    default: -g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$
    doc: |
      the Eukaryote primer pair e.g. \"-g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$ \"
      using cutadapt syntax, primers have to be anchored with ^ and $
  primer_prok: 
    type: string
    default: -g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$
    doc: |
      the Prokaryote primer pair e.g. \"-g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$\"
      using cutadapt syntax, primers have to be anchored with ^ and $
      
 
  
  
    

# outputs:
#   classified:
#     type: File
#     outputSource: classify/classified
 
 
  
steps:
  
  prep:  
    label: STAGE:0001    
    doc: prepare UNITE and SIVLA fasta database files and taxonomy tables
    
  merging:
    label: STAGE:0050    
    doc: Mate pair merging
    
  barcode:
    label: STAGE:0055
    doc: barcode label into fastq header  
  
  removePHIX :
    label: STAGE:0060
    doc: PHIX removal using bowtie2 with Illumina RTA genome and Illumina built indeces
    
  removePrimer:
    label: STAGE:0100
    doc: target specific primer removal using cutadpt 
    
  removeIdentical:
    label: STAGE:0200
    doc: dereplicating exactly identical reads
    
  clusteringOTU:
    label: STAGE:0300
    doc: OTUclustering
    
  extractFeatures:
    label: STAGE:0400    
    doc: |
        16s ribosomal feature extraction via Metaxa [PROK]
        ITS feature extraction via ITSx [EUK]  
              
  mapReads:
    label: STAGE:0500
    doc: |
        map cleaned reads against centroid sequences (vsearch -userarch_global) [PROK]
        map cleaned reads against centroid sequences (vsearch -fastx_getseqs) [EUK]          
  
  reformat:
    label: STAGE:0600
    doc: format conversion to .otu files
    
  classify:
    label: STAGE:0700
    doc: classification using mothur  
  
  # filter:
 #    run: ../Tools/DynamicTrimmer.tool.cwl
 #    in:
 #      sequences:  sequences
 #      output:
 #        source: jobid
 #        valueFrom: $(self).100.preprocess.length.stats
 #    out: [trimmed , rejected ]
 #
 #
 #  trimmed2fasta:
 #    run: ../Tools/seqUtil.tool.cwl
 #    in:
 #      sequences:
 #        # set format to fastq
 #        source: filter/trimmed
 #        valueFrom: |
 #          ${
 #            inputs.sequences.format = "fastq" ; return inputs.sequences
 #          }
 #      fastq2fasta:
 #        default: true
 #      output:
 #        source: jobid
 #        valueFrom: $(self).100.preprocess.passed.fasta
 #    out: [file]
 #
 #  rejected2fasta:
 #    run: ../Tools/seqUtil.tool.cwl
 #    in:
 #      sequences: filter/rejected
 #      fastq2fasta:
 #        default: true
 #      output:
 #        source: jobid
 #        valueFrom: $(self).100.preprocess.removed.fasta
 #
 #    out: [file]
      