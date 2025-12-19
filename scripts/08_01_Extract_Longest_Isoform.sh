#!/bin/bash

#SBATCH --job-name=Extract_Longest_Isoform
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=50
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
INDIR=$WORKDIR/results/07_Filtering_Refining_Gene_Annotation
OUTDIR=$WORKDIR/results/08_Quality_Assessment_of_Gene_Annotations

# Create output directory:
mkdir -p "$OUTDIR"
cd "$OUTDIR"

cp $INDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta $OUTDIR/maker_proteins.fasta
cp $INDIR/assembly.all.maker.transcripts.fasta.renamed.filtered.fasta $OUTDIR/maker_transcripts.fasta

module load SeqKit/2.6.1

# Due to isoforms, a gene may have multiple proteins or transcripts.
# To avoid BUSCO from seeing gene duplicates and thus giving us a
# worse score than we actually have, we extract the longest protein
# and transcript per gene. The length of each entry is written in the
# fasta file.

# Extract the longest protein isoform per gene
seqkit fx2tab maker_proteins.fasta | \
awk -F'\t' '{
  match($1, /(.*)-R[A-Z]+/, arr);
  gene = arr[1];
  if (!(gene in seen)) {
    order[++n] = gene;
    seen[gene] = 1;
  }
  if (length($2) > len[gene]) {
    seq[gene] = $0;
    len[gene] = length($2);
  }
}
END {
  for (i = 1; i <= n; i++) print seq[order[i]];
}' | seqkit tab2fx > maker_proteins.longest.fasta


# extract the longest transcripts isoform per gene
seqkit fx2tab maker_transcripts.fasta | \
awk -F'\t' '{
  match($1, /(.*)-R[A-Z]+/, arr);
  gene = arr[1];
  if (!(gene in seen)) {
    order[++n] = gene;
    seen[gene] = 1;
  }
  if (length($2) > len[gene]) {
    seq[gene] = $0;
    len[gene] = length($2);
  }
}
END {
  for (i = 1; i <= n; i++) print seq[order[i]];
}' | seqkit tab2fx > maker_transcripts.longest.fasta
