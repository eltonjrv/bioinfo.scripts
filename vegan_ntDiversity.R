library(vegan)
args <- commandArgs(TRUE)
x = read.delim(args[1], row.names=1)
x[is.na(x)] = 0
xdiv = diversity(x)
out = gsub("-bc.tab", "-div.tab", args[1])
write.table(xdiv, file = out, sep = "\t", quote = FALSE, col.names = FALSE)
