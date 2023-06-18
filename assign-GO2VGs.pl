#!/usr/bin/perl
# Programmer: Elton Vasconcelos (11.Apr.2016)
# Usage: perl assign-GO2VGs.pl [file1] [file2] >table2validate.tab
##############################################################
##### Example of file1 (geneID must be on the 1st column)
#Smp_000420	-1.77927375123374	-1.35264821518043	-1.79418
#Smp_000430	-1.42835145445093	-1.1298736949329	-1.6106
#Smp_000480	-0.465827068544084	-0.419415722354718	-0.500419
#Smp_000950	-3.16404091569563	-2.36347982910007	-3.48834
#Smp_001830	-1.02708888591659	-0.837356167920206	-0.981178
##### Example of file2 (geneID on the 1st column and GOterms on the 2nd one)
#Smp_000480	GO:0003743,GO:0005852,GO:0006413,GO:0031369,GO:0005515
#Smp_004060	GO:0005515
#Smp_004600	GO:0005524
#Smp_004990	GO:0005524
#Smp_005180	GO:0003924,GO:0005525

use List::MoreUtils qw(uniq);

open(FILE,"$ARGV[0]") or die ("Can't open $ARGV[0]\n");
$line=<FILE>;
chomp($line);

open(FILE2,"$ARGV[1]") or die ("Can't open $ARGV[1]\n");;
$line2=<FILE2>;
chomp($line2);

while($line2 ne "")	{
	@array2 = split(/\t/,$line2);
	$geneID = $array2[0];
	while ($array2[0] eq $geneID) {
		push(@GOterms, $array2[1]);
		$line2=<FILE2>;
		chomp($line2);
		@array2 = split(/\t/,$line2);	
	}
	$joinGOs = join(",", @GOterms);
	@GOs = split(/\,/, $joinGOs);
	@uniqGOs = uniq @GOs;
	$hash{$geneID} = join(",", @uniqGOs);
	@GOterms = ();
}

while($line ne "")	 { 
	@array = split(/\t/, $line);
	if ($hash{$array[0]} ne "") {
		print("$line\t$hash{$array[0]}\n");
	} 
	else {
		print("$line\t\n"); 
	} 
	$line=<FILE>;
	chomp($line);
}

