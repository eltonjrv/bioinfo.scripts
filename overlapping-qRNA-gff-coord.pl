#!/usr/bin/perl
#Programmer: Elton Vasconcelos (04/May/2013)
# Usage: perl overlapping-qRNA-gff-coord.pl [qRNA-output.gff]
#The infile must be already filtered to contain only RNA predictions (do it with grep)

open (INFILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line = <INFILE>;
chomp($line);
my @array = split(/\t/, $line);
my $coord1 = $array[3];
my $coord2 = $array[4];
my $chr = $array[0];
my $score = $array[5];
my $c = 1;
my $score_med;
while ($line ne "") {
    $line = <INFILE>;
    chomp($line);
    @array = split(/\t/, $line);
    while ($array[0] eq $chr && $array[3] > $coord1 && $array[3] < $coord2) {
        $coord2 = $array[4];
        $score = $score + $array[5];
        $c++;
        $line = <INFILE>;
        chomp($line);
        @array = split(/\t/, $line);
    }
    $score_med = $score / $c;
    print("$chr\tQRNA\tRNA\t$coord1\t$coord2\t$score_med\n");
    $coord1 = $array[3];
    $coord2 = $array[4];
    $chr = $array[0];
    $score = $array[5];
    $c = 1;
}