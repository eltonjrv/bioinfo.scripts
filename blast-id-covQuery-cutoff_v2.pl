#!/usr/bin/perl
# Programmer: Elton Vasconcelos (02.Apr.2013)
# Script that filters BlastHits by cutoffs of %id and alignment length (coverage) established by the user
# Your fasta file should contain the length of the sequences at the end of each headline (e.g. >Seq_name 22 bp)
# Usage: perl blast-id-covQuery-covSbjct-cutoff_v2.pl [query_fasta_file] [db_fasta_file] [Blast-tabular.tab] [threshold for %id, integer 1-100] [fraction of coverage, fraction 0.n - 1] >outfile.tab
##################################################################################################################
# ATTENTION: the headline of the queries' fasta file must end with the regexp \d+ bp$ (run readseq.jar to generate this kind of fasta file, but make sure the name of the sequences haven't changed)

########################################################
######## Working with the db_fasta_file ################
########################################################
open (DBFILE, "$ARGV[1]") or die ("Can't open $ARGV[1]\n");
my $db_line = <DBFILE>;
chomp($db_line);
my $seq_db;
my $sbjct_size;
my %hash;

while ($db_line ne "") {
    if ($db_line =~ m/^>.*/) {
        $seq_db = $&;                #catching only the seq_db ID
        $seq_db =~  s/^>//g;
        $seq_db =~  s/ .*//g;        #Keeping only the first word of the sequence (after ">" and before the first blank space)
        $db_line =~ m/\d+ bp$/;
        $sbjct_size = $&;	            #armazenando o tamanho (pb) da sbjct
        $sbjct_size =~ s/\,//g;         #removendo a virgula
        $sbjct_size =~ s/ bp//g;            #armazenando apenas o tamanho (pb) da sbjct
        $hash{$seq_db} = $sbjct_size;      #Creating a hash containing each seq_db size. It will be used on line 73
        $db_line = <DBFILE>;
        chomp($db_line);
    }
    else {        #Just in the case the FASTA file is not starting with a headline (^>.+)
        $db_line = <DBFILE>;
        chomp($db_line);
    }
}
#my @test = keys %hash;
######################################################

open (FILE1, "$ARGV[0]") or die ("Can't open $ARGV[0]\n");
my $line1 = <FILE1>;
chomp($line1);
open (FILE2, "$ARGV[2]") or die ("Can't open $ARGV[2]\n");
my $line2 = <FILE2>; 
chomp($line2);
my @array = split(/\t/, $line2);
my $query; my $qsize;
#my $sbjct_name; my $sbjct_bp;
my $id = $ARGV[3];		# %identity cutoff
my $cov_frac = $ARGV[4];	# coverage fraction cutoff
my $cov_size_q;			# coverage size cutoff regarding the Query length
my $cov_size_s;			# coverage size cutoff regarding the Sbjct length

while ($line2 ne "") {
	if ($line1 =~ m/^>$array[0]\b/) {
		$query = $&;
		$query =~ s/>//g;		#armazenando o nome da query
                $line1 =~ m/\d+ bp$/;
                $qsize = $&;	#armazenando o tamanho (pb) da query
                $qsize =~ s/ bp//g;      #armazenando apenas o tamanho (pb) da query
                if ($line1 =~ m/\d+\,\d+ bp$/) { #em caso de queries maiores que 10mil pb, pois no output blasta aparecerah (10,000 letters)
                    $qsize = $&;	#armazenando o tamanho (pb) da query
                    $qsize =~ s/\,//g;  #removendo a virgula
                    $qsize =~ s/ bp//g;      #armazenando apenas o tamanho (pb) da query
                }
                $cov_size_q = $qsize * $cov_frac;	# tamanho do cutoff do alignment length (tamanho da query x fracao definida pelo usuario)
		while ($array[0] eq $query) {	        #caminhando no arquivo de saida blast2table ateh que mude a query
		    if ($array[2] >= $id && $array[3] >= $cov_size_q) {	#atendendo os cutoffs, a linha do arquivo blast2table serah impressa
			print("$line2\n");
		    }
		   # else {   #Se nao atender os cutoffs acima de %ID e %covQuery, vamos tentar se pelo menos a %covSbjct estah acima do cutoff pretendido
			     #caso tenhamos short sequences no DB usado no blast
                  #      $cov_size_s = $hash{$array[1]} * $cov_frac;	     #tamanho do cutoff do alignment length (tamanho da sbjct x fracao definida pelo usuario)
                  #      if ($array[2] >= $id && $array[3] >= $cov_size_s) {	#atendendo os cutoffs, a linha do arquivo blast2table serah impressa
                                                                                #Obs: o cutoff de %ID continua o mesmo
                   #         print("$line2\n");
                    #    }
                    #}
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
