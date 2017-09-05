# to start the pipeline, move into the project directory with folders "1_raw", "2_QC", "3_taxonomy", "4_otu"

# unpack, rename and label fastq files
cd 1_raw
for a in *gz; do gunzip -c $a > `basename $a .gz`; done
gxargs -a rename.txt -n 2 mv

# quality filtering and OTU construction
usearch -fastq_mergepairs *R1*.fastq -fastqout 1_merged.fastq -relabel @ -fastq_maxdiffs 30 -fastq_maxdiffpct 10 -fastq_minovlen 30 -fastq_minmergelen 300 -log 1_merged.log -report 1_merged.report.txt -tabbedout 1_merged.decisions.txt -alnout 1_merged.alnout # merge PE reads
mv 1_merged* ../2_QC && rm *fastq && cd ../2_QC
usearch -filter_phix 1_merged.fastq -output 2_merged.nophix.fastq # filter phix
cutadapt -g ^CCTAYGGGDBGCWSCAG -e 0.06 -f fastq --trimmed-only -o temp 2_merged.nophix.fastq # trim forward and reverse primers
cutadapt -a ATTAGADACCCBNGTAGTCC$ -e 0.06 -f fastq --trimmed-only -o 3_merged.nophix.noprimer.fastq temp && rm temp # trim forward and reverse primers
usearch -fastq_filter 3_merged.nophix.noprimer.fastq -fastqout 4_merged.nophix.noprimer.maxee1.fastq -fastq_maxee 1 # filter reads by maximum expected error
usearch -fastx_uniques 4_merged.nophix.noprimer.maxee1.fastq -fastaout 5_merged.nophix.noprimer.maxee1.uniq.fasta -sizeout -relabel Uniq # dereplicate
usearch -cluster_otus 5_merged.nophix.noprimer.maxee1.uniq.fasta -otu_radius_pct 3 -otus 6_merged.nophix.noprimer.maxee1.uniq.otu97.min2.fasta -uparseout 6_merged.nophix.noprimer.maxee1.uniq.otu97.min2.up -relabel OTU -minsize 2 # OTU clustering
swapnames.pl -f -i 6_merged.nophix.noprimer.maxee1.uniq.otu97.min2.fasta -l swap_OTUdigit.5dig.txt -o 6_merged.nophix.noprimer.maxee1.uniq.otu97.min2.new.fasta && gsed -i 's/OTU/BOTU/' 6_merged.nophix.noprimer.maxee1.uniq.otu97.min2.new.fasta && rename .new. . * # normalize OTU labels
metaxa2_x -i 6_merged.nophix.noprimer.maxee1.uniq.otu97.min2.fasta -o 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa --complement F --cpu 4
awk -F "|" '{print $1}' 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.fasta > 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta
usearch -usearch_global 3_merged.nophix.noprimer.fastq -db 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta -strand plus -id 0.97 -maxaccepts 0 -top_hit_only -maxrejects 100 -uc 8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.uc -matched 8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.fasta -otutabout 8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.txt -mothur_shared_out 8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.shared # map sequences to verified OTUs and create OTU table

# taxonomic classification against RDP training set
cp 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta ../3_taxonomy/ && cd ../3_taxonomy/
mothur_1.34 "#classify.seqs(fasta=7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta, template=rdp_16s_v16.341F806R.fasta, taxonomy=rdp_16s_v16.341F806R.tax, cutoff=80, processors=4)" # classify against RDP with RDP classifier
rename 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.wang.taxonomy 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.taxassign.rdp.rdp * && rm *wang*
usearch -sintax 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta -db rdp_16s_v16.341F806R.sintax -tabbedout 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.taxassign.rdp.sintax -strand both -sintax_cutoff 0.8 # classify against RDP with SINTAX

# taxonomic classification against full SILVA Ref NR
mothur "#classify.seqs(fasta=7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta, template=silva_v128NR.341F816R.fasta, taxonomy=silva_v128NR.341F816R.tax, cutoff=80, processors=4)" # classify against unite with RDP classifier
rename 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.wang.taxonomy 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.taxassign.silva.rdp * && rm *wang*
usearch -sintax 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.fasta -db silva_v128NR.341F816R.sintax -tabbedout 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.taxassign.silva.sintax -strand both -sintax_cutoff 0.8 # classify against unite with SINTAX

# remove non-target groups from OTU table and taxonomy
cat 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.taxassign.silva.sintax | grep -v "Chloroplast" | grep -v "Mitochondria" | gawk '{print $1}' > nonorganelle_otus.txt
(gawk 'NR==1' ../2_QC/8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.txt;grep -f nonorganelle_otus.txt ../2_QC/8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.txt) > ../2_QC/8_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.OTU.nonorganelle.txt
grep -f nonorganelle_otus.txt 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.taxassign.silva.sintax > 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.nonorganelle.taxassign.silva.sintax
cat 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.nonorganelle.taxassign.silva.sintax | gawk '{print $1 "\t" $4}' | gsed 's/,/\t/g' | gsed '1 i\OTU\tdomain\tphylum\tclass\torder\tfamily\tgenus\tspecies' > 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.nonorganelle.taxassign.silva.sintax.path

# generate input for taxonomic network
cat 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.nonorganelle.taxassign.silva.sintax | gawk '{print $4 "\t" $1}' | gsed 's/,/\t/g' | gsort -k1 > temp1
(gawk '{print $1 "\t" $2 "\t1\t" $1 "\tunclassified\tunclassified\tunclassified\tunclassified\tunclassified\tunclassified"}' temp1;gawk '{print $2 "\t" $3 "\t2\t" $1 "\t" $2 "\tunclassified\tunclassified\tunclassified\tunclassified\tunclassified"}' temp1;gawk '{print $3 "\t" $4 "\t3\t" $1 "\t" $2 "\t" $3 "\tunclassified\tunclassified\tunclassified\tunclassified"}' temp1;gawk '{print $4 "\t" $5 "\t4\t" $1 "\t" $2 "\t" $3 "\t" $4 "\tunclassified\tunclassified\tunclassified"}' temp1;gawk '{print $5 "\t" $6 "\t5\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\tunclassified\tunclassified"}' temp1;gawk '{print $6 "\t" $7 "\t6\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\tunclassified"}' temp1;gawk '{print $7 "\t" $8 "\t7\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}' temp1) > temp2
cat temp2 | grep -v "^BOTU" | grep -v "^\t" | gawk '$2!~"BOTU"{print $0;next}{print $1 "\t" $2 "\t7\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10}' | gawk '!seen[$0]++' | gsed '1 i\source\ttarget\tweight\tdomain\tphylum\tclass\torder\tfamily\tgenus\tspecies' > 7_merged.nophix.noprimer.maxee1.uniq.otu97.min2.metaxa.extraction.clean.nonorganelle.taxassign.silva.sintax.cyto
rm temp*
