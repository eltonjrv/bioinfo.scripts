#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (28.Dec.2015)
# Script that does not print features with FPKM = 0.0000000000 ib the transcripts.gtf cufflinks output file
# Usage: perl removing-FPKMzero-cufflinksGTF.pl transcripts.gff 1>outfile.gtf 2>FPKMzero.gtf
#################################################################################################

open (INFILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <INFILE>;
chomp($line);

while ($line ne "") {    
    if ($line =~ m/FPKM \"0\.0000000000\"\;/) {
	print STDERR ("$line\n");
        $line = <INFILE>;
        chomp($line);
    }
    else {
        print("$line\n");
        $line = <INFILE>;
        chomp($line);
    }
}
