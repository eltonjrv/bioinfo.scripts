#!/usr/bin/perl
# Programmer: Elton Vasconcelos (13.04.2011)
# Script that filters BlastHits by cutoffs of %id and alignment length (coverage) established by the user
# Usage: perl blast-id-coverage-cutoff.pl [Blast-output] [Blast-tabular-output] [threshold for %id, integer 1-100] [fraction of coverage, fraction 0.n - 1] >outfile

open (FILE1, "$ARGV[0]") or die ("Can't open $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
open (FILE2, "$ARGV[1]") or die ("Can't open $ARGV[1]\n");
my $line2 = <FILE2>; 
chomp($line2);
my @array = split(/\t/, $line2);
my $id = $ARGV[2];		# %identity cutoff
my $cov_frac = $ARGV[3];	# coverage fraction cutoff
my $cov_size;			# coverage size cutoff

while ($line2 ne "") {
	if ($line1 =~ m/^Query= $array[0]\b/) {
		my $query = $&;
		$query =~ s/Query= //g;		#armazenando o nome da query
		until ($line1 =~ m/^ +\(.+ letters\)/) {	#indo para a linha que informa o tamanho da query sequence na saida blast
			$line1 = <FILE1>;
		}
                $line1 =~ m/\d+/;
                $qsize = $&;	#armazenando o tamanho (pb) da query        
                if ($line1 =~ m/\d+\,\d+/) { #em caso de queries maiores que 10mil pb, pois no output blasta aparecerah (10,000 letters)
                    $qsize = $&;	#armazenando o tamanho (pb) da query
                    $qsize =~ s/\,//g;    #removendo a virgula
                }
		$cov_size = $qsize * $cov_frac;		# tamanho do cutoff do alignment length (tamanho da query x fracao definida pelo usuario)
		while ($array[0] eq $query) {	#caminhando no arquivo de saida blast2table ateh que mude a query
			if ($array[2] >= $id && $array[3] >= $cov_size) {	#atendendo os cutoffs, a linha do arquivo blast2table serah impressa
				print("$line2\n");
			}  
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
