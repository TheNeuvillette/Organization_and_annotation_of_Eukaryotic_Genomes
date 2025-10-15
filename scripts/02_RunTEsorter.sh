#!/bin/bash

#SBATCH --job-name=Run_TEsorter
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif
OUTDIR=$WORKDIR/results/02_TEsorter
INPUT_FASTA=$WORKDIR/data/05_02_Hifiasm.bp.p_ctg.fa

mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

apptainer exec --bind $WORKDIR $CONTAINER \
 TEsorter $INPUT_FASTA -db rexdb-plant -p $SLURM_CPUS_PER_TASK