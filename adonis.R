library(vegan)
x = read.table("bDivPlots/weighted_unifrac_dm-woNTC.txt", header=T, check.names=F)
rownames(x)
y = read.delim("bDivPlots/sample-metadata-woNTC-sameOrderAsDM.tsv", row.names=1)
rownames(y)
### ATTENTION: The rownames from both x and y must be on the same order
adonis(x ~ y$Description, data=y)
