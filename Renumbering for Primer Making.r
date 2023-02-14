#Mapping Variant Loci to Exclude in Primer Making
#Created by Sarah Lester
#Modified 02-14-23

#Example files can be found in GitHub repository

library(tidyverse)

setwd("Working/Directory/Here")

#Read in sequence txt file with sequence copy-pasted from the genome browser with header "Sequence"
sequence_raw <- data.frame(read.delim("Sequence_From_GenomeBrowser.txt"), stringsAsFactors = FALSE)

#Combine rows into a single row
sequence_raw$group <- 1
sequence_merged <- sequence_raw %>%
                    group_by(group) %>%
                    summarise(Sequence = paste(Sequence, collapse = ""))
sequence <- sequence_merged$Sequence

#Split sequence into individual characters
sequence <- unlist(strsplit(sequence, split = ""))

#Assign genomic coordinates to sequence (make sure you consider whether the gene is transcribed on the + or - strand!)
#No need for chromosome number, just start and stop loci
start <- 108811175
stop <- 108841609
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
variants <- read.delim("Variant_Locations.txt")

#Use variant list to change snps from base to "SNP" to easily see where they are
sequence_trimmed[names(sequence_trimmed) %in% variants$Position] <- "SNP"

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
results <- data.frame(Result = c("Sequence For IDT", "SNPs To Avoid", "Exon Junctions"),
                        Data = c(sequenceForIDT, to_avoid, junctions))

results <- results %>% add_row(Result = "", Data = "", .after = 1)
results <- results %>% add_row(Result = "", Data = "", .after = 3)

write.table(results, file = "IDT_Inputs.txt", col.names = FALSE, row.names = FALSE)