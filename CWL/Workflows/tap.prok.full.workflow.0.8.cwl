cwlVersion: v1.0
class: Workflow

label: TAP
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

  primer:
    doc: Euk and Prokaryote primer
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
    doc: Directory containing bowtie indices. Must containe index files with 'genome' prefix.
  reference_database:
    doc: Reference database, e.g. UNITE or SILVA
    type: File
    format:
      - fasta
  reference_taxonomy:
    doc: Taxonomy mapping from accession to tax string
    type: File

outputs:
  database:
    type: File
    outputSource: prep/processed
  raw:
    type: Any
    outputSource: decompress/mate_pair_decompressed
  merged:
    type: File
    outputSource: merging/fastq
  noPHIX:
    type: File
    outputSource: PHIX/unaligned
  noPrimer:
    type: File
    outputSource: removePrimer/processed
  dereplicated:
    type: File
    outputSource: dereplicate/fasta
  clustered:
    type: File
    outputSource: cluster/centroidsFile
  features:
    type: File[]
    outputSource: [extractFeatures/fasta, extractFeatures/results]   
  relabeled:
    type: File[] 
    outputSource: [removeCommentsAddBarcodeLabel/modified, removeCommentsAddBarcodeLabel/error] 
  mappedReads:
    type: File[]
    outputSource: [mapReads/uclust , mapReads/matched_sequences]  
  OTUs:
    type: File
    outputSource: convertToOTU/otu
  RegexpTool:
    type: File[]
    outputSource: [removeCommentsAddBarcodeLabel/error , removeCommentsAddBarcodeLabel/modified]  
  Classified:
    type: File[]
    outputSource: [ classification/output , classification/error ,classification/log , classification/summary , classification/taxonomy ]
  
  
steps:
 
  # Conditional - only run if step output does not exist
  prep:  
    label: Trimm DB (cutadapt)  
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
    label: Uncompress
    doc: Stage 0010:create tap input files, uncompress gzipped fastq input files and reaname them
    run: ../Workflows/decompress_mate_pair.workflow.cwl
    in:
      mate_pair: mate_pair
    out: [mate_pair_decompressed]
    
 


  merging:
    label: Merge mate pairs (vsearch)
    doc: Stage 0050 Mate pair merging
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
     label: PHIX (bowtie2)
     doc: Stage 0060:\ PHIX removal using bowtie2 with Illumina RTA genome and Illumina built indeces
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
    label: Remove primer (cutadapt)
    doc: Stage 0100:\ target specific primer removal using cutadpt
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
    label: Dereplicate (vsearch)
    doc: Stage 0200:\ dereplicating exactly identical reads 
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
    label: Cluster (vsearch)
    doc: Stage 0300:\ OTUclustering via vsearch
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
    label: Features (metaxa2_x)
    doc: |
       Stage 0400:\ 16s ribosomal feature extraction via Metaxa [PROK]
       # ITS feature extraction via ITSx [EUK]
    run: ../Tools/metaxa2_x.tool.cwl
    in:
      profile:
        valueFrom: $(['a','b'])
      complement:
        default: F
      input: cluster/centroidsFile
      prefix:
        source: cluster/centroidsFile
        valueFrom: $(self.basename.split(".")[0]).tap.0400.fasta   
        default: 16s.ribosomal.feature.fasta
    out: [results,fasta]

  removeCommentsAddBarcodeLabel:
    label: Relabel
    doc: regexp tool
    run: ../Tools/regexp.tool.cwl
    in:
      regexp:
        default: 's/\(^.*\)|.*/\1barcodelabel=test;/g'
        source: extractFeatures/fasta
        valueFrom: |
            ${
               var name   = self.basename.replace(/\.?tap.*/ , "") ;
               var regexp = 's/\u005c(^.*\u005c)|.*/\u005c\u0031' + 'barcodelabel=' + name + ';/g' ;
               return regexp  ;
              }
      input: extractFeatures/fasta
      output:
        default: test.output.txt
        source: extractFeatures/fasta
        valueFrom: |
            ${
              return self.basename.replace(/\.?tap.*/ , "") + ".tap.401.fasta" ;
            }
    out: [modified,error]     
 #
 #  renameFile:
 #    label: none
 #    doc: Change filename
 #    run: ../Tools/mv/tool.cwl
 
  mapReads:
    label: Map reads (vsearch)
    doc: Stage 0500:\ map cleaned reads against centroid sequences
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
        source: extractFeatures/fasta 
        valueFrom: $(self.basename.split(".")[0]).tap.0500.uc
      matched:
        source: extractFeatures/fasta 
        valueFrom: $(self.basename.split(".")[0]).tap.0500.fasta
    out: [uclust , matched_sequences]
    
  convertToOTU:
    label: 
    doc: Stage 0600:\ convert .uc to .otu files
    run: ../Tools/uc2otu.tool.cwl
    in:
      input: mapReads/uclust
      output:
        source: mapReads/uclust
        valueFrom: $(self.basename.split(".")[0]).tap.0600.otu
    out: [otu]
    
    
  classification:
    label: Classify cluster (mothur)
    doc: Stage 0700:\ classify centroid sequences 
    run: ../Tools/mothur/classification.mothur.tool.cwl
    in: 
      fasta: cluster/centroidsFile
      reference_database: reference_database
      taxonomy_file: reference_taxonomy
    out: [ output , error ,log , summary , taxonomy ]
    
    
 
      
