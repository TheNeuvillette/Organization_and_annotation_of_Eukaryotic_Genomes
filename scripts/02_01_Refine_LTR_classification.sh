#!/bin/bash

#SBATCH --job-name=Refine_LTR_classification
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif
OUTDIR=$WORKDIR/results/02_Inferring_LTR_Age
INPUT_FASTA=$WORKDIR/results/01_EDTA_annotation/Hifiasm.bp.p_ctg.fa.mod.EDTA.raw/Hifiasm.bp.p_ctg.fa.mod.LTR.raw.fa

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

# Before inferring the LTR-RT age from percent identity,
# we must first refine TE classification for full length 
# LTR-RTs and split them into clades. 

# The clade classification file is generated using TEsorter.

# TEsorter is run on the EDTA LTR results, using the TEsorter container:
apptainer exec --bind $WORKDIR $CONTAINER \
 TEsorter $INPUT_FASTA -db rexdb-plant -p $SLURM_CPUS_PER_TASK