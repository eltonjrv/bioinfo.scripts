# Programmer: Elton Vasconcelos (22/02/2022)
# Usage: perl filter_rMATs.pl [ASE.MATS.JC.txt] [mean_reads_IJC_SJC_cutoff] [FDR_cutoff] [IncLevDiff_cutoff] >ASE.MATS.JC.filtered.tsv
open(FILE, "$ARGV[0]") or die ("*** Error ***\nCan't find $ARGV[0]\nUsage: perl filter_rMATs.pl [ASE.MATS.JC.txt] [mean_reads_IJC_SJC_cutoff] [FDR_cutoff] [IncLevDiff_cutoff] >ASE.MATS.JC.filtered.tsv\n");
if($ARGV[1] =~ m/^\D/ || $ARGV[1] eq "") { die ("*** Error ***\nThe second argument must be numeric!\nUsage: perl filter_rMATs.pl [ASE.MATS.JC.txt] [mean_reads_IJC_SJC_cutoff] [FDR_cutoff] [IncLevDiff_cutoff] >ASE.MATS.JC.filtered.tsv\n");}
elsif($ARGV[2] =~ m/^\D/ || $ARGV[2] eq "") { die ("*** Error ***\nThe third argument must be numeric!\nUsage: perl filter_rMATs.pl [ASE.MATS.JC.txt] [mean_reads_IJC_SJC_cutoff] [FDR_cutoff] [IncLevDiff_cutoff] >ASE.MATS.JC.filtered.tsv\n");}
elsif($ARGV[3] =~ m/^\D/ || $ARGV[3] eq "") { die ("*** Error ***\nThe fourth argument must be numeric!\nUsage: perl filter_rMATs.pl [ASE.MATS.JC.txt] [mean_reads_IJC_SJC_cutoff] [FDR_cutoff] [IncLevDiff_cutoff] >ASE.MATS.JC.filtered.tsv\n");}

while(<FILE>) {
	chomp($_);
	if($_ =~ m/^ID/) {
		 @array = split(/\t/, $_);
		 for($i=0;$i<@array;$i++) {
			 if($array[$i] eq "IJC_SAMPLE_1") {
				 last;
			 }
		 } 
		$colIJC1 = $i;
		$colSJC1 = $i + 1;
		$colIJC2 = $i + 2;
		$colSJC2 = $i + 3;
		$FDR = $i + 7;
		$incLevDiff = $i + 10;
		print("$_\tIJC_SJC_avg\n");
	}
	else { 
		@array = split(/\t/, $_);
		@JC = split(/,/, join(",", @array[$colIJC1..$colSJC2]));
		$JC_sum = 0;
		for($i=0;$i<@JC;$i++) {
			$JC_sum += $JC[$i];
		}
		$JC_avg = $JC_sum / @JC;
		#print("$JC_sum\t$JC_avg\n");
		if($JC_avg >= $ARGV[1] && $array[$FDR] <= $ARGV[2] && $array[$incLevDiff] >= $ARGV[3]) {
			print("$_\t$JC_avg\n");
		}
	}
}
