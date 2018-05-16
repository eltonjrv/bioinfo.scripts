#!/usr/bin/perl
# Programmer: Elton Vasconcelos (27/Jun/2016)
# Usage: perl gffFromRepeatMasker2bed.pl infile.gff >outfile.bed

open (INFILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <INFILE>;
chomp($line);
my (@array, $chrID, @reapID, $fmin, $fmax, $strand, $blockSize, $score);

while ($line ne "") {
    if ($line =~ m/^\#/) {
	$line = <INFILE>;
        chomp($line);
    }
    else {
    @array = split(/\t/, $line);
    $chrID = $array[0];
    @repID = split(/ /, $array[8]);
    $repID[1] =~ s/\"//g;
    $fmin = $array[3] - 1;
    $fmax = $array[4];
    $strand = $array[6];
    $blockSize = $array[4] - $array[3] + 1;
    $score = $array[5];
    print ("$chrID\t$fmin\t$fmax\t$repID[1]\t$score\t$strand\t$fmin\t$fmax\t255,0,0\t1\t$blockSize\t0,\n");
    $line = <INFILE>;
    chomp($line);
    }
}
