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
  && ln -s ITSx_1.0.11 ITSx \
  && rm -rf ITSx_*.tar.gz

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
   && tar xzvf /root/python_scripts.tar.gz \
   && rm /root/python_scripts.tar.gz

# fastx_toolkit
RUN cd /root \
  && mkdir fastx_bin \
  && cd fastx_bin \
  && wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
  && tar xf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
  && install -m755 bin/* /usr/local/bin/  \
  && rm -rf fastx_bin/
    

# add PEAR matepair merger
RUN cd /root \
  && git clone https://github.com/xflouris/PEAR.git \
  && cd PEAR \
  && ./autogen.sh \
  && ./configure \
  && make install \
  && rm -rf /root/PEAR
  

# vseaarch
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


