
##### SAINT-EX SNAKEFILE #####
## The plan here is for a tool that can accept assemblies on the command line and output 
## a spreadsheet of allele-specific matches for *stx* gene components

from Bio import Seq

# config: "config.yaml"

# path to assembly files
# assemblydir = "/home/seq/MDU/QC/"
# ass_name = "contigs.fa"


# variable assignment
SEQIDs = [ i.strip() for i in open( "seq_name.list", 'r' ).readlines() ]
SEQPATHS = [ i.strip() for i in open( "seq_path.list", 'r' ).readlines() ]
ACCS = [ i.split('\t')[1].strip() for i in open( "stx_gene_accessions.tab", 'r' ).readlines() ]
DBfiles = [ "nhr", "nin", "nsq" ]


rule all:
	input:
		expand( "stxSeq/{accs}.fa", accs = ACCS ),
		expand( "db_files/stxDB.{DBF}", DBF = DBfiles ),
		expand( "matches/{seqids}_matches.fa", seqids = SEQIDs ),
		expand( "matches/{seqids}_hits.fa", seqids = SEQIDs ),
		expand( "{seqpaths}", seqpaths = SEQPATHS ),
 		"outfile.tab"
		


# check that stx-allele sequences are present and download them if not
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

# check that stx-allele sequence database is present and build it if not
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

# check that primer file is present and build it if not
rule make_primers:
	input:
		"stxSeq/all_stx_seq.fasta"
	output:
		"stxSeq/stx_allele_primers.fasta"
	shell:
		"""
		python3 primerise.py > {output}
		"""

# use `isPcr` to pull out the sequence of any stx genes in the sample isolates
rule extract_genes:
	input:
		"stxSeq/stx_allele_primers.fasta",
		"seq_path.list",
		"seq_name.list"
	output:
		"matches/{seqids}_matches.fa"
	shell:
		"""
		mkdir -p matches
		isPcr -flipReverse {input[1]} stxSeq/stx_allele_primers.fasta {output}
		"""

# `blast` extracted stx gene seq.s against stx-allele DB
rule blasting:
	input:
		"matches/{seqids}_matches.fa"
	output:
		"matches/{seqids}_hits.fa"
	shell:
		"""
		blastn -db db_files/stxDB -query {input} -perc_identity 95 -outfmt '6' > {output}
		"""

# turn multiple `blast` results files into a labelled table
rule tabulate:
	input:
		expand( "matches/{seqids}_hits.fa", seqids = SEQIDs )
	output:
		"outfile.tab"
	shell:
		"""
		echo "query_acc\tsubject_acc\t%_identity\talignment_length\t\mismatches\tgap_opens\tq_start\tq_end\ts_start\ts_end\tevalue\tbit_score" > {output}
		cat {input} >> {output}
		"""

