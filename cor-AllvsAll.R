f = read.delim("SMPsLincRNAs-allStages-TPMs_gt1_onAtLeastOneStage.tsv")
n = length(f[,1])
for (i in 1:(n-1)) {
	for (j in (i+1):n) {
		a = cor.test(as.vector(as.matrix(f[j,2:16])),as.vector(as.matrix(f[i,2:16])));
		genes = as.vector(f[i:j,1]);
		out = t(as.vector(c(genes[1], genes[length(genes)], a$estimate, a$p.value)));
		write.table(out, file = "pccAll.tsv", append = TRUE, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE);
	}
}

