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
      fields:
        # - name: eukaryote
        #   doc: Eukaryote primer pair
        #   type:
        #     type: record
        #     fields:
        #       - name: forward
        #         type: string
        #       - name: reverse
        #         type: string
        - name: prokaryote
          doc: Prokaryote primer pair
          type:
            type: record
            fields:
              - name: forward
                type: string
              - name: reverse
                type: string
    
      
 
  
  
    

# outputs:
#   classified:
#     type: File
#     outputSource: classify/classified
 

outputs:
  tmp:
    type: File[]
    outputSource: [prep/classified_prok , prep/classified_euk] 
  
steps:
  
  prep:  
    label: STAGE:0001    
    doc: prepare UNITE and SIVLA fasta database files and taxonomy tables
    run: create_primer.workflow.cwl
    in: 
      euka_forward: 
        source: primer
        valueFrom: $(self.eukaryote.forward)
      euka_reverse: 
        source: primer
        valueFrom: $(self.primer.eukaryote.reverse)
      euka_sequences:
        default: /usr/local/share/db/UNITE*.fasta
      prok_forward: 
        default: "CCTAYGGGDBGCWSCAG"
      prok_reverse: 
        default: "ATTAGADACCCBNGTAGTCC"  
      prok_sequences:
        default: /usr/local/share/db/SILVA*.fasta 
      
    out: [classified_prok , classified_euk]
  
  # rename_and_uncompress:
 #    label: STAGE:0010
 #    doc: create tap input files, uncompress gzipped fastq input files and reaname them
 #    run: ../Tools/create_tap_input_files.tool.cwl
 #    in:
 #      sequences: File
 #    out: [uncompressed]
 #
 #
 #
 #  merging:
 #    label: STAGE:0050
 #    doc: Mate pair merging
 #    run: ../Tool/merge_mate_pairs.tool.cwl
 #    in:
 #      mate_pair: mate_pair
 #      stage:
 #        default: "0050"
 #      fastqout:
 #        source: mate_pair
 #        valueFrom: |
 #            $ {
 #              f = self.forward.basename
 #              prefix = f.replace( /\.R1.*$/ , '');
 #              return prefix + ".tap.0050.fastq" ;
 #            }
 #    out: [merged]
 #
 #
 #
 #  barcode:
 #    label: STAGE:0055
 #    doc: barcode label into fastq header
 #
 #  removePHIX :
 #    label: STAGE:0060
 #    doc: PHIX removal using bowtie2 with Illumina RTA genome and Illumina built indeces
 #    run: ../Tool/remove_PHIX.tool.cwl
 #    in:
 #      fastqin: merging/merged
 #      unaligned_out: unaligned.fasta
 #      mate_pair: mate_pair
 #      stage:
 #        default: "0050"
 #      fastqout:
 #        source: mate_pair
 #
 #    out: [merged]
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
      