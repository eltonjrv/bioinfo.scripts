# R script that calculates shannon entropy values for each column of a MSA
# Programmer: Elton Vasconcelos (20/Apr/2017)
# Usage: Rscript vegan_ntDiversity.R [output from baseCount_perMSAcolumn.pl script]
#############################################################################
library(vegan)
args <- commandArgs(TRUE)
x = read.delim(args[1], row.names=1)
x[is.na(x)] = 0
xdiv = diversity(x)
out = gsub(".tab", "-div.tab", args[1])     # Edit here according to your input file extension (if it is not .tab, replace by what it is)
write.table(xdiv, file = out, sep = "\t", quote = FALSE, col.names = FALSE)
