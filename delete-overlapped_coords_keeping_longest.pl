#!/usr/bin/perl
# Programador: Elton Vasconcelos (06/Mar/2015)
# Script that deletes overlapped features in a sorted tabular file (by coord_start), keeping the longest one
# Usage: perl delete-overlapped_coords_keeping_longest.pl infile.tab-sorted >outfile.tab
#####################################################################
# ATTENTION-1: One must sort by the input file by the column where the start_coord is placed
# $ sort -k [col_start_coord] -n infile.tab >infile.tab-sorted
# ATTENTION-2: Input file must be a three column tabular one (feature_name\tstart_coord\tend_coord)
##### Example of input file ######
#>Smp_137360     9512    14416
#>Smp_027990     121508  133202
#>Smp_027970     163498  182433
#>Smp_137330     193093  199766
##################################

my $input = $ARGV[0];
open (INFILE, "$input") ||
                          die ("Can't open file $input!\n");
my $line = <INFILE>;
chomp($line);
my @array = split(/\t/,$line);
my ($coord1, $coord2, $var, $line2print, $m);

while ($line ne "") {
    $m = 0;
    $var = $line;
    $coord1 = $array[1];  #elemento da array que eh a coord inicial
    $coord2 = $array[2];    #elemento da array que eh a coord final
    $line = <INFILE>;
    chomp($line);
    @array = split(/\t/,$line);
    if ($array[1] >= $coord1 && $array[1] <= $coord2 + 1) { 	
	if ($array[2] < $coord2) {
            $line2print = "$var\t\#longest one"; 
            $line = <INFILE>;
            chomp($line);
            @array = split(/\t/,$line);
            $m = 1;
        }    
        while ($array[1] >= $coord1 && $array[1] <= $coord2 + 1) {	
            #$coord1 will always be the one from the first feature that has overlapped ones on lines below
            #Because the input file is sorted by start_coord  
            if ($array[2] >= $coord2) {
                $line2print = "$array[0]\t$coord1\t$array[2]\t\#coords edited to keep the longest one";
                $coord2 = $array[2];	#Assigning the new coord2, because it is bigger than the previous one
                $m = 1;  
            }
            $line = <INFILE>;
            chomp($line);
            @array = split(/\t/,$line);
	}
    }
    else {
        print ("$var\n"); 
    }
    if ($m == 1) {    # Um dos loops "while" acima foi executado
        print("$line2print\n");
        #$line2print = "";
    }
}

close(INFILE);
