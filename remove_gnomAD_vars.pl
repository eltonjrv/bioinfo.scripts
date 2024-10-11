#!/usr/bin/perl
# Programmer: Elton Vasconcelos (27/02/2024)
# Usage: perl remove_gnomAD.pl input1.maf input2_gnomad.vcf 1>output-noGnomAD.maf 2>output-inGnomAD.txt
#######################################################################################################
# Two outputs will be created according to the sintaxe above (1> and 2>): a maf with the gnomAD matched variants removed, and a txt caontaining the matched variants
# Script written for removing gnomAD exome variants according to what Prof Sue Burchill requested (AF_nfe > 0.02, as well as < 30yo population)
# Those target variants to be romved were caught through another filter_gt2pct.pl, also available in this github branch

open(FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
open(FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n"); 
while(<FILE2>) {
	chomp($_); 
	@array2 = split(/\t/, $_); 
	$var_gnomAD = $array2[0]."_".$array2[1]."_".$array2[3]."_".$array2[4];
	$hash{$var_gnomAD} = 1;
}
while(<FILE>) {
	chomp($_); 
	@array = split(/\t/, $_);
	$var = $array[1]."_".$array[2]."_".$array[4]."_".$array[5];
	if($hash{$var} eq "") {
		print("$_\n");
	}
	else {
		print STDERR ("$var\n");
	}
}
