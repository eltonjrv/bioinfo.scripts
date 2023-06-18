# Programmer: Elton Vasconcelos (13/Oct/2015)
# Usage: Rscript fisher4GOenrichment.R [GO.count] [number_of_genes_on_list]  [total_number_of_genes_with_GO]
####################################################################################################
### The following is an input file example, where col2 is the number of genes on the list and col3 is the total number of genes assigned to the GO term on col1:
#GO:0000166	2	61
#GO:0003676	2	243
#GO:0003677	1	267
#GO:0003700	1	116
#GO:0003735	1	111

args <- commandArgs(TRUE)
x = read.table(args[1])
i = 1
n = dim(x)
glist = as.numeric(c(args[2]))
total_genes_wGO = as.numeric(c(args[3]))
for (i in c(i:n)) {
  onList_onGO = x[i,2];
  onList_notGO = glist - x[i,2];
  onGO_notList = x[i,3] - x[i,2];
  notList_notGO = total_genes_wGO - onList_onGO - onList_notGO - onGO_notList;
  y <- matrix(c(onList_onGO, onList_notGO, onGO_notList, notList_notGO), 2, 2, byrow=T);
  print(fisher.test(y)$p.value);
}
