##############
# Programmer: Elton Vasconcelos (08/02/2022)
# Usage: Rscript EVolcano-auto.R DESeq2_output_table
# NOTE: The input must have the following 9 columns: "GeneID" "baseMean" "log2FoldChange" "lfcSE" "stat" "pvalue" "padj" "GeneSymbol" "Biotype"
# The two last columns are customized ones, if you don't have them, consider editing the EnhancedVolcano function with "lab = x[,1]", and comment the for loop where x$newlab is created.
#############
library(EnhancedVolcano)
library(dplyr)
library(stringi)

args = commandArgs(TRUE)
x = read.delim(args[1])

for (i in 1:length(x[,8])) { if(stri_detect_regex(x[i,8], "^gene_source") == "TRUE") { x$newlab[i] = as.character(x$Biotype[i]) } else { x$newlab[i] = as.character(x$GeneSymbol[i]) } }

outpdf = gsub(".[a-z]+$", "-volcanoPlot.pdf", args[1])
pdf(outpdf)
EnhancedVolcano(x, lab = x$newlab, x = 'log2FoldChange', y = 'padj', xlim = c(round(min(x[,3], na.rm=TRUE)-1),round(max(x[,3], na.rm=TRUE)+1)), ylim = c(0,round(-log10(x[1,7])+1)), FCcutoff=1, pCutoff = 0.05, labSize=2, col = c("grey30", "orange", "royalblue", "red2"), title = gsub(".[a-z]+$", "", args[1]), drawConnectors = TRUE, widthConnectors = 0.3, colConnectors = "grey")
dev.off()
