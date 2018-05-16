#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (11/Sep/2013)
# Script that generates a fasta file from a tabular file containing the coordinates
# Usage: perl tab2fasta-Leish-v2.pl [targets-tabular-file] [Leish-WG.fasta] [col_chrID] [col_coord1] [col_coord2] >outfile.fasta
#################################################################################################
# IMPORTANT Notes, lines to edit: 
#NOTE 1: A string containing the chromosome ID (the same that will be tagged within the Leish-WG.fasta file) 
#NOTE 2: You should provide the columns number where both chrID and coordinates are placed on your target_input tabular file (start counting from zero)

if (@ARGV != 5) {
die ("**Error**\nThe cmd line must contain 5 arguments:\n\$perl tab2fasta-Leish-v2.pl [file1.tab] [Leish-WG.fasta] [col#_file1_chrID] [col#_file1_coord1] [col#_file1_coord2]\nRead script's initial commented lines for a better explanation\n");
}

########################################################
######## Working with the Leish-WG.fasta file ##########
########################################################
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
my $chr;
my %hash;

while ($line2 ne "") {
    if ($line2 =~ m/^>[\w\d\._]+ /) {
        $chr = $&;                #catching only the chr ID (i.e. LmjF.01)
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
my @array;
my $chr_target;
my $transcript;
my $coord1; my $coord2;
my $dist;
my $gene_id; #use this variable if you wanna assing a specific ID contained in your input tabular fuile

while ($line1 ne "") {
    @array = split(/\t/, $line1);
    #$gene_id = $array[0];    #use this variable if you wanna assing a specific ID contained in your input tabular fuile
    $chr_target = $array[$ARGV[2]];
    if ($line1 =~ m/\t\+\t/ || $line1 =~ m/\t\+$/) { #your gff is indicating the feature is on top strand (column "+")
        $dist = $array[$ARGV[4]] - $array[$ARGV[3]] + 1;
        $transcript = substr($hash{$chr_target}, $array[$ARGV[3]]-1, $dist);
        #$gene_id = ;        #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
        print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
        #print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
    }
    elsif ($line1 =~ m/\t\-\t/ || $line1 =~ m/\t\-$/) { #your gff is indicating the feature is on bottom strand (column "-")
        $dist = $array[$ARGV[4]] - $array[$ARGV[3]] + 1;
        $transcript = reverse(substr($hash{$chr_target}, $array[$ARGV[3]]-1, $dist));
        $transcript =~ tr/ATGCNatgcn/TACGNtacgn/;
        #$gene_id = ;  #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
        print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
        #print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
    }
    else {    #if it's not a gff file (i.e. a blast tabular output)
        if ($array[$ARGV[3]] < $array[$ARGV[4]]) { #coordinates are on an increasing way on your target_tabular_file
                                                    #It is supposed to mean Forward Orientation
            $dist = $array[$ARGV[4]] - $array[$ARGV[3]] + 1;
            $transcript = substr($hash{$chr_target}, $array[$ARGV[3]]-1, $dist);
            #$gene_id = ;        #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
            print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
            #print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\+\) $dist bp\n$transcript\n");
        }
        elsif ($array[$ARGV[3]] > $array[$ARGV[4]]) { #coordinates are on an decreasing way on your target_tabular_file
                                                  # It is supposed to mean Reverse Orientation
            $dist = $array[$ARGV[3]] - $array[$ARGV[4]] + 1;
            $transcript = reverse(substr($hash{$chr_target}, $array[$ARGV[4]]-1, $dist));
            $transcript =~ tr/ATGCNatgcn/TACGNtacgn/;
            #$gene_id = ;  #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
            print(">$chr_target\:$array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
            #print(">$gene_id $array[$ARGV[3]]\..$array[$ARGV[4]] \(\-\) $dist bp\n$transcript\n");
            
        }
    }
    $line1 = <FILE1>;
    chomp($line1);
}
