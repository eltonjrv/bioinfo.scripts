#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (20.03.2015)
# Usage: perl cpg2gff.pl 
############################################
# Note-1: The cpgi130.pl outputs must be named *.cpgOUT
# Note-2: Edit line 18 according your input names to be considered
# GFF files will be created with the same name of the inputs *.cpgOUT.gff

my ($line_cpg, $outfile, @array, $chr_name, $fmin, $fmax, $score, $ID);

foreach my $cpgOUT ( <*.cpgOUT> ) {
    if ( -f $cpgOUT ) {
        print STDERR ("*** $cpgOUT done! ***\n");
        open (CPGFILE, "$cpgOUT") or die ("Can't open $cpgOUT\n");
        $line_cpg = <CPGFILE>;
        chomp($line_cpg);
        $chr_name = $cpgOUT;
        $chr_name =~ s/\-CDSsMasked.seq.*//g;    #Considering that *.seq.cpgOUT inputs refer to chromosome or scaffold names
        $outfile = $cpgOUT.".gff";
        open (OUTFILE, ">$outfile") or die ("Can't open $outfile\n");  #abrindo arquivo de saida
        while ($line_cpg ne "") {             
            if ($line_cpg =~ m/start\=\d+/) {
                $line_cpg =~ s/\, +/\t/g;
                @array = split(/\t/, $line_cpg);
                $fmin = $array[2];
                $fmin =~ s/start\=//g;
                $fmax = $array[3];
                $fmax =~ s/end\=//g;
                $score =  $array[5];
                $score =~ s/ObsCpG\/ExpCpG\=//g;
                $ID = $array[1];
                $ID =~ s/ +/_/g;
                print OUTFILE ("$chr_name\tIQUSP\tCpG_island\t$fmin\t$fmax\t$score\t\+\t\.\tID\=$ID\;note\=$array[4]\+$array[5]\+$array[6]\;\n");
		$line_cpg = <CPGFILE>;
                chomp($line_cpg);
            }
            elsif ($line_cpg =~ m/^by Takai/) {
                $line_cpg = <CPGFILE>;
                $line_cpg = <CPGFILE>;
                chomp($line_cpg);
            }
            else {
                $line_cpg = <CPGFILE>;
                chomp($line_cpg);
            }
        }
    }
    else {
         print STDERR ("$cpgOUT does not exist!\n"); # print a standard error msg in case there's no .cpgOUT file
    }
}
