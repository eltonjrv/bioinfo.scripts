#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (01/Nov/2018)
# Script that generates a fasta file for all gene features within a genbank file
# Usage: perl gbGeneFeat2fasta.pl [infile.gb] [infile.fasta] >gene_features.fasta
#################################################################################################
#IMPORTANT NOTE: New version of gb files doesn't have the actual whole sequences. NCBI is providing a separate fasta file for the whole sequences of each gb LOCUS entry. Usually the files have the same name. For instance, see the file names' structure in https://ftp.ncbi.nih.gov/refseq/release/bacteria/. Therefore, this script takes both *.gbff and *.fna files as inputs.

if (@ARGV != 2) {
die ("**Error**\nThe cmd line must contain 2 input files as arguments:\n\$perl gbGeneFeat2fasta.pl [infile.gb] [infile.fna] >gene_features.fasta\nRead script's initial commented lines for a better explanation\n");
}

########################################################
############## Working on infile.fna ###################
########################################################
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
my $ctg;	#genomic contig
my %hash;

while ($line2 ne "") {
    if ($line2 =~ m/^>\S+/) {
        $ctg = $&;                #catching the contig ID
        $ctg =~  s/^>//;
	$line2 = <FILE2>;
        chomp($line2);
        until ($line2 =~ m/^>/ || $line2 eq "") {             
            $seq .= $line2;            #putting the whole contig sequence in one single line
            $line2 = <FILE2>;
            chomp($line2);
        }
        $hash{$ctg} = $seq;            #Creating a hash containing each chromosome in the file
        $seq = "";
    }
    else {        #Just in case the FASTA file is not starting with a headline (^>.+)
        $line2 = <FILE2>;
        chomp($line2);
    }
}

########################################################
############# Working on infile.gbff ###################
########################################################
open (FILE1, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my ($version, $org, $gene_seq, $coord, $start, $end, $dist, $locus_tag, $product);
while(<FILE1>) {
	chomp($_);
	if ($_ =~ m/^VERSION\s+.*/) {
		$version = $&;			#should be the same as genomic contig ID in the fasta input
		$version =~ s/^VERSION\s+//g;
	}
	if ($_ =~ m/^\s+\/organism\=.*/) {
		$org = $&;
		$org =~ s/^\s+\/organism\=//g;	#storing organism's name
		$org =~ s/\"//g;
		$org =~ s/ +/_/g;
	}
	if ($_ =~ m/^ {5}gene\s+.*/) {
		if ($_ !~ m/complement/) {	#gene on sense orientation
			$coord = $_;
			$coord =~ s/\s+gene\s+//g;
			$coord =~ s/[<>]//g;
			$start = $coord;
			$start =~ s/\.\.\d+//g;
			$end = $coord;
			$end =~ s/\d+\.\.//g;
			$dist = $end - $start + 1;
			$gene_seq = substr($hash{$version}, $start - 1, $dist);
		}
		else {				#gene on anti-sense orientation
			$coord = $_;
			$coord =~ s/\s+gene\s+complement\(//g;
			$coord =~ s/\)//g;
			$coord =~ s/[<>]//g;
			$start = $coord;
			$start =~ s/\.\.\d+//g;
			$end = $coord;
			$end =~ s/\d+\.\.//g;
			$dist = $end - $start + 1;
			$gene_seq = reverse(substr($hash{$version}, $start - 1, $dist));
			$gene_seq =~ tr/ATGCNatgcn/TACGNtacgn/;
		}
	}
	if ($_ =~ m/^\s+\/locus_tag\=.*/) {
		$locus_tag = $&;
		$locus_tag =~ s/^\s+\/locus_tag\=//g;	#storing locus_tag ID
		$locus_tag =~ s/\"//g;
	}
	if ($_ =~ m/^\s+\/product\=.*/) {		#last important description of a gene feature
		$product = $&;
		$product =~ s/^\s+\/product\=//g;	#storing organism's name
		$product =~ s/\"//g;
		$product =~ s/ +/_/g;

		print(">$locus_tag $org $product $dist bp\n$gene_seq\n");
		$coord = "";
		$dist = "";
		$gene_seq = "";
		$locus_tag = "";
		$product = "";
	}	
	if ($_ =~ m/^\/\//) {
		$version = "";
		$org = "";
	}
}
