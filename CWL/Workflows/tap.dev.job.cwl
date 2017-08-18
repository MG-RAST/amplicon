unite:
  class: File
  path: /usr/local/share/db/UNITEv6_sh_dynamic_s.fasta
  # ../Data/Inputs/sequences.all.fasta
  # /usr/local/share/db/UNITE*.fasta
  format: edam:format_1929  # fasta
silva:
  class: File
  path: /usr/local/share/db/SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta
  # ../Data/Inputs/sequences.all.fasta
  # /usr/local/share/db/SILVA*.fasta
  format: edam:format_1929  # fasta
files:
  - forward:
      class: File
      path: ../Data/Inputs/samples_R1.fastq.gz
    reverse:
      class: File
      path: ../Data/Inputs/samples_R2.fastq.gz
  - forward:
      class: File
      path: ../Data/Inputs/samples_R1.fastq.gz
    reverse:
      class: File
      path: ../Data/Inputs/samples_R2.fastq.gz

primer: 
  eukaryote:
    forward: CAHCGATGAAGAACGYRG
    reverse: GCATATCAATAAGCGSAGGA
  prokaryote:
    forward: CCTAYGGGDBGCWSCAG
    reverse: ATTAGADACCCBNGTAGTCC    
  
mate_pair:
  forward:  
    class: File
    path: ../Data/Inputs/samples_R1.fastq.gz
    format: fastq.gz
  reverse:  
    class: File
    path: ../Data/Inputs/samples_R2.fastq.gz 
    format: fastq.gz
    
    
# euka_forward: "CAHCGATGAAGAACGYRG"
# euka_reverse: "GCATATCAATAAGCGSAGGA" 
# euka_sequences:
#   class: File
#   path: ../Data/Inputs/sequences.all.fasta
#   # /usr/local/share/db/UNITE*.fasta
#   format: fasta
# prok_forward: "CCTAYGGGDBGCWSCAG"
# prok_reverse: "ATTAGADACCCBNGTAGTCC"
# prok_sequences:
#   class: File
#   path: ../Data/Inputs/sequences.all.fasta
#   # /usr/local/share/db/SILVA*.fasta
#   format: fasta
