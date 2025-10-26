#!/bin/bash

#SBATCH --job-name=Refining_TE_Classification
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# User-editable variables 
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/05_Refining_TE_Classification
INPUT_FASTA=$WORKDIR/results/01_EDTA_annotation/Hifiasm.bp.p_ctg.fa.mod.EDTA.TElib.fa

mkdir -p "$OUTDIR"
 cd "$OUTDIR"

# Add SeqKit
module load SeqKit/2.6.1

# Extract Copia sequences 
seqkit grep -r -p "Copia" $INPUT_FASTA > Copia_sequences.fa 
# Extract Gypsy sequences 
seqkit grep -r -p "Gypsy" $INPUT_FASTA > Gypsy_sequences.fa 