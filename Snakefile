
## The plan here is for a tool that can accept assemblies on the command line and output 
## a spreadsheet of allele-specific matches for *stx* gene components

from Bio import Seq


# path to database files
stxDB = "database_files/stxDB"
assemblydir = "/home/seq/MDU/QC/"


# variable assignment
ACCS = [ i.split('\t')[1].strip() for i in open("stx_gene_accessions.tab", 'r' ).readlines() ]
DBfiles = [ "nhr", "nin", "nsq" ]


rule all:
	input:
		#"{OUTFILENAME}.csv",
		expand( "stxSeq/{accs}.fa", accs = ACCS ),
		expand( "db_files/stxDB.{DBF}", DBF = DBfiles )


rule check_seqs:
	input:
		"stx_gene_accessions.tab"
	output:
		"stxSeq/{accs}.fa"
	shell:
		"""
		mkdir -p stxSeq && cd stxSeq
		ncbi-acc-download -m nucleotide -F fasta {wildcards.accs}
		cd ..
		"""


rule build_db:
	input:
		expand( "stxSeq/{accs}.fa", accs = ACCS )
	output:
		"db_files/stxDB.nhr",
		"db_files/stxDB.nin",
		"db_files/stxDB.nsq",
		"stxSeq/all_stx_seq.fasta"
	shell:
		"""
		mkdir -p database_files
		cat {input} > {output[3]}
		makeblastdb -dbtype 'nucl' -in stxSeq/all_stx_seq.fasta -out db_files/stxDB
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

# rule extract_genes:
# 	input:
# 		""
# 	output:
# 		""
# 	shell:
# 		"""
# 		isPcr -flipReverse assemblydir/2007-21593/contigs.fa stxSeq/stx_allele_primers.fasta {output}
# 		"""