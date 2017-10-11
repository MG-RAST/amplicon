FROM debian:jessie

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  autoconf \
  automake \
  bowtie2 \
  build-essential \
  cython \
  curl \
  dh-autoreconf \
  git \
  hmmer \
  libtool \
  mafft \
  ncbi-blast+  \
  node.js \
  pcregrep \
  perl \
  python \
  python-biopython \
  python-pip \
  python-yaml \
  unzip \
  velvet \
  wget

# SILVA DB for 16s // requires primer pair specific post-processing
# full version https://www.arb-silva.de/no_cache/download/archive/current/Exports/SILVA_128_SSURef_tax_silva_trunc.fasta.gz
# RUN cd /root \
#    && wget  --no-check-certificate https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta.gz \
#    && gunzip SILVA*.gz \
#    && mkdir -p /usr/local/share/db \
#    && install -m 644 SILVA*.fasta /usr/local/share/db \
#    && rm -f SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta*
 
# # unite for ITS
# WORKDIR /root
# RUN cd /root
# RUN wget --no-check-certificate https://unite.ut.ee/sh_files/sh_mothur_release_s_20.11.2016.zip
# RUN unzip sh_mothur_release*.zip
# RUN mkdir -p /usr/local/share/db
# RUN install -m644 UNITE*dynamic* /usr/local/share/db
# RUN rm -f UNITE* sh*mothur*.zip
#    # && ( for i in /usr/local/share/db/ITSx_db/HMMs/*.hmm ; do hmmpress -f $i ; done )
 
#
# # phix DB from Illumina
# RUN cd /root \
#    && wget ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/PhiX/Illumina/RTA/PhiX_Illumina_RTA.tar.gz \
#    && tar xf PhiX*Illumina*.tar.gz \
#    && mkdir -p /usr/local/share/db/bowtie2 \
#    && install -m644 /root/PhiX/Illumina/RTA/Sequence/Bowtie2Index/*  /usr/local/share/db/bowtie2
#    # && rm -fr  PhiX*Illumina*.tar.gz /root/PhiX

RUN cd /root \
  && wget  http://spades.bioinf.spbau.ru/release3.10.1/SPAdes-3.10.1-Linux.tar.gz \
  && tar xzf SPAdes-*.tar.gz \
  && install -m755 SPAdes-*/bin/* /usr/local/bin/ \
  && mv SPAdes-*/share/* /usr/local/share/ \
  && rm -rf SPAdes-*
  
RUN cd /root \
  && wget http://microbiology.se/sw/ITSx_1.0.11.tar.gz \
  && tar xzf ITSx_*.tar.gz \
  && mkdir -p /usr/local/share/db \
  && install -m755 ITSx_*/ITSx /usr/local/bin \
  && mv ITSx_*/ITSx_db /usr/local/share/db \
  && ln -s /usr/local/share/db/ITSx_db /usr/local/bin/ITSx_db \
  && rm -rf ITSx_*.tar.gz ITSx_*

RUN cd /root \
  && wget http://microbiology.se/sw/Metaxa2_2.1.3.tar.gz \
  && tar xzf Metaxa2_*.tar.gz  \
  && cd Metaxa2_* \
  && echo -e "yes\n/usr/local/bin/\nyes\n" | ./install_metaxa2  \
  && rm -rf /root/Metaxa2_*

# install cutadapt (we do not use the debian unstable source package)
RUN pip install cutadapt 

# fastx_toolkit
RUN cd /root \
  && mkdir fastx_bin \
  && cd fastx_bin \
  && wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
  && tar xf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
  && install -m755 bin/* /usr/local/bin/  \
  && rm -rf /root/fastx_bin/
    

# install CPAN module Text::Table
RUN cd /root \
  && yes | perl -MCPAN -e "CPAN::Shell->notest(qw!install Text::Table!)"
  

# vsearch 2.4.4
RUN cd /root \
	&& wget https://github.com/torognes/vsearch/archive/v2.4.4.tar.gz \
	&& tar xzf v2*.tar.gz \
	&& cd vsearch-2* \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local/ \
	&& make \
	&& make install \
	&& make clean \
	&& cd .. \
  && rm -rf /root/vsearch-* /root/v2*.tar.gz

  
# SILVA DB for 16s // requires primer pair specific post-processing
# full version https://www.arb-silva.de/no_cache/download/archive/current/Exports/SILVA_128_SSURef_tax_silva_trunc.fasta.gz
# RUN cd /root \
#  && wget  --no-check-certificate https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta.gz \
#  && gunzip SILVA*.gz \
#  && mkdir -p /usr/local/share/db \
#  && install -m 644 SILVA*.fasta /usr/local/share/db \
#  && rm -f SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta*
 
# # unite for ITS
# RUN cd /root \
#  && wget --no-check-certificate https://unite.ut.ee/sh_files/sh_mothur_release_s_20.11.2016.zip \
#  && unzip sh_mothur_release*.zip \
#  && mkdir -p /usr/local/share/db \
#  && install -m644 UNITE*dynamic* /usr/local/share/db \
#  && rm -f UNITE* sh*mothur*.zip \
#  # && ( for i in /usr/local/share/db/ITSx_db/HMMs/*.hmm ; do hmmpress -f $i ; done )
 
 
# mothur 1.39.5 
RUN cd /root \
  && wget https://github.com/mothur/mothur/releases/download/v1.39.5/Mothur.linux_64_static.zip \
  && unzip Mothur.linux_64_static.zip \
  && cp mothur/mothur /usr/local/bin \
  && rm Mothur.linux_64_static.zip 
 
 
# # phix DB from Illumina
# RUN cd /root \
#  && wget ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/PhiX/Illumina/RTA/PhiX_Illumina_RTA.tar.gz \
#  && tar xf PhiX*Illumina*.tar.gz \
#  && mkdir -p /usr/local/share/db/bowtie2 \
#  && install -m644 /root/PhiX/Illumina/RTA/Sequence/Bowtie2Index/*  /usr/local/share/db/bowtie2 \
#  && rm -fr  PhiX*Illumina*.tar.gz /root/PhiX


# Upgrade pip, setuptools and wheel and install cwltool
RUN pip install -U pip setuptools wheel
RUN pip install cwlref-runner

# install contents of bin directory in /usr/local/bin
COPY bin/* /usr/local/bin/
RUN chmod 755 /usr/local/bin/*
  
# added CWL dirs
# COPY . /amplicon
