#!/bin/bash

#SBATCH --job-name=Postprocessing_MAKER
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=100
#SBATCH --mem=100G
#SBATCH --time=05:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/06_Gene_Annotation
DATASTORE_INDEX_LOG=$OUTDIR/Hifiasm.bp.p_ctg.maker.output/Hifiasm.bp.p_ctg_master_datastore_index.log
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
MAKERBIN=$COURSEDIR/softwares/Maker_v3.01.03/src/bin

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR"


# MAKER postprocessing consists of sorting,
# deleting duplicate records and most importantly merging GFF files. 
$MAKERBIN/gff3_merge -s -d \
 $DATASTORE_INDEX_LOG > \
 assembly.all.maker.gff

$MAKERBIN/gff3_merge -n -s -d \
 $DATASTORE_INDEX_LOG > \
 assembly.all.maker.noseq.gff 

$MAKERBIN/fasta_merge -d \
 $DATASTORE_INDEX_LOG -o assembly