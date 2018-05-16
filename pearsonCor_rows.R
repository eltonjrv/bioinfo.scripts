# R script
# Programmer: Elton Vasconcelos (20/May/2013)
# Script that calculates the Pearson Correlation Coefficient between all combinations of pairs of rows in a table.
# USAGE: Rscript pearsonCor_rows.R [tabular_file]
##############################################
args <- commandArgs(TRUE)
file = read.delim(args[1])
m = as.matrix(file[,2:ncol(file)])	#excluding the first column which is GeneID (or any other feature name), and taking only the numerical columns
n = dim(m)
all_pcc = NULL
i=1
j=2
for(i in 1:(n-1)) { for(j in (i+1):n) { pcc_pair = cor(m[j,], m[i,]); all_pcc = c(all_pcc, pcc_pair)}}
mean(all_pcc)
write(all_pcc, file = "all-pairwise-cor.txt")
