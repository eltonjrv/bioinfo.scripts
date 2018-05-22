# Programmer: Elton Vasconcelos (21/May/2018)
# Script primarily written for calculating relative abundance and plotting stripcharts (with a mean blue segment) for the "Chicken Seasonal Manuscript" from Brian Oakley
# One should type file names as arguments in order to run with Rscript command
# Usage: Rscript diffAbundTaxa-stripCharts.R [otu_table.tsv] [diffAbundTaxa.txt]
#############################################################################
# NOTE-1: The otu_table.tsv must have the following header structure: OTU_ID\tSample1_category\tSample2_category\tSampleN_category\tTaxa
# where category corresponds to the experimental condition one wants to assess.
# For instance, in our chicken seasonal microbiome experiment, we used "winter", "summer", "fall" and "spring" as categories. 
# ATTENTION: The table header must not contain the sample IDs, only their corresponding target category/condition to be assessed on the stripchart
# NOTE-2: Each line in the diffAbundTaxa.txt file must contain a taxon description that perfectly matches the one present in the "Taxa" column from the otu_table.tsv
# NOTE-3: A "diffAbundTaxa-stripcharts.pdf" output will be generated in the current directory
args <- commandArgs(TRUE)
table4strip = read.table(args[1], header = T, sep = "\t", check.names=F)
x = read.table(args[2])
diffAbundTaxa = as.vector(x[,1])
nsamples = length(colnames(table4strip)) - 2	#-2 because of the first and last columns (OTU_ID and Taxa, respectively)
b = matrix(ncol= nsamples, nrow=length(diffAbundTaxa))
i = 1
j = 2
# Calculating relative abundance of all selected taxa (diffAbundTaxa.txt) in each sample:
for (i in 1:length(diffAbundTaxa)) { for(j in 2:(nsamples + 1)) {  a = sum(table4strip[which(table4strip$Taxa == diffAbundTaxa[i]),j]) / sum(table4strip[,j]); b[i,j-1] = a; }}
rownames(b) = diffAbundTaxa
colnames(b) = colnames(table4strip)[2:(nsamples + 1)]
z = t(b)
# Plotting the stripcharts for all selected taxa (diffAbundTaxa.txt)
pdf("ancom-diffAbundTaxa-stripcharts.pdf")
i = 1
for(i in 1:length(diffAbundTaxa)) { stripchart(z[,i] ~ factor(rownames(z)), method = "jitter", vertical = TRUE, jitter = 0.2, pch=1,  main = colnames(z)[i], ylab = "rel_proportion", cex.lab=1.5, cex.axis=1.2, cex.main=0.7, las=2, frame.plot = FALSE); y = as.vector(c(mean(z[which(rownames(z) == "F1_Conv"),i]), mean(z[which(rownames(z) == "F1_Org"),i]), mean(z[which(rownames(z) == "F2_Conv"),i]), mean(z[which(rownames(z) == "F2_Org"),i]))); segments(1:4-0.15,y,1:4+0.15,y,lwd=2, col="blue");}
dev.off()
