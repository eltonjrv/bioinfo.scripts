library(org.Hs.eg.db)
library(clusterProfiler)
args <- commandArgs(TRUE)
x = read.table(args[1], sep="\t") 	#input file is a 2-column table (log2FC and GeneSymbol)
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
pdf("bubbleChart_cnetPlot-PDvsCL-fullDEGsLits-enrichGObp.pdf")
dotplot(degs.goBP, showCategory=30, font.size=7)
cnetplot(edoxGObp, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxGObp, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxGObp@result, file="PDvsCL-fullDEGsLits-enrichGObp.tsv", sep="\t", quote=FALSE, row.names=FALSE)

### GSEA GO MF
degs.goMF = gseGO(sort(degs.entrez, decreasing=T), OrgDb=org.Hs.eg.db, ont="MF", keyType="ENTREZID", pvalueCutoff = 0.01)
edoxGOmf = setReadable(degs.goMF, 'org.Hs.eg.db', 'ENTREZID')
pdf("bubbleChart_cnetPlot-PDvsCL-fullDEGsLits-enrichGOmf.pdf")
dotplot(degs.goMF, showCategory=30, font.size=7)
cnetplot(edoxGOmf, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxGOmf, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxGOmf@result, file="PDvsCL-fullDEGsLits-enrichGOmf.tsv", sep="\t", quote=FALSE, row.names=FALSE)

### GO CC
degs.goCC = gseGO(sort(degs.entrez, decreasing=T), OrgDb=org.Hs.eg.db, ont="CC", keyType="ENTREZID", pvalueCutoff = 0.01)
edoxGOcc = setReadable(degs.goCC, 'org.Hs.eg.db', 'ENTREZID')
pdf("bubbleChart_cnetPlot-PDvsCL-fullDEGsLits-enrichGOcc.pdf")
dotplot(degs.goCC, showCategory=30, font.size=7)
cnetplot(edoxGOcc, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxGOcc, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxGOcc@result, file="PDvsCL-fullDEGsLits-enrichGOcc.tsv", sep="\t", quote=FALSE, row.names=FALSE)

## KEGG
degs.kegg = gseKEGG(sort(degs.entrez, decreasing=T), organism="hsa", keyType="ncbi-geneid", pvalueCutoff = 0.01)
edoxKEGG = setReadable(degs.kegg, 'org.Hs.eg.db', 'ENTREZID')
pdf("bubbleChart_cnetPlot-PDvsCL-fullDEGsLits-enrichKEGG.pdf")
dotplot(degs.kegg, showCategory=30, font.size=7)
cnetplot(edoxKEGG, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxKEGG, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3) 
dev.off()
write.table(edoxKEGG@result, file="PDvsCL-fullDEGsLits-enrichKEGG.tsv", sep="\t", quote=FALSE, row.names=FALSE)

## REACTOME
library(ReactomePA)
degs.react <- gsePathway(sort(degs.entrez, decreasing=T), pvalueCutoff = 0.01)
edoxREACT = setReadable(degs.react, 'org.Hs.eg.db', 'ENTREZID')
pdf("bubbleChart_cnetPlot-PDvsCL-fullDEGsLits-enrichREACT.pdf")
dotplot(degs.react, showCategory=30, font.size=7)
cnetplot(edoxREACT, foldChange=degs2entrez, node_label="category") 
cnetplot(edoxREACT, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3, cex_label_category = 3)
dev.off()
write.table(edoxREACT@result, file="PDvsCL-fullDEGsLits-enrichREACT.tsv", sep="\t", quote=FALSE, row.names=FALSE)

## GSEA Disease Ontology (DO)
#degs.gsea = gseDO(sort(degs.entrez, decreasing=T))
#edox = setReadable(degs.gsea, 'org.Hs.eg.db', 'ENTREZID')
#pdf("bubbleChart_cnetPlot-PDvsCL-fullDEGsLits-GSEA.pdf")
#dotplot(degs.gsea, showCategory=30, font.size=7)
#cnetplot(edox, foldChange=degs2entrez, node_label="all", cex_label_gene = 0.3) 
#dev.off()
#write.table(edox@result, file="PDvsCL-fullDEGsLits-GSEA.tsv", sep="\t", quote=FALSE, row.names=FALSE)
