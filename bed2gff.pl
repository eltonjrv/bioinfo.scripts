#!/usr/bin/perl
# Programmer: Elton Vasconcelos (07/Apr/2015)
# Usage: perl bed2gff.pl [infile.bed] [source_type] [feature_type] >outfile.gff
# Note: This scripts only takes the coordinates from bed (columns 2 and 3) and transfer that info to a gff format)
# If you have bed 12 (several exons on one line), you must run 'bedtools bed12tobed6' to have one exon (block) per line on your bed6 file.
# After running this script, one might also need to run entire_gene_coords_gff.pl script if working with bed6 that contains only exons.

open(FILE, "$ARGV[0]") or die ("Can't open $ARGV[0]\n");
$line=<FILE>;
chomp($line);
while($line ne ""){
	@array = split(/\t/,$line);
	$fmin = $array[1] + 1;	# 'coord_start' on bed format starts counting from zero
	$fmax = $array[2];
	print("$array[0]\t$ARGV[1]\t$ARGV[2]\t$fmin\t$fmax\t\.\t$array[5]\t\.\tID\=$array[3]\;\n");
	$line=<FILE>;
	chomp($line);
}


