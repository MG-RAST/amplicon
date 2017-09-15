cwlVersion: v1.0
class: CommandLineTool

label: mothur command line
doc:  |
  n/a
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/mothur:1.0
    
requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: mothur.input
        entry: |       
          classify.seqs(fasta=$(inputs.fasta.basename), template=$(inputs.reference_database.basename), taxonomy=$(inputs.taxonomy_file.basename),  cutoff=$(inputs.cutoff))
      - $(inputs.fasta)
      - $(inputs.reference_database)
      - $(inputs.taxonomy_file)   

     
baseCommand: [mothur]
  
stdout: mothur.log
stderr: mothur.error



inputs:
      
  fasta:
    type: File
    doc: fasta file for classification
  reference_database:
    type: File
    doc: /usr/local/share/db/UNITEv6_sh_dynamic_s.fasta
  taxonomy_file: 
    type: File
    doc:  /usr/local/share/db/UNITEv6_sh_dynamic_s.tax    
  cutoff:
    type: string #int
    default: "60"  
 
arguments:
  -  mothur.input
  
outputs:
  output:
    type: stdout
  error: 
    type: stderr  
  log: 
    type: File
    outputBinding:
      glob: mothur.*.logfile  
  summary:
    type: File
    outputBinding:
      glob: "*.tax.summary"
  taxonomy:
    type: File
    outputBinding:
      glob: $(inputs.fasta.nameroot).*.wang.taxonomy    
        

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"