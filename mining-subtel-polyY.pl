#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (08/Aug/2019)
# Script that detects whether a subtelomeric region (between the last CDS end coordinate and the chromosome end) contains a polY track followed by the AG SAS,
# which can be an indication for the TERRA trans-splicing signaling
# Usage: perl mining-subtel-polyY.pl  [infile.fasta] [1stAndLast_CDSlocation_byCHR.tab] >outfile.tab
#################################################################################################
#Note: Edit lines 65 and 82 in order to alter the regular expression for the polyY-AG occurence pattern
# Example of second input file [1stAndLast_CDSlocation_byCHR.tab]:
# >LmjF.01.0010:mRNA      location=LmjF.01:3704-4702(-)   >LmjF.01.0830:mRNA      location=LmjF.01:258831-260867(+)
# >LmjF.02.0010:mRNA      location=LmjF.02:4431-6875(-)   >LmjF.02.0740:mRNA      location=LmjF.02:351494-353530(+)
# >LmjF.03.0010:mRNA      location=LmjF.03:1165-4176(-)   >LmjF.03.0980:mRNA      location=LmjF.03:381260-382501(-)
# >LmjF.04.0010:mRNA      location=LmjF.04:4636-7707(+)   >LmjF.04.1230:mRNA      location=LmjF.04:467442-468572(-)

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line = <FILE>;
chomp($line);

my ($seq, $headline, @array, $start_coord, $end_coord, $left_end_seq, $left_end_seq_woTHR, $right_end_seq, $right_end_seq_woTHR, $chr_length, $match, $posF, $posI, $THR1, $THR2, $right_THR_start, @arrayTHRleft, @arrayTHRright);

$THR1 = "GGGTTAGGGTTA";	#Telomeric hexamer repeat (G strand, usually top strand from right end)
$THR2 = "CCCTAACCCTAA";	#Telomeric hexamer repeat (C strand, usually top strand from left end)

while ($line ne "") {
    if ($line =~ m/^>.*/) {
        $headline = $line;
        $headline =~ s/ .*//g;        #deleting the content after a white space on the sequence headline
	$line =~ m/length\=\d+/;
 	$chr_length = $&;
	$chr_length =~ s/length\=//g;
        $line = <FILE>;
        chomp($line);
        until ($line =~ m/^>/ || $line eq "") {             
            $seq .= $line;            #concatenating the whole sequence in one single line
            $line = <FILE>;
            chomp($line);
        }
        VerifyMatch();
        $seq = "";
    }
    else {        #Just in the case the FASTA file is not starting with a headline (^>.+)
        $line = <FILE>;
        chomp($line);
    }
}
#################
sub VerifyMatch {
	open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
	while(<FILE2>) {
		chomp($_);
		if($_ =~ m/^$headline/) {
			@array = split(/\t/, $_);
			$start_coord = $array[1];
			$start_coord =~ s/^.*\://g;
			$start_coord =~ s/\-.*$//g;
			$end_coord = $array[3];
			$end_coord =~ s/^.*\:\d+\-//g;
			$end_coord =~ s/\(.*$//g;
		}
 	}
  	if($seq ne "") {                            #Verify whether the sequence is null
		##### Working on the "left" end #####
		$left_end_seq = substr($seq, 0, $start_coord);
		@arrayTHRleft = split(/$THR2/, $left_end_seq);
		$left_end_seq_woTHR = pop(@arrayTHRleft);		#grabbing the last element of the array, which is the sequence downstream of the THRs within the "left" end
		if($left_end_seq_woTHR =~ m/CT\w{10,400}[AG]{8,}/ig) {          #Search for the polyY-AG match (Note that the regexp pattern is on revcomp, because it's for the bottom strand)
		       	$match = $&;                          			#Store the match 
		        $seq =~ m/$match/g;
			$posF = pos($seq);			                #Store the final position of the match
		        $posI = $posF - length($match) + 1;    			#Store the start position of the match
		        $match =~ tr/ATGCNatgc/TACGtacg/;
			$match = reverse($match);
			print("$headline left_end $posF..$posI\n$match\n");
		}	
		else {
		       	print("$headline\tNo polyY-AG found within the \"left\" subtelomeric region\n");
		}
		
		##### Working on the "right" end #####
		$right_end_seq = substr($seq, $end_coord, $chr_length - 1);
		@arrayTHRright = split(/$THR1/, $right_end_seq);
		$right_end_seq_woTHR = shift(@arrayTHRright);		#grabbing the 1st element of the array, which is the sequence upstream of the THRs within the "right" end
		if($right_end_seq_woTHR =~ m/[CT]{8,}\w{10,400}AG/ig) {         #Search for the polyY-AG match
       			$match = $&;                          			#Store the match 
		        $posF = pos($right_end_seq_woTHR) + $end_coord;               #Store the final position of the match
       			$posI = $posF - length($match) + 1;    			#Store the start position of the match
        		print("$headline right_end $posI..$posF\n$match\n");
		}	
		else {
       			print("$headline\tNo polyY-AG found within the \"right\" subtelomeric region\n");
		}	
	}
	else {
	      print("Null sequence from the genome fasta file!\n");
 	}
}
