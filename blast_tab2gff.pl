#!/usr/bin/perl
# Programmer: Elton Vasconcelos (11/Jun/2014)
# Usage: perl blast_tab2gff.pl [blast_tabular.tab] >output.gff
##########################################################################

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line = <FILE>;
chomp($line);
my @array;
my $strand;
my $fmin; my $fmax;
my @query; #my $last_query;
while ($line ne "") {
    #my $m = 0;     #marker to detect if the "for" loop below has printed some line
    @array = split(/\t/, $line);
    push(@query, $array[0]);
    if ($array[8] < $array[9]) { #$array[8] and [9] are the columns where the sbjct coordinates are placed
        $strand = "+";
        $fmin = $array[8];
        $fmax = $array[9];
        
    }
    else {
        $strand = "-";
        $fmin = $array[9];
        $fmax = $array[8];
    }
    if ($array[0] eq $query[-2]) {
        print("$array[1]\tSBRI\tgene\t$fmin\t$fmax\t$array[11]\t$strand\t\.\tID=$array[0]\;colour=238+58+140\;note=secondary+Blast+hit+\(e-Value+=+$array[10]\,+\%id+=+$array[2]\)\n");
    }
    else {
        print("$array[1]\tSBRI\tgene\t$fmin\t$fmax\t$array[11]\t$strand\t\.\tID=$array[0]\;colour=123+104+238\;note=primary+Blast+hit+\(e-Value+=+$array[10]\,+\%id+=+$array[2]\)\n");
    }
    $line = <FILE>;
    chomp($line);
}