
cwlVersion: v1.0
class: CommandLineTool

label: vsearch
doc:  |
    vsearcg

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: vsearch.log
stderr: vsearch.error
inputs:

    userfields:
      type: string?
      doc: fields to output in userout file
      inputBinding:
        prefix: --userfields

    sizeout:
      type: boolean?
      doc: include abundance information when relabelling
      inputBinding:
        prefix: --sizeout

    reverse:
      type: File?
      doc: specify FASTQ file with reverse reads
      inputBinding:
        prefix: --reverse

    fastaout_notmerged_fwd:
      type: string?
      doc: FASTA filename for non-merged forward sequences
      inputBinding:
        prefix: --fastaout_notmerged_fwd

    alnout:
      type: string?
      doc: filename for human-readable alignment output
      inputBinding:
        prefix: --alnout

    fastq_truncqual:
      type: int?
      doc: base quality value for truncation
      inputBinding:
        prefix: --fastq_truncqual

    target_cov:
      type: float?
      doc: reject if fraction of target seq. aligned lower
      inputBinding:
        prefix: --target_cov

    fastq_asciiout:
      type: int?
      doc: FASTQ output quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_asciiout

    cli_help:
      type: boolean?
      doc: display help information
      inputBinding:
        prefix: --help

    fastq_minlen:
      type: int?
      doc: minimum input read length after truncation (1)
      inputBinding:
        prefix: --fastq_minlen

    usearch_global:
      type: File?
      doc: filename of queries for global alignment search
      inputBinding:
        prefix: --usearch_global

    bzip2_decompress:
      type: boolean?
      doc: decompress input with bzip2 (required if pipe)
      inputBinding:
        prefix: --bzip2_decompress

    qmask:
      type: string?
      doc: mask seqs with dust, soft or no method (dust)
      inputBinding:
        prefix: --qmask

    notmatched:
      type: string?
      doc: FASTA file for non-matching query sequences
      inputBinding:
        prefix: --notmatched

    consout:
      type: string?
      doc: output cluster consensus sequences to FASTA file
      inputBinding:
        prefix: --consout

    log:
      type: File?
      doc: write messages, timing and memory info to file
      inputBinding:
        prefix: --log

    fastq_stats:
      type: File?
      doc: report statistics on FASTQ file
      inputBinding:
        prefix: --fastq_stats

    mintsize:
      type: int?
      doc: reject if target abundance lower
      inputBinding:
        prefix: --mintsize

    uchimealns:
      type: string?
      doc: output chimera alignments to file
      inputBinding:
        prefix: --uchimealns

    fastq_chars:
      type: File?
      doc: analyse FASTQ file for version and quality range
      inputBinding:
        prefix: --fastq_chars

    mismatch:
      type: int?
      doc: score for mismatch (-4)
      inputBinding:
        prefix: --mismatch

    sortbylength:
      type: File?
      doc: sort sequences by length in given FASTA file
      inputBinding:
        prefix: --sortbylength

    slots:
      type: int?
      doc: option is ignored
      inputBinding:
        prefix: --slots

    sample_pct:
      type: float?
      doc: sampling percentage between 0.0 and 100.0
      inputBinding:
        prefix: --sample_pct

    maxqt:
      type: float?
      doc: reject if query/target length ratio higher
      inputBinding:
        prefix: --maxqt

    uchime_ref:
      type: File?
      doc: detect chimeras using a reference database
      inputBinding:
        prefix: --uchime_ref

    mincols:
      type: int?
      doc: reject if alignment length shorter
      inputBinding:
        prefix: --mincols

    output:
      type: string?
      doc: output to specified FASTA file
      inputBinding:
        prefix: --output

    fastq_maxmergelen:
      type: boolean?
      doc: maximum length of entire merged sequence
      inputBinding:
        prefix: --fastq_maxmergelen

    maxaccepts:
      type: int?
      doc: number of hits to accept and show per strand (1)
      inputBinding:
        prefix: --maxaccepts

    self:
      type: boolean?
      doc: exclude identical labels for --uchime_ref
      inputBinding:
        prefix: --self

    threads:
      type: int?
      doc: number of threads to use, zero for all cores (0)
      inputBinding:
        prefix: --threads

    fastq_maxns:
      type: int?
      doc: maximum number of N's
      inputBinding:
        prefix: --fastq_maxns

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    fastx_filter:
      type: File?
      doc: filter and truncate sequences in FASTA/FASTQ file
      inputBinding:
        prefix: --fastx_filter

    maxsizeratio:
      type: float?
      doc: reject if query/target abundance ratio higher
      inputBinding:
        prefix: --maxsizeratio

    version:
      type: boolean?
      doc: display version information
      inputBinding:
        prefix: --version

    fastq_maxlen:
      type: int?
      doc: maximum length of sequence for filter
      inputBinding:
        prefix: --fastq_maxlen

    quiet:
      type: boolean?
      doc: output just warnings and fatal errors to stderr
      inputBinding:
        prefix: --quiet

    idprefix:
      type: int?
      doc: reject if first n nucleotides do not match
      inputBinding:
        prefix: --idprefix

    mid:
      type: float?
      doc: reject if percent identity lower, ignoring gaps
      inputBinding:
        prefix: --mid

    maskfasta:
      type: File?
      doc: mask sequences in the given FASTA file
      inputBinding:
        prefix: --maskfasta

    fastq_qminout:
      type: int?
      doc: minimum base quality value for FASTQ output (0)
      inputBinding:
        prefix: --fastq_qminout

    randseed:
      type: int?
      doc: seed for PRNG, zero to use random data source (0)
      inputBinding:
        prefix: --randseed

    maxuniquesize:
      type: int?
      doc: maximum abundance for output from dereplication
      inputBinding:
        prefix: --maxuniquesize

    gzip_decompress:
      type: boolean?
      doc: decompress input with gzip (required if pipe)
      inputBinding:
        prefix: --gzip_decompress

    minwordmatches:
      type: int?
      doc: minimum number of word matches required (12)
      inputBinding:
        prefix: --minwordmatches

    sortbysize:
      type: File?
      doc: abundance sort sequences in given FASTA file
      inputBinding:
        prefix: --sortbysize

    maxdiffs:
      type: int?
      doc: reject if more substitutions or indels
      inputBinding:
        prefix: --maxdiffs

    fastqout_discarded:
      type: string?
      doc: FASTQ filename for discarded sequences
      inputBinding:
        prefix: --fastqout_discarded

    fulldp:
      type: boolean?
      doc: full dynamic programming alignment (always on)
      inputBinding:
        prefix: --fulldp

    uchimeout:
      type: string?
      doc: output to chimera info to tab-separated file
      inputBinding:
        prefix: --uchimeout

    xsize:
      type: boolean?
      doc: strip abundance information in output
      inputBinding:
        prefix: --xsize

    sizeorder:
      type: boolean?
      doc: sort accepted centroids by abundance (AGC)
      inputBinding:
        prefix: --sizeorder

    msaout:
      type: string?
      doc: output multiple seq. alignments to FASTA file
      inputBinding:
        prefix: --msaout

    maxrejects:
      type: int?
      doc: number of non-matching hits to consider (32)
      inputBinding:
        prefix: --maxrejects

    fastq_maxdiffs:
      type: int?
      doc: maximum number of different bases in overlap (5)
      inputBinding:
        prefix: --fastq_maxdiffs

    min_unmasked_pct:
      type: boolean?
      doc: min unmasked % of sequences to keep (0.0)
      inputBinding:
        prefix: --min_unmasked_pct

    maxsize:
      type: int?
      doc: maximum abundance for sortbysize
      inputBinding:
        prefix: --maxsize

    maxgaps:
      type: int?
      doc: reject if more indels
      inputBinding:
        prefix: --maxgaps

    fastq_eestats:
      type: File?
      doc: quality score and expected error statistics
      inputBinding:
        prefix: --fastq_eestats

    fastq_minovlen:
      type: boolean?
      doc: minimum length of overlap between reads (16)
      inputBinding:
        prefix: --fastq_minovlen

    maxseqlength:
      type: int?
      doc: maximum sequence length (50000)
      inputBinding:
        prefix: --maxseqlength

    fastqout_notmerged_rev:
      type: string?
      doc: FASTQ filename for non-merged reverse sequences
      inputBinding:
        prefix: --fastqout_notmerged_rev

    borderline:
      type: string?
      doc: output borderline chimeric sequences to file
      inputBinding:
        prefix: --borderline

    db:
      type: File?
      doc: reference database for --uchime_ref
      inputBinding:
        prefix: --db

    minsize:
      type: int?
      doc: minimum abundance for sortbysize
      inputBinding:
        prefix: --minsize

    uc:
      type: string?
      doc: specify filename for UCLUST-like output
      inputBinding:
        prefix: --uc

    clusterout_sort:
      type: boolean?
      doc: order msaout, consout, profile by decr abundance
      inputBinding:
        prefix: --clusterout_sort

    cons_truncate:
      type: boolean?
      doc: do not ignore terminal gaps in MSA for consensus
      inputBinding:
        prefix: --cons_truncate

    fastqout:
      type: string?
      doc: FASTQ output filename for merged sequences
      inputBinding:
        prefix: --fastqout

    xn:
      type: boolean?
      doc: REAL                   'no' vote weight (8.0)
      inputBinding:
        prefix: --xn

    fastx_mask:
      type: File?
      doc: mask sequences in the given FASTA or FASTQ file
      inputBinding:
        prefix: --fastx_mask

    mothur_shared_out:
      type: string?
      doc: filename for OTU table output in mothur format
      inputBinding:
        prefix: --mothur_shared_out

    minuniquesize:
      type: int?
      doc: minimum abundance for output from dereplication
      inputBinding:
        prefix: --minuniquesize

    maxsl:
      type: float?
      doc: reject if shorter/longer length ratio higher
      inputBinding:
        prefix: --maxsl

    fastq_qmaxout:
      type: int?
      doc: maximum base quality value for FASTQ output (41)
      inputBinding:
        prefix: --fastq_qmaxout

    maxsubs:
      type: int?
      doc: reject if more substitutions
      inputBinding:
        prefix: --maxsubs

    fastq_qmax:
      type: int?
      doc: maximum base quality value for FASTQ input (41)
      inputBinding:
        prefix: --fastq_qmax

    idsuffix:
      type: int?
      doc: reject if last n nucleotides do not match
      inputBinding:
        prefix: --idsuffix

    fastq_ascii:
      type: int?
      doc: FASTQ input quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_ascii

    sizein:
      type: boolean?
      doc: propagate abundance annotation from input
      inputBinding:
        prefix: --sizein

    usersort:
      type: boolean?
      doc: indicate sequences not pre-sorted by length
      inputBinding:
        prefix: --usersort

    fastq_nostagger:
      type: boolean?
      doc: disallow merging of staggered reads (default)
      inputBinding:
        prefix: --fastq_nostagger

    profile:
      type: string?
      doc: output sequence profile of each cluster to file
      inputBinding:
        prefix: --profile

    fastapairs:
      type: string?
      doc: FASTA file with pairs of query and target
      inputBinding:
        prefix: --fastapairs

    matched:
      type: string?
      doc: FASTA file for matching query sequences
      inputBinding:
        prefix: --matched

    biomout:
      type: string?
      doc: filename for OTU table output in biom 1.0 format
      inputBinding:
        prefix: --biomout

    relabel_md5:
      type: boolean?
      doc: relabel filtered sequences with md5 digest
      inputBinding:
        prefix: --relabel_md5

    alignwidth:
      type: int?
      doc: width of alignment in uchimealn output (80)
      inputBinding:
        prefix: --alignwidth

    otutabout:
      type: string?
      doc: filename for OTU table output in classic format
      inputBinding:
        prefix: --otutabout

    fastq_convert:
      type: File?
      doc: convert between FASTQ file formats
      inputBinding:
        prefix: --fastq_convert

    minseqlength:
      type: int?
      doc: |
        min seq length (clust/derep/search: 32, other:1)
      inputBinding:
        prefix: --minseqlength

    fastqout_notmerged_fwd:
      type: string?
      doc: FASTQ filename for non-merged forward sequences
      inputBinding:
        prefix: --fastqout_notmerged_fwd

    shuffle:
      type: File?
      doc: shuffle order of sequences in FASTA file randomly
      inputBinding:
        prefix: --shuffle

    cluster_fast:
      type: File?
      doc: cluster sequences after sorting by length
      inputBinding:
        prefix: --cluster_fast

    fastq_maxee:
      type: float?
      doc: maximum expected error value for merged sequence
      inputBinding:
        prefix: --fastq_maxee

    fastaout:
      type: string?
      doc: FASTA output filename for merged sequences
      inputBinding:
        prefix: --fastaout

    dbmatched:
      type: string?
      doc: FASTA file for matching database sequences
      inputBinding:
        prefix: --dbmatched

    selfid:
      type: boolean?
      doc: exclude identical sequences for --uchime_ref
      inputBinding:
        prefix: --selfid

    acceptall:
      type: boolean?
      doc: output all pairwise alignments
      inputBinding:
        prefix: --acceptall

    samout:
      type: string?
      doc: filename for SAM format output
      inputBinding:
        prefix: --samout

    hardmask:
      type: boolean?
      doc: mask by replacing with N instead of lower case
      inputBinding:
        prefix: --hardmask

    allpairs_global:
      type: File?
      doc: perform global alignment of all sequence pairs
      inputBinding:
        prefix: --allpairs_global

    minsl:
      type: float?
      doc: reject if shorter/longer length ratio lower
      inputBinding:
        prefix: --minsl

    query_cov:
      type: float?
      doc: reject if fraction of query seq. aligned lower
      inputBinding:
        prefix: --query_cov

    fastq_trunclen:
      type: int?
      doc: read length for sequence truncation
      inputBinding:
        prefix: --fastq_trunclen

    sample_size:
      type: int?
      doc: sampling size
      inputBinding:
        prefix: --sample_size

    dbmask:
      type: string?
      doc: mask db with dust, soft or no method (dust)
      inputBinding:
        prefix: --dbmask

    fastq_truncee:
      type: float?
      doc: maximum total expected error for truncation
      inputBinding:
        prefix: --fastq_truncee

    minsizeratio:
      type: float?
      doc: reject if query/target abundance ratio lower
      inputBinding:
        prefix: --minsizeratio

    pattern:
      type: string?
      doc: option is ignored
      inputBinding:
        prefix: --pattern

    fastq_qmin:
      type: int?
      doc: minimum base quality value for FASTQ input (0)
      inputBinding:
        prefix: --fastq_qmin

    topn:
      type: int?
      doc: output just first n sequences
      inputBinding:
        prefix: --topn

    eeout:
      type: boolean?
      doc: include expected errors in output
      inputBinding:
        prefix: --eeout

    fastq_maxee_rate:
      type: float?
      doc: maximum expected error rate for filter
      inputBinding:
        prefix: --fastq_maxee_rate

    fastq_eeout:
      type: boolean?
      doc: include expected errors in FASTQ output
      inputBinding:
        prefix: --fastq_eeout

    dn:
      type: boolean?
      doc: REAL                   'no' vote pseudo-count (1.4)
      inputBinding:
        prefix: --dn

    cluster_smallmem:
      type: File?
      doc: cluster already sorted sequences (see -usersort)
      inputBinding:
        prefix: --cluster_smallmem

    eetabbedout:
      type: string?
      doc: output error statistics to specified file
      inputBinding:
        prefix: --eetabbedout

    fastq_stripleft:
      type: int?
      doc: bases on the left to delete
      inputBinding:
        prefix: --fastq_stripleft

    gapopen:
      type: string?
      doc: penalties for gap opening (20I/2E)
      inputBinding:
        prefix: --gapopen

    uc_allhits:
      type: boolean?
      doc: show all, not just top hit with uc output
      inputBinding:
        prefix: --uc_allhits

    abskew:
      type: float?
      doc: min abundance ratio of parent vs chimera (2.0)
      inputBinding:
        prefix: --abskew

    fastaout_notmerged_rev:
      type: string?
      doc: FASTA filename for non-merged reverse sequences
      inputBinding:
        prefix: --fastaout_notmerged_rev

    maxqsize:
      type: int?
      doc: reject if query abundance larger
      inputBinding:
        prefix: --maxqsize

    match:
      type: int?
      doc: score for match (2)
      inputBinding:
        prefix: --match

    nonchimeras:
      type: string?
      doc: output non-chimeric sequences to file
      inputBinding:
        prefix: --nonchimeras

    wordlength:
      type: int?
      doc: length of words for database index 3-15 (8)
      inputBinding:
        prefix: --wordlength

    max_unmasked_pct:
      type: boolean?
      doc: max unmasked % of sequences to keep (100.0)
      inputBinding:
        prefix: --max_unmasked_pct

    notrunclabels:
      type: boolean?
      doc: do not truncate labels at first space
      inputBinding:
        prefix: --notrunclabels

    fastq_minmergelen:
      type: boolean?
      doc: minimum length of entire merged sequence
      inputBinding:
        prefix: --fastq_minmergelen

    mindiffs:
      type: int?
      doc: minimum number of differences in segment (3)
      inputBinding:
        prefix: --mindiffs

    fastq_tail:
      type: int?
      doc: min length of tails to count for fastq_chars (4)
      inputBinding:
        prefix: --fastq_tail

    clusters:
      type: string?
      doc: output each cluster to a separate FASTA file
      inputBinding:
        prefix: --clusters

    rereplicate:
      type: File?
      doc: rereplicate sequences in the given FASTA file
      inputBinding:
        prefix: --rereplicate

    fastq_allowmergestagger:
      type: boolean?
      doc: Allow merging of staggered reads
      inputBinding:
        prefix: --fastq_allowmergestagger

    top_hits_only:
      type: boolean?
      doc: output only hits with identity equal to the best
      inputBinding:
        prefix: --top_hits_only

    derep_fulllength:
      type: File?
      doc: dereplicate sequences in the given FASTA file
      inputBinding:
        prefix: --derep_fulllength

    userout:
      type: string?
      doc: filename for user-defined tab-separated output
      inputBinding:
        prefix: --userout

    minh:
      type: float?
      doc: minimum score (0.28)
      inputBinding:
        prefix: --minh

    derep_prefix:
      type: File?
      doc: dereplicate sequences in file based on prefixes
      inputBinding:
        prefix: --derep_prefix

    rightjust:
      type: boolean?
      doc: reject if terminal gaps at alignment right end
      inputBinding:
        prefix: --rightjust

    minqt:
      type: float?
      doc: reject if query/target length ratio lower
      inputBinding:
        prefix: --minqt

    iddef:
      type: int?
      doc: id definition, 0-4=CD-HIT,all,int,MBL,BLAST (2)
      inputBinding:
        prefix: --iddef

    samheader:
      type: boolean?
      doc: include a header in the SAM output file
      inputBinding:
        prefix: --samheader

    relabel:
      type: string?
      doc: relabel filtered sequences with given prefix
      inputBinding:
        prefix: --relabel

    mindiv:
      type: float?
      doc: minimum divergence from closest parent (0.8)
      inputBinding:
        prefix: --mindiv

    maxhits:
      type: int?
      doc: maximum number of hits to show (unlimited)
      inputBinding:
        prefix: --maxhits

    cluster_size:
      type: File?
      doc: cluster sequences after sorting by abundance
      inputBinding:
        prefix: --cluster_size

    rowlen:
      type: int?
      doc: width of alignment lines in alnout output (64)
      inputBinding:
        prefix: --rowlen

    centroids:
      type: string?
      doc: output centroid sequences to FASTA file
      inputBinding:
        prefix: --centroids

    uchime_denovo:
      type: File?
      doc: detect chimeras de novo
      inputBinding:
        prefix: --uchime_denovo

    fasta_width:
      type: int?
      doc: width of FASTA seq lines, 0 for no wrap (80)
      inputBinding:
        prefix: --fasta_width

    clusterout_id:
      type: boolean?
      doc: add cluster id info to consout and profile files
      inputBinding:
        prefix: --clusterout_id

    fastx_subsample:
      type: File?
      doc: subsample sequences from given FASTA/FASTQ file
      inputBinding:
        prefix: --fastx_subsample

    strand:
      type: string?
      doc: cluster using plus or both strands (plus)
      inputBinding:
        prefix: --strand

    chimeras:
      type: string?
      doc: output chimeric sequences to file
      inputBinding:
        prefix: --chimeras

    relabel_sha1:
      type: boolean?
      doc: relabel filtered sequences with sha1 digest
      inputBinding:
        prefix: --relabel_sha1

    fastaout_discarded:
      type: string?
      doc: FASTA filename for discarded sequences
      inputBinding:
        prefix: --fastaout_discarded

    maxid:
      type: float?
      doc: reject if identity higher
      inputBinding:
        prefix: --maxid

    blast6out:
      type: string?
      doc: filename for blast-like tab-separated output
      inputBinding:
        prefix: --blast6out

    leftjust:
      type: boolean?
      doc: reject if terminal gaps at alignment left end
      inputBinding:
        prefix: --leftjust

    uchimeout5:
      type: boolean?
      doc: make output compatible with uchime version 5
      inputBinding:
        prefix: --uchimeout5

    id:
      type: float?
      doc: |
        reject if identity lower, accepted values: 0-1.0
      inputBinding:
        prefix: --id

    gapext:
      type: string?
      doc: penalties for gap extension (2I/1E)
      inputBinding:
        prefix: --gapext

    fastq_mergepairs:
      type: File?
      doc: merge paired-end reads into one sequence
      inputBinding:
        prefix: --fastq_mergepairs

    search_exact:
      type: File?
      doc: filename of queries for exact match search
      inputBinding:
        prefix: --search_exact

    fastx_revcomp:
      type: File?
      doc: Reverse-complement seqs in FASTA or FASTQ file
      inputBinding:
        prefix: --fastx_revcomp

    fastq_filter:
      type: File?
      doc: filter and truncate sequences in FASTQ file
      inputBinding:
        prefix: --fastq_filter

    weak_id:
      type: float?
      doc: include aligned hits with >= id; continue search
      inputBinding:
        prefix: --weak_id

    output_no_hits:
      type: boolean?
      doc: output non-matching queries to output files
      inputBinding:
        prefix: --output_no_hits

    fasta_score:
      type: boolean?
      doc: include chimera score in fasta output
      inputBinding:
        prefix: --fasta_score

    dbnotmatched:
      type: string?
      doc: FASTA file for non-matching database sequences
      inputBinding:
        prefix: --dbnotmatched

    label_suffix:
      type: boolean?
      doc: suffix to append to label of merged sequences
      inputBinding:
        prefix: --label_suffix
outputs:

  info:
    type: stdout
  error: 
    type: stderr
  fastq:
    type: File?
    outputBinding:    
      glob: $(inputs.fastqout)
  