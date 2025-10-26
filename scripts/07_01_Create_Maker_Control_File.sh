#!/bin/bash

#SBATCH --job-name=Create_Maker_Control_Files
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# User-editable variables 
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/07_Gene_Annotation
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif

mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

# Create Control Files
apptainer exec --bind $WORKDIR $CONTAINER \
  maker -CTL