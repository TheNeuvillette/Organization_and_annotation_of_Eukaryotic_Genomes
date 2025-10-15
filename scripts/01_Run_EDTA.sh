#!/bin/bash

#SBATCH --job-name=Run_EDTA
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=64
#SBATCH --mem=128G
#SBATCH --time=2-00:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# User-editable variables 
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/01_EDTA_annotation
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif
INPUT_FASTA=$WORKDIR/data/Hifiasm.bp.p_ctg.fa

mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

# Run the program in the container: 
apptainer exec --bind "$WORKDIR" "$CONTAINER" EDTA.pl \
 --genome $INPUT_FASTA \
 --species others \
 --step all \
 --sensitive 1 \
 --cds "/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated" \
 --anno 1 \
 --threads $SLURM_CPUS_PER_TASK