# R script that calculates shannon entropy values for each OTU
# Programmer: Elton Vasconcelos (20/Apr/2017)
# Usage: Rscript vegan_ntDiversity.R [OTU_table-QIIME_format]
#############################################################################
library(vegan)
args <- commandArgs(TRUE)
x = read.table(args[1], row.names=1)
y = t(x)
ydiv = diversity(y)
write.table(ydiv, file = "samples_diversity.tab", sep = "\t", quote = FALSE, col.names = FALSE)
