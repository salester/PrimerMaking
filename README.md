# PrimerMaking
Trimming, re-indexing, and mapping SNPs and exon junctions for primer design tools.

There are example files in this repository with the required formatting for you to refer baack to.

Genome Browser link: http://genome.ucsc.edu/cgi-bin/hgTracks?db=mm39&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=chr12%3A56741761%2D56761390&hgsid=1906059936_BMPFsOR39Pbdg5TNJaXxHAHe9bdr

MAKE SURE YOU'RE USING MOUSE GENOME MM39

Search for your gene of interest and select gene from drop down list 

Left-click on blue gene name on left hand side of genome browser

Under "Sequence and Links" section, click "Genomic Sequence"

Under "Sequence Retrieval Region Options", select 5' UTR exons, CDS exons, 3'UTR exons, and introns; also select one FASTA record per gene

Under "Sequence Formatting Options", select Exons in uppercase, everything else in lowercase

Click SUBMIT

On the first line where it says range: that's your genomic coordinates that you'll use for start and stop, and where you put the higher number is determined by the strand (+ or -) [see script for guidelines]

Copy the entire sequence into a .txt file that has "Sequence" on the first line and name it something like "GeneName_Sequence.txt"

CC Founder Variants link: https://churchilllab.jax.org/foundersnps/search

Select Release = REL-2021 SNP

Click "Need help finding a gene?" to use the gene's name to get its Ensembl ID, which you can click on paste it into the search box and click "Go"

Click "Download Data"

In Excel, filter to include only the following consequences: 
    Coding_sequence_variant
    Frameshift_variant
    Inframe_deletion
    Inframe_insertion
    Missense_variant
    Synonymous_variant
    Start_lost
    Start_retained_variant
    Stop_gained
    Stop_lost
    Stop_retained_variant

In a new spreadsheet, make your first column "Gene" and your second "Position." Paste the positions from the .csv you just filtered and put the gene name in each row. Save this as "GeneName_Variant_Locations.txt" MAKE SURE IT IS SAVED AS A .TXT FILE.