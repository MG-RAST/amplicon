wget http://download.microbiome.ch/silva_v128NR.zip
wget http://download.microbiome.ch/unite.v72_dynamic.zip
unzip silva_v128NR.zip
unzip unite.v72_dynamic.zip

# Get Phix
wget ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/PhiX/Illumina/RTA/PhiX_Illumina_RTA.tar.gz
tar xf PhiX*Illumina*.tar.gz 
mv PhiX/Illumina/RTA/Sequence/Bowtie2Index/* Phix/  
rm -rf Phix/Illumina

