#!/bin/bash

#SBATCH --job-name=Generate_Fai
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
CONTAINER=/containers/apptainer/samtools-1.19.sif
OUTDIR=$WORKDIR/results/04_Visualizing_TE_Annotations
INPUT_FASTA=$WORKDIR/data/Hifiasm.bp.p_ctg.fa

mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

apptainer exec --bind $WORKDIR $CONTAINER \
 samtools faidx $INPUT_FASTA