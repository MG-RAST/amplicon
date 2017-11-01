# SOP - Annotating amplicon mate pairs

TAP CWL Workflow

* * *


**Authors:** Andreas Wilke

**Version:** 0.9.1

**Audience:** This document is intended for users who are familiar with docker and amplicon data analysis.

**Requirements:**

*   <span class="c0">text editor</span>
*   <span>mate pair sequence files    
    (e.g.</span> <span class="c8">sequences_R1.fastq</span><span> and</span> <span class="c8">sequences_R2.fastq</span><span class="c0">)</span>
*   <span class="c0">docker</span>
*   <span class="c0">wget</span>

<span class="c0"></span>

**Known limitations:**

*   <span class="c0">memory > 8 GB (depends on data input size and classification algorithm)</span>

## Introduction:

<span class="c0">This SOP describes the steps necessary to run the TAP (prokaryote) pipeline.</span>

## SOP:

1.  `git clone https://github.com/MG-RAST/amplicon.git`
2.  <span>Change into cloned repository:  
    </span><span class="c3">`cd amplicon`  
    </span>
3.  <span>Download reference databases:  
    </span><span class="c10">`./setup.sh`  

    </span><span>or from within the container</span><span class="c3">  

    ```docker run -v `pwd`:/amplicon -ti --rm --entrypoint bash  --workdir /amplicon mgrast/amplicon:latest setup.sh```</span>



4.  Change into the newly created Data directory:  

    ```cd Data```
    
    This will be your working directory. Copy or move your sequence files into this directory and rename them to **R1.fastq.gz** and **R2.fastq.gz**. For example:

    -  `cp your_path/your_sequence_files.R1.fastq.gz  R1.fastq.gz`
    -  `cp your_path/your_sequence_files.R2.fastq.gz  R2.fastq.gz`  


5.  ```docker run -ti --rm -v `pwd`:/Data mgrast/tap:latest prok```



* * *


## Notes:



*   <span>To get help:  
    </span><span class="c3">  
    docker run -ti --rm -v `pwd`:/Data mgrast/tap:latest help  
    </span>
*   <span>Run any command in container:  
    </span><span class="c10">docker run -ti --rm -v `pwd`:/Data mgrast/tap:latest</span> <span class="c1 c18">COMMAND</span>

