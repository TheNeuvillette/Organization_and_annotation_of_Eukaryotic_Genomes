#!/bin/bash

#SBATCH --job-name=Run_AGAT
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/08_Quality_Assessment_of_Gene_Annotations
CONTAINERDIR=/data/courses/assembly-annotation-course/CDS_annotation/containers/agat_1.5.1--pl5321hdfd78af_0.sif

INPUT_FILE=$WORKDIR/results/07_Filtering_Refining_Gene_Annotation/filtered.genes.renamed.gff3

# Create output directory:
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Run AGAT:
apptainer exec --bind $WORKDIR $CONTAINERDIR agat_sp_statistics.pl\
 -i $INPUT_FILE -o $OUTDIR/annotation.stat