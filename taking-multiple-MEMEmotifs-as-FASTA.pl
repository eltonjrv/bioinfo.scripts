#/usr/bin/perl -w
#Programmer: Elton Vasconcelos (26.04.2011)
# script escrito para gerar um fasta de motifs encontrados nos arquivos de saida do MEME
# Usage: perl taking-multiple-MEMEmotifs.pl
# Os motifs devem estar dentro dos arquivos meme.txt que, por sua vez, estao dentro dos diretorios *validating*
# se fos diretorios tiverem outro padrao de nomenclatura, deve-se alterar a linha 7.

foreach my $contigDIR ( <*validating> ) {
    if (-d $contigDIR) {
        my $nam = $contigDIR;
        $nam =~ s/\-validating//g;
        `grep -P '^MO|^Mu' $contigDIR/meme.txt >x`;
        open (FILE, "x") or die ("Can't open x\n");
        @array = <FILE>;	#elementos pares serao os cabecalhos e impares as sequencias
        #chomp(@array);
        my $element = @array;
        my $c = 0;
        while ($c <= $element) {
            $array[$c] =~ s/MOTIF +/>MOTIF/g;
	    $array[$c] =~ s/\t/\-$nam  /g;
            $array[$c] =~ s/Multilevel +//g;
            $c++;
        }
	print("@array");
   } 
   else {
        print("Directories' names are not correct! Please read this script's initial commented lines.\n");
    }
}
close(FILE);
#close(OUTFILE);
