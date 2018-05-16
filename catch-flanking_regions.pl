#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (24/Jun/2014)
# Script that takes the specified flanking sequence of each annotated feature on the input gff file
# Usage: perl catch-flanking_regions.pl [infile.gff] [up or down] [number of nt] [WholeGenome.fasta] >output.fasta
#################################################################################################
#if ($ARGV[1] !~ m/^up/ || $ARGV[1] !~ m/^down/) {
#    die ("You must type either [up] or [down] as your second argument \(without brackets\).\n");
#}
if ($ARGV[2] !~ m/^\d/) {
    die ("You must type an integer as your third argument \(number of nucleotides of your desired flanking sequences to be caught\).\n");
}

########################################################
#### Working on the Genomic-TriTrypDB.fasta file  ######
########################################################
open (FILE2, "$ARGV[3]") or die ("Can't open file $ARGV[3]\n");
my $line2 = <FILE2>;
chomp($line2);
my $seq;
my $chr;
my %hash;

while ($line2 ne "") {
    if ($line2 =~ m/^>[\w\.\-]+ /) {
        $chr = $&;                #catching only the chr ID (i.e. LmjF.01)
        $chr =~  s/^>//;
        $chr =~ s/ $//g;
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
#$var = $hash{'LmjF.02'};
#print("$var\n");

######################################################################
## Working with the tab gff file containing the genes of interest ####
######################################################################
open (FILE1, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
my @array;
my $chr_gene;
my $UTR;        #consider $UTR as the flanking sequence to be retrieved
my $UTRrev;
my $dist;
my $gene;

while ($line1 ne "") {
    @array = split(/\t/, $line1);
    $chr_gene = $array[0];
    $gene = $array[8];
    $gene =~ s/\;.*//g;
    $gene =~ s/ID\=//g;
    if ($line1 =~ m/\t\+\t/) {    #Annotated feature on the top strand, as indicated by the gff file
        if ($ARGV[1] eq "up") {    #the user wants to catch upstream flanking regions
            $dist = $array[3]-$ARGV[2];
            $UTR = substr($hash{$chr_gene}, $dist-1, $ARGV[2]);
            print(">$gene upstream_flanking_region $ARGV[2] bp\n$UTR\n");
        }
        elsif ($ARGV[1] eq "down") {    #the user wants to catch downstream flanking regions
            $UTR = substr($hash{$chr_gene}, $array[4], $ARGV[2]);
            print(">$gene downstream_flanking_region $ARGV[2] bp\n$UTR\n");
        }
    }
    elsif ($line1 =~ m/\t\-\t/) {    #Annotated feature on the bottom strand, as indicated by the gff file
        if ($ARGV[1] eq "up") {
            $UTR = substr($hash{$chr_gene}, $array[4], $ARGV[2]);
            $UTRrev = reverse($UTR);
            $UTRrev =~ tr/atgcnATGCN/tacgnTACGN/;
            print(">$gene upstream_flanking_region $ARGV[2] bp\n$UTRrev\n");
        }
        elsif ($ARGV[1] eq "down") {
            $dist = $array[3]-$ARGV[2];
            $UTR = substr($hash{$chr_gene}, $dist-1, $ARGV[2]);
            $UTRrev = reverse($UTR);
            $UTRrev =~ tr/atgcnATGCN/tacgnTACGN/;
            print(">$gene downstream_flanking_region $ARGV[2] bp\n$UTRrev\n");
        }
    }
    $line1 = <FILE1>;
    chomp($line1);
}