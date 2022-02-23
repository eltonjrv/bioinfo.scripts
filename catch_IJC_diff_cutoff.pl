# Programmer: Elton Vasconcelos (22/02/2022)
# Usage: perl catch_IJC_diff_cutoff.pl [ASE.MATS.JC.txt] [IJC_diff_cutoff]  >ASE.MATS.JC.filtered.tsv
open(FILE, "$ARGV[0]") or die ("*** Error ***\nCan't find $ARGV[0] file!\nUsage: perl catch_IJC_diff_cutoff.pl [ASE.MATS.JC.txt] [IJC_diff_cutoff] >ASE.MATS.JC.filtered.tsv\n");
if($ARGV[1] =~ m/[a-zA-Z]+/ || $ARGV[1] eq "") { die ("*** Error ***\nThe second argument must be numerical!\nUsage: perl catch_IJC_diff_cutoff.pl [ASE.MATS.JC.txt] [IJC_diff_cutoff] >ASE.MATS.JC.filtered.tsv\n");}
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
		$colIJC2 = $i + 2;
		print("$_\tIJC_diff\n");
	}
	else { 
		@array = split(/\t/, $_);
		@IJC1 = split(/,/, $array[$colIJC1]);
		$IJC1_sum = 0;
		for($i=0;$i<@IJC1;$i++) {
			$IJC1_sum += $IJC1[$i];
		}
		$IJC1_avg = $IJC1_sum / @IJC1;
		@IJC2 = split(/,/, $array[$colIJC2]); 
                $IJC2_sum = 0;
                for($i=0;$i<@IJC2;$i++) {
                        $IJC2_sum += $IJC2[$i];
                }
                $IJC2_avg = $IJC2_sum / @IJC2; 
		#print("$IJC1_sum\t$IJC1_avg\t$IJC2_sum\t$IJC2_avg\n");
		if($IJC1_avg - $IJC2_avg >= $ARGV[1] || $IJC1_avg - $IJC2_avg <= -$ARGV[1]) {
			$IJC_diff = $IJC1_avg - $IJC2_avg;
			print("$_\t$IJC_diff\n");
		}
	}
}
