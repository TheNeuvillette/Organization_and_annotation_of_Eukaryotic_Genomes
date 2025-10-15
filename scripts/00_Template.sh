#!/bin/bash

#SBATCH --job-name=JOB_NAME            # e.g. TE_annotation
#SBATCH --partition=pibu_el8           # IBU cluster partition
#SBATCH --cpus-per-task=NCPUS          # e.g. 20
#SBATCH --mem=MEM                      # e.g. 64G or 200G
#SBATCH --time=TIME                    # format D-HH:MM, e.g. 2-00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# User-editable variables 
WORKDIR=/path/to/your/workdir 
CONTAINER=/path/to/TOOL_container.sif  # e.g. /data/.../EDTA2.2.sif 
INPUT_FASTA=$WORKDIR/data/assemblies/assembly.fasta 
OUTDIR=$WORKDIR/results/TOOL_run 
TOOL_CMD="TOOL_COMMAND --input $INPUT_FASTA --other-options"  # replace with actual command inside container 

mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

# Full run: runs TOOL_CMD inside the container using allocated CPUs 
apptainer exec --bind "$WORKDIR" \ 
 "$CONTAINER" \ 
 "$TOOL_CMD --threads \$SLURM_CPUS_PER_TASK"