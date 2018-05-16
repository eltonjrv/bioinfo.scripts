#!/usr/bin/perl
# Programmer: Elton Vasconcelos (27/Jun/2017)
# Usage: perl fasta2boulder-checkPrimers.pl primers.fasta
# Script that takes a list of primers (in a FASTA file) and generates a boulder format for all the possible combinations of primer pairs.
# The boulder file can then be used as input for primer3 ("check_primers" task only)
# ATTENTION: The sequence content of each primer in the FASTA file must occupy one single line only (after the header)

my(%hash, @array, $F, $R, $seqID, $seq);

while (<>) {
	chomp($_);
	if ($_ =~ m/^>/) {
		$seqID = $_;
		$seqID =~ s/>//g;
		push(@array, $seqID);
	}
	else {
		$seq = $_;
	}
	if ($seq ne "") {
		$hash{$seqID} = $seq;
		$seqID = "";
		$seq = "";
	}
}

for ($i = 0; $i < @array - 1; $i++) {
	for ($j = $i + 1; $j < @array; $j++) {
		print("SEQUENCE_ID=$array[$i]"."-$array[$j]\nPRIMER_TASK=check_primers\nSEQUENCE_PRIMER=$hash{$array[$i]}\nSEQUENCE_PRIMER_REVCOMP=$hash{$array[$j]}\nPRIMER_THERMODYNAMIC_PARAMETERS_PATH=/home/elton/bioinformatics-tools/primer3-2.3.5/src/primer3_config/\n=\n")
	}
}
