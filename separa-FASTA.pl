#!/usr/bin/perl
# Programador: Elton Vasconcelos (01.08.2012)
# Script que separa um arquivo FASTA em "n" arquivos com "X" sequencias cada
# "X" deve ser um numero inteiro definido pelo usuario
# Usage: perl separa-FASTA.pl [infile] [integer]

my $c = 1;
my $X = $ARGV[1];
my $count = 1;
my $outfile = $ARGV[0];
$outfile =~ s/\.\w+$/--file$count\.fasta/g;
open (INFILE, "$ARGV[0]") ||
			     die ("Can't open $ARGV[0]\n");

my $line = <INFILE>;

while ($line ne "") {

        if ($line =~ m/^>/) {
            open (OUTFILE, ">$outfile") ||
                        die ("Can't open file $outfile\n");

                print OUTFILE ("$line");
                $line = <INFILE>;
                while ($c <= $X && $line ne "") {
                        print OUTFILE ("$line");
                        $line = <INFILE>;
			if ($line =~ m/^>/) {
				$c++;
			}
                }
            $count++;
            $outfile =~ s/file\d+\.fasta/file$count\.fasta/g;
            close(OUTFILE);
	    $c = 1;
        }
        else   {
                    $line = <INFILE>;
        }
}

close(INFILE);




