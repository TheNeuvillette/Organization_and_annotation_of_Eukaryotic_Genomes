#!/bin/bash

#SBATCH --job-name=Run_Genespace
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=120
#SBATCH --mem=200G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


# Paths and Variables: 
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/10_Comparative_Genomics
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
SCRIPTDIR=$WORKDIR/scripts

# Create output directory:
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Run genespace in its container:
apptainer exec \
    --bind /data \
    --bind $SCRATCH:/temp \
    $COURSEDIR/containers/genespace_latest.sif Rscript $SCRIPTDIR/10_02_Genespace.R $OUTDIR