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
    
  pipeline_options:
    type: 
      name: pipeline_options_record
      type: record
      fields:
        - name: merging
          doc: params for mate pair merging
          type:
            name: merging_record
            type: record
            fields:
              - name: fastq_allowmergestagger
                type: boolean?
                doc: Allow merging of staggered reads
              - name: fastq_ascii 
                type: int?
                doc:  FASTQ input quality score ASCII base char (33)
              - name: fastq_maxdiffs 
                type: int?
                doc: maximum number of different bases in overlap (5)
              - name: fastq_maxee 
                type: float?  #REAL
                doc: maximum expected error value for merged sequence
              - name: fastq_maxmergelen 
                type: int?
                doc: maximum length of entire merged sequence
              - name: fastq_maxns 
                type: int?
                doc: maximum number of N's
              - name: fastq_minlen
                type: int?
                doc: minimum input read length after truncation (1)
              - name: fastq_minmergelen
                type: int?
                doc: minimum length of entire merged sequence
              - name: fastq_minovlen   
                type: int?
                doc: minimum length of overlap between reads (16)
              - name: fastq_nostagger
                type: boolean?
                doc: disallow merging of staggered reads (default)
              - name: fastq_qmax 
                type: int?
                doc: maximum base quality value for FASTQ input (41)
              - name: fastq_qmaxout 
                type: int?
                doc:  maximum base quality value for FASTQ output (41)
              - name: fastq_qmin 
                type: int?
                doc: minimum base quality value for FASTQ input (0)
              - name: fastq_qminout 
                type: int?
                doc: minimum base quality value for FASTQ output (0)
              - name: fastq_truncqual 
                type: int?
                doc: base quality value for truncation
        - name: primer_trimming
          doc: params for mate pair merging
          type:
            name: primer_trimming_record
            type: record
            fields:
              - name: error
                type: float?
                doc: cutadapt error rate  
        - name: filter_reads
          doc: params for read filtering
          type:
            name: filter_reads_record 
            type: record
            fields:
              - name: max_expected_error
                type: float?
        - name: dereplication
          doc: dereplication options
          type:
            type: record
            name: dereplication_params
            fields:
              - name: maxuniquesize
                type: int?
                doc: maximum abundance for output from dereplication
              - name: minuniquesize
                type: int?
                doc: minimum abundance for output from dereplication
              - name: sizein
                type: boolean?
                doc: propagate abundance annotation from input
              - name: strand
                type: string?
                  # type: enum?
#                   name: strand_values
#                   symbols:
#                     - plus
#                     - both
                doc: dereplicate plus or both strands (plus)
        - name: clustering
          doc: cluster options
          type:
            type: record
            name: cluster_params
            fields:
              - name: percent_identity
                type: float?
        - name: read_mapping
          doc:  map reads to cluster
          type:
            type: record
            name: map_reads_params
            fields:
              - name: percent_identity
                type: float?   
              - name: maxaccepts
                type: int?
              - name: maxrejects
                type: int?  
        - name: classify
          doc: classification options
          type:
            type: record
            name: classification_params
            fields:
              - name: cutoff
                type: int?   

    
    

outputs:
  # database:
  #   type: File
  #   outputSource: prep/processed
  raw:
    type: Any
    outputSource: decompress/mate_pair_decompressed
  merged:
    type: File[]
    outputSource: [merging/error , merging/info ,  merging/fastq , merging/logged , merging/tabbed, merging/aligned , merging/fastq_notmerged_fwd , merging/fastq_notmerged_rev]
  noPHIX:
    type: File
    outputSource: PHIX/unaligned
  noPrimer:
    type: File[]
    outputSource: [removePrimer/processed , removeForwardPrimer/processed , removeReversePrimer/processed]
  filtered:
    type: File
    outputSource: filter/filtered_fastq  
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
    outputSource: [relabel/modified, relabel/error]
  mappedReads:
    type: File[]
    outputSource: [mapReads/uclust , mapReads/matched_sequences]
  mappedReadsTest:
    type: File[]?
    outputSource: [mapReads_primer_test/uclust , mapReads_primer_test/matched_sequences]  
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
 
  decompress:
    label: Uncompress
    doc: Stage 0010:create tap input files, uncompress gzipped fastq input files and reaname them
    run: ../Workflows/decompress_mate_pair.workflow.cwl
    in:
      mate_pair: mate_pair
    out: [mate_pair_decompressed]

  merging:
    label: merge PE reads
    doc: Stage 0050 Mate pair merging
    run: ../Tools/vsearch/Paired-end_reads_merging.vsearch.cwl
    
    # missing -fastq_maxdiffpct 10 
    # missing -report 1_merged.report.txt
    
    in:
      fastq_mergepairs:
        source: decompress/mate_pair_decompressed
        valueFrom: $(self.forward)
      reverse: 
        source: decompress/mate_pair_decompressed    
        valueFrom: $(self.reverse)
      fastq_maxdiffs:
        source: pipeline_options
        default: 30  # not applied  
        valueFrom: | 
            ${ 
               if (self.merging.fastq_maxdiffs) {
                 return self.merging.fastq_maxdiffs
               } else {
                 return 30
               } 
              }
      # not supported   
      # fastq_maxdiffpct:
      #   default: 10
      fastq_minovlen:
        default: 30
        source: pipeline_options
        valueFrom: | 
            ${ 
               if (self.merging.fastq_minovlen) {
                 return self.merging.fastq_minovlen
               } else {
                 return 30
               } 
              }
      fastq_minmergelen:
        default: 300 
        source: pipeline_options
        valueFrom: | 
            ${ 
               if (self.merging.fastq_minmergelen) {
                 return self.merging.fastq_minmergelen
               } else {
                 return 300
               } 
              }
      relabel:
        default: "@"
      log:
        default: "merged.log.log"
      # report:
      #   default: merged.report.txt
      tabbedout:
        default: merged.decisions.txt
      alnout:
        default: "merged.alnout.test" 
      fastq_notmerged_fwd:
        default: "unmerged.forward.fastq"
      fastq_notmerged_rev:
        default: "unmerged.reverse.fastq"
              
      fastqout:
        source: decompress/mate_pair_decompressed
        valueFrom: |
            ${
              var f       = self.forward.basename ;
              var prefix  = f.replace( /[\.|_]R1.*$/ , '');
              return prefix + ".tap.0050.fastq" ;
            }

    out: [aligned, error, fastq , info, logged , tabbed, reported , fastq_notmerged_fwd , fastq_notmerged_rev]
    
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
       source: pipeline_options
       default: "0.06"
       valueFrom: | 
           ${ 
              if (self.primer_trimming.error) {
                return self.primer_trimming.error
              } else {
                return 0.06
              } 
             }

     output:
       source: PHIX/unaligned
       valueFrom:  $(self.basename.split(".")[0]).tap.0100.$(self.nameext.split(".").pop())
    out: [processed]

  removeForwardPrimer:
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
     # a:
#        source: primer
#        valueFrom: $(self.reverse + '$')
     trimmed-only:
       default: true
     error:
       source: pipeline_options
       default: "0.06"
       valueFrom: | 
           ${ 
              if (self.primer_trimming.error) {
                return self.primer_trimming.error
              } else {
                return 0.06
              } 
             }

     output:
       source: PHIX/unaligned
       valueFrom:  $(self.basename.split(".")[0]).tap.0101.$(self.nameext.split(".").pop())
    out: [processed]
    
  removeReversePrimer:
    label: Remove primer (cutadapt)
    doc: Stage 0100:\ target specific primer removal using cutadpt
    run: ../Tools/cutadapt.tool.cwl
    in:
     sequences: removeForwardPrimer/processed
     format:
       source: removeForwardPrimer/processed
       valueFrom: $(self.nameext.split(".").pop())
     # g:
#          source: primer
#          valueFrom: ^$(self.forward)
     a:
       source: primer
       valueFrom: $(self.reverse + '$')
     trimmed-only:
       default: true
     error:
       source: pipeline_options
       default: "0.06"
       valueFrom: | 
           ${ 
              if (self.primer_trimming.error) {
                return self.primer_trimming.error
              } else {
                return 0.06
              } 
             }

     output:
       source: removeForwardPrimer/processed
       valueFrom:  $(self.basename.split(".")[0]).tap.0102.$(self.nameext.split(".").pop())
    out: [processed]
    
  convert2fasta:
    label: format conversion
    doc: Create fasta from fastq for mapping step
    run: ../Tools/seqUtil.tool.cwl
    in:
      sequences: removeReversePrimer/processed
      output:
        source: removeReversePrimer/processed
        valueFrom:  $(self.basename.split(".")[0]).tap.0102.fasta  
      fastq2fasta: 
        default: true        
    out: [file]      
    
  filter:
    label: Filter reads
    doc: Stage 0150:\ filter reads by maximum expected error
    run: ../Tools/vsearch/Filtering.vsearch.cwl
    in:
      fastq_maxee:
        source: pipeline_options
        default: 1
        valueFrom: | 
            ${ 
               if (self.filter_reads.max_expected_error) {
                 return self.filter_reads.max_expected_error
               } else {
                 return 1
               } 
              }
      fastq_filter: removePrimer/processed
      fastqout:
        source: removePrimer/processed
        valueFrom: $(self.basename.split(".")[0]).tap.0150.fastq
    out: [filtered_fastq]

  dereplicate:
    label: Dereplicate (vsearch)
    doc: Stage 0200:\ dereplicating exactly identical reads
    run: ../Tools/vsearch/Dereplication_and_rereplication.vsearch.cwl
    in:
      relabel: 
        default: Uniq
      sizeout:
        default: true
      # maxuniquesize:
#         default: 2
      derep_fulllength: filter/filtered_fastq
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
        # seems to have no effect
        default: true
      sizeout:
        default: true
      percent_identity:
        source: pipeline_options
        default: 0.97
        valueFrom: |
            ${ 
               if (self.clustering.percent_identity) {
                 return self.clustering.percent_identity
               } else {
                 return 0.97
               } 
              }
      cluster_size: dereplicate/fasta
        # cluster sequences after sorting by abundance        
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
    run: ../Tools/metaxa2_x.tool.cwl
    in:
      profile:
        valueFrom: $(['a','b'])
      complement:
        default: F
      input: cluster/centroidsFile
      prefix:
        source: cluster/centroidsFile
        valueFrom: $(self.basename.split(".")[0]).tap.0400
        default: 16s.ribosomal.feature.fasta
    out: [results,fasta]

  relabel:
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
              return self.basename.replace(/\.?tap.*/ , "") + ".tap.0401.fasta" ;
            }
    out: [modified,error]
#  #
#  #  renameFile:
#  #    label: none
#  #    doc: Change filename
#  #    run: ../Tools/mv/tool.cwl
#
  mapReads_primer_test:
    label: Map reads (vsearch)
    doc: Stage 0500:\ map cleaned reads against centroid sequences
    run: ../Tools/vsearch/Searching.vsearch.cwl
    in:
      strand:
        default: plus
      reject_lower:
        default: 0.97
        source: pipeline_options
        valueFrom: |
            ${ 
               if (self.read_mapping.percent_identity) {
                 return self.read_mapping.percent_identity
               } else {
                 return 0.97
               } 
              }
      maxaccepts:
        valueFrom: ${ return 0 ; }
      top_hits_only:
        valueFrom: ${ return true ; }
      maxrejects:
        valueFrom: ${ return 0 ; }
      usearch_global: cluster/centroidsFile
      db: relabel/modified
      uc:
        source: extractFeatures/fasta
        valueFrom: $(self.basename.split(".")[0]).tap.0501.uc
      matched:
        source: extractFeatures/fasta
        valueFrom: $(self.basename.split(".")[0]).tap.0501.fasta
    out: [uclust , matched_sequences]
    
    
  mapReads:
    label: Map reads (vsearch)
    doc: Stage 0500:\ map cleaned reads against centroid sequences
    run: ../Tools/vsearch/Searching.vsearch.cwl
    in:
      strand:
        default: plus
      reject_lower:
        default: 0.97
        source: pipeline_options
        valueFrom: |
            ${
               if (self.read_mapping.percent_identity) {
                 return self.read_mapping.percent_identity
               } else {
                 return 0.97
               }
              }
      maxaccepts:
        valueFrom: ${ return 0 ; }
      top_hits_only:
        valueFrom: ${ return true ; }
      maxrejects:
        valueFrom: ${ return 0 ; }
      usearch_global: convert2fasta/file
      db: relabel/modified
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
    
    
 
      
