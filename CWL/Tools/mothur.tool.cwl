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
          $(inputs.input)
    
  
     
baseCommand: [mothur]
  
stdout: mothur.log
stderr: mothur.error


  mothur_cmd="#classify.seqs(fasta=${file}, \
     template=/usr/local/share/db/UNITEv6_sh_dynamic_s.fasta,  \
     taxonomy=/usr/local/share/db/UNITEv6_sh_dynamic_s.tax, \

     ${MOTHUR_PARAMS})"
  cmd="mothur ${mothur_cmd}"

inputs:
      
  input:
    type: string
    doc: mothor command
 
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
      glob: *.logfile  
  files:
    type: File[]
    outputBinding:
      glob: $(inputs.sequences.nameroot).*

$namespaces:
  Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"