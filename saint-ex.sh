#! /bin/bash

### THIS SCRIPT IS JUST A CONTROLLER TO PARSE INPUT FOR snakemake
### SEE ./Snakefile for the methodology

# fail politely if no input provided
if (($# == 0)); then
	echo Please provide MDU IDs or assemblies.
fi



## command line help
display_help() {
	echo "The What:"
	echo "	this tool extracts stx genes and IDs alleles"
    echo "The How:"
    echo "	bash saint-ex.sh [options] <input_file.txt>" >&2
    echo "Options:"
    echo "   -h			show this help screen"
    echo "   -a			treat input as paths to assemblies (default is to search /home/seq/MDU/QC)"
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
while getopts ":har" opt; do
  case $opt in
    h)
      display_help >&2
      ;;
    a)
      ass_path="TRUE"
      ;;
    r)
     check_reqs >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done



# make input file ready for `Snakefile` input
if [ ! -z ${ass_path} ] ; then
	echo ${ass_path}
	INFILE=$2
	cp ${INFILE} input.list
else
	INFILE=$1
	cat ${INFILE} | while read i ; do
		echo "/home/seq/MDU/QC/"${i}"/contigs.fa" >> input.list
	done
fi

### Run the thing!

snakemake




# write IDs to input.list