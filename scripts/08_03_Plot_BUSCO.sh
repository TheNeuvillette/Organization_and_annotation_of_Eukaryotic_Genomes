#!/bin/bash

#SBATCH --job-name=Plot_BUSCO
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=50
#SBATCH --mem=50G
#SBATCH --time=05:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/08_Quality_Assessment_of_Gene_Annotations

PROTEIN_DIR=$OUTDIR/busco_output_proteins
TRANSCRIPTOME_DIR=$OUTDIR/busco_output_transcripts

# Create output directory:
mkdir -p "$OUTDIR"
cd "$OUTDIR"

module load BUSCO/5.4.2-foss-2021a

# Generate individual plots 
generate_plot.py -wd $PROTEIN_DIR
generate_plot.py -wd $TRANSCRIPTOME_DIR

# Generate combined plot
mkdir -p combined_summaries
cp $PROTEIN_DIR/short_summary*.txt combined_summaries/
cp $TRANSCRIPTOME_DIR/short_summary*.txt combined_summaries/
generate_plot.py -wd combined_summaries/