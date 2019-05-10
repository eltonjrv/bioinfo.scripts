### Rscript for detecting the N50 and plotting a histogram for your assembly 
## Programmer: Elton Vasconcelos (10/May/2016)
# NOTE: One must sort contigs' lengths from the assembly fasta output (descending order), and provide this numerical-only text file as input argument for this script
# USAGE: Rscript get-N50-hist.R [contigs_length.txt]

args <-  commandArgs(TRUE)
x = read.table(args[1])	# file where each line represents a contig length (bp)
total = sum(x[,1])
i = 1
soma = 0
ncontigs = length(x[,1])
for (i in c(i:ncontigs)) { soma = soma+x[i,]; if ((soma / total) >= 0.5) {j=as.vector(c(i, soma)); print(j); break}  }

### One must grab the i on the first print of j and type the following to catch the N50
cat("N50 = ", x[i,], "bp", "\n")
cat("Total bases = ", total, "\n")
pdf("histogram.pdf")
hist(x[,1], xlab = "Range (bp)", ylab = "# contigs", main = "", col = "grey", breaks = 100)
dev.off()
