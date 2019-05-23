
## The plan here is for a tool that can accept assemblies on the command line and output 
## a spreadsheet of allele-specific matches for *stx* gene components

from Bio import Seq


# path to database files
stxDB = "database_files/stxDB"
assemblydir = "/home/seq/MDU/QC/"



rule all:
	input:
		"{OUTFILENAME}.csv"


rule build_db:
	input:
		"stxSeq/AF043627.fa",
		"stxSeq/AJ010730.fa",
		"stxSeq/AY170851.fa",
		"stxSeq/AY286000.fa",
		"stxSeq/DQ059012.fa",
		"stxSeq/L11079.fa",
		"stxSeq/M19473.fa",
		"stxSeq/M21534.fa",
		"stxSeq/Z36901.fa",
		"stxSeq/Z37725.fa"
	output:
		"database_files/stxDB.nhr",
		"database_files/stxDB.nin",
		"database_files/stxDB.nsq",
		"stxSeq/all_stx_seq.fasta"
	shell:
		"""
		mkdir -p database_files
		cat {input} > stxSeq/all_stx_seq.fasta
		makeblastdb -dbtype 'nucl' -in stxSeq/all_stx_seq.fasta -out database_files/stxDB
		"""

rule make_primers:
	input:
		"stxSeq/all_stx_seq.fasta"
	output:
		"stxSeq/stx_allele_primers.fasta"
	shell:
		"""
		python3 primerise.py > {output}
		"""

rule extract_genes:
	input:
		""
	output:
		""
	shell:
		"""
		isPcr -flipReverse assemblydir/2007-21593/contigs.fa stxSeq/stx_allele_primers.fasta {output}
		"""