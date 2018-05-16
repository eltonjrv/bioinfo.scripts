#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (02/Feb/2016)
# Script that generates a fasta file of mature transcripts from a gtf input file
# Usage: perl gtf2fasta-byEV.pl [infile.gtf] [genome.fasta] >transcripts.fasta
#################################################################################################
#Important NOTE 1- Only "exon" features on column 3 will be considered (change line 53 if you want to consider other feature type)
#IMportant NOTE 2- Chromosome IDs must match on both input.gtf (col 1) and genome.fasta files

########################################################
############# Working on the fasta file ##############
########################################################
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
my $chr;
my %hash;

while ($line2 ne "") {
    if ($line2 =~ m/^>[\w\.\-]+ /) {
        $chr = $&;                #catching only the chr ID that is between the '>' and the first blank space on the sequence header
        $chr =~  s/^>//;
        $chr =~  s/ //;
        $line2 = <FILE2>;
        chomp($line2);
        until ($line2 =~ m/^>/ || $line2 eq "") {             
            $seq .= $line2;            #putting the whole chromosome sequence in one single line
            $line2 = <FILE2>;
            chomp($line2);
        }
        $hash{$chr} = $seq;            #Creating a hash containing each chromosome in the file
        $seq = "";
    }
    else {        #Just in the case the FASTA file is not starting with a headline (^>.+)
        $line2 = <FILE2>;
        chomp($line2);
    }
}
#my @test = keys %hash;
#print("@test\n");
#$var = $hash{'LdoB.02'};
#print("$var\n");

##############################################################################
################## Working with the targets tabular file #####################
##############################################################################
open (FILE1, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
my (@array, $chr_target, $transcript, $coord1, $coord2, $dist, $geneID, $length, $m);

while ($line1 ne "") {
    if ($line1 =~ m/\texon\t/) {
        @array = split(/\t/, $line1);
        $chr_target = $array[0];
        $dist = $array[4] - $array[3] + 1;
        $array[8] =~ m/transcript_id \"[\w\.\-]+\"/;
	$geneID = $&;
        $geneID =~ s/\"//g;
        $geneID =~ s/transcript_id //g;    
	$m = 0;
	while ($line1 =~ m/transcript_id \"$geneID\"/) {
            if ($line1 =~ m/\t\+\t/) { #the gtf is indicating the feature is on top strand (column "+")
                 $transcript .= substr($hash{$chr_target}, $array[3]-1, $dist);
		 $length += $dist;
            }
            elsif ($line1 =~ m/\t\-\t/) { #the gtf is indicating the feature is on bottom strand (column "-")
                $transcript .= reverse(substr($hash{$chr_target}, $array[3]-1, $dist));
	        $length += $dist;
		$m = 1;
            }
	    $line1 = <FILE1>;
            chomp($line1);
	    @array = split(/\t/, $line1);
            $chr_target = $array[0];
            $dist = $array[4] - $array[3] + 1;
	}
	if ($m == 1) {	#transcript on reverse strand
	    $transcript =~ tr/ATGCNatgcn/TACGNtacgn/;
	}
	print (">$geneID $length bp\n$transcript\n");
	$length = 0;
        $transcript = "";
    }  
    else {
        $line1 = <FILE1>;
        chomp($line1);
    }
}
