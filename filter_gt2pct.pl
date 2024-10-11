#!/usr/bin/perl
# Programmer: Elton Vasconcelos (23/02/2024)
# Script written for filtering gnomAD exome vcf files according to what Prof Sue Burchill requested (AF_nfe > 0.02, as well as < 30yo population).
# Usage: perl filter_gt2pct.pl
## NOTE: gnomad*.vcf files (per chromosome) must exist in the current directory
foreach my $file (<gnomad*vcf>) {
	if( -f $file ) {
	$out1 = $file;
	$out1 =~ s/\.\w+$/-filtOpt1.vcf/g;
	$out2 = $file;
	$out2 =~ s/\.\w+$/-filtOpt2.vcf/g;
	open(FILE, "$file") or die("Can't open $file\n");
	open(OUT1, ">$out1") or die("Can't open $out1\n");
	open(OUT2, ">$out2") or die("Can't open $out2\n");
	while(<FILE>) {
		chomp($_);
		if($_ !~ m/^\#/) { 
			@array = split(/\t/, $_);
			if($array[7] =~ m/AF_nfe\=[\d\+\-\.e]+/) {
				@AF = split(/=/, $&); 
				$array[7] =~ m/age_hist_het_n_smaller\=[\d\.]+/; 
                                @lt30_hetCount = split(/=/, $&); 
                                $array[7] =~ m/age_hist_hom_n_smaller\=[\d\.]+/; 
                                @lt30_homCount = split(/=/, $&); 
                                $lt30_Count = $lt30_hetCount[1] + $lt30_homCount[1];  
				if($AF[1] >= 0.02 && $lt30_Count >= 91) {
						print OUT1 ("$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\tAF_nfe=$AF[1];lt30yo=$lt30_Count\n"); 
				}
				elsif($AF[1] >= 0.02 && $lt30_Count < 91) {
                                                print OUT2 ("$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\tAF_nfe=$AF[1];lt30yo=$lt30_Count\n");
                                }
				elsif($AF[1] < 0.02 && $lt30_Count >= 91) {
                                                print OUT2 ("$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\tAF_nfe=$AF[1];lt30yo=$lt30_Count\n");
                                }
			}
		}
	}
	}
	else {
		die("There's no such file in the cwd\n");
	}
}
