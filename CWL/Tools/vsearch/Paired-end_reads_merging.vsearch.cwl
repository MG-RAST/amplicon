
cwlVersion: v1.0
class: CommandLineTool

label: Paired-end_reads_merging
doc:  |
    Paired-end reads merging

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Paired-end_reads_merging.log
stderr: Paired-end_reads_merging.error
inputs:

    fastq_eeout:
      type: boolean?
      doc: include expected errors in FASTQ output
      inputBinding:
        prefix: --fastq_eeout

    fastq_minmergelen:
      type: boolean?
      doc: minimum length of entire merged sequence
      inputBinding:
        prefix: --fastq_minmergelen

    fastq_maxmergelen:
      type: boolean?
      doc: maximum length of entire merged sequence
      inputBinding:
        prefix: --fastq_maxmergelen

    eetabbedout:
      type: string?
      doc: output error statistics to specified file
      inputBinding:
        prefix: --eetabbedout

    reverse:
      type: File?
      doc: specify FASTQ file with reverse reads
      inputBinding:
        prefix: --reverse

    fastqout:
      type: string?
      doc: FASTQ output filename for merged sequences
      inputBinding:
        prefix: --fastqout

    fastq_allowmergestagger:
      type: boolean?
      doc: Allow merging of staggered reads
      inputBinding:
        prefix: --fastq_allowmergestagger

    fastaout_notmerged_fwd:
      type: string?
      doc: FASTA filename for non-merged forward sequences
      inputBinding:
        prefix: --fastaout_notmerged_fwd

    fastq_qmaxout:
      type: int?
      doc: maximum base quality value for FASTQ output (41)
      inputBinding:
        prefix: --fastq_qmaxout

    fastqout_notmerged_fwd:
      type: string?
      doc: FASTQ filename for non-merged forward sequences
      inputBinding:
        prefix: --fastqout_notmerged_fwd

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

    fastq_qmax:
      type: int?
      doc: maximum base quality value for FASTQ input (41)
      inputBinding:
        prefix: --fastq_qmax

    fastq_minlen:
      type: int?
      doc: minimum input read length after truncation (1)
      inputBinding:
        prefix: --fastq_minlen

    fastq_truncqual:
      type: int?
      doc: base quality value for truncation
      inputBinding:
        prefix: --fastq_truncqual

    fastq_maxns:
      type: int?
      doc: maximum number of N's
      inputBinding:
        prefix: --fastq_maxns

    fastq_mergepairs:
      type: File?
      doc: merge paired-end reads into one sequence
      inputBinding:
        prefix: --fastq_mergepairs

    fastq_minovlen:
      type: boolean?
      doc: minimum length of overlap between reads (16)
      inputBinding:
        prefix: --fastq_minovlen

    fastq_maxdiffs:
      type: int?
      doc: maximum number of different bases in overlap (5)
      inputBinding:
        prefix: --fastq_maxdiffs

    fastaout_notmerged_rev:
      type: string?
      doc: FASTA filename for non-merged reverse sequences
      inputBinding:
        prefix: --fastaout_notmerged_rev

    fastq_ascii:
      type: int?
      doc: FASTQ input quality score ASCII base char (33)
      inputBinding:
        prefix: --fastq_ascii

    fastq_qminout:
      type: int?
      doc: minimum base quality value for FASTQ output (0)
      inputBinding:
        prefix: --fastq_qminout

    fastq_qmin:
      type: int?
      doc: minimum base quality value for FASTQ input (0)
      inputBinding:
        prefix: --fastq_qmin

    label_suffix:
      type: boolean?
      doc: suffix to append to label of merged sequences
      inputBinding:
        prefix: --label_suffix

    fastq_nostagger:
      type: boolean?
      doc: disallow merging of staggered reads (default)
      inputBinding:
        prefix: --fastq_nostagger

    fastqout_notmerged_rev:
      type: string?
      doc: FASTQ filename for non-merged reverse sequences
      inputBinding:
        prefix: --fastqout_notmerged_rev
outputs:

  info:
    type: stdout
  error: 
    type: stderr  
  