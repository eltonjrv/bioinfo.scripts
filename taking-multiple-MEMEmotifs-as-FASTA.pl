#/usr/bin/perl -w
#Programmer: Elton Vasconcelos (26.04.2011)
# script that generates a FASTA file of motifs present within the MEME default output
# Usage: perl taking-multiple-MEMEmotifs.pl
# Motifs must be in meme.txt files, which is withn diretorios *validating directories
# Please edit line 8 if your directories have other nomenclature pattern

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
