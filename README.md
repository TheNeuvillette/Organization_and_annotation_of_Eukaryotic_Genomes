# Organization and Annotation of Eukaryotic Genomes

This repository contains the scripts and workflows coded and used during the "Organization and Annotation of Eukaryotic Genomes" course with the aim of transposable elements and gene annotation, as well as the comparative genomics analysis of *Arabidopsis thaliana* accessions, specifically focusing on the Etna-2 accession from the active volcano Mt. Etna in Sicily, Italy.

The workflow uses PacBio HiFi reads from accession Etna-2 for de novo genome assembly and Illumina reads from RNA-seq for de novo transcriptome assembly. Furthermore, PacBio HiFi reads from the accessions Ice-1, Are-6 and Altai-5 are used to explore comparative genomics. All raw data stems from the major papers [Qichao Lian et al.](https://www.nature.com/articles/s41588-024-01715-9) and [Jiao WB, Schneeberger K](https://www.nature.com/articles/s41467-020-14779-y).

# Workflow Overview

## 1. TE Annotation and Classification

### 1.1. TE Annotation using EDTA
- **`01_Run_EDTA.sh`** - Runs EDTA on the assembly for TE annotation.

### 1.2. Inferring LTR-RT Age from Percentage Identity
- **`02_01_Refine_LTR_classification.sh`** - Refines TE classification for full length LTR-RTs and split them into clades using TEsorter.
- **`02_02_Plot_LTR_Percent_Identity.R`** - Plots the age distribution of full-Length LTR retrotransposons by clade in the Copia and Gypsy superfamilies.

### 1.3. Visualizing TE annotations from EDTA
- **`03_01_Generate_Fai_index_file.sh`** - Produces a ".fai" index file required for the circle plot construction.
- **`03_02_Visualize_TE_Annotations.R`** - Creates a circle plot representation of the distribution and density of major TE superfamilies across the assembled genomic scaffolds.

### 1.4. Refining TE Classification with TEsorter
- **`04_01_Extract_Copia_Gypsy.sh`** - Extracts the Copia and Gypsy sequences from the EDTA-generated TE library for downstream analysis.
- **`04_02_Refine_Copia_Gypsy_Classification.sh`** - Refines the TE classification for Copia and Gypsy superfamilies and splits them into clades using TEsorter.

### 1.5. TE Age Estimation
- **`05_01_ParseRM.pl`** - Calculates the corrected percentage of divergence of each TE copy from its consensus sequence.
- **`05_02_Run_ParseRM.sh`** - Runs the ParseRM script.
- **`05_03_Plot_Div.r`** - Creates a TE Landscape Plot of Sequence Insertion Age Across Superfamilies.

## 2. Annotation of Genes with the MAKER Pipeline

### 2.1. MAKER Gene Annotation
- **`06_01_Create_MAKER_Control_File.sh`** - Generates the control files required for MAKER to run.
- **`06_02_Run_MAKER.sh`** - Run MAKER to annotate the genes in the assembly.
- **`06_03_Postprocessing_MAKER.sh`** - Sorts files, deletes duplicate records and merges GFF files.

### 2.2. Filtering and Refining Gene Annotations
- **`07_Filtering_Refining_Gene_Annotations.sh`** - Refines, filters and validates the gene annotations from MAKER.

### 2.3	Quality Assessment of Gene Annotations
- **`08_01_Extract_Longest_Isoform.sh`** - Extracts the longest isoform of transcripts or proteins to avoid BUSCO from seeing false gene duplicates.
- **`08_02_Run_BUSCO.sh`** - BUSCO quality assessment of gene annotation completeness.
- **`08_03_Plot_BUSCO.sh`** - Visualize the BUSCO results. 
- **`08_04_Run_AGAT.sh`** - Run AGAT for gene annotation summary statistics.

## 3. Orthology Based Gene Functional Annotation and Genome Comparisons

### 3.1. Testing Sequence Homology to Functionally Validated Proteins 
- **`09_Run_Blast.sh`** - Run Blast to find sequence homology of predicted protein-coding genes to curated protein databases. 

### 3.2. Comparative Genomics
- **`10_01_Genespace_Setup.sh`** - Creates BED and FASTA files containing the coordinates and peptide sequence for each gene. (Script coded and shared by Luis Ansorge (Github: luisansorge)).
- **`10_02_Genespace.R`** - Runs GENESPACE to obtain orthogroup assignments, generates riparian plots, and others.
- **`10_03_Run_Genespace.sh`** - Runs the Genespace.R script.
- **`10_04_Process_Pangenome.R`** - Visualizes the pangenome compostion via multiple plots. (Section 6 of script was coded and shared by Luis Ansorge (Github: luisansorge)).

# Dependencies

### Software, Tools

- TE Annotation and Classification: EDTA (version 2.2), TEsorter (version 1.3.0), R (version 4.4.1), Samtools (version 1.19), SeqKit (version 2.6.1), BioPerl (version 1.7.8)
- Annotation of Genes with the MAKER Pipeline: MAKER (version 3.01.03), OpenMPI (version 4.1.1), Augustus (version 3.4.0), UCSC-Utils (version 448-foss-2021a), MariaDB (version 10.6.4), InterProScan (version 5.70-102.0), BUSCO (version 5.4.2), AGAT (version 1.5.1)
- Orthology Based Gene Functional Annotation and Genome Comparisons: BLAST+ (version 2.15.0), GENESPACE

### R Packages
- tidyverse
- data.table
- cowplot
- circlize
- ComplexHeatmap
- dplyr
- reshape2
- GENESPACE
