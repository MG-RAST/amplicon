FROM debian:jessie

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  autoconf \
  automake \
  bowtie2 \
  build-essential \
  cython \
  dh-autoreconf \
  git \
  hmmer \
  libtool \
  mafft \
  mothur \
  ncbi-blast+  \
  perl \
  python \
  python-pip \
  unzip \
  velvet \
  wget


RUN cd /root \
  && wget  http://spades.bioinf.spbau.ru/release3.10.1/SPAdes-3.10.1-Linux.tar.gz \
  && tar xzf SPAdes-*.tar.gz \
  && install -m755 SPAdes-*/bin/* /usr/local/bin/ \
  && mv SPAdes-*/share/* /usr/local/share/ \
  && rm -rf SPAdes-*
  
RUN cd /root \
  && wget http://microbiology.se/sw/ITSx_1.0.11.tar.gz \
  && tar xzf ITSx_*.tar.gz \
  && mkdir /usr/local/share/db \
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

# python scripts from Robert 
RUN cd /root \
   && wget http://drive5.com/python/python_scripts.tar.gz \
   && cd /usr/local/bin \
   && tar xzf /root/python_scripts.tar.gz \
   && rm /root/python_scripts.tar.gz

# fastx_toolkit
RUN cd /root \
  && mkdir fastx_bin \
  && cd fastx_bin \
  && wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
  && tar xf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
  && install -m755 bin/* /usr/local/bin/  \
  && rm -rf /root/fastx_bin/
    

# add PEAR matepair merger
RUN cd /root \
  && git clone https://github.com/xflouris/PEAR.git \
  && cd PEAR \
  && ./autogen.sh \
  && ./configure \
  && make install \
  && rm -rf /root/PEAR
  

# vsearch
RUN cd /root \
	&& wget https://github.com/torognes/vsearch/archive/v2.4.2.tar.gz \
	&& tar xzf v2*.tar.gz \
	&& cd vsearch-2* \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local/ \
	&& make \
	&& make install \
	&& make clean \
	&& cd .. \
  && rm -rf /root/vsearch-* /root/v2*.tar.gz

#https://downloads.sourceforge.net/project/bbmap/BBMap_37.02.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fbbmap%2F&ts=1491253864&use_mirror=cytranet
# BBMap for its demultiplexing function
# RUN cd /root \
#  && wget https://downloads.sourceforge.net/project/bbmap/BBMap_37.02.tar.gz
#  && tar xf BBMap* \
#  && rm BBMap*.tar* \
#  && cd bbmap
  
# SILVA DB for 16s // requires primer pair specific post-processing
# full version https://www.arb-silva.de/no_cache/download/archive/current/Exports/SILVA_128_SSURef_tax_silva_trunc.fasta.gz
RUN cd /root \
 && wget  --no-check-certificate https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta.gz \
 && gunzip SILVA*.gz \
 && mkdir -p /usr/local/share/db \
 && install -m 644 SILVA*.fasta /usr/local/share/db \
 && rm -f SILVA_128_SSURef_Nr99_tax_silva_trunc.fasta*
 
# unite for ITS
RUN cd /root \
 && wget --no-check-certificate https://unite.ut.ee/sh_files/sh_mothur_release_s_20.11.2016.zip \
 && unzip sh_mothur_release*.zip \
 && mkdir -p /usr/local/share/db \
 && install -m644 UNITE*dynamic* /usr/local/share/db \
 && rm -f UNITE* sh*mothur*.zip
 
   
  
  
  
