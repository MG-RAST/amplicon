#!/bin/bash

# move to fix 6 ranks classification scheme
# silva processing
# remove environmental, uncultured
# extract fixed length
# no junk from current Silva


# download files from silva (https://www.arb-silva.de/no_cache/download/archive/current/Exports/, e.g. SILVA_128_SSURef_tax_silva_trunc.fasta.gz and SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta.gz) and unpack

for a in *fasta; do unwrap.pl -o $a.new $a;done && rename .new "" *new # unwrap file
for a in *fasta; do gawk '/^>/{print;next}{gsub("U","T",$1);print $1}' $a > $a.new; done && rename .new "" *new # replace U by T
for a in *fasta; do cat $a | grep -A1 -e " Bacteria;" -e " Archaea;" | grep -v "^--$" > `basename $a fasta`prok.fasta; done # extract bacteria and archaea
for a in *prok.fasta; do cat $a | gawk '/^[^>]/{print;next}{print $1}' > `basename $a fasta`acc.fasta; done # generate fasta with IDs only
cat SILVA_128_SSURef_tax_silva_trunc.prok.fasta | grep ">" | gsed 's/^>//;s/ Bacteria;/;Bacteria;/;s/ Archaea;/;Archaea;/' | gsed 's/ /_/g' | gsed 's/,/./g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap # generate taxonomy swap file
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{print $1 "\t" $1 ";tax=d:" $2}' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.domain # get swap IDs and domain
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{$NF="";print "p:" $3}' | gawk 'IGNORECASE=1{if ($1!~"uncultured") print $1; else print ""}' | gawk 'IGNORECASE=1{if ($1!~"unknown") print $1; else print ""}' | gsed 's/^p:$//;s/'\''//g;s/\[//g;s/\]//g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.phylum # clean up phylum
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{$NF="";print "c:" $4}' | gawk 'IGNORECASE=1{if ($1!~"uncultured") print $1; else print ""}' | gawk 'IGNORECASE=1{if ($1!~"unknown") print $1; else print ""}' | gsed 's/^c:$//;s/'\''//g;s/\[//g;s/\]//g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.class # clean up class
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{$NF="";print "o:" $5}' | gawk 'IGNORECASE=1{if ($1!~"uncultured") print $1; else print ""}' | gawk 'IGNORECASE=1{if ($1!~"unknown") print $1; else print ""}' | gsed 's/^o:$//;s/'\''//g;s/\[//g;s/\]//g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.order # clean up order
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{$NF="";print "f:" $6}' | gawk 'IGNORECASE=1{if ($1!~"uncultured") print $1; else print ""}' | gawk 'IGNORECASE=1{if ($1!~"unknown") print $1; else print ""}' | gsed 's/^f:$//;s/'\''//g;s/\[//g;s/\]//g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.family # clean up family
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{$NF="";print "g:" $7}' | gawk 'IGNORECASE=1{if ($1!~"uncultured") print $1; else print ""}' | gawk 'IGNORECASE=1{if ($1!~"unknown") print $1; else print ""}' | gawk '{if ($1!~"marine_group") print $1; else print ""}' | gsed 's/^g:$//;s/'\''//g;s/\[//g;s/\]//g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.genus # clean up genus
cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap | gawk -F ";" '{print "s:" $NF}' | gawk -F "_" '{if ($1~"Candidatus") print $1 "_" $2 "_" $3; else print $1 "_" $2}' \
 | gawk '{if ($1!~"^s:a") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:b") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:c") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:d") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:e") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:f") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:g") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:h") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:i") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:j") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:k") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:l") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:m") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:n") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:o") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:p") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:q") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:r") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:s") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:t") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:u") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:v") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:w") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:x") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:y") print $1; else print ""}' \
 | gawk '{if ($1!~"^s:z") print $1; else print ""}' \
 | gawk '{if ($1!~"uncultured") print $1; else print ""}' \
 | gawk '{if ($1!~"uncultivated") print $1; else print ""}' \
 | gawk '{if ($1!~"unidentified") print $1; else print ""}' \
 | gawk '{if ($1!~"unknown") print $1; else print ""}' \
 | gawk '{if ($1!~"environmental") print $1; else print ""}' \
 | gawk '{if ($1!~"_marine") print $1; else print ""}' \
 | gawk '{if ($1!~"_soil") print $1; else print ""}' \
 | gawk '{if ($1!~"_filamentous") print $1; else print ""}' \
 | gawk '{if ($1!~"_enrichment") print $1; else print ""}' \
 | gawk '{if ($1!~"_endosymbiont") print $1; else print ""}' \
 | gawk '{if ($1!~"_sp.") print $1; else print ""}' \
 | gawk '{if ($1!~"_cf.") print $1; else print ""}' \
 | gawk '{if ($1!~"_str.") print $1; else print ""}' \
 | gawk '{if ($1!~"_genomosp.") print $1; else print ""}' \
 | gawk '{if ($1!~"_metagenome") print $1; else print ""}' \
 | gawk '{if ($1!~"_clone") print $1; else print ""}' \
 | gawk '{if ($1!~"_gut$") print $1; else print ""}' \
 | gawk '{if ($1!~"_oral$") print $1; else print ""}' \
 | gawk '{if ($1!~"_bacterium$") print $1; else print ""}'  \
 | gawk '{if ($1!~"_archaeon$") print $1; else print ""}' \
 | gawk '{if ($1!~"_proteobacterium$") print $1; else print ""}'  \
 | gawk '{if ($1!~"_phylum$") print $1; else print ""}'  \
 | gawk '{if ($1!~"_$") print $1; else print ""}' \
 | gsed 's/'\''//g;s/\[//g;s/\]//g' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.species  # clean up species
paste -d, SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.domain SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.phylum SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.class SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.order SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.family SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.genus SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.species > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean
gsed 's/,,*/,/g;s/$/;/;s/,;$/;/' SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean.new && rename .new "" *new
#cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean | gawk -F "g:Candidatus_Phytoplasma," '{print $1 "g:Candidatus_Phytoplasma;"}' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean.new && rename .new "" *new
#cat SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean | gawk -F "Chloroplast," '{print $1 "Chloroplast;"}' | gawk -F "Mitochondria," '{print $1 "Mitochondria;"}' > SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean.new && rename .new "" *new
swapnames.pl -f -i SILVA_128_SSURef_tax_silva_trunc.prok.acc.fasta -l SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean -o SILVA_128_SSURef_tax_silva_trunc.prok.sintax.fasta
swapnames.pl -f -i SILVA_128_SSURef_NR99_tax_silva_trunc.prok.acc.fasta -l SILVA_128_SSURef_tax_silva_trunc.prok.sintax.swap.clean -o SILVA_128_SSURef_NR99_tax_silva_trunc.prok.sintax.fasta
usearch -tax_stats SILVA_128_SSURef_tax_silva_trunc.prok.sintax.fasta -log SILVA_128_SSURef_tax_silva_trunc.prok.sintax.stats.txt
usearch -tax_stats SILVA_128_SSURef_NR99_tax_silva_trunc.prok.sintax.fasta -log SILVA_128_SSURef_NR99_tax_silva_trunc.prok.sintax.stats.txt