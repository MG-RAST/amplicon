cwlVersion: v1.0
class: Workflow

label: TAP
doc:  

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../Tools/ITSx-profile.yaml

inputs:
  # unite:
  #   type: File
  #   format:
  #     - fasta
  #
  # silva:
  #   type: File
  #   format:
  #     - fasta
   
  mate_pair: 
    doc: List of forward and reverse compressed fastq file records
    type:
      type: record
      fields:
        - name: forward
          doc: R1.fastq.gz 
          type: File
          # format: fastq.gz
        - name: reverse
          doc: R2.fastq.gz
          type: File
          # format: fastq.gz
  ion_torrent: 
    type: boolean
    default: False
  tidy_up: 
    type: boolean
    default: False
  # primer_euk:
#     type: string
#     default: -g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$
#     doc: |
#       the Eukaryote primer pair e.g. \"-g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$ \"
#       using cutadapt syntax, primers have to be anchored with ^ and $
#   primer_prok:
#     type: string
#     default: -g ^CCTAYGGGDBGCWSCAG -a ATTAGADACCCBNGTAGTCC$
#     doc: |
#       the Prokaryote primer pair e.g. \"-g ^CAHCGATGAAGAACGYRG -a GCATATCAATAAGCGSAGGA$\"
#       using cutadapt syntax, primers have to be anchored with ^ and $
  primer:
    doc: Euk primer
    type:
      type: record
      # name: primer
      fields:
        - name: forward
          type: string
        - name: reverse
          type: string

  indexDir:
    type: Directory
    doc: Directory containing bowtie indices. Must contain index files with 'genome' prefix.
  reference_database:
    doc: Reference database, e.g. UNITE or SILVA
    type: File
    format:
      - fasta
  reference_taxonomy:
    doc: Taxonomy mapping from accession to tax string
    type: File
 

outputs:
  tmp:
    type: File
    outputSource: [prep/processed]
  raw:
    type: Any
    outputSource: [decompress/mate_pair_decompressed]
  merged:
    type: File
    outputSource: [merging/fastq]
  noPHIX:
    type: File
    outputSource: [PHIX/unaligned] 
  noPrimer:
    type: File
    outputSource: [removePrimer/processed]
  dereplicated:
    type: File
    outputSource: [dereplicate/fasta]
  clustered:
    type: File
    outputSource: [cluster/centroidsFile]
  features:
    type: File[]
    outputSource: [extractFeatures/full, extractFeatures/summary]   
  cleanedReads:
    type: File[]
    outputSource: [cleanReads/uclust , cleanReads/matched_sequences]  
  OTUs:
    type: File
    outputSource: [convertToOTU/otu]  
  
  RegexpTool:
    type: File[]
    outputSource: [removeCommentsAddBarcodeLabel/error , removeCommentsAddBarcodeLabel/modified]  
  
  Classified:
    type: File
    outputSource: [classification/summary]
  
steps:
 
  # Conditional - only run if step output does not exist
  prep:  
    label: STAGE:0001    
    doc: prepare prok fasta database files and taxonomy tables
    run: ../Tools/cutadapt.tool.cwl
    in: 
      sequences: 
        source: reference_database
        # doc: /usr/local/share/db/SILVA*.fasta
      format:
        source: reference_database
        valueFrom: |
          ${
             return self.format.split("/").slice(-1)[0]
            }
      g: 
        source: primer
        valueFrom: $(self.forward)
      a: 
        source: primer
        valueFrom: $(self.reverse)
      error:
        default: "0.06"
      discard-untrimmed: 
        default: true
      output: 
        source: [reference_database , primer ]
        valueFrom: $(self[0].basename).$(self[1].forward).$(self[1].reverse)  
    out: [processed]
  
  decompress:
    label: STAGE:0010
    doc: create tap input files, uncompress gzipped fastq input files and reaname them
    run: ../Workflows/decompress_mate_pair.workflow.cwl
    in:
      mate_pair: mate_pair
    out: [mate_pair_decompressed]
    
 


  merging:
    label: STAGE:0050
    doc: Mate pair merging
    run: ../Tools/vsearch.tool.cwl
    in:
      # mate_pair: mate_pair
 #      stage:
 #        default: "0050"
      fastqout:
        source: decompress/mate_pair_decompressed
        valueFrom: |
            ${
              var f       = self.forward.basename ;
              var prefix  = f.replace( /[\.|_]R1.*$/ , '');
              return prefix + ".tap.0050.fastq" ;
            }
      fastq_mergepairs:
        source: decompress/mate_pair_decompressed
        valueFrom: $(self.forward)
      reverse: 
        source: decompress/mate_pair_decompressed    
        valueFrom: $(self.reverse)    
      # threads:
      #   valueFrom: $(runtime.cores) 
    out: [fastq]
    
  PHIX:
     label: STAGE:0060
     doc: PHIX removal using bowtie2 with Illumina RTA genome and Illumina built indeces
     run: ../Tools/bowtie2.tool.cwl
     in:
       fastqin: merging/fastq
       unaligned_out: 
         source: merging/fastq 
         valueFrom:  $(self.basename.split(".")[0]).tap.0060.fastq
                     # self.split("/").slice(-1)[0]
       index: 
         default: "genome"             
       indexDir: indexDir
         
     out: [unaligned]
     
  removePrimer:
    label: STAGE:0100
    doc: target specific primer removal using cutadpt
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: PHIX/unaligned
     format:
       source: PHIX/unaligned
       valueFrom: $(self.nameext.split(".").pop())
     g: 
       source: primer
       valueFrom: ^$(self.forward)
     a:
       source: primer
       valueFrom: $(self.reverse + '$') 
     trimmed-only: 
       default: true
     error: 
       default: "0.06"      
   
     output: 
       source: PHIX/unaligned
       valueFrom:  $(self.basename.split(".")[0]).tap.0100.$(self.nameext.split(".").pop())
    out: [processed]
  
  dereplicate:
    label: STAGE:0200
    doc: dereplicating exactly identical reads 
    run: ../Tools/vsearch/Dereplication_and_rereplication.vsearch.cwl
    in:
      # VSEARCH_GLOBAL="--threads ${THREADS}"
      # VSEARCH_DEREP_OPTIONS="${VSEARCH_GLOBAL} -sizeout -minuniquesize 2"
      # cmd="vsearch ${VSEARCH_DEREP_OPTIONS} \
      #      -derep_fulllength ${file} \
      #      -output ${name}.tap.${STAGE}.fasta "
      #  
      # threads: n/a
      sizeout: 
        default: true
      minuniquesize:
        default: 2
      derep_fulllength: removePrimer/processed
      output:
        source: removePrimer/processed
        valueFrom: $(self.basename.split(".")[0]).tap.0200.fasta
    out: [fasta]
    
  cluster:
    label: STAGE:0300
    doc: OTUclustering via vsearch
    run: ../Tools/vsearch/Clustering.vsearch.cwl
    in:
      sizein:
        default: true
      sizeout:
        default: true
      id: 
        default: 0.97
      cluster_size: dereplicate/fasta
      relable: 
        source: dereplicate/fasta
        valueFrom: OTU$(self.basename.charAt(0))_      
      centroids: 
        source: dereplicate/fasta
        valueFrom: $(self.basename.split(".")[0]).tap.0300.fasta   
    out: [centroidsFile]       
      
  extractFeatures:
    label: STAGE:0400
    doc: |
       ITS feature extraction via ITSx [EUK]
    run: ../Tools/ITSx.tool.cwl
  
    in:
      input: cluster/centroidsFile
      prefix:
        source: cluster/centroidsFile
        valueFrom: $(self.basename.split(".")[0]).tap.0400.fasta   
        default: 16s.ribosomal.feature.fasta
      profile:
        default: ['all']
      complement:
        default: F
      preserve:
        default: T
      only_full:
        default: T
      reset: 
        default: T        
    out: [summary,full]

  removeCommentsAddBarcodeLabel:
    label: none
    doc: regexp tool
    run: ../Tools/regexp.tool.cwl
    in:
      regexp:
        default: 's/\(^.*\)|.*/\1barcodelabel=test;/g'
        source: extractFeatures/full
        valueFrom: |
            ${
               var name   = self.basename.replace(/\.?tap.*/ , "") ;
               var regexp = 's/\u005c(^.*\u005c)|.*/\u005c\u0031' + 'barcodelabel=' + name + ';/g' ;
               return regexp  ;
              }
      input: extractFeatures/full
      output:
        default: test.output.txt
        source: extractFeatures/full
        valueFrom: |
            ${
              return self.basename.replace(/\.?tap.*/ , "") + ".tap.401.fasta" ;
            }
    out: [modified,error]     
 
  cleanReads:
    label: STAGE:0500
    doc: map cleaned reads against centroid sequences
    run: ../Tools/vsearch/Searching.vsearch.cwl
    in:
      strand: 
        default: plus 
      reject_lower: 
        valueFrom: ${ return 0.97 ; } 
      maxaccepts: 
        valueFrom: ${ return 0 ; } 
      top_hits_only:
        valueFrom: ${ return true ; }
      maxrejects: 
        valueFrom: ${ return 0 ; }
      usearch_global: cluster/centroidsFile 
      # db: extractFeatures/fasta
      db: removeCommentsAddBarcodeLabel/modified 
      uc:
        source: extractFeatures/full 
        valueFrom: $(self.basename.split(".")[0]).tap.0500.uc
      matched:
        source: extractFeatures/full 
        valueFrom: $(self.basename.split(".")[0]).tap.0500.fasta
    out: [uclust , matched_sequences]
    
  convertToOTU:
    label: STAGE:0600
    doc: convert .uc to .otu files
    run: ../Tools/uc2otu.tool.cwl
    in:
      input: cleanReads/uclust
      output:
        source: cleanReads/uclust
        valueFrom: $(self.basename.split(".")[0]).tap.0600.otu
    out: [otu]
    
  classification:
    label: STAGE
    doc: read classification with mothur 
    run: ../Tools/mothur/classification.mothur.tool.cwl
    in: 
      fasta: cluster/centroidsFile
      reference_database: reference_database
      taxonomy_file: reference_taxonomy
    out: [ output , error ,log , summary , taxonomy ]
          
  
    
 
      
