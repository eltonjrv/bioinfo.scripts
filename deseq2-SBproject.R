library(DESeq2)
library(edgeR)
library(sva)

metadata = read.table("sampleGroups.tab", row.names = 1, sep="\t")
dim(metadata)
colnames(metadata) = c("CellType")
metadata$batch = c(rep("NextSeq_3rd", 8), rep("HighSeq_1st", 39), rep("HighSeq_2nd", 6))

hs1 = read.delim("1stBatch-rawCounts-44k.tsv", row.names=1)
hs2 = read.delim("2ndBatch-rawCounts-44k.tsv", row.names=1)
ns3 = read.delim("3rdBatch-rawCounts-44k.tsv", row.names=1)
df = cbind(ns3, hs1, hs2)
keep = rowSums(df) >= 1
df.keep = df[keep,]

df.keep.adj <- ComBat_seq(as.matrix(df.keep), batch=metadata$batch, group=NULL)
group = factor(c(rep("3", 8), rep("1", 39), rep("2", 6)))
z = DGEList(counts=df.keep.adj, group=group)
z = calcNormFactors(z)
mdsBEC <- plotMDS(z)
pdf("MDSplot_edgeR-BEcorrec.pdf")
plot(mdsBEC, col=cols[group], pch=16)
legend("bottomright", legend=unique(metadata$batch), col = unique(cols[as.factor(metadata$batch)]), pch=16)
plotMDS(z, cex=0.3)
plot(mdsBEC, col=cols[as.factor(metadata$CellType)], pch=16)
legend("bottomright", legend=unique(metadata$CellType), col = unique(cols[as.factor(metadata$CellType)]), pch=16)
dev.off()


ddsBEC = DESeqDataSetFromMatrix(countData=df.keep.adj, colData=metadata, design =~ CellType)
ddsBEC = DESeq(ddsBEC, fitType="local")
vst_transf_BEC = varianceStabilizingTransformation(ddsBEC, blind=T)

ddsBEC_batch = DESeqDataSetFromMatrix(countData=df.keep.adj, colData=metadata, design =~ batch)
ddsBEC_batch = DESeq(ddsBEC_batch, fitType="local")
vst_transf_batch_BEC = varianceStabilizingTransformation(ddsBEC_batch, blind=T)

## Plotting PCAs by CellType and Batch
pdf("PCA-DESeq-BEcorrec.pdf")
plotPCA(vst_transf_BEC, intgroup="CellType")
plotPCA(vst_transf_batch_BEC, intgroup="batch")
dev.off()

## Catching DE results (3 pairwise comparisons)
ddsBEC.res.1 = results(ddsBEC, contrast=c("CellType", "PatientDerived", "Ctrl"))
ddsBEC.res.2 = results(ddsBEC, contrast=c("CellType", "ESCSC", "Ctrl"))
ddsBEC.res.3 = results(ddsBEC, contrast=c("CellType", "ESCSC", "PatientDerived"))
summary(ddsBEC.res.1)
summary(ddsBEC.res.2)
summary(ddsBEC.res.3)
write.table(ddsBEC.res.1[order(ddsBEC.res.1$padj),], file="Ctrl-vs-PatDeriv_DESeq2_BEcorrec.tsv", sep = "\t", quote=F, col.names=NA)
write.table(ddsBEC.res.2[order(ddsBEC.res.2$padj),], file="Ctrl-vs-ESCSC_DESeq2_BEcorrec.tsv", sep = "\t", quote=F, col.names=NA)
write.table(ddsBEC.res.3[order(ddsBEC.res.3$padj),], file="PatDeriv-vs-ESCSC_DESeq2_BEcorrec.tsv", sep = "\t", quote=F, col.names=NA)
save.image()
