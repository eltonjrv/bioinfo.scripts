#!/usr/bin/perl
# Programmer: Elton Vasconcelos (30/Dec/2013)
# Usage: perl getIntronSizesfromBED12.pl infile.bed >outfile.tab

open (INFILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <INFILE>;
chomp($line);
my (@array, @blockSizes, @blockStarts, $num_introns, @intronSizes, $intronSizes_print);

while ($line ne "") {
    @array = split(/\t/, $line);
    $num_introns = $array[9] - 1;    # The 10th column is blockCounts, that is, number of exons
    if ($array[9] > 1) {         
        @blockSizes = split(/\,/, $array[10]);
        @blockStarts = split(/\,/, $array[11]);
        for ($i = 0; $i < $num_introns; $i++) {
            $intronSizes[$i] = $blockStarts[$i+1] - ($blockStarts[$i] + $blockSizes[$i]);
        }
        $intronSizes_print = join(",", @intronSizes);
        print("$array[0]\t$array[3]\t$num_introns\t$intronSizes_print\n");
    }
    else {
        print("$array[0]\t$array[3]\t$num_introns\tSingle-block feature\n");
    }
    $line = <INFILE>;
    chomp($line);
    @intronSizes = ();
}