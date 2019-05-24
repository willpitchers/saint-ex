#! /bin/bash

### THIS SCRIPT IS JUST A CONTROLLER TO PARSE INPUT FOR snakemake
### SEE ./Snakefile for the methodology

# fail politely if no input provided
if (($# == 0)); then
	echo Please provide MDU IDs or assemblies.
fi

rm seq_path.list seq_name.list outfile.tab


## command line help
display_help() {
	echo "The What:"
	echo "	this tool extracts stx genes and IDs alleles"
    echo "The How:"
    echo "	bash saint-ex.sh [options] <input_file.txt>"
    echo "			Input should be: seq-ID <tab> /path/to/seq.fa"
    echo "			(path can be skipped if using MDU IDs - see below)"
    echo "Options:"
    echo "   -h			show this help screen"
    echo "   -m			input list of MDU ID no.s only"
    echo "   -r			check requirements are met"
    echo
    exit 1
}


## requirements checker
check_reqs() {
	command -v python3 >/dev/null 2>&1 || { echo >&2 "I require python3 but it's not installed.  Aborting."; exit 1; }
	command -v snakemake >/dev/null 2>&1 || { echo >&2 "I require snakemake but it's not installed.  Aborting."; exit 1; }
	command -v isPcr >/dev/null 2>&1 || { echo >&2 "I require isPcr but it's not installed.  Aborting."; exit 1; }
	command -v makeblastdb >/dev/null 2>&1 || { echo >&2 "I require makeblastdb but it's not installed.  Aborting."; exit 1; }
	command -v blastn >/dev/null 2>&1 || { echo >&2 "I require blastn but it's not installed.  Aborting."; exit 1; }
	command -v ncbi-acc-download >/dev/null 2>&1 || { echo >&2 "I require ncbi-acc-download but it's not installed.  Aborting."; exit 1; }
	echo "Requirements met -- Good job!"
}


# parse non-zero input: help flag
while getopts ":hmr" opt; do
  case $opt in
    h)
      display_help >&2
      ;;
    m)
      mdu_path="TRUE"
      ;;
    r)
     check_reqs >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


## writing a config.yaml for snakemake to eat?
# write_config_mdu() {
# 	echo 										>> config.yaml
# 	echo 'assemblydir = "/home/seq/MDU/QC/"'	>> config.yaml
# }


# make input file ready for `Snakefile` input
if [ ! -z ${mdu_path} ] ; then
	INFILE=$2
	cp ${INFILE} seq_name.list
	cat ${INFILE} | while read i ; do
		echo "/home/seq/MDU/QC/"${i}"/contigs.fa" >> seq_path.list
	done	
else
	INFILE=$1
	cut -f 1 ${INFILE} > seq_name.list
	cut -f 2 ${INFILE} > seq_path.list
fi

### Run the thing!

snakemake




# write IDs to input.list