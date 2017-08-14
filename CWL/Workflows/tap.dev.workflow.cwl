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
  unite:
    type: File
    format: 
      - fasta
    
  silva:
    type: File
    format: 
      - fasta 
   
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
  primer:
    doc: Euk and Prokaryote primer
    type:
      type: record
      name: primer
      fields:
        - name: eukaryote
          doc: Eukaryote primer pair
          type:
            type: record
            name: direction
            fields:
              - name: forward
                type: string
              - name: reverse
                type: string
        - name: prokaryote
          doc: Prokaryote primer pair
          type:
            name: direction
            type: record
            fields:
              - name: forward
                type: string
              - name: reverse
                type: string
  indexDir:
    type: Directory?
    doc: Directory containing bowtie indices. Must containe index files with 'genome' prefix.
    default: 
      class: Directory
      path: /usr/local/share/db/bowtie2  
    
 

outputs:
  tmp:
    type: File[]
    outputSource: [prep/classified_prok , prep/classified_euk]
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
    outputSource: [removePrimer/trimmed_sequences]        
  
steps:
 
  # Conditional - only run if step output does not exist
  prep:  
    label: STAGE:0001    
    doc: prepare UNITE and SIVLA fasta database files and taxonomy tables
    run: ../Workflows/create_primer.workflow.cwl
    in: 
      euka_forward: 
        source: primer
        valueFrom: $(self.eukaryote.forward)
      euka_reverse: 
        source: primer
        valueFrom: $(self.eukaryote.reverse)
      euka_sequences: unite
        # source: unite
        # default: /usr/local/share/db/UNITE*.fasta
      prok_forward:
        default: "CCTAYGGGDBGCWSCAG"
      prok_reverse:
        default: "ATTAGADACCCBNGTAGTCC"
      prok_sequences:
        source: silva
        default: /usr/local/share/db/SILVA*.fasta
      
    out: [classified_prok , classified_euk]
  
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
    run: ../Workflows/remove_euk_prok_primer.workflow.cwl
    in:
      sequences: PHIX/unaligned
      primer: primer
      error: 
        default: "0.06"

    out: [trimmed_sequences]
  
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
      derep_fulllength: removePrimer/trimmed_sequences
      output:
        source: removePrimer/trimmed_sequences
        valueFrom: $(self.basename.split(".")[0]).tap.0200.fasta
    out: [fasta]
        
      
              
           

  
 #
 #
 #  barcode:
 #    label: STAGE:0055
 #    doc: barcode label into fastq header
 #

 #
 #
 #  removePrimer:
 #    label: STAGE:0100
 #    doc: target specific primer removal using cutadpt
 #    run: ../Tool/vsearch.tool.cwl
 #    # cmd="cutadapt ${EUKARYOTE_PRIMER_PAIR}  ${CUTADAPT_PARAM} ${file} -o ${out_file} "
 #    #  CUTADAPT_PARAM="-e 0.06 -f fasta "
 #    in:
 #      sequences: removePHIX/merged
 #      g:
 #        source: primer.eukaryote.forward
 #        valueFrom: |
 #          ...
 #      a:
 #        source:  primer.eukaryote.reverse
 #      error: "0.06"
 #      format: "fasta"
 #      output:
 #        source:
 #    out: [outputs]
 #
 #  removeIdentical:
 #    label: STAGE:0200
 #    doc: dereplicating exactly identical reads
 #
 #  clusteringOTU:
 #    label: STAGE:0300
 #    doc: OTUclustering
 #
 #  extractFeatures:
 #    label: STAGE:0400
 #    doc: |
 #        16s ribosomal feature extraction via Metaxa [PROK]
 #        ITS feature extraction via ITSx [EUK]
 #
 #  mapReads:
 #    label: STAGE:0500
 #    doc: |
 #        map cleaned reads against centroid sequences (vsearch -userarch_global) [PROK]
 #        map cleaned reads against centroid sequences (vsearch -fastx_getseqs) [EUK]
 #
 #  reformat:
 #    label: STAGE:0600
 #    doc: format conversion to .otu files
 #
 #  classify:
 #    label: STAGE:0700
 #    doc: classification using mothur
  
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
      