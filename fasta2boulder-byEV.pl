#!/usr/bin/perl
# Programmer: Elton Vasconcelos (27/Jun/2017)
# Usage: perl fasta2boulder-byEV.pl infile.fasta >outfile.boulder
# Script that takes a FASTA file and generates a boulder format in order to be used as an input for primer3.
########################################################################
# NOTE: One must change/add parameters from line 32 on according to his/her needs.
open(FILE, "$ARGV[0]") or die ("can't open $ARGV[0]!\n");
my(%hash, @array, $F, $R, $seqID, $seq, $line);
$line = <FILE>;
chomp($line);

while ($line ne "") {
        if ($line =~ m/^>/) {
                $seqID = $line;
                $seqID =~ s/>//g;
		$seqID =~ s/ .*//g;
                push(@array, $seqID);
		$line = <FILE>;
		chomp($line);
        }
        else {
		until ($line =~ m/^>/ || $line eq "") {
			$seq .= $line;            #putting the whole sequence in one single line
			$line = <FILE>;
			chomp($line);
	        }
                $hash{$seqID} = $seq;
                $seqID = "";
                $seq = "";
        }
}
# one must change/add parameters according to his/her needs.
for ($i = 0; $i < @array; $i++) {
    print ("SEQUENCE_ID=$array[$i]\n");
    print ("SEQUENCE_TEMPLATE=$hash{$array[$i]}\n");
    print "PRIMER_TASK=generic\n";
    print "PRIMER_PRODUCT_SIZE_RANGE=425-550\n";
    print "PRIMER_MIN_TM=49\n";
    print "PRIMER_OPT_TM=58\n";
    print "PRIMER_NUM_RETURN=20\n";
    print "PRIMER_PAIR_MAX_COMPL_ANY=4\n";
    print "PRIMER_PAIR_MAX_COMPL_END=2\n";
    print "PRIMER_MAX_SELF_ANY=4\n";   
    print "PRIMER_MAX_SELF_END=2\n";
    print "PRIMER_THERMODYNAMIC_PARAMETERS_PATH=/home/elton/bioinformatics-tools/primer3-2.3.5/src/primer3_config/\n";	#ATTENTION: Check primer3 installation directory in your system and replace the path accordingly!
    print "=\n";
}
