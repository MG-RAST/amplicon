unite:
  class: File
  path: ../Data/Inputs/sequences.all.fasta
  # /usr/local/share/db/UNITE*.fasta
  format: fasta
silva:
  class: File
  path: ../Data/Inputs/sequences.all.fasta
  # /usr/local/share/db/SILVA*.fasta 
  format: fasta  
files:
  - forward: ../Data/Inputs/samples_R1.fastq.gz
    reverse: ../Data/Inputs/samples_R2.fastq.gz 
  - forward: ../Data/Inputs/samples_R1.fastq.gz
    reverse: ../Data/Inputs/samples_R2.fastq.gz
  
primer: 
  eukaryote:
    forward: CAHCGATGAAGAACGYRG
    reverse: GCATATCAATAAGCGSAGGA
  prokaryote:
    forward: CCTAYGGGDBGCWSCAG
    reverse: ATTAGADACCCBNGTAGTCC    
