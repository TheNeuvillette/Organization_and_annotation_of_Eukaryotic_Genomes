# Load the circlize package
library(circlize)
library(tidyverse)
library(ComplexHeatmap)

# Load the TE annotation GFF3 file
TE_anno_file <- "Hifiasm.bp.p_ctg.fa.mod.EDTA.TEanno.gff3"
TE_data <- read.table(TE_anno_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

gene_annotation_file <- "filtered.genes.renamed.gff3"
gene_annotation_data <- read.table(gene_annotation_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Check the superfamilies present in the GFF3 file, and their counts
TE_data$V3 %>% table()


# custom ideogram data
## To make the ideogram data, you need to know the lengths of the scaffolds.
## There is an index file that has the lengths of the scaffolds, the `.fai` file.
## To generate this file you need to run the following command in bash:
## samtools faidx assembly.fasta
## This will generate a file named assembly.fasta.fai
## You can then read this file in R and prepare the custom ideogram data

custom_ideogram <- read.table("Hifiasm.bp.p_ctg.fa.fai", header = FALSE, stringsAsFactors = FALSE)
custom_ideogram$chr <- custom_ideogram$V1
custom_ideogram$start <- 1
custom_ideogram$end <- custom_ideogram$V2
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
sum(custom_ideogram$end[1:20])

# Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
custom_ideogram <- custom_ideogram[1:20, ]

# Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
filter_superfamily <- function(TE_data, superfamily, custom_ideogram) {
  filtered_data <- TE_data[TE_data$V3 == superfamily, ] %>%
    as.data.frame() %>%
    mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
    select(chrom, start, end, strand) %>%
    filter(chrom %in% custom_ideogram$chr)
  return(filtered_data)
}

pdf("02-TE_density.pdf", width = 10, height = 10)
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram)

# add gene track to the plot
circos.genomicDensity(filter_superfamily(gene_annotation_data, "gene", custom_ideogram), count_by = "number", col = "black", track.height = 0.07, window.size = 1e5)
# Plot te density
circos.genomicDensity(filter_superfamily(TE_data, "Gypsy_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "#7FC97F", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "Mutator_TIR_transposon", custom_ideogram), count_by = "number", col = "#BEAED4", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "L1_LINE_retrotransposon", custom_ideogram), count_by = "number", col = "#FDC086", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "CACTA_TIR_transposon", custom_ideogram), count_by = "number", col = "#FFFF99", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "Copia_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "#386CB0", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "PIF_Harbinger_TIR_transposon", custom_ideogram), count_by = "number", col = "#F0027F", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "hAT_TIR_transposon", custom_ideogram), count_by = "number", col = "#BF5B17", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(TE_data, "Tc1_Mariner_TIR_transposon", custom_ideogram), count_by = "number", col = "#666666", track.height = 0.07, window.size = 1e5)
circos.clear()

lgd <- Legend(
  title = "Superfamily", at = c("Annotated Genes", "Gypsy (LTR)", "Mutator (TIR)", "L1 (LINE)", "CACTA (TIR)", "Copia (LTR)", "PIF Harbinger (TIR)", "hAT (TIR)", "Tc1 Mariner (TIR)"),
  legend_gp = gpar(fill = c("black", "#7FC97F", "#BEAED4", "#FDC086", "#FFFF99", "#386CB0", "#F0027F", "#BF5B17", "#666666"))
)
draw(lgd, x = unit(13, "cm"), y = unit(13, "cm"), just = c("center"))

dev.off()

# Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae).
# You need to run the TEsorter on TElib to get the clades classification from the TE library

# ============================================================
# 1. Load EDTA GFF3
# ============================================================

gff_file <- "Hifiasm.bp.p_ctg.fa.mod.EDTA.TEanno.gff3"
gff_data <- read.table(
  gff_file,
  header = FALSE,
  sep = "\t",
  stringsAsFactors = FALSE,
  comment.char = "#"
)

# ============================================================
# 2. Load Gypsy clade annotation (TEsorter output)
# ============================================================

gypsy_file <- "Gypsy_sequences.fa.rexdb-plant.cls.tsv"
gypsy_data <- read.table(
  gypsy_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  comment.char = ""       # KEEP "#" for parsing, don't treat as comment
)

# clean TE name column
gypsy_data <- gypsy_data %>%
  rename(TE_raw = X.TE) %>%
  mutate(
    TE = sub("#.*", "", TE_raw),      # remove trailing "#LTR/Gypsy"
    TE_base = sub("_.*", "", TE)      # extract family prefix: TE_00000094
  )

# ============================================================
# 3. Extract Athila and CRM TE base IDs
# ============================================================

athila_ids <- gypsy_data %>%
  filter(Clade == "Athila") %>%
  pull(TE_base)

crm_ids <- gypsy_data %>%
  filter(Clade == "CRM") %>%
  pull(TE_base)


# ============================================================
# 4. Filtering function to match GFF3 entries
# ============================================================

filter_clade <- function(gff_data, clade_base_ids, custom_ideogram) {
  
  gff_data %>%
    mutate(
      # extract Name field from V9
      Name = sub(".*Name=([^;]+).*", "\\1", V9),
      # Name is like TE_00000094_LTR → extract TE_00000094
      TE_base = sub("_.*", "", Name)
    ) %>%
    filter(TE_base %in% clade_base_ids) %>%
    transmute(
      chrom = V1,
      start = as.numeric(V4),
      end   = as.numeric(V5),
      strand = V7
    ) %>%
    filter(chrom %in% custom_ideogram$chr)
}


# ============================================================
# 5. Load the custom ideogram (scaffold lengths)
# ============================================================

custom_ideogram <- read.table(
  "Hifiasm.bp.p_ctg.fa.fai",
  header = FALSE,
  stringsAsFactors = FALSE
)

custom_ideogram <- custom_ideogram %>%
  transmute(
    chr = V1,
    start = 1,
    end = V2
  ) %>%
  arrange(desc(end)) %>%
  slice(1:20)     # top 20 largest scaffolds


# ============================================================
# 6. Produce circos plot
# ============================================================

pdf("TE_distribution_Athila_CRM.pdf", width = 10, height = 10)

gaps <- c(rep(1, nrow(custom_ideogram) - 1), 5)

circos.clear()  # reset BEFORE plotting

circos.par(
  start.degree = 90,
  gap.after = gaps,
  track.margin = c(0, 0),
  canvas.xlim = c(-1.4, 1.4),
  canvas.ylim = c(-1.4, 1.4)
)

circos.genomicInitialize(custom_ideogram)


# ---- Athila ----
athila_data <- filter_clade(gff_data, athila_ids, custom_ideogram)

if (nrow(athila_data) > 0) {
  circos.genomicDensity(
    athila_data,
    count_by = "number",
    col = "#FF6347",
    track.height = 0.1,
    window.size = 1e5
  )
} else {
  message("No Athila elements found.")
}


# ---- CRM ----
crm_data <- filter_clade(gff_data, crm_ids, custom_ideogram)

if (nrow(crm_data) > 0) {
  circos.genomicDensity(
    crm_data,
    count_by = "number",
    col = "#4682B4",
    track.height = 0.1,
    window.size = 1e5
  )
} else {
  message("No CRM elements found.")
}


# ---- Legend ----
lgd <- Legend(
  title = "Clade",
  at = c("Athila", "CRM"),
  legend_gp = gpar(fill = c("#FF6347", "#4682B4"))
)

draw(lgd, x = unit(12, "cm"), y = unit(13, "cm"), just = c("center"))

circos.clear()
dev.off()