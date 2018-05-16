#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (21/Oct/2013)
# Script that catches uORFs from ATGs located upstream of the canonical ATG and downstream the SL site for each protein-coding gene in a chromosome
# It takes as input1 a gff file generated by Gowthaman (Tb927-TritrypV5p0.11ChrOnly.pma.5utr.noadjust.gff) after our manual ATG curation.
# The input1 is a gff containing the annotation of the 5'UTR of each Tb927 protein-coding gene.
# The input2 is also a gff, but now cointaining the CDS features only.
# Usage: perl NT_ORFs2fasta.pl [input-file1.gff] [input-file2.gff] [Tb927-WG.fasta] >outfile.fasta
#################################################################################################
########### Example of FILE1 (Tb927-TritrypV5p0.11ChrOnly.pma.5utr.noadjust.gff)#################
#Tb927_10_v5     SBRI    5UTR    2571651 2571705 .       -       .       ID=NCDS.Tb927.10.10451;length=55;has5UTRdefined=YES
#Tb927_10_v5     SBRI    5UTR    3257540 3257725 .       -       .       ID=NCDS.Tb927.10.13341;length=186;has5UTRdefined=YES
#Tb927_10_v5     SBRI    5UTR    3967616 3967639 .       +       .       ID=NCDS.Tb927.10.16121;length=24;has5UTRdefined=YES
#Tb927_10_v5     SBRI    5UTR    524642  524687  .       +       .       ID=NCDS.Tb927.10.1991;length=46;has5UTRdefined=YES
##############################################


########################################################
######## Working with the Tb927-WG.fasta file ##########
########################################################
open (FILE3, "$ARGV[2]") or die ("Can't open file $ARGV[2]\n");
my $line3 = <FILE3>;
chomp($line3);
my $seq;
my $chr;
my %hash;

while ($line3 ne "") {
    if ($line3 =~ m/^>/) {
        $chr = $line3;                
        $chr =~ s/^>//;
        $chr =~ s/ .*//g;               #catching only the chr ID (i.e. Tb927_01_v4)
        $line3 = <FILE3>;
        chomp($line3);
        until ($line3 =~ m/^>/ || $line3 eq "") {             
            $seq .= $line3;            #putting the whole chromosome sequence in one single line
            $line3 = <FILE3>;
            chomp($line3);
        }
        $hash{$chr} = $seq;            #Creating a hash containing each chromosome in the file
        $seq = "";
    }
    else {        #Just in the case the FASTA file is not starting with a headline (^>.+)
        $line3 = <FILE3>;
        chomp($line3);
    }
}


########################################################
######## Working with the CDSs gff file ################
########################################################
open (FILE2, "$ARGV[1]") or die ("Can't open file $ARGV[1]\n");
my $line2 = <FILE2>;
chomp($line2);
my @array2;
my %hash2;    #Hash to store the CDS end coordinates for each gene
my $geneID2;
while ($line2 ne "") {
    @array2 = split(/\t/, $line2);
    if ($line2 =~ m/\tCDS\t/ && $line2 =~ m/\t\+\t/) {    #gene on the top strand
        $geneID2 = $array2[8];        #Column 9 "Attributes where we have the gene ID"
        $geneID2 =~ s/\-mRNA.*$//g;
        $geneID2 =~ s/^ID.*Tb/Tb/g;
        $hash2{$geneID2} = $array2[4]; #Column 5 "CDS end coord" on the plus strand. Storing it in %hash2
    }
    elsif ($line2 =~ m/\tCDS\t/ && $line2 =~ m/\t\-\t/) {    #gene on the bottom strand
        $geneID2 = $array2[8];        #Column 9 "Attributes where we have the gene ID"
        $geneID2 =~ s/\-mRNA.*$//g;
        $geneID2 =~ s/^ID.*Tb/Tb/g;
        $hash2{$geneID2} = $array2[3]; #Column 4 "CDS end coord" on the minus strand. Storing it in %hash2
    }
    $line2 = <FILE2>;
    chomp($line2);
}

##############################################################################
################## Working with the 5'UTRs gff file ##########################
##############################################################################
open (FILE1, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
my @array;
my $chr_target; my $geneID;
my $SL;
my $atg_coord; my $fiveUTR; my $fiveUTR_rev; my $CDS_end;

while ($line1 ne "") {
    @array = split(/\t/, $line1);
    $chr_target = $array[0];    #Column 1 "Chromosome ID"
    $geneID = $array[8];        #Column 9 "Attributes where we have the gene ID"
    $geneID =~ s/\;.*//g;
    $geneID =~ s/^ID.*Tb/Tb/g;
    $CDS_end = $hash2{$geneID};
    if ($line1 =~ m/\t\+\t/) { #gff is indicating the feature is on top strand (column "+")
        $SL = $array[3];            #Column 4 "5UTR start coord"
        $atg_coord = $array[4] + 1;     #Column 5 "5UTR end coord", actually it is the end of 5UTR (one nt upstream of the ATG)
        if ($line1 =~ m/YES$/) {    #if the gene has a defined 5UTR (as it is assigned in the end of each line from the gff input file)
            #$five_UTR = substr($hash{$chr_target}, $SL - 1, $atg_coord - $SL);          #taking the sequence from the SL site to the given atg_coord (5'UTR)
            $fiveUTR = substr($hash{$chr_target}, $SL - 1, $CDS_end - $SL);  #taking the sequence from the SL site to the CDS end
            &CatchORF();
        }
        else {
            print(">$array[8]\t***sbriSLsite is downstream of the canonical ATG***\n");
        }
    }
    elsif ($line1 =~ m/\t\-\t/) { #your gff is indicating the feature is on bottom strand (column "-")
        $SL = $array[4];            #Column 5 "5UTR start coord"
        $atg_coord = $array[3] - 1;     #Column 4 "5UTR end coord", actually it is the end of 5UTR (one nt upstream of the ATG)
        if ($line1 =~ m/YES$/) {    #if the gene has a defined 5UTR (as it is assigned in the end of each line from the gff input file)
            #$five_UTR_rev = substr($hash{$chr_target}, $atg_coord, $SL - $atg_coord); #taking the sequence from the given atg_coord to the SL site (minus strand)
            $fiveUTR_rev = substr($hash{$chr_target}, $CDS_end - 1, $SL - $CDS_end + 1);         #taking the chromosome sequence until the $SL coord
            $fiveUTR = reverse($fiveUTR_rev);
            $fiveUTR =~ tr/ATGCNatgcn/TACGNtacgn/;
            &CatchORF();
        }
        else {
             print(">$array[8]\t***sbriSLsite is downstream of the canonical ATG***\n");
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
    my $fiveUTR2 = $fiveUTR; $fiveUTR2 =~ s/^.//g;      #frame 2, relative to the string on $fiveUTR
    my $fiveUTR3 = $fiveUTR; $fiveUTR3 =~ s/^..//g;     #frame 3, relative to the string on $fiveUTR
    my @frames = ($fiveUTR, $fiveUTR2, $fiveUTR3);
    my @codons; my $m; my $n; my $c = 1;
    my $posI; my $posI_temp; my $posF;
    my $uorf; my $uStart_coord; my $uStop_coord;
    my $rest; my $frame_abs;    #frame based on the absolute coordinate. Go to the line 169 and downward
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
            if ($line1 =~ m/\t\+\t/) {     ### On the Top strand
                if ($j == 0) {
                    $uStart_coord = $SL + $posI - 1;
                    $uStop_coord = $SL + $posF - 1;
                }
                elsif ($j == 1) {
                    $uStart_coord = $SL + $posI;
                    $uStop_coord = $SL + $posF;
                }
                elsif ($j == 2) {
                    $uStart_coord = $SL + $posI + 1;
                    $uStop_coord = $SL + $posF + 1;
                }
                $rest = $uStart_coord % 3;    # Taking the rest of the division
                if ($rest == 1) {
                    $frame_abs = "+1";
                }
                elsif ($rest == 2) {
                    $frame_abs = "+2";
                }
                elsif ($rest == 0) {
                    $frame_abs = "+3";
                }
            }    
            if ($line1 =~ m/\t\-\t/) { ### On the Bottom strand
                if ($j == 0) {
                    $uStart_coord = $SL - $posI + 1;
                    $uStop_coord = $SL - $posF + 1;
                }    
                elsif ($j == 1) {
                    $uStart_coord = $SL - $posI;
                    $uStop_coord = $SL - $posF;
                }
                elsif ($j == 2) {
                    $uStart_coord = $SL - $posI - 1;
                    $uStop_coord = $SL - $posF - 1;
                }
                $rest = (length($hash{$chr_target}) - $uStart_coord + 1) % 3;    # Taking the rest of the division
                if ($rest == 1) {
                    $frame_abs = "-1";
                }
                elsif ($rest == 2) {
                    $frame_abs = "-2";
                }
                elsif ($rest == 0) {
                    $frame_abs = "-3";
                }
            }             
            $bp = length($uorf);
            print(">$geneID-uORF_$c-frame_$frame_abs $bp bp \($uStart_coord..$uStop_coord\) \($array[6]\)\n$uorf\n");
            $c++;
        }
        $posI = "";
        $posF = "";
    }
    if ($uorf eq "") {
         print(">$geneID\t***No uORFs found***\n");
    }
    $uorf = "";
  }
}
