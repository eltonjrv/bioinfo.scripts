#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (11/Sep/2013)
# Script that generates a fasta file from a tabular file containing the coordinates
# Usage: perl tab2fasta.pl [targets-tabular-file] [infile.fasta] [col_chrID] [col_coord1] [col_coord2] >outfile.fasta
#################################################################################################
#IMPORTANT NOTE: One must provide the columns number where both chrID and coordinates are placed on your target_input tabular file (start counting from zero)

if (@ARGV != 5) {
die ("**Error**\nThe cmd line must contain 5 arguments:\n\$perl tab2fasta.pl [file1.tab] [file2.fasta] [col#_file1_chrID] [col#_file1_coord1] [col#_file1_coord2]\nRead script's initial commented lines for a better explanation\n");
}

########################################################
############ Working on the infile.fasta ###############
########################################################
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
my $chr;
my %hash;

while ($line2 ne "") {
    if ($line2 =~ m/^>/) {
        $chr = $line2;                
        $chr =~  s/^>//;
        $chr =~  s/ .*//;              #catching only the first word (ID) of the header (e.g. chr_ID if it is a whole genome FASTA)
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
my @array;
my $chr_target;
my $transcript;
my $coord1; my $coord2;
my $dist;
my $gene_id; #use this variable if you wanna assing a specific ID contained in your input tabular fuile

while ($line1 ne "") {
    @array = split(/\t/, $line1);
    $gene_id = $array[0];    #use this variable if you wanna assing a specific ID contained in your input tabular fuile
    $chr_target = $array[$ARGV[2]];
    if ($line1 =~ m/\t\+\t/) { #your gff is indicating the feature is on top strand (column "+")
        $dist = $array[$ARGV[4]] - $array[$ARGV[3]] + 1;
        $transcript = substr($hash{$chr_target}, $array[$ARGV[3]]-1, $dist);
        #$gene_id = ;        #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
        #print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
        print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
    }
    elsif ($line1 =~ m/\t\-\t/) { #your gff is indicating the feature is on bottom strand (column "-")
        $dist = $array[$ARGV[4]] - $array[$ARGV[3]] + 1;
        $transcript = reverse(substr($hash{$chr_target}, $array[$ARGV[3]]-1, $dist));
        $transcript =~ tr/ATGCNatgcn/TACGNtacgn/;
        #$gene_id = ;  #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
        #print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
        print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
    }
    else {    #if it's not a gff file (i.e. a blast tabular output)
        if ($array[$ARGV[3]] < $array[$ARGV[4]]) { #coordinates are on an increasing way on your target_tabular_file
                                                    #It is supposed to mean Forward Orientation
            $dist = $array[$ARGV[4]] - $array[$ARGV[3]] + 1;
            $transcript = substr($hash{$chr_target}, $array[$ARGV[3]]-1, $dist);
            #$gene_id = ;        #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
            #print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
            print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
        }
        elsif ($array[$ARGV[3]] > $array[$ARGV[4]]) { #coordinates are on an decreasing way on your target_tabular_file
                                                  # It is supposed to mean Reverse Orientation
            $dist = $array[$ARGV[3]] - $array[$ARGV[4]] + 1;
            $transcript = reverse(substr($hash{$chr_target}, $array[$ARGV[4]]-1, $dist));
            $transcript =~ tr/ATGCNatgcn/TACGNtacgn/;
            #$gene_id = ;  #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
            #print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
            print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
            
        }
    }
    $line1 = <FILE1>;
    chomp($line1);
}
