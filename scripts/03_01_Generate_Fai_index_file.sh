#!/bin/bash

#SBATCH --job-name=Generate_Fai_index_file
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
CONTAINER=/containers/apptainer/samtools-1.19.sif
OUTDIR=$WORKDIR/results/03_Visualizing_TE_Annotations
INPUT_FASTA=$WORKDIR/data/Hifiasm.bp.p_ctg.fa

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

# To make the ideogram data, you need to know the lengths of the scaffolds.
# This information is contained in the ".fai" index file.

# Create the Fai index file in the container:
apptainer exec --bind $WORKDIR $CONTAINER \
 samtools faidx $INPUT_FASTA