library(org.Hs.eg.db)
library(clusterProfiler)
args <- commandArgs(TRUE)
x = read.table(args[1], sep="\t") 	#input file is a 2-column table (log2FC and GeneSymbol), with a .tsv extension
geneFClist <- setNames(as.numeric(x[,1]), x[,2])
length(geneFClist)
degs <- names(geneFClist)[abs(geneFClist) > 1]
length(degs)
entrez =  bitr(names(geneFClist[degs]), fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
degs2entrez = geneFClist[entrez[,1]]
entrez =  bitr(names(degs2entrez), fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
degs.entrez = degs2entrez
names(degs.entrez) = entrez[,2]

### GSEA GO BP
degs.goBP = gseGO(sort(degs.entrez, decreasing=T), OrgDb=org.Hs.eg.db, ont="BP", keyType="ENTREZID", pvalueCutoff = 0.01)
edoxGObp = setReadable(degs.goBP, 'org.Hs.eg.db', 'ENTREZID')
outGObp = gsub(".tsv$", "-enrichGObp.tsv", args[1])
outGObpPlot = gsub("tsv$", "pdf", outGObp)
pdf(outGObpPlot)
dotplot(degs.goBP, showCategory=30, font.size=7)
cnetplot(edoxGObp, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxGObp, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxGObp@result, file=outGObp, sep="\t", quote=FALSE, row.names=FALSE)

### GSEA GO MF
degs.goMF = gseGO(sort(degs.entrez, decreasing=T), OrgDb=org.Hs.eg.db, ont="MF", keyType="ENTREZID", pvalueCutoff = 0.01)
edoxGOmf = setReadable(degs.goMF, 'org.Hs.eg.db', 'ENTREZID')
outGOmf = gsub(".tsv$", "-enrichGOmf.tsv", args[1])
outGOmfPlot = gsub("tsv$", "pdf", outGOmf)
pdf(outGOmfPlot)
dotplot(degs.goMF, showCategory=30, font.size=7)
cnetplot(edoxGOmf, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxGOmf, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxGOmf@result, file=outGOmf, sep="\t", quote=FALSE, row.names=FALSE)

### GO CC
degs.goCC = gseGO(sort(degs.entrez, decreasing=T), OrgDb=org.Hs.eg.db, ont="CC", keyType="ENTREZID", pvalueCutoff = 0.01)
edoxGOcc = setReadable(degs.goCC, 'org.Hs.eg.db', 'ENTREZID')
outGOcc = gsub(".tsv$", "-enrichGOcc.tsv", args[1])
outGOccPlot = gsub("tsv$", "pdf", outGOcc)
pdf(outGOccPlot)
dotplot(degs.goCC, showCategory=30, font.size=7)
cnetplot(edoxGOcc, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxGOcc, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxGOcc@result, file=outGOcc, sep="\t", quote=FALSE, row.names=FALSE)

## KEGG
degs.kegg = gseKEGG(sort(degs.entrez, decreasing=T), organism="hsa", keyType="ncbi-geneid", pvalueCutoff = 0.01)
edoxKEGG = setReadable(degs.kegg, 'org.Hs.eg.db', 'ENTREZID')
outKEGG = gsub(".tsv$", "-enrichKEGG.tsv", args[1])
outKEGGplot = gsub("tsv$", "pdf", outKEGG)
pdf(outKEGGplot)
dotplot(degs.kegg, showCategory=30, font.size=7)
cnetplot(edoxKEGG, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxKEGG, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxKEGG@result, file=outKEGG, sep="\t", quote=FALSE, row.names=FALSE)

## REACTOME
library(ReactomePA)
degs.react <- gsePathway(sort(degs.entrez, decreasing=T), pvalueCutoff = 0.01)
edoxREACT = setReadable(degs.react, 'org.Hs.eg.db', 'ENTREZID')
outREACT = gsub(".tsv$", "-enrichREACT.tsv", args[1])
outREACTplot = gsub("tsv$", "pdf", outREACT)
pdf(outREACTplot)
dotplot(degs.react, showCategory=30, font.size=7)
cnetplot(edoxREACT, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxREACT, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3)
dev.off()
write.table(edoxREACT@result, file=outREACT, sep="\t", quote=FALSE, row.names=FALSE)
