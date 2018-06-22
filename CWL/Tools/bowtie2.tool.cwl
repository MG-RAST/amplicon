cwlVersion: v1.0
class: CommandLineTool

label: PHIX
doc:  |
    STAGE:0060 PHIX removal using bowtie2 with Illumina RTA genome and 
    Illumina built indeces
    
hints:
  DockerRequirement:
    dockerPull: mgrast/amplicon:1.0
    # dockerPull: mgrast/tools:1.0
    
requirements:
  InlineJavascriptRequirement: {}
  # EnvVarRequirement:
#     envDef:
#       - envName: BOWTIE2_INDEXES
#         envValue: ./
#   InitialWorkDirRequirement:
#     listing: |
#       ${
#         var list = [] ;
#          var re = new RegExp("^" + inputs.index , "i");
#          var files = inputs.indexDir.listing ;
#          for (var f in files) {
#             var file = files[f] ;
#            if ( re.test(file.basename) ){ list.push(file) }
#            else { list.push(inputs.index)}
#          }
#
#          return list;
#       }
#
 
  
stdout: bowtie.sam
stderr: bowtie.error


inputs:
  fastqin:
    type: File
    # format:
    #   - fastq
    inputBinding:
      prefix: -U
  unaligned_out:
    type: string
    doc: write unpaired reads that didn't align
    inputBinding:
      prefix: --un
  index: 
    type: string
    default: genome
    inputBinding:
      prefix: -x  
      valueFrom: $(inputs.indexDir.path)/$(self)
  indexDir:
    type: Directory
      
baseCommand: [bowtie2]

arguments:   
  - prefix: --threads 
    valueFrom: $(runtime.cores)  
 
outputs:
  unaligned:
    type: File
    # format: fastq
    outputBinding:
      glob: $(inputs.unaligned_out)
  sam:
    type: stdout
  error: 
    type: stderr  
  

# $namespaces:
#   Formats: FileFormats.cv.yaml
# s:license: "https://www.apache.org/licenses/LICENSE-2.0"
# s:copyrightHolder: "MG-RAST"
