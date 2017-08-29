wget http://download.microbiome.ch/silva_v128NR.zip
wget http://download.microbiome.ch/unite.v72_dynamic.zip
unzip silva_v128NR.zip
unzip unite.v72_dynamic.zip

# Get Phix
wget ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/PhiX/Illumina/RTA/PhiX_Illumina_RTA.tar.gz
tar xf PhiX*Illumina*.tar.gz 
cp PhiX/Illumina/RTA/Sequence/Bowtie2Index/* Phix/  
rm -rf Phix/Illumina


# Silva version
# wget  --no-check-certificate https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta.gz
# gunzip SILVA*.gz


# Unite version
# wget --no-check-certificate https://unite.ut.ee/sh_files/sh_mothur_release_s_20.11.2016.zip
# unzip sh_mothur_release*.zip