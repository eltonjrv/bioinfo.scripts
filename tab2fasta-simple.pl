#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (16/Jun/2013)
# Script that generates a fasta file from a tabular file containing the coordinates
# The sequences are caught from a source unique bigger sequence within the input_FASTA (unique_seq.fasta, below)
# Usage: perl tab2fasta-simple.pl [tabular-file] [unique_seq.fasta] >outfile.fasta
#################################################################################################
# IMPORTANT Notes, lines to edit: 
# A string containing the chromosome ID (the same that will be tagged within the Leish-WG.fasta file) 
# must exist in each line of the tabular file (e.g. LmjF.01)
# edit line 49-52 conform your tabular input file

########### Working with the FASTA file ################### 
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
while ($line2 ne "") {
    if ($line2 =~ m/^>[\w\d\._\-]+/) {
        $chr = $&;                #catching only the seq ID 
        $chr =~  s/^>//;
        $line2 = <FILE2>;
        chomp($line2);
        until ($line2 =~ m/^>/ || $line2 eq "") {             
            $seq .= $line2;            #putting the whole chromosome sequence in one single line
            $line2 = <FILE2>;
            chomp($line2);
        }
        #$hash{$chr} = $seq;            #Creating a hash containing each chromosome in the file
        #$seq = "";
    }
    else {        #Just in the case the FASTA file is not starting with a headline (^>.+)
        $line2 = <FILE2>;
        chomp($line2);
    }
}   
   
########### Working with the gff (tabular) file ################### 
open (FILE1, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
my @array;
#my $chr_gene;
my $transcript; 
my $dist;
my $gene_id;

while ($line1 ne "") {
    @array = split(/\t/, $line1);
    #$chr_gene = $array[1];        #this line should be edited conform the tabular input file (the column where chrID is placed)
    $dist = $array[4]-$array[3];  #this line should be edited conform the tabular input file (the column where coordinates are placed)
    $transcript = substr($seq, $array[3]-1, $dist);
    $gene_id = "$chr"."_$array[1]"."_$array[2]";        #this line should be edited conform the tabular input file (the column where gene/featureID is placed)
    print(">$gene_id $array[3]:$array[4] $dist bp\n$transcript\n");
    
    $line1 = <FILE1>;
    chomp($line1);
}