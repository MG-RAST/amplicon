FROM	ubuntu:14.04
MAINTAINER The MG-RAST team

RUN apt-get update && apt-get install -y \
	vim \
	ssh \
	git \
	build-essential \
	python-dev \
	python-pip \
	libpq-dev \
	perl-modules \
	libcache-memcached-perl \
	libcwd-guard-perl \
	libdbi-perl \
	libdbd-mysql-perl \
	libdbd-pg-perl \
	libmongodb-perl \
	libdata-dump-streamer-perl \
	libdatetime-perl \
	libdigest-md5-perl \
	libdigest-md5-file-perl \
	libfile-slurp-perl \
	libfilehandle-fmode-perl \
	libjson-perl \
	libstring-random-perl \
	libtemplate-perl \
	libwww-perl \
	libgetopt-long-descriptive-perl \
	liburi-encode-perl \
	libunicode-escape-perl \
	liblist-allutils-perl \
	libposix-strptime-perl \
	libberkeleydb-perl \
	libemail-simple-perl \
	libemail-sender-perl
RUN pip install biopython psycopg2 gspread openpyxl numpy

RUN mkdir /usr/local/lib/site_perl
RUN cd /usr/local/lib/site_perl && wget https://raw.githubusercontent.com/MG-RAST/pipeline/master/lib/PipelineAWE.pm
RUN cd /usr/local/bin && wget https://raw.githubusercontent.com/MG-RAST/pipeline/master/bin/sff_extract_0_2_8 && wget https://raw.githubusercontent.com/MG-RAST/pipeline/master/bin/pairend_join.py && wget https://raw.githubusercontent.com/MG-RAST/pipeline/master/bin/demultiplex.py && wget https://raw.githubusercontent.com/MG-RAST/pipeline/master/awecmd/awe_seq_length_stats.pl && chmod a+x awe_seq_length_stats.pl sff_extract_0_2_8 pairend_join.py demultiplex.py
