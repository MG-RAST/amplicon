
cwlVersion: v1.0
class: CommandLineTool

label: Searching
doc:  |
    Searching

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Searching.log
stderr: Searching.error
inputs:

    maxgaps:
      type: int?
      doc: reject if more indels
      inputBinding:
        prefix: --maxgaps

    samheader:
      type: boolean?
      doc: include a header in the SAM output file
      inputBinding:
        prefix: --samheader

    iddef:
      type: int?
      doc: id definition, 0-4=CD-HIT,all,int,MBL,BLAST (2)
      inputBinding:
        prefix: --iddef

    maxrejects:
      type: int?
      doc: number of non-matching hits to consider (32)
      inputBinding:
        prefix: --maxrejects

    db:
      type: File?
      doc: filename for FASTA formatted database for search
      inputBinding:
        prefix: --db

    rowlen:
      type: int?
      doc: width of alignment lines in alnout output (64)
      inputBinding:
        prefix: --rowlen

    maxhits:
      type: int?
      doc: maximum number of hits to show (unlimited)
      inputBinding:
        prefix: --maxhits

    minwordmatches:
      type: int?
      doc: minimum number of word matches required (12)
      inputBinding:
        prefix: --minwordmatches

    top_hits_only:
      type: boolean?
      doc: output only hits with identity equal to the best
      inputBinding:
        prefix: --top_hits_only

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

    fulldp:
      type: boolean?
      doc: full dynamic programming alignment (always on)
      inputBinding:
        prefix: --fulldp

    maxdiffs:
      type: int?
      doc: reject if more substitutions or indels
      inputBinding:
        prefix: --maxdiffs

    userout:
      type: string?
      doc: filename for user-defined tab-separated output
      inputBinding:
        prefix: --userout

    search_exact:
      type: File?
      doc: filename of queries for exact match search
      inputBinding:
        prefix: --search_exact

    sizein:
      type: boolean?
      doc: propagate abundance annotation from input
      inputBinding:
        prefix: --sizein

    gapext:
      type: string?
      doc: penalties for gap extension (2I/1E)
      inputBinding:
        prefix: --gapext

    reject_lower:
      type: float?
      doc: reject if identity lower
      inputBinding:
        prefix: --id

    dbnotmatched:
      type: string?
      doc: FASTA file for non-matching database sequences
      inputBinding:
        prefix: --dbnotmatched

    matched:
      type: string?
      doc: FASTA file for matching query sequences
      inputBinding:
        prefix: --matched

    fastapairs:
      type: string?
      doc: FASTA file with pairs of query and target
      inputBinding:
        prefix: --fastapairs

    output_no_hits:
      type: boolean?
      doc: output non-matching queries to output files
      inputBinding:
        prefix: --output_no_hits

    weak_id:
      type: float?
      doc: include aligned hits with >= id; continue search
      inputBinding:
        prefix: --weak_id

    strand:
      type: string?
      doc: search plus or both strands (plus)
      inputBinding:
        prefix: --strand

    uc:
      type: string?
      doc: filename for UCLUST-like output
      inputBinding:
        prefix: --uc

    maxsubs:
      type: int?
      doc: reject if more substitutions
      inputBinding:
        prefix: --maxsubs

    idsuffix:
      type: int?
      doc: reject if last n nucleotides do not match
      inputBinding:
        prefix: --idsuffix

    leftjust:
      type: boolean?
      doc: reject if terminal gaps at alignment left end
      inputBinding:
        prefix: --leftjust

    blast6out:
      type: string?
      doc: filename for blast-like tab-separated output
      inputBinding:
        prefix: --blast6out

    mothur_shared_out:
      type: string?
      doc: filename for OTU table output in mothur format
      inputBinding:
        prefix: --mothur_shared_out

    maxsl:
      type: float?
      doc: reject if shorter/longer length ratio higher
      inputBinding:
        prefix: --maxsl

    maxid:
      type: float?
      doc: reject if identity higher
      inputBinding:
        prefix: --maxid

    hardmask:
      type: boolean?
      doc: mask by replacing with N instead of lower case
      inputBinding:
        prefix: --hardmask

    samout:
      type: string?
      doc: filename for SAM format output
      inputBinding:
        prefix: --samout

    dbmatched:
      type: string?
      doc: FASTA file for matching database sequences
      inputBinding:
        prefix: --dbmatched

    notmatched:
      type: string?
      doc: FASTA file for non-matching query sequences
      inputBinding:
        prefix: --notmatched

    selfid:
      type: boolean?
      doc: reject if sequences identical
      inputBinding:
        prefix: --selfid

    dbmask:
      type: string?
      doc: mask db with dust, soft or no method (dust)
      inputBinding:
        prefix: --dbmask

    slots:
      type: int?
      doc: option is ignored
      inputBinding:
        prefix: --slots

    pattern:
      type: string?
      doc: option is ignored
      inputBinding:
        prefix: --pattern

    minsizeratio:
      type: float?
      doc: reject if query/target abundance ratio lower
      inputBinding:
        prefix: --minsizeratio

    query_cov:
      type: float?
      doc: reject if fraction of query seq. aligned lower
      inputBinding:
        prefix: --query_cov

    mismatch:
      type: int?
      doc: score for mismatch (-4)
      inputBinding:
        prefix: --mismatch

    mintsize:
      type: int?
      doc: reject if target abundance lower
      inputBinding:
        prefix: --mintsize

    minsl:
      type: float?
      doc: reject if shorter/longer length ratio lower
      inputBinding:
        prefix: --minsl

    biomout:
      type: string?
      doc: filename for OTU table output in biom 1.0 format
      inputBinding:
        prefix: --biomout

    alnout:
      type: string?
      doc: filename for human-readable alignment output
      inputBinding:
        prefix: --alnout

    userfields:
      type: string?
      doc: fields to output in userout file
      inputBinding:
        prefix: --userfields

    sizeout:
      type: boolean?
      doc: write abundance annotation to dbmatched file
      inputBinding:
        prefix: --sizeout

    usearch_global:
      type: File?
      doc: filename of queries for global alignment search
      inputBinding:
        prefix: --usearch_global

    qmask:
      type: string?
      doc: mask query with dust, soft or no method (dust)
      inputBinding:
        prefix: --qmask

    target_cov:
      type: float?
      doc: reject if fraction of target seq. aligned lower
      inputBinding:
        prefix: --target_cov

    otutabout:
      type: string?
      doc: filename for OTU table output in classic format
      inputBinding:
        prefix: --otutabout

    mid:
      type: float?
      doc: reject if percent identity lower, ignoring gaps
      inputBinding:
        prefix: --mid

    maxqsize:
      type: int?
      doc: reject if query abundance larger
      inputBinding:
        prefix: --maxqsize

    idprefix:
      type: int?
      doc: reject if first n nucleotides do not match
      inputBinding:
        prefix: --idprefix

    match:
      type: int?
      doc: score for match (2)
      inputBinding:
        prefix: --match

    wordlength:
      type: int?
      doc: length of words for database index 3-15 (8)
      inputBinding:
        prefix: --wordlength

    self:
      type: boolean?
      doc: reject if labels identical
      inputBinding:
        prefix: --self

    maxaccepts:
      type: int?
      doc: number of hits to accept and show per strand (1)
      inputBinding:
        prefix: --maxaccepts

    mincols:
      type: int?
      doc: reject if alignment length shorter
      inputBinding:
        prefix: --mincols

    maxqt:
      type: float?
      doc: reject if query/target length ratio higher
      inputBinding:
        prefix: --maxqt

    maxsizeratio:
      type: float?
      doc: reject if query/target abundance ratio higher
      inputBinding:
        prefix: --maxsizeratio

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

arguments:
  - prefix: --threads
    valueFrom: $(runtime.cores)        
        
outputs:
  uclust:
    type: File
    outputBinding:
      glob: $(inputs.uc)
  matched_sequences:
    type: File
    outputBinding:
      glob: $(inputs.matched)

  info:
    type: stdout
  error: 
    type: stderr  
  
