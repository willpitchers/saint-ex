# ***saint-ex***

A tool for finding &amp; ID-ing stx alleles...

## Shigatoxin

Shiga toxins are a family of related toxins with two major groups, Stx1 and Stx2, named for discoverer Kiyoshi Shiga. These toxin genes can occur in some strains of *Escherichia coli* – referred to as STEC (Shiga-Toxin producing *E. Coli*) – as well as in the *Shigella spp.* that share their etymology. Shiga toxin is associated with symptoms such as abdominal pain and diarrhea, as well as more serious conditions as hemorrhagic colitis and hemolytic-uremic syndrome, and is thus a public health concern. 

## *stx* Detection

This tool takes a 2-step approach to identify *stx* genes in sequence data down the the level of allele. Firstly, *in silico* PCR is used to pull out potentially matching loci. I then `BLAST` these matches against a database of published sequences for the known *stx* alleles: 

Allele  | Accession no.
--------|--------------
*stx1a* |  M19473
*stx1c* |  Z36901
*stx1d* |  AY170851
*stx2a* |  Z37725
*stx2b* |  AF043627
*stx2c* |  L11079
*stx2d* |  DQ059012
*stx2e* |  M21534
*stx2f* |  AJ010730
*stx2g* |  AY286000

The output tabulates the `BLAST` matching statistics for each putative *stx* coding sequence, allowing the user to make informed judgements, rather than relying on present/absent calls.
