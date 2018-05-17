# Programmer: Elton Vasconcelos (11/Apr/2018)
# Script primarily written for calculating relative abundance and plotting stripcharts (with a mean blue segment) for the "Chicken Seasonal Manuscript" from Brian Oakley
table4strip = read.table("feature-table_biom-wTaxa.tsv2", header = T, sep = "\t", check.names=F)
diffAbundTaxa = as.vector(c("k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Rikenellaceae;g__AF12;s__", "k__Bacteria;p__Firmicutes;c__Bacilli;o__Lactobacillales;f__Streptococcaceae;g__Streptococcus;s__alactolyticus", "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__Clostridium;s__piliforme", "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__;s__", "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Veillonellaceae;g__Megamonas;s__"))
j = 1
i = 2
b = matrix(ncol=87, nrow=5)
for (j in 1:length(diffAbundTaxa)) { for(i in 2:88) {  a = sum(table4strip[which(table4strip$Taxa == diffAbundTaxa[j]),i]) / sum(table4strip[,i]); b[j,i-1] = a; }}
rownames(b) = diffAbundTaxa
colnames(b) = colnames(table4strip)[2:88]
c = t(b)
pdf("ancom-diffAbund-stripcharts.pdf")
#for(i in 1:5) { stripchart(c[,i] ~ rownames(c), method = "jitter", vertical = TRUE, jitter = 0.2, pch=1,  main = colnames(c)[i], ylab = "rel_proportion"); y = as.vector(c(mean(c[which(rownames(c) == "fall"),i]), mean(c[which(rownames(c) == "spring"),i]), mean(c[which(rownames(c) == "summer"),i]), mean(c[which(rownames(c) == "winter"),i]))); segments(1:4-0.15,y,1:4+0.15,y,lwd=3, col="blue");}
for(i in 1:5) { stripchart(c[,i] ~ factor(rownames(c), levels=c("winter","spring","summer","fall")), method = "jitter", vertical = TRUE, jitter = 0.2, pch=1,  main = colnames(c)[i], ylab = "rel_proportion", cex.lab=1.8, cex.axis=1.5, cex.main=0.7, frame.plot = FALSE); y = as.vector(c(mean(c[which(rownames(c) == "winter"),i]), mean(c[which(rownames(c) == "spring"),i]), mean(c[which(rownames(c) == "summer"),i]), mean(c[which(rownames(c) == "fall"),i]))); segments(1:4-0.15,y,1:4+0.15,y,lwd=3, col="blue");}
dev.off()
