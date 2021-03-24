#!/usr/bin/env bash

# i.e. enable conda (de)activate
eval "$(conda shell.bash hook)"

# Load conda environment
conda activate GRECO-BIT-motif-discovery-pipeline

# Run workflows
snakemake --snakefile Snakefile --cores 4 --configfile ./config.yml
