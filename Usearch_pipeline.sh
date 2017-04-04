usearch -fastq_mergepairs R1.fastq -relabel @ -fastqout merged.fq

usearch -fastq_filter merged.fq -fastq_maxee 1.0 -relabel Filt -fastaout filtered.fa

usearch -fastx_uniques filtered.fa -relabel Uniq -sizeout -fastaout uniques.fa

usearch -cluster_otus uniques.fa -minsize 2 -otus otus.fa -relabel Otu

usearch -usearch_global merged.fq -db otus.fa -strand plus -id 0.97 \
  -otutabout otutab.txt -biomout otutab.json