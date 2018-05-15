#!/usr/bin/perl
# Programmer: Elton Vasconcelos (05.Sep.2013)
# Usage: perl blast-sense_antisense-detector.pl [blastN_tabular_output.tab] >outfile.tab
#########################################################################################
# IMPORTANT Notes: SENSE and ANTISENSE assignments will be always regarding the query orientation onto the subject
# on the blast output. You ought to know whether your Blast-DB sequences are all in the correct orientation (.g. *AnnotatedTranscripts.fasta or
# *AnnotatedCDSs.fasta files from TriTrypDB are all good to run this script)
# --> If your blast analysis was against a whole genome DB, the "SENSE" assignment will mean "Forward Strand" and the "ANTIsense" assignment
# will mean "Reverse Strand" on the given chromosome where the query was aligned.

open (FILE, "$ARGV[0]") or die ("Can't open infile $ARGV[0]\n");
my $line = <FILE>;
chomp($line);
my @array;
while ($line ne "") {
    @array = split(/\t/,$line);
    if ($array[8] < $array[9]) { #$array[8] and [9] are the columns where the sbjct coordinates are placed
        print("$line\tSENSE\n");
    }
    else {
       print("$line\tANTIsense\n");
    } 
    $line = <FILE>;
    chomp($line);
}