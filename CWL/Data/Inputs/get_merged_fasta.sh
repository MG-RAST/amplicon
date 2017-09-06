#!/usr/bin/env bash

## Samples
#  mgm4762306.3=Prok.forest1
#  mgm4762301.3=Prok.forest2
#  mgm4762305.3=Prok.forest3
#  mgm4762303.3=Prok.grassland1
#  mgm4762302.3=Prok.grassland2
#  mgm4762300.3=Prok.grassland3

# Download fasta for sample
for ID in mgm4762306.3 mgm4762301.3 mgm4762305.3 mgm4762303.3 mgm4762302.3 mgm4762300.3 
 do
    echo Downloading $ID
    # AUTH="auth: $token:
    echo curl -H "$AUTH" "http://api.metagenomics.anl.gov/download/${ID}?file=100.1"
    curl -H "$AUTH" "http://api.metagenomics.anl.gov/download/${ID}?file=100.1" >${ID}.100.1.fasta
 done

# Rename files
mv mgm4762306.3.100.1.fasta Prok.forest1.fasta
mv mgm4762301.3.100.1.fasta Prok.forest2.fasta
mv mgm4762305.3.100.1.fasta Prok.forest3.fasta
mv mgm4762303.3.100.1.fasta Prok.grassland1.fasta
mv mgm4762302.3.100.1.fasta Prok.grassland2.fasta
mv mgm4762300.3.100.1.fasta Prok.grassland3.fasta
