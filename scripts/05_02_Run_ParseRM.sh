#!/bin/bash

#SBATCH --job-name=Run_ParseRM
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=00:20:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/05_Dynamics_of_TEs
INPUT_FASTA=$WORKDIR/results/01_EDTA_annotation/Hifiasm.bp.p_ctg.fa.mod.EDTA.anno/Hifiasm.bp.p_ctg.fa.mod.out
SCRIPTSDIR=$WORKDIR/scripts/05_01_ParseRM.pl

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR"

# Run the Perl script "parseRM.pl" to process the raw alignment outputs from RepeatMasker.
# This script calculates the corrected percentage of divergence of each TE copy from its consensus sequence. 
module add BioPerl/1.7.8-GCCcore-10.3.0
perl $SCRIPTSDIR -i $INPUT_FASTA -l 50,1 -v