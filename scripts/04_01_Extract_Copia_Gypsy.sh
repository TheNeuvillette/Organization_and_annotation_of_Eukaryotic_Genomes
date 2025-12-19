#!/bin/bash

#SBATCH --job-name=Extract_Copia_Gypsy
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/04_Refining_TE_Classification
INPUT_FASTA=$WORKDIR/results/01_EDTA_annotation/Hifiasm.bp.p_ctg.fa.mod.EDTA.TElib.fa

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR"

# Prior to running TE sorter, we extract the Copia and Gypsy
# sequences from the EDTA-generated TE library, since we will
# conduct further analysis on these sequences only. 

# Add SeqKit
module load SeqKit/2.6.1

# Extract Copia sequences 
seqkit grep -r -p "Copia" $INPUT_FASTA > Copia_sequences.fa 
# Extract Gypsy sequences 
seqkit grep -r -p "Gypsy" $INPUT_FASTA > Gypsy_sequences.fa 