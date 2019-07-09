#!/usr/bin/perl
# Programmer: Elton Vasconcelos (08/Jul/2019)
# Script that generates a fasta file containing 15aa-long sequences with an acetylated Lysin (Kac) placed in the middle (position 8 within the 15aa-long seq).
# It can be further used as input file for Rmotifx (or any other motif finder algorithm).
# Usage: perl catch-15aa-centralKac.pl [input1_proteins.fasta] [input2.tab] >outfile-15aa.fasta
############################################################################
# NOTE: input2.tab must be a two-columns tabular file, where 1st column is for proteinID and 2nd one is for the position of the Kac residue within that protein sequence.
# ATTENTION: Protein IDs from both input files MUST match!

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <FILE>;
chomp($line);
my($seqID, $seq, %hash, @array, $motifx_input, $pos, $pos_end);

##### Working on FASTA file #####
while ($line ne "") {
	if ($line =~ m/^>/) {             
	   $seqID = $line;
	   $seqID =~ s/>//g;
	   $seqID =~ s/ .*//g;
	   $line = <FILE>;
           chomp($line);
	   until ($line =~ m/^>/ || $line eq "") { 
	   	$seq .= $line;            #putting the whole sequence in one single line
		$line = <FILE>;
	        chomp($line);
	   }
	   $hash{$seqID} = $seq;
	   $seq = "";
        }
}

##### Working on the Kac position tab file #####
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]!\n");
my $c = 1;
while (<FILE2>) {
	chomp($_);
	@array = split(/\t/, $_);
	$pos = $array[1] - 8;
	if ($pos <= 0) {
	   $motifx_input = substr($hash{$array[0]}, 0, 15);
	   print(">$array[0]_$c\n$motifx_input\n");
	}
	elsif ($array[1] + 7 >= length($hash{$array[0]})) { 
	   $pos_end = length($hash{$array[0]}) - 15;
	   $motifx_input = substr($hash{$array[0]}, $pos_end, 15);
	   print(">$array[0]_$c\n$motifx_input\n");
	}
	else {
	   $motifx_input = substr($hash{$array[0]}, $pos, 15 );
	   print(">$array[0]_$c\n$motifx_input\n");
	}
	$c++;
}

