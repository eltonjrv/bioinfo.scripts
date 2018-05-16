#!/usr/bin/perl
# Programmer: Elton Vasconcelos (14.Jun.2013)
# Script that calculates the percent of the alignment coverage ragarding the entire query sequence
# Usage: perl blast-catch-cov_percent.pl [Blast-output] [Blast-tabular-output] >outfile.tab

open (FILE1, "$ARGV[0]") or die ("Can't open $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
open (FILE2, "$ARGV[1]") or die ("Can't open $ARGV[1]\n");
my $line2 = <FILE2>; 
chomp($line2);
my @array = split(/\t/, $line2);
#my $id = $ARGV[2];		# %identity cutoff
my $cov_frac;        	# coverage fraction (percentage)
my $qsize;

while ($line2 ne "") {
	if ($line1 =~ m/^Query= $array[0]\b/) {
		my $query = $&;
		$query =~ s/Query= //g;		#armazenando o nome da query
		until ($line1 =~ m/^ +\(.+ letters\)/) {	#indo para a linha que informa o tamanho da query sequence na saida blast
			$line1 = <FILE1>;
		}
                $line1 =~ m/\d+/;
                $qsize = $&;	#armazenando o tamanho (pb) da query        
                if ($line1 =~ m/\d+\,\d+/) { #em caso de queries maiores que 10mil pb, pois no output blast aparecerah (10,000 letters)
                    $qsize = $&;	  #armazenando o tamanho (pb) da query
                    $qsize =~ s/\,//g;    #removendo a virgula
                }
                while ($array[0] eq $query) {	#caminhando no arquivo de saida blast2table ateh que mude a query
                    $cov_frac = $array[3] / $qsize;		# tamanho do cutoff do alignment length (tamanho da query x fracao definida pelo usuario)
		    print("$array[0]\t$array[1]\t$array[2]\t$cov_frac\n");
                    $line2 = <FILE2>; 
		    chomp($line2);
		    @array = split(/\t/, $line2);		
		}
        }
	else {
	    $line1 = <FILE1>;
            chomp($line1);
	}
}