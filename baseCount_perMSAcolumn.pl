#!/usr/bin/perl
# Programmer: Elton Vasconcelos (24/Mar/2017)
# Usage: perl baseCount_perMSAcolumn.pl [aligned.fasta] >outfile.tab
#################################################################
# The infile must be a multiple alignment in fasta format (easily obtained by running muscle)
# The sequence content must be placed on one single line after the header of each sequence (easily obtained by running fasta-single-line.pl)

my (@array, %hashA, %hashC, %hashG, %hashT);

print ("position\tA_count\tC_count\tG_count\tT_count\n");
while (<>) {
	chomp($_);
	if ($_ !~ m/^>/) {	
		@array = split("", $_);
		for ($i = 0; $i < @array; $i++) {
			if ($array[$i] eq "A") {
				$hashA{$i} = $hashA{$i} + 1;
			}
			elsif ($array[$i] eq "C") {
				$hashC{$i} = $hashC{$i} + 1;
			}
			elsif ($array[$i] eq "G") {
				$hashG{$i} = $hashG{$i} + 1;
			}
			elsif ($array[$i] eq "T" or $array[$i] eq "U") {
				$hashT{$i} = $hashT{$i} + 1;
			}	
		}
	}   
}

for ($i = 0; $i < @array; $i++) {
	print("column$i\t$hashA{$i}\t$hashC{$i}\t$hashG{$i}\t$hashT{$i}\n");
}
