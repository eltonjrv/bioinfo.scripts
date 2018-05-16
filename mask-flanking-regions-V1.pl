#! /usr/bin/perl 

#Atualizado em: 12/01/2006

use strict;
use Getopt::Long; #http://savage.net.au/Perl-modules/html/Getopt/Simple.html , http://aplawrence.com/Unix/perlgetopts.html
use Pod::Usage;


# Process command line options
my $opt_help = 0;  #parametro --help
my $opt_interval = -1;  #parametro --help
my $file01_name =""; #parametro -f  = file_input
my $file02_name =""; #parametro -c = file_coordenate





my $result = GetOptions("help"   =>  \$opt_help,
                        "interval:i"   =>  \$opt_interval, #opcional
                        "f=s"   =>  \$file01_name,
                        "c=s"   =>  \$file02_name);



# Caso argumento seja "--help" ou não passou argumento necessario executa HELP
pod2usage({-exitval => 0, -verbose => 2}) if $opt_help || $file01_name eq "" || $file02_name eq ""; 

unless (open(FIN, $file01_name)) {		    #Abre o arquivo para leitura
	die ("O ".$file01_name ." nao pode ser aberto!\n");   #Imprime a mensagem se nao for aberto
}

unless (open(FCOORD, $file02_name)) {		    #Abre o arquivo para leitura
	die ("O ".$file02_name ." nao pode ser aberto!\n");   #Imprime a mensagem se nao for aberto
}


my $seqname; #armazena o nome da sequencia
my $seq;    #armazena a sequencia

my $line = <FIN>;       #Le a primeira linha do arquivo
while ($line ne ""){    #Testa qdo chega o fim do arquivo. Se nao existe linha $line tem valor zero
    chomp($line);       #Retirar caracteres invalidos no inicio e fim da variavies
    
    if ($line =~ m/^>.*/){  #caso a linha seja o nome da sequencia (Ex.: ">nome da sequencia")
        $seqname = $line;
    }else{                  #caso não armazena na string de sequencia
        $seq.=$line;
    }
    $line = <FIN>;
}

my $ini_d = 1;        #a ultima posicao do gene do cromosso. Util para calcular as distancias entre os genes
my $all_distance = 0; #armazena todos os valores das distancias entre os genes do cromossomo
my $b_log = 0; # caso de erro, será gerado um output de log
my $error_log = ""; # caso de erro, armazenara a mensagem de erro
my $last_seq =""; # armazena a ultima sequencia antes do erro
my $average_value= 0; # armazena a ultima sequencia antes do erro
my @all_interval;


$line = <FCOORD>;       #Le a primeira linha do arquivo
while ($line ne ""){    #Testa qdo chega o fim do arquivo. Se nao existe linha $line tem valor zero
    chomp($line);       #Retirar caracteres invalidos no inicio e fim da variavies
    my @col = split('\t',$line); #separa o arquivo de coordenadas em colunas

    if (($col[1] - $ini_d ) > 0){
        substr($seq,$col[1]-1,($col[2] - $col[1]) + 1 ) = generateMask($col[2] - $col[1] + 1 );
        $all_distance.=  ($col[1] - $ini_d ).":"; #calcula a distancia entre o gene e as armazena todas
        push(@all_interval,[$col[1] ,$col[2],$col[0]]);
        
    }else{
        $b_log = 1;
        $error_log.= "::::\n$last_seq\n$col[0]\n";        
    }
    $ini_d = $col[2]+1;        #define o novo inicio da distancia
    $last_seq = $col[0];
    $line = <FCOORD>;
}

if (!($b_log)){
    
    #cria arquivo de saida com a adição da extensão ".screen"
    my $file03_name = $file01_name . ".screen";

    unless (open(FOUT, ">$file03_name")) {		    #Abre o arquivo para escrita
	die ("O ".$file03_name ." nao pode ser aberto!\n");   #Imprime a mensagem se nao for aberto
    }
    print FOUT "$seqname\n$seq";
    close(FOUT);
    averageDistance($all_distance);
    generateSeqInterval() if $opt_interval > -1 ;
    
}else{

    #cria arquivo de saida com a adição da extensão ".screen"
    my $erro_file_name = "mask_error.log";

    unless (open(FOUT, ">>$erro_file_name")) {		    #Abre o arquivo para escrita
	die ("O ".$erro_file_name ." nao pode ser aberto!\n");   #Imprime a mensagem se nao for aberto
    }
    
    print FOUT "\n##ERROR". getLogDateTime()."##\n$error_log;";
    close(FOUT);
    print "Error: Arquivo de entrada com coordenada errada. Verifique arquivo de log."
    
    

}

close(FIN);
close(FCOORD);










sub getLogDateTime{
    
my($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ; 

# How to add a leading zero in Perl 
if($Day < 10){ $Day = "0" . $Day ;} # add a leading zero to one-digit days 

$Month = $Month + 1 ; # Months of the year are not zero-based 
# Perl code will need to be adjusted for one-digit months 
if($Month < 10) { $Month = "0" . $Month ;} 

if($Year >= 100) { 
    $Year = ($Year - 100) + 2000 ; 
} 
else 
{ 
    $Year = $Year +2000; 
} 

return "($Day/$Month/$Year - $Hour:$Minute:$Second)";

}







#gera as string contendo tantos X's necessarios
sub generateMask {
    my ($size) = @_;
    my $maskString;
    for( my $i=0 ; $i < $size;$i++) {$maskString.="X";}
    return $maskString;
}








#calcula a média das distancias e exibe a maior e menor distancias
sub averageDistance {
    my ($distances) = @_;
    my @dist_values = split(':',$distances);
    my $qte_dist = @dist_values ;
    my $sum_values = 0;
    foreach my $value (@dist_values){$sum_values += $value;}
    
    @dist_values  = sort crescente (@dist_values);
    $average_value =int($sum_values / $qte_dist ) -1 ;
    #Nome_da_sequencia    Menor_distancia    Maior_distancia    Distancia_média
    print "$seqname\t$dist_values[0]\t$dist_values[@dist_values -1]";
    print ("\t$average_value\n");
}

sub geraName{
    my ($seqNameTemp) = @_;
    $seqNameTemp =~ m/ /g;
    my $position = pos($seqNameTemp);    
    return substr($seqNameTemp,0,$position-1);
}


#ordena o array de maneira crescente
sub crescente{
    my $retval;
    if ($a > $b){
        $retval = 1;
    }elsif($a == $b){
        $retval = 0;
    }else{
        $retval = -1;
    }
    return $retval;
}






sub generateSeqInterval{
    
    my $piece_seq;
    
    #imprime $piece_seq com o seu nome ideal
    my $piece_size;
    my $itvl =0;
    
    #caso não seja definido um intervalo, será utilizado a média das distancias
    if ($opt_interval == 0){
        $itvl = $average_value;
    }else{
        $itvl = $opt_interval;
    }
 
    
    #$piece_seq = "$seqname" . "_L_" . $all_interval[0][0] . "_". $average_value1  . "pb.fasta\n";
    my $seqnameT = "";
    $seqnameT = geraName( $all_interval[0][2] );
    
        
    $piece_seq = "$seqnameT" . "_L " . $all_interval[0][0] . "_";
    if ( $all_interval[0][0] - $itvl < 0){ #caso primeira coordenada seja antes do tamanho do intervalo
        $piece_seq .= $all_interval[0][0] . "pb.fasta\n";
        $piece_seq .= substr($seq,0,$all_interval[0][0] -1 ) ."\n";
    }else{
        $piece_seq .= $itvl . "pb.fasta\n";
        $piece_seq .= substr($seq,$all_interval[0][0] - $itvl,$itvl -1)."\n";
    }
    
    
    my $i;
    for ($i=1;$i< @all_interval;$i++){
    
        if ($all_interval[$i][0] - $all_interval[$i-1][1] < ($itvl * 2 ) ){
            $piece_size = int(($all_interval[$i][0] - $all_interval[$i-1][1]) / 2 )  ;
        }else{
            $piece_size = $itvl ;
        }
        
        $seqnameT = geraName( $all_interval[$i-1][2]);
        #$piece_seq .= "$seqname" . "_R_" . $all_interval[$i-1][1] . "_". $piece_size . "pb.fasta\n";
        $piece_seq .= "$seqnameT" . "_R " . $all_interval[$i-1][1] . "_". $piece_size . "pb.fasta\n";
        $piece_seq .= substr($seq,$all_interval[$i-1][1],$piece_size ) ."\n";
        
        $seqnameT = geraName( $all_interval[$i][2]);
        #$piece_seq .= "$seqname" . "_L_" . $all_interval[$i][0] . "_". $piece_size . "pb.fasta\n";
        $piece_seq .= "$seqnameT" . "_L " . $all_interval[$i][0] . "_". $piece_size . "pb.fasta\n";
        $piece_seq .= substr($seq,$all_interval[$i][0] - $piece_size ,$piece_size -1 ) ."\n";
    }

    #$piece_seq .= "$seqname" . "_R_" . $all_interval[$i-1][1] . "_". $piece_size . "pb.fasta\n";
    
    $seqnameT = geraName( $all_interval[$i-1][2]);    
    $piece_seq .= "$seqnameT" . "_R " . $all_interval[$i-1][1] . "_";
    
    if ($all_interval[$i-1][1] + $itvl > length($seq)){ #caso a coordenada + o intervalo seja maior que a sequencia
        $piece_seq .= (length($seq)  - $all_interval[$i-1][1] ) . "pb.fasta\n";
        $piece_seq .= substr($seq,$all_interval[$i-1][1]) ."\n";
    }else{
        $piece_seq .= $itvl . "pb.fasta\n";
        $piece_seq .= substr($seq,$all_interval[$i-1][1],$itvl) ."\n";    
    }

    my $temp_R = $file01_name . ".interval";
    
    unless (open(FT, ">$temp_R")) {		    #Abre o arquivo para escrita
	die ("O ".$temp_R ." nao pode ser aberto!\n");   #Imprime a mensagem se nao for aberto
    }
    
    print FT "$piece_seq";
    close(FT)
    
}



__END__

=head1 NAME

B<mask-flanking-regions.pl> - Utilizando um arquivo em formato fasta, esse programa faz: 1)mascara regioes especificadas por coordenadas gerando um arquivo nome-seq.screen ou; 2) extrai regioes flanqueadoras de uma regiao definida por coordenadas gerando os arquivos (nome.seq.screen , nome.seq.interval) values......

=head1 SYNOPSIS

mask-flanking-regions.pl -f input_fasta_file -c input_coord_file <-interval>


=head1 OPTIONS

=over 2

=item B<-f>

Define o arquivo fasta a ser processado

=item B<-c>

Define o arquivo com as coordenadas a serem utilizadas:

Exemplo:

Formato do arquivo (cada linha deve ter o seguinte formato):

>NOME\tCOORD-01\tCOORD-02

>Linj01.0010 Linj01.0010 hypothetical protein, conserved reverse	140	1513

>Linj01.0020 Linj01.0020 CLC-type chloride channel, putative reverse 	2936	5248

>Linj01.0030 Linj01.0030 hypothetical protein, conserved reverse	6729	7308

>Linj01.0040 Linj01.0040 hypothetical protein, conserved reverse	8005	8907


=item B<-interval>

Define o intervalo quando se deseja extrair as regioes flanqueadoras das regioes definidas

Deve ser um numero inteiro Ex: -interval 1000

Atencao: qdo as distancias entre os genes for menor que o valor especificado pela variavel -interval o programa divide a distancia disponivel entre os dois genes.


=item B<--help>

show this page..hehehe.

=back

=head1 DESCRIPTION

Utilizando um arquivo em formato fasta, esse programa faz: 1)mascara regioes especificadas por coordenadas gerando um arquivo nome-seq.screen ou; 2) extrai regioes flanqueadoras de uma regiao definida por coordenadas gerando os arquivos (nome.seq.screen , nome.seq.interval).

=head1 EXIT CODES

Para a sequencia analizada o script imprime na tela:

<Nome_da_sequencia> <Menor_distancia> <Maior_distancia> <Distancia_média>

=head1 BUGS

Please report them to Romulo <romulovitor@pop.com.br> or Jeronimo <jcruiz@rbi.fmrp.usp.br>

=cut
