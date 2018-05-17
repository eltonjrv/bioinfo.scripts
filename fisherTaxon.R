# R script that calculates a Fisher Exact Test p-value for a user-defined taxon of interest
# Programmer: Elton Vasconcelos (15/Aug/2017)
# usage: Rscript fisherTaxon.R [input_table.tsv] [pattern_for_taxon_of_interest]
###########################################################################################
# NOTE: The input table must have three columns (treatment1, treatment2, Taxa), where the
# first two ones contain raw read counts for each taxon, and the third is the taxon name
# The columns must also have a header

args <- commandArgs(TRUE)
x = read.delim(args[1])
y = x[1:length(x[,1]) %in% grep(args[2], x[,3]),]
t_t1 = sum(y[,1])
t_t2 = sum(y[,2])
nt_t1 = sum(x[,1]) - t_t1
nt_t2 = sum(x[,2]) - t_t2
m4f = matrix(c(t_t1, t_t2, nt_t1, nt_t2), 2, 2, byrow = T)
m4f
fisher.test(m4f)$p.value
