#Mapping Variant Loci to Exclude in Primer Making
#Created by Sarah Lester
#Modified 09-01-2025

#Example files can be found in GitHub repository

if (!require(tidyverse)) install.packages("tidyverse")
if (!require(biomaRt)) BiocManager::install("biomaRt")
library(tidyverse)
library(biomaRt)

# VARIABLES YOU NEED TO CHANGE
# File paths
working_directory_path <- "working/directory/here/" # Make this the folder where all of your input files are and where you want your output files to go
sequence_raw_path <- "Gene_Sequence.txt" # Make sure this is a .txt file and in your working directory
variant_locations_path <- "Gene_Variant_Locations.csv" # Make sure this is a .csv file and in your working directory

# Genomic Coordinates - If on the positive strand (transcribed left to right on genome browser), start has a lower number than stop
#                       If on the negative strand (transcribed right to left on genome browser), start has a higher number than stop
start <- NUM_HERE
stop <- NUM_HERE

# Consequences of Interest - Can be changed if necessary
consequences <- c("coding_sequence_variant", 
                  "frameshift_variant",  
                  "inframe_deletion",
                  "inframe_insertion",
                  "missense_variant",
                  "synonymous_variant",
                  "start_lost", 
                  "start_retained_variant",
                  "stop_gained",
                  "stop_lost",
                  "stop_retained_variant")

# THIS SECTION SHOULD REMAIN UNCHANGED
setwd(working_directory_path)
geneName <- str_split_i(sequence_raw_path, "_", 1)

#Read in sequence txt file with sequence copy-pasted from the genome browser with header "Sequence"
sequence_raw <- data.frame(read.delim(sequence_raw_path), stringsAsFactors = FALSE)

#Combine rows into a single row
sequence_raw$group <- 1
sequence_merged <- sequence_raw %>%
                    group_by(group) %>%
                    summarise(Sequence = paste(Sequence, collapse = ""))
sequence <- sequence_merged$Sequence

#Split sequence into individual characters
sequence <- unlist(strsplit(sequence, split = ""))

names(sequence) <- seq(from = start, to = stop)

#Find exons based on capital letters (introns are lowercase, exons are uppercase)
uppers <- unlist(gregexpr("[A-Z]", sequence))
names(uppers) <- names(sequence)

#Trim introns out of sequence
sequence_trimmed <- sequence[which(uppers == 1)]
sequenceForIDT <- paste0(sequence_trimmed, collapse = "")

#Get positions of exon end points for primers/probes that need to cover exon junctions
junctions <- which(diff(uppers) == -2)

#Change exon junctions to "J"
sequence_junctions <- sequence
sequence_junctions[junctions]  <- "J"

#Trim introns out of sequence_junctions
sequence_trimmed <- sequence_junctions[which(uppers == 1)]

#Read in list of variant locations
variants <- read.csv(variant_locations_path)

### START TEST ###
# Verify that consequences match those in Ensembl 104
# Retaining for additional testing

# ensembl104 <- useEnsembl(biomart = "snps", version = 104, dataset = "mmusculus_snp")
# 
# forVerification <- getBM(attributes = c("refsnp_id", "chrom_start", "chrom_end", "consequence_type_tv", "snp"),
#                          filters = "snp_filter",
#                          values = variants$SNP.ID,
#                          mart = ensembl104)
# 
# test <- variants %>% left_join(forVerification, by = join_by(SNP.ID == refsnp_id))

## On first glance it looks like yes, at least for this gene they match
### END TEST ###

# Get updated annotation from current ensembl version
ensembl <- useEnsembl(biomart = "snps", dataset = "mmusculus_snp")

newAnno <- getBM(attributes = c("refsnp_id", "chrom_start", "consequence_type_tv"),
                 filters = "snp_filter",
                 values = variants$SNP.ID,
                 mart = ensembl)

# Join new annotation, 
# filter for consequences of interest in most current ensembl version,
# Rename chrom_start (most current position) for use in rest of script
variants_newAnno <- variants %>% full_join(newAnno, by = join_by(SNP.ID == refsnp_id)) %>% 
                                 filter(consequence_type_tv %in% consequences) %>% 
                                 rename(Position = chrom_start) %>% 
                                 mutate()

#Use variant list to change snps from base to "SNP" to easily see where they are
sequence_trimmed[names(sequence_trimmed) %in% variants_newAnno$Position] <- "SNP"

#Renumber sequence to reflect length, not genomic position
sequence_renumber <- sequence_trimmed
names(sequence_renumber) <- seq(from = 1, to = length(sequence_renumber))

#Get exon junction coordinates in renumbered sequence
junctions <- names(sequence_renumber[sequence_renumber == "J"])
junctions <- paste(junctions, collapse = ", ")

#Get new snp position identifiers and format them into ranges that can be easily copy-pasted into primer-making tools
to_avoid <- names(sequence_renumber[which(sequence_renumber == "SNP")])
to_avoid <- data.frame(to_avoid, to_avoid)
to_avoid$x <- paste(to_avoid$to_avoid, to_avoid$to_avoid.1, sep = "-")
to_avoid <- to_avoid$x
to_avoid <- paste(to_avoid, collapse = ", ")

#Output a CSV with all relevant information
#This is all just to make the final document easier to read
results <- data.frame(Result = c("Sequence For IDT", "Excluded Region List/SNPs to Avoid", "Overlap Junction List"),
                        Data = c(sequenceForIDT, to_avoid, junctions))

results <- results %>% add_row(Result = "", Data = "", .after = 1)
results <- results %>% add_row(Result = "", Data = "", .after = 3)

write.table(results, file = paste0(geneName, "_IDT_Inputs.txt"), col.names = FALSE, row.names = FALSE)
