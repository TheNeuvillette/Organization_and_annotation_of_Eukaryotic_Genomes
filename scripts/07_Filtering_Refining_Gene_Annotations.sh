#!/bin/bash

#SBATCH --job-name=Filtering_Refining_Gene_Annotations
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=100
#SBATCH --mem=100G
#SBATCH --time=05:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err 

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
INDIR=$WORKDIR/results/06_Gene_Annotation/Merged_GFF
OUTDIR=$WORKDIR/results/07_Filtering_Refining_Gene_Annotation
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
MAKERBIN=$COURSEDIR/softwares/Maker_v3.01.03/src/bin

protein="assembly.all.maker.proteins.fasta" 
transcript="assembly.all.maker.transcripts.fasta" 
gff="assembly.all.maker.noseq.gff"

module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0

# Create output directory:
mkdir -p "$OUTDIR"
 cd "$OUTDIR"

# Rename Genes and Transcripts:
# We create a directory to store the final filtered annotations
# and copy the necessary files to it. Furthermore, we assign
# clean, consistent IDs to the gene models.

cp $INDIR/$gff $OUTDIR/${gff}.renamed.gff 
cp $INDIR/$protein $OUTDIR/${protein}.renamed.fasta 
cp $INDIR/$transcript $OUTDIR/${transcript}.renamed.fasta
cd $OUTDIR

$MAKERBIN/maker_map_ids --prefix Etna-2 --justify 7 ${gff}.renamed.gff > id.map 
$MAKERBIN/map_gff_ids id.map ${gff}.renamed.gff 
$MAKERBIN/map_fasta_ids id.map ${protein}.renamed.fasta 
$MAKERBIN/map_fasta_ids id.map ${transcript}.renamed.fasta 

# Run InterProScan on the Protein File:
# First, we run InterProScan to annotate the protein sequences
# with functional domains, such as those from the Pfam database.
# We are adding goterms and iprlookup to the output. These
# options provide additional functional annotations for the
# protein sequences.

apptainer exec \
  --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data \
  --bind $WORKDIR \
  --bind $COURSEDIR \
  --bind $SCRATCH:/temp \
  $COURSEDIR/containers/interproscan_latest.sif \
  /opt/interproscan/interproscan.sh \
  -appl pfam --disable-precalc -f TSV \
  --goterms --iprlookup --seqtype p \
  -i $OUTDIR/assembly.all.maker.proteins.fasta.renamed.fasta -o output.iprscan

# Update GFF with InterProScan Results:
# Incorporate the InterProScan functional annotations
# into the GFF3 file using the ipr_update_gff tool.

$MAKERBIN/ipr_update_gff ${gff}.renamed.gff output.iprscan > ${gff}.renamed.iprscan.gff

# Calculate AED Values:
# AED (Annotation Edit Distance) values are essential for
# evaluating how well gene models are supported by the evidence.
# We use MAKERʼs AED_cdf_generator.pl to generate AED values for
# all annotations.

perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 ${gff}.renamed.gff > assembly.all.maker.renamed.gff.AED.txt

# Filter the GFF File for Quality:
# Filter the GFF file based on the AED values and/or
# functional annotations from InterProScan.

perl $MAKERBIN/quality_filter.pl -s ${gff}.renamed.iprscan.gff > ${gff}_iprscan_quality_filtered.gff 
# In the above command: -s  Prints transcripts with an AED <1 and/or Pfam domain if in gff3

# Filter the GFF File for Gene Features: 

# We only want to keep gene features in the third column of the gff file 
grep -P  "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${gff}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3 
# Check 
cut -f3 filtered.genes.renamed.gff3 | sort | uniq 

# Extract mRNA Sequences and Filter FASTA Files:
# Extract the list of remaining mRNA IDs from the filtered
# GFF3 file, and use this list to filter the transcript and
# protein FASTA files.

grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt
faSomeRecords ${transcript}.renamed.fasta list.txt ${transcript}.renamed.filtered.fasta
faSomeRecords ${protein}.renamed.fasta list.txt ${protein}.renamed.filtered.fasta 