#!/usr/bin/perl 
# Programador: Elton Vasconcelos (10.01.2012)
# Script escrito para pegar as ilhas CPGs dentro dos fastas em que o cpgi130.pl foir rodadoeste exemplo foi para o chr28 
# Usage: perl take-islands.pl [file.cpgOUT] [file.fasta]

my $line1;        #Arquivo cpgOUT
my $line2;	  #Arquivo fasta
my $seq;          #seq-alvo do fasta que possui a ilha CpG em questao  
my $coord_start;
my @array1;        #array em que os elementos as coordenadas (iniciais) da ilha dentro do fasta-alvo
my $coord_end;
my @array2;        #array em que os elementos as coordenadas (finais) da ilha dentro do fasta-alvo
my $length;       #extensao da ilha CpG
my $seq_island;   #sequencia da ilha CpG
my $headline;	  #nome do cabecalho das ilhas do fasta output 

open (FILE2, "$ARGV[1]") or die ("Can't open $ARGV[1]\n");
            $line2 = <FILE2>;    #primeira linha cabecalho do fasta
            $line2 = <FILE2>;    #linha referente ao inicio da seq do primeiro cabecalho
            chomp($line2);
            until ($line2 =~ m/^>/ || $line2 eq "") {     #ateh que comece outra seq ou o arquivo acabe
                    $seq .= $line2;     #jogamos toda a seq numa linha soh na variavel $seq
                    $line2 = <FILE2>;	########## ATENCAO, este script soh trabalha com a primeira seq do arquivo fasta $ARGV[1]
                    chomp($line2);
	    }

open (FILE1, "$ARGV[0]") or die ("Can't open $ARGV[0]\n");
$line1 = <FILE1>;
chomp($line1);

while ($line1 ne "") {			#O arquivo cpgOUT tem uma null line ("") no meio do arquivo
   $line1 = <FILE1>;
   chomp($line1);
}
 $line1 = <FILE1>;		#Depois tem que pular mais duas linhas para que comece
 $line1 = <FILE1>;		#as descricoes das ilhas encontradas
 chomp($line1);

while ($line1 =~ m/start/) {	  	
	if ($line1 =~ m/start\=\d+/) {
    		$coord_start = $&;        #coord inicial
		$coord_start =~ s/start\=//g;
  	}
  	if ($line1 =~ m/end\=\d+/) {
    		$coord_end = $&;        #coord final
    		$coord_end =~ s/end\=//g;
  	}
 	$length = $coord_end - $coord_start + 1 ;    #extensao da ilha CpG
  	$seq_island = substr($seq,$coord_start,$length);
	$line1 =~ m/^.+island \d+/;
	$headline = $&;
	$headline =~ s/ +//g;
	print(">$headline\n$seq_island\n");
  	$line1 = <FILE1>;
  	chomp($line1);
    }
	


