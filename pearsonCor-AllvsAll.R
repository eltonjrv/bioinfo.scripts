# R script
# Programmer: Elton Vasconcelos (20/May/2016)
# Script that calculates the Pearson Correlation Coefficient between all combinations of pairs of rows in a table.
# USAGE: Rscript pearsonCor-AllvsAll.R [tabular_file]
##################################################################################################################
# NOTE-1: It is ideal that your input table has a header 
# NOTE-2: The first column must be gene/feature IDs, and all other columns must be numerical values
args <- commandArgs(TRUE)
f = read.delim(args[1])		#ATTENTION: If your table doesn't have header, use read.table instead of read.delim
n = length(f[,1])
for (i in 1:(n-1)) {
	for (j in (i+1):n) {
		a = cor.test(as.vector(as.matrix(f[j,2:ncol(f)])),as.vector(as.matrix(f[i,2:ncol(f)])));
		genes = as.vector(f[i:j,1]);
		out = t(as.vector(c(genes[1], genes[length(genes)], a$estimate, a$p.value)));
		write.table(out, file = "pccAll.tsv", append = TRUE, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE);
	}
}

