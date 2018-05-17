args <- commandArgs(TRUE)
x = read.table(args[1])
mean(x[,1])
median(x[,1])
