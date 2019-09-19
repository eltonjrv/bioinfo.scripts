# Rscript
# Programmer: Elton Vasconcelos (31/May/2018)
# Usage: Rscript histogram-wDistCurve.R [input.tsv] [output.png]
################################################################
# NOTE-1: input.tsv must be a two columns table: SampleID \t #Reads
# NOTE-2: Edit the labels on "hist" function as you want to be displayed in your chart 
args = commandArgs(TRUE)
x = read.table(args[1])	# This is a 2 columns table: SampleID \t #Reads

## Using density function just to see how the distribution looks like
d = density(x$V2)
plot(d)
d = density(log10(x$V2))
plot(d)

## Plotting a histogram and assigning it to a variable "h"
hist(log10(x[,2]), breaks=100, xlim=c(0,6), ylim=c(0,10), ylab="Number of Samples", xlab="Number of reads (log10)", main="18S samples after demultiplexing", col="gray")
h = hist(log10(x[,2]), breaks=100, xlim=c(0,6), ylim=c(0,10), ylab="Number of Samples", xlab="Number of reads (log10)", main="18S samples after demultiplexing", col="gray")

## Fitting a distribution curve
xfit<-seq(min(log10(x[,2])),max(log10(x[,2])),length=6) 
yfit<-dnorm(xfit,mean=mean(log10(x[,2])),sd=sd(log10(x[,2])))
yfit <- yfit*diff(h$mids[1:2])*length(x[,2]) 
lines(xfit, yfit, col="blue", lwd=2) 

## Saving the chart in a png file
png(commandArgs[2])
hist(log10(x[,2]), breaks=100, xlim=c(0,6), ylim=c(0,10), ylab="Number of Samples", xlab="Number of reads (log10)", main="18S samples after demultiplexing", col="gray")
lines(xfit, yfit, col="blue", lwd=2) 
dev.off()
