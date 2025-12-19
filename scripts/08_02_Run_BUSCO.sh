#!/bin/bash

#SBATCH --job-name=Run_BUSCO
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=100
#SBATCH --mem=100G
#SBATCH --time=05:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/08_Quality_Assessment_of_Gene_Annotations

# Create output directory:
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# BUSCO is run on the longest isoforms of proteins and transcripts:
module load BUSCO/5.4.2-foss-2021a

busco -i maker_proteins.longest.fasta -l brassicales_odb10 -o busco_output_proteins -m proteins 
busco -i maker_transcripts.longest.fasta -l brassicales_odb10 -o busco_output_transcripts -m transcriptome