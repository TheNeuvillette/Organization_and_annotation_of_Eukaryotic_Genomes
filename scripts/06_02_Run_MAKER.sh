#!/bin/bash

#SBATCH --job-name=Run_MAKER
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=500G
#SBATCH --time=6-00:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# Paths and Variables:
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/06_Gene_Annotation

REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"
export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR" 

# The genome annotation pipeline MAKER is highly time and resource demanding.
# Therefore, we use MPI (Message Passing Interface), which is a standard for
# parallel computing across multiple processors. 

module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

# MAKER is run on the Hifiasm assembly, using its container:
mpiexec --oversubscribe -n 50 apptainer exec \
 --bind $SCRATCH:/TMP --bind $COURSEDIR --bind $AUGUSTUS_CONFIG_PATH --bind \
 $REPEATMASKER_DIR \
 ${COURSEDIR}/containers/MAKER_3.01.03.sif \
 maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl \
 maker_evm.ctl maker_exe.ctl