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
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif

mkdir -p "$OUTDIR"
 cd "$OUTDIR"

apptainer exec --bind $WORKDIR $CONTAINER \
 TEsorter Copia_sequences.fa -db rexdb-plant 

apptainer exec --bind $WORKDIR $CONTAINER \
 TEsorter Gypsy_sequences.fa -db rexdb-plant