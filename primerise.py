#! /home/linuxbrew/.linuxbrew/bin/python3

from Bio import SeqIO

infile="stxSeq/all_stx_seq.fasta"

for seq_record in SeqIO.parse(infile, "fasta"):
	print( seq_record.id, "\t", seq_record.seq[0:21], "\t",  seq_record.seq[ len(seq_record)-21:len(seq_record)])


