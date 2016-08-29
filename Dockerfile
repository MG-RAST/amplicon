FROM debian:jessie

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bowtie2 \
  cython \
  dh-autoreconf \
  hmmer \
  mafft \
  mothur \
  ncbi-blast+  \
  perl \
  python \
  python-pip \
  velvet \
  wget

ADD http://spades.bioinf.spbau.ru/release3.6.0/SPAdes-3.6.0-Linux.tar.gz /tmp/ 
RUN tar xzf /tmp/SPAdes-3.6.0-Linux.tar.gz && \
    mv SPAdes-3.6.0-Linux/bin/* /usr/local/bin/ && \
    mv SPAdes-3.6.0-Linux/share/* /usr/local/share/

ADD http://microbiology.se/sw/ITSx_1.0.11.tar.gz /
RUN cd / && tar xvzf ITSx_1.0.11.tar.gz && \
    ln -s ITSx_1.0.11 ITSx

ADD http://microbiology.se/sw/Metaxa2_2.0.2.tar.gz /
RUN cd / && tar xvzf /Metaxa2_2.0.2.tar.gz && \
    cd /Metaxa2_2.0.2 && \ 
    echo -e "yes\n/usr/local/bin/\nyes\n" | ./install_metaxa2

# install cutadapt (we do not use the debian unstable source package)
RUN pip install cutadapt 

# python scripts from Robert 
ADD http://drive5.com/python/python_scripts.tar.gz /
RUN cd /usr/local/bin && \
    tar xzvf /python_scripts.tar.gz && \
    rm /python_scripts.tar.gz

# fastx_toolkit
ADD http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 /fastx_bin/
RUN cd /fastx_bin/ && \
    tar -xjf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 && \
    mv /fastx_bin/bin/* /usr/local/bin/


RUN cd /root \
	&& wget https://github.com/torognes/vsearch/archive/v2.0.2.tar.gz \
	&& tar xzf v2.0.2.tar.gz \
	&& cd vsearch-2.0.2 \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local/ \
	&& make \
	&& make install \
	&& make clean \
	&& cd .. \
&& rm -rf /root/vsearch-2.02 /root/v2.0.2.tar.gz


