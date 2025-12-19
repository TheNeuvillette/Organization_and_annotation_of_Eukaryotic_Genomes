#!/bin/bash

#SBATCH --job-name=Run_Blast
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=120
#SBATCH --mem=200G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


# User-editable variables 
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
INDIR=$WORKDIR/results/07_Filtering_Refining_Gene_Annotation
OUTDIR=$WORKDIR/results/09_Blast
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin

# Database paths
UNIPROT_DB=/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa
TAIR10_DB=/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_pep_20110103_representative_gene_model

# filtered MAKER proteins and GFF3 input files
maker_proteins_fasta=$INDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta
maker_gff=$INDIR/filtered.genes.renamed.gff3

# Output file paths
blastp_uniprot_output=$OUTDIR/blastp_uniprot_output.out
blastp_tair10_output=$OUTDIR/blastp_tair10_output.out

mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Load BLAST+ module
module load BLAST+/2.15.0-gompi-2021a

blastp -query $maker_proteins_fasta -db $UNIPROT_DB -num_threads 20 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out $blastp_uniprot_output

# Now sort the blast output to keep only the best hit per query sequence
sort -k1,1 -k12,12g $blastp_uniprot_output | sort -u -k1,1 --merge > ${blastp_uniprot_output}.besthits

cp ${maker_proteins_fasta} ${maker_proteins_fasta}.Uniprot
cp ${maker_gff} ${maker_gff}.Uniprot

$MAKERBIN/maker_functional_fasta ${UNIPROT_DB} ${blastp_uniprot_output}.besthits ${maker_proteins_fasta} > ${maker_proteins_fasta}.Uniprot

$MAKERBIN/maker_functional_gff ${UNIPROT_DB} ${blastp_uniprot_output} ${maker_gff} > ${maker_gff}.Uniprot.gff3

blastp -query ${maker_proteins_fasta} -db ${TAIR10_DB} -num_threads 20 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out ${blastp_tair10_output}

sort -k1,1 -k12,12g ${blastp_tair10_output} | sort -u -k1,1 --merge > ${blastp_tair10_output}.besthits