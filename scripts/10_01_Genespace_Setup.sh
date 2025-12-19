#!/bin/bash

#SBATCH --job-name=Genespace_setup
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=120
#SBATCH --mem=200G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


# Paths and Variables:
WORKDIR=/data/users/jimhof/Organization_and_annotation_of_Eukaryotic_Genomes
OUTDIR=$WORKDIR/results/10_Comparative_Genomics

COURSE_DATA="/data/courses/assembly-annotation-course/CDS_annotation/data"
LIAN_GFF="${COURSE_DATA}/Lian_et_al/gene_gff/selected"
LIAN_PROTEIN="${COURSE_DATA}/Lian_et_al/protein/selected"

# Accession names, underscores for GENESPACE compatibility
MY_ACCESSION="Etna_2"
OTHER_ACCESSIONS=("Altai_5" "Are_6" "Ice_1")

# Create output directory:
mkdir -p "$OUTDIR"
cd "$OUTDIR"
mkdir -p "${OUTDIR}/peptide" # peptide FASTA files
mkdir -p "${OUTDIR}/bed"     # bed files for gene locations

# Process Etna-2
GFF_FILE=$WORKDIR/results/07_Filtering_Refining_Gene_Annotation/filtered.genes.renamed.gff3
PROTEIN_FILE=$WORKDIR/results/08_Quality_Assessment_of_Gene_Annotations/maker_proteins.longest.fasta

# Create bed file from GFF3 (chr, start, end, gene_name)
grep -P "\tgene\t" "${GFF_FILE}" | \
awk 'BEGIN{OFS="\t"} {
    split($9, a, ";");
    split(a[1], b, "=");
    gene_id = b[2];
    gsub(/[:.-]/, "_", gene_id);
    print $1, $4-1, $5, gene_id
}' | sort -k1,1 -k2,2n > "${OUTDIR}/bed/${MY_ACCESSION}.bed"

# Create peptide FASTA file with cleaned IDs
awk '
/^>/ {
    if(seq != "") {
        print seq;
    }
    id = substr($1, 2);
    sub(/-R.*/, "", id);
    sub(/\.[0-9]+$/, "", id);
    gsub(/[:.-]/, "_", id);
    print ">" id;
    seq = "";
    next;
}
{
    gsub(/[^A-Za-z*]/, "", $0);
    seq = seq $0;
}
END {
    if(seq != "") {
        print seq;
    }
}
' "${PROTEIN_FILE}" > "${OUTDIR}/peptide/${MY_ACCESSION}.fa"

# Process TAIR10 reference genome, clean IDs
awk 'BEGIN{OFS="\t"} {
    gene_id = $4;
    sub(/\.[0-9]+$/, "", gene_id);
    gsub(/[:.-]/, "_", gene_id);
    print $1, $2, $3, gene_id;
}' "${COURSE_DATA}/TAIR10.bed" | sort -k1,1 -k2,2n > "${OUTDIR}/bed/TAIR10.bed"

# Clean TAIR10 peptide FASTA (same cleaning as above)
awk '
/^>/ {
    if(seq != "") {
        print seq;
    }
    id = substr($1, 2);
    sub(/\.[0-9]+$/, "", id);
    gsub(/[:.-]/, "_", id);
    print ">" id;
    seq = "";
    next;
}
{
    gsub(/[^A-Za-z*]/, "", $0);
    seq = seq $0;
}
END {
    if(seq != "") {
        print seq;
    }
}
' "${COURSE_DATA}/TAIR10.fa" > "${OUTDIR}/peptide/TAIR10.fa"

# Process other accessions from Lian et al. dataset
for ACC in "${OTHER_ACCESSIONS[@]}"; do
    ACC_DASH="${ACC//_/-}"
    
    GFF="${LIAN_GFF}/${ACC_DASH}.*.gff"
    GFF=$(ls ${GFF} 2>/dev/null | head -n 1)
    
    PROT="${LIAN_PROTEIN}/${ACC_DASH}.protein.faa"
    PROT=$(ls ${PROT} 2>/dev/null | head -n 1)
    
    if [[ -z "${GFF}" ]] || [[ -z "${PROT}" ]]; then
        continue
    fi
    
    grep -P "\tgene\t" "${GFF}" | \
    awk 'BEGIN{OFS="\t"} {
        split($9, a, ";");
        split(a[1], b, "=");
        gene_id = b[2];
        gsub(/[:.-]/, "_", gene_id);
        print $1, $4-1, $5, gene_id
    }' | sort -k1,1 -k2,2n > "${OUTDIR}/bed/${ACC}.bed"
    
    awk '
    /^>/ {
        if(seq != "") {
            print seq;
        }
        id = substr($1, 2);
        sub(/-R.*/, "", id);
        sub(/\.[0-9]+$/, "", id);
        gsub(/[:.-]/, "_", id);
        print ">" id;
        seq = "";
        next;
    }
    {
        gsub(/[^A-Za-z*]/, "", $0);
        seq = seq $0;
    }
    END {
        if(seq != "") {
            print seq;
        }
    }
    ' "${PROT}" > "${OUTDIR}/peptide/${ACC}.fa"
done

echo "Done"