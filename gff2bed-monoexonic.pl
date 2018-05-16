#!/usr/bin/perl
# Programmer: Elton Vasconcelos (30/Dec/2013)
# Usage: perl gff2bed-monoexonic.pl infile.gff >outfile.bed

open (INFILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <INFILE>;
chomp($line);
my (@array, $chrID, $geneID, $fmin, $fmax, $strand, $blockSize);

while ($line ne "") {
    @array = split(/\t/, $line);
    $chrID = $array[8];
    $chrID =~ s/^ID\=//g;
    $chrID =~ s/\.\d+\;.*//g;
    $chrID =~ s/Schisto_mansoni/Sm/g;
    $geneID = $array[8];
    $geneID =~ s/^.*locus_tag\=//g;
    $fmin = $array[3] - 1;
    $fmax = $array[4];
    $strand = $array[6];
    $blockSize = $array[4] - $array[3] + 1;
    print ("$chrID\t$fmin\t$fmax\t$geneID\t500\t$strand\t$fmin\t$fmax\t255,0,0\t1\t$blockSize\t0,\n");
    $line = <INFILE>;
    chomp($line);
}