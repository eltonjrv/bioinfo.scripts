#!/usr/bin/perl
# Programmer: Elton Vasconcelos (30/Aug/2017)
# Script that cuts a multiple sequence alignment (MSA) in a user-defined stretch
# The stretch is defined by the target_sequence_ID, the sequence_motif as a marker to start or finish the target stretch,
# the stretch_length (an integer), and either "for" or "rev" flag to inform whether the stretch has to be elongated through forward (to the right side)
# or reverse (to the left side) orientation.
# Usage: perl cutMSA.pl [infile.aln.fa] [target_seq_name] [target_motif_seq] [stretch_length] [for|rev] >outfile.aln.fa
#######################################################################################################################
# IMPORTANT NOTES:
# 1. The MSA input [infile.aln.fa] must be in fasta format. It is easily obtained by running muscle (its default output format)
# 2. [target_seq_name] must match exactly the ID of a sequence in the infile.aln.fa
# 3. [target_motif_seq] must be either a nucleotide or amino acid short sequence (only letters are allowed). Check whether there are lowercase or uppercase characters in your infile.aln.fa
# 4. [stretch_length] must be an integer
# 5. [for|rev] must be either "for" or "rev" FLAG (without quotes)

if (@ARGV != 5) {
        die ("*** ERROR: You must specify 5 arguments ***\nUsage: perl cutMSA.pl [infile.aln.fa] [target_seq_name] [target_motif_seq] [stretch_length] [for|rev] >outfile.aln.fa\nPlease, read script's header for more instructions.\n");
}
if ($ARGV[2] =~ m/[\d_\-\.\,\;\:]/) {
	die ("*** ERROR: You must specify either a nucleotide or amino acid motif sequence as [target_motif_seq] argument ***\nOnly either lowercase or uppercase letters are acceptable!\nPlease, read script's header for more instructions.\n");
}
if ($ARGV[3] =~ m/[\D_\-\.\,\;\:]/) {
	die ("*** ERROR: You must specify an integer as [stretch_length] argument ***\nPlease, read script's header for more instructions.\n");
}
if ($ARGV[4] !~ m/for|rev/) {
	die ("*** ERROR: You must specify either for or rev as a flag for the fifth (and last) argument ***\nPlease, read script's header for more instructions.\n");
}



open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <FILE>;
chomp($line);
my($seq, $motif, $length, $target_seq, $seq_rev, $motif_rev, $target_seq_rev, $seq_wGaps, @start, @end, $target_wGaps, $coord1, $coord2, $seq2print);
$motif = $ARGV[2];
$length = $ARGV[3];

###############################################################
####### Getting the coordinates of the target stretch #########
$seq = "";
while ($line ne "") {
	if ($line =~ m/^>$ARGV[1]/) {             
	   $line = <FILE>;
           chomp($line);
	   until ($line =~ m/^>/ || $line eq "") { 
	   	$seq .= $line;            #putting the whole sequence in one single line
		$line = <FILE>;
	        chomp($line);
	   }
	   $seq_wGaps = $seq;	#keeping the gaps in a new variable
	   $seq =~ s/\-//g;	#removing the gaps
	   last;
        }
   #$line = <FILE>;
   #chomp($line);
}

if ($seq eq "") {
	die ("*** ERROR: Your [target_seq_name] is not present in the $ARGV[0] input file ***\nPlease, read script's header for more instructions.\n");
}
else {
 	if ($seq =~ m/$motif/g) {		#matching the motif
	   if ($ARGV[4] eq "for") {		#walking to the right side (forward) to catch the target_stretch
		$target_seq = substr($seq, pos($seq)-length($motif), $length);
		print STDERR (">$ARGV[1]\n$target_seq\n");
	   }
	   elsif ($ARGV[4] eq "rev") {		#walking to the left side (reverse) to catch the target_stretch
		$seq_rev = reverse($seq);
		$motif_rev = reverse($motif);
		$seq_rev =~ m/$motif_rev/g;
		$target_seq_rev = substr($seq_rev, pos($seq_rev)-length($motif), $length);
		$target_seq = reverse($target_seq_rev);
		print STDERR (">$ARGV[1]\n$target_seq\n");
	   }
	}
	else {
	   die ("*** ERROR: Your [target_motif_seq] is not present in the target_seq $ARGV[1] ***\nCheck whether $ARGV[0] has lowercase or uppercase sequence characters\nPlease, read script's header for more instructions.\n");
	}
}
@start = split(//, substr($target_seq, 0, 10));				#catching the initial 10 residues of the target_stretch and storing them into an array
@end = split(//, substr($target_seq, length($target_seq)-10, 10));	#catching the last 10 residues of the target_stretch and storing them into an array
print STDERR ("@start\t@end\n");
$seq_wGaps =~ m/$start[0]\-*$start[1]\-*$start[2]\-*$start[3]\-*$start[4]\-*$start[5]\-*$start[6]\-*$start[7]\-*$start[8]\-*$start[9]/g;
$coord1 = pos($seq_wGaps) - length($&);			#Assigning the initial coord (coord1)
$seq_wGaps =~ m/$end[0]\-*$end[1]\-*$end[2]\-*$end[3]\-*$end[4]\-*$end[5]\-*$end[6]\-*$end[7]\-*$end[8]\-*$end[9]/g;
$coord2 = pos($seq_wGaps);				#Assigning the final coord (coord2)
print STDERR ("$coord1\t$coord2\n");
close(FILE);
###################################################################
### Cutting the MSA according to the target stretch coordinates ###

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
$line = <FILE>;
chomp($line);

while ($line ne "") {
	$seq = "";
	if ($line =~ m/^>/) { 
	   print("$line\n");            
	   $line = <FILE>;
           chomp($line);
	}
	else {
	   until ($line =~ m/^>/ || $line eq "") { 
	   	$seq .= $line;            #putting the whole sequence in one single line
		$line = <FILE>;
	        chomp($line);
	   }
	   $seq2print = substr($seq, $coord1, $coord2 - $coord1);
	   print("$seq2print\n");
        }
}





