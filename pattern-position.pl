#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (03/Aug/2013)
# Script that prints the start and end positions of the first occurrence of an user-specified pattern present within each sequence from the input FASTA file
# Usage: perl pattern-position.pl [infile.fasta] [user_pattern_to_match] >outfile.tab
#################################################################################################
#Note: Your pattern can also be a limited regular expression. Be carefull with some special characters at the cmd line

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line = <FILE>;
chomp($line);
my $pattern = $ARGV[1];
my $seq;
my $headline;

print("Seq_Name\tPattern\tStart_pos\tEnd_pos\n");

while ($line ne "") {
    if ($line =~ m/^>.*/) {
        $headline = $line;
        $headline =~ s/ .*//g;        #deleting the content after a white space on the sequence headline
        $line = <FILE>;
        chomp($line);
        until ($line =~ m/^>/ || $line eq "") {             
            $seq .= $line;            #concatenating the whole sequence in one single line
            $line = <FILE>;
            chomp($line);
        }
        #print("$headline\n$seq\n");
        VerifyMatch();
        $seq = "";
    }
    else {        #Just in the case the FASTA file is not starting with a headline (^>.+)
        $line = <FILE>;
        chomp($line);
    }
}
#################
sub VerifyMatch {
 if($seq ne "") {                                 #Verify whether the sequence is null
    if($seq =~ m/$pattern/ig) {                   #Search for the match on a case insensitive manner
        my $match = $&;                           #Store the match 
        my $posF = pos($seq);                     #Store the final position of the match
        my $posI = $posF - length($match) + 1;    #Store the start position of the match
        print("$headline\t$match\t$posI\t$posF\n");
    }
    else {
        print("$headline\tNo matches found\n");
    }
  }
}
