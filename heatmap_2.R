# Script adapted from https://github.com/DeWitP/SFG/tree/master/scripts
#install.packages("gplots")
library(gplots)

# type "?heatmap.2" to get the R documentation for heatmap.2 that describes the parameters and provides examples (also search the interwebs)
args = commandArgs(TRUE)
mydata <- read.delim(args[1], row.names=1) # select your .txt file of normalized fold difference or counts data
head(mydata) # check out your data
pairs.breaks <- seq(-2, 2, by=0.05)
length(pairs.breaks)  # take this value minus one as the input for n in the line below
mycol <- colorpanel(n=80, low="blue",mid="white",high="red") #n needs to be 1 less than length pairs.breaks
out <- gsub("4heatmap.tsv", "_heatmap.pdf", args[1])
pdf(out)
heatmap.2(data.matrix(mydata), Rowv=T, Colv=F, dendrogram = c("row"), scale = "none", keysize=1, breaks = pairs.breaks, col=mycol, trace = "none", symkey = F, density.info = "none", labCol=colnames(mydata), colsep=c(24), sepcolor=c("white"), sepwidth=c(.1,.1), margins = c(7,17), key.title=NA, key.xlab="Log2(FC)")
dev.off()
