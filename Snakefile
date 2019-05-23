
## The plan here is for a tool that can accept assemblies on the command line and output 
## a spreadsheet of allele-specific matches for *stx* gene components

from Bio import Seq


# path to assembly files
assemblydir = "/home/seq/MDU/QC/"


# variable assignment
MDUIDs = [ i.strip() for i in open( "input.list", 'r' ).readlines() ]
ACCS = [ i.split('\t')[1].strip() for i in open( "stx_gene_accessions.tab", 'r' ).readlines() ]
DBfiles = [ "nhr", "nin", "nsq" ]


rule all:
	input:
		#"{OUTFILENAME}.csv",
		expand( "stxSeq/{accs}.fa", accs = ACCS ),
		expand( "db_files/stxDB.{DBF}", DBF = DBfiles ),
		expand( "matches/{mduids}_matches.fa", mduids = MDUIDs ),
		expand( "matches/{mduids}_hits.fa", mduids = MDUIDs ),
 		"outfile.tab"
		


# check that 
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


rule extract_genes:
	input:
		"stxSeq/stx_allele_primers.fasta",
		"input.list"
	output:
		"matches/{mduids}_matches.fa"
	shell:
		"""
		mkdir -p matches
		isPcr -flipReverse {assemblydir}/{wildcards.mduids}/contigs.fa stxSeq/stx_allele_primers.fasta {output}
		"""


rule blasting:
	input:
		"matches/{mduids}_matches.fa"
	output:
		"matches/{mduids}_hits.fa"
	shell:
		"""
		blastn -db db_files/stxDB -query {input} -perc_identity 95 -outfmt '6' > {output}
		"""


rule tabulate:
	input:
		expand( "matches/{mduids}_hits.fa", mduids = MDUIDs )
	output:
		"outfile.tab"
	shell:
		"""
		echo "query_acc\tsubject_acc\t%_identity\talignment_length\t\mismatches\tgap_opens\tq_start\tq_end\ts_start\ts_end\tevalue\tbit_score" > {output}
		cat {input} >> {output}
		"""




