
cwlVersion: v1.0
class: CommandLineTool

label: Clustering
doc:  |
    Clustering

baseCommand: [vsearch]  
  
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
  
requirements:
  InlineJavascriptRequirement: {}

stdout: Clustering.log
stderr: Clustering.error
inputs:

    iddef:
      type: int?
      doc: id definition, 0-4=CD-HIT,all,int,MBL,BLAST (2)
      inputBinding:
        prefix: --iddef

    percent_identity:
      type: string? #float?
      doc: reject if identity lower, accepted values:\ 0-1.0
      #default: "0.97"
      inputBinding:
        prefix: --id

    msaout:
      type: string?
      doc: output multiple seq. alignments to FASTA file
      inputBinding:
        prefix: --msaout

    relabel:
      type: string?
      doc: relabel centroids with this prefix string
      inputBinding:
        prefix: --relabel

    usersort:
      type: boolean?
      doc: indicate sequences not pre-sorted by length
      inputBinding:
        prefix: --usersort

    sizein:
      type: boolean?
      doc: propagate abundance annotation from input
      inputBinding:
        prefix: --sizein

    consout:
      type: string?
      doc: output cluster consensus sequences to FASTA file
      inputBinding:
        prefix: --consout

    profile:
      type: string?
      doc: output sequence profile of each cluster to file
      inputBinding:
        prefix: --profile

    centroids:
      type: string?
      doc: output centroid sequences to FASTA file
      inputBinding:
        prefix: --centroids

    cluster_size:
      type: File?
      doc: cluster sequences after sorting by abundance
      inputBinding:
        prefix: --cluster_size

    sizeout:
      type: boolean?
      doc: write cluster abundances to centroid file
      inputBinding:
        prefix: --sizeout

    clusterout_id:
      type: boolean?
      doc: add cluster id info to consout and profile files
      inputBinding:
        prefix: --clusterout_id

    clusterout_sort:
      type: boolean?
      doc: order msaout, consout, profile by decr abundance
      inputBinding:
        prefix: --clusterout_sort

    uc:
      type: string?
      doc: specify filename for UCLUST-like output
      inputBinding:
        prefix: --uc

    relabel_md5:
      type: boolean?
      doc: relabel with md5 digest of normalized sequence
      inputBinding:
        prefix: --relabel_md5

    relabel_sha1:
      type: boolean?
      doc: relabel with sha1 digest of normalized sequence
      inputBinding:
        prefix: --relabel_sha1

    biomout:
      type: string?
      doc: filename for OTU table output in biom 1.0 format
      inputBinding:
        prefix: --biomout

    cluster_smallmem:
      type: File?
      doc: cluster already sorted sequences (see -usersort)
      inputBinding:
        prefix: --cluster_smallmem

    cons_truncate:
      type: boolean?
      doc: do not ignore terminal gaps in MSA for consensus
      inputBinding:
        prefix: --cons_truncate

    clusters:
      type: string?
      doc: output each cluster to a separate FASTA file
      inputBinding:
        prefix: --clusters

    strand:
      type: string?
      doc: cluster using plus or both strands (plus)
      inputBinding:
        prefix: --strand

    relabel_keep:
      type: boolean?
      doc: keep the old label after the new when relabelling
      inputBinding:
        prefix: --relabel_keep

    otutabout:
      type: string?
      doc: filename for OTU table output in classic format
      inputBinding:
        prefix: --otutabout

    qmask:
      type: string?
      doc: mask seqs with dust, soft or no method (dust)
      inputBinding:
        prefix: --qmask

    cluster_fast:
      type: File?
      doc: cluster sequences after sorting by length
      inputBinding:
        prefix: --cluster_fast

    sizeorder:
      type: boolean?
      doc: sort accepted centroids by abundance (AGC)
      inputBinding:
        prefix: --sizeorder

    mothur_shared_out:
      type: string?
      doc: filename for OTU table output in mothur format
      inputBinding:
        prefix: --mothur_shared_out

    xsize:
      type: boolean?
      doc: strip abundance information in output
      inputBinding:
        prefix: --xsize
outputs:

  info:
    type: stdout
  error: 
    type: stderr
  centroidsFile:
    type: File
    outputBinding:
      glob: $(inputs.centroids)    
  
