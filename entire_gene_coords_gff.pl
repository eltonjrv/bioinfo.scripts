#!/usr/bin/perl
# Programmer: Elton Vasconcelos 
# Script that generates a line for the entire gene on a bed6-derived gff that contains only exons
# Usage: perl entire_gene_coords_gff.pl infile.gff >outfile.gff
#################################################################################################
# Script first run on verjo-server-01 within /media/misc/users/elton/tophat-SRA/
# $ 

open (INFILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]!\n");
my $line = <INFILE>;
chomp($line);
my ($geneID, $coord1, $coord2, @fmin, @fmax, $chr, $source, $feature_type, $score, $strand, $phase, @x, @y);

while ($line ne "") {    #reading the gff file until the sequence part (starting with ">")
    if ($line =~ m/\tCDS\t/) {
        @array = split(/\t/, $line);
        $chr = $array[0];
        $source = $array[1];
        $feature_type = $array[2];
        $score = $array[5];
        $strand = $array[6];
        $phase = $array[7];
        $geneID = $array[8];
        while ($array[8] eq $geneID) {
            $line =~ s/\tID\=/\tParent\=/g;
            print("$line\n");
            push(@x, $array[3]);
            push(@y, $array[4]);
            $line = <INFILE>;
            chomp($line);
            @array = split(/\t/, $line);
            $m = 1;
        }
        @fmin = sort {$a <=> $b} @x;
        @fmax = sort {$a <=> $b} @y;
        print("$chr\t$source\t$feature_type\t$fmin[0]\t$fmax[-1]\t$score\t$strand\t$phase\t$geneID\n");
    }
    else {
        print("$line\n");
        $line = <INFILE>;
        chomp($line);
    }
    @x = ();
    @y = ();
    @fmin = ();
    @fmax = (); 
}