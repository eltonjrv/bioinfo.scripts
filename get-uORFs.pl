#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (21/Oct/2013)
# Script that catches uORFs from ATGs located upstream of the canonical ATG and downstream the SL site for each protein-coding gene in a chromosome
# It takes as input a tabular plain Text file derived from the spreadsheets which we did the manutal ATG curation (i.e. ManualATGannotation_Tb927_01_v4.xlsx)
# Usage: perl NT_ORFs2fasta.pl [input-file.tab] [Tb927-WG.fasta] >outfile.fasta
#################################################################################################
########### Example of FILE1 #################
#Tb927.6.100	Tb927_06_v4	protein coding	+	1	1326	710	710	NA	16			receptor-type adenylate cyclase GRESAG 4, pseudogene, putative,receptor-type adenylate cyclase GRESAG 4, degenerate
#Tb927.6.110	Tb927_06_v4	protein coding	+	2180	2416	2338	1981	1751	ns			hypothetical protein
#Tb927.6.120	Tb927_06_v4	protein coding	+	2780	3205	2598	2598	NA	ns			hypothetical protein
#Tb927.6.130	Tb927_06_v4	protein coding	+	3409	7725	3470	3470	NA	3541			leucine-rich repeat protein (LRRP, pseudogene), putative,leucine-rich repeat protein 1 (LRRP1), frameshift
##############################################
#See spreadsheets within the dir:
#/nearline/ngs/projects/RibosomeProfiling/Analysis_V5.0/Genomes/ForATGcuration

#if (@ARGV != 5) {
#die ("**Error**\nThe cmd line must contain 5 arguments:\n\$perl tab2fasta-Leish-v2.pl [file1.tab] [Leish-WG.fasta] [col#_file1_chrID] [col#_file1_coord1] [col#_file1_coord2]\nRead script's initial commented lines for a better explanation\n");
#}

########################################################
######## Working with the Tb927-WG.fasta file ##########
########################################################
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
my $chr;
my %hash;

while ($line2 ne "") {
    if ($line2 =~ m/^>[\w\d\._]+/) {
        $chr = $&;                #catching only the chr ID (i.e. Tb927_01_v4)
        $chr =~  s/^>//;
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
my $SL;
my $atg_coord; my $fiveUTR; my $fiveUTR_rev;

while ($line1 ne "") {
    @array = split(/\t/, $line1);
    $chr_target = $array[1];    #Column B "Chromosome"
    $SL = $array[7];            #Column H "sbri5UTR"
    if ($line1 =~ m/\t\+\t/ && $array[2] =~ m/protein coding/) { #your gff is indicating the feature is on top strand (column "+")
        if ($array[9] =~ m/\d+/) {    #To the Column J "NewATG" was assigned a new value by the curators
            $atg_coord = $array[9];    #Column J "NewATG"
        }
        else {
            $atg_coord = $array[4];    #Column E "CDSstart"
        }
        if ($SL < $atg_coord) {
            #$five_UTR = substr($hash{$chr_target}, $SL - 1, $atg_coord - $SL);          #taking the sequence from the SL site to the given atg_coord (5'UTR)
            $fiveUTR = substr($hash{$chr_target}, $SL - 1, length($hash{$chr_target}));  #taking the sequence from the SL site to the end of the chr
            &CatchORF();
        }
        else {
            print(">$array[0]\t***sbriSLsite is downstream of the canonical ATG***\tColumnJ=\"$array[9]\"\n");
        }
    }
    elsif ($line1 =~ m/\t\-\t/ && $array[2] =~ m/protein coding/) { #your gff is indicating the feature is on bottom strand (column "-")
        if ($array[9] =~ m/\d+/) {    #To the Column J "NewATG" was assigned a new value by the curators
            $atg_coord = $array[9];    #Column J "NewATG"
        }
        else {
            $atg_coord = $array[4];    #Column E "CDSstart"
        }
        if ($SL > $atg_coord) {
            #$five_UTR_rev = substr($hash{$chr_target}, $atg_coord, $SL - $atg_coord); #taking the sequence from the given atg_coord to the SL site (minus strand)
            $fiveUTR_rev = substr($hash{$chr_target}, 0, $SL);         #taking the chromosome sequence until the $SL coord
            $fiveUTR = reverse($fiveUTR_rev);
            $fiveUTR =~ tr/ATGCNatgcn/TACGNtacgn/;
            &CatchORF();
        }
        else {
             print(">$array[0]\t***sbriSLsite is downstream of the canonical ATG***\tColumnJ=\"$array[9]\"\n");
        }
    }
    $line1 = <FILE1>;
    chomp($line1);
}
#############################################
################# Sub-routines ##############
#############################################
sub CatchORF {                        #Sub-routine to Catch uORFs
 if ($fiveUTR ne "") {                 #Verify whether the sequence is null
    my $fiveUTR2 = $fiveUTR; $fiveUTR2 =~ s/^.//g;      #frame 2
    my $fiveUTR3 = $fiveUTR; $fiveUTR3 =~ s/^..//g;     #frame 3
    my @frames = ($fiveUTR, $fiveUTR2, $fiveUTR3);
    my @codons; my $m; my $n; my $c = 1;
    my $posI; my $posI_temp; my $posF;
    my $uorf; my $uStart_coord; my $uStop_coord;
    for($j=0;$j<@frames;$j++) {
        @codons = ($frames[$j] =~ m/.{3}/g);        #spliting the sequence into 3-characters groups (each element of @codons is a codon)
        $m = 0;
        $n = 0;
        for ($i=0;$i<@codons;$i++) {
            $posI_temp = ($i * 3) + 1;              #Store the initial position of any codon (the first nt of the codon)
            if ($line1 =~ m/\t\+\t/) {     #Top strand
                if ($codons[$i] =~ m/ATG/ig && $n == 0 && $SL + $posI_temp < $atg_coord - 2) {     #Search for the match with START on a case insensitive manner, catching only ATG upstream the canonical one
                    $posI = ($i * 3) + 1;              #Store the initial position of the uATG (the first nt of the START codon)
                    $n = 1;
                }
                if ($codons[$i] =~ m/T[GA]A|TAG/ig && $m == 0 && $posI =~ m/\d+/) {     #Search for the match with STOP on a case insensitive manner
                    $posF = ($i * 3) + 3;             #Store the final position of the STOP (the third nt of the STOP codon)
                    $m = 1;
                }
                if ($m == 1) {
                    last;
                }
            }
            elsif ($line1 =~ m/\t\-\t/) {    #Bottom strand  
                if ($codons[$i] =~ m/ATG/ig && $n == 0 && $SL - $posI_temp > $atg_coord + 2) { #Search for the match with START on a case insensitive manner, catching only ATG upstream the canonical one
                    $posI = ($i * 3) + 1;              #Store the initial position (the first nt of the START codon)
                    $n = 1;
                }
                if ($codons[$i] =~ m/T[GA]A|TAG/ig && $m == 0 && $posI =~ m/\d+/) {     #Search for the match with STOP on a case insensitive manner
                    $posF = ($i * 3) + 3;             #Store the final position (the third nt of the STOP codon)
                    $m = 1;
                }
                if ($m == 1) {
                    last;
                }
            }
        }
        if ($m == 1 && $posI < $posF) {
            $uorf = substr($frames[$j], $posI - 1, $posF - $posI + 1);    #Catching the uORF sequence
            ###### The following lines are to catch the absolute coordinates of the uORF within the chromosome
            ### On the Top strand
            if ($j == 0 && $line1 =~ m/\t\+\t/) {
                $uStart_coord = $SL + $posI - 1;
                $uStop_coord = $SL + $posF - 1;
            }
            elsif ($j == 1 && $line1 =~ m/\t\+\t/) {
                $uStart_coord = $SL + $posI;
                $uStop_coord = $SL + $posF;
            }
            elsif ($j == 2 && $line1 =~ m/\t\+\t/) {
                $uStart_coord = $SL + $posI + 1;
                $uStop_coord = $SL + $posF + 1;
            }
            ### On the Bottom strand
            elsif ($j == 0 && $line1 =~ m/\t\-\t/) {
                $uStart_coord = $SL - $posI + 1;
                $uStop_coord = $SL - $posF + 1;
            }
            elsif ($j == 1 && $line1 =~ m/\t\-\t/) {
                $uStart_coord = $SL - $posI;
                $uStop_coord = $SL - $posF;
            }
            elsif ($j == 2 && $line1 =~ m/\t\-\t/) {
                $uStart_coord = $SL - $posI - 1;
                $uStop_coord = $SL - $posF - 1;
            }
            $bp = length($uorf);
            print(">$array[0]_uORF_$c $bp bp \($uStart_coord..$uStop_coord\) \($array[3]\) ColumnJ=\"$array[9]\"\n$uorf\n");
            $c++;
        }
        $posI = "";
        $posF = "";
    }
    if ($uorf eq "") {
         print(">$array[0]\t***No uORFs found***\tColumnJ=\"$array[9]\"\n");
    }
    $uorf = "";
  }
}
