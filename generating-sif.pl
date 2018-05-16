#!/usr/bin/perl
# Programmer: Elton Vasconcelos (Mar/08/2013)
# Usage: perl generating-sif.pl >outfile.sif
# The infiles must be a list of geneIDs (one per line)
# The directory where the script will be ran must contain the infiles to be treated
# i.e.: *.genes files

#In the case of running on a single file, use the commented line below:
#open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
#my @array = <FILE>;
#chomp(@array);

foreach my $cluster ( <*.genes> ) {
    if (-f $cluster) {
        open (FILE, "$cluster") or die ("Can't open $cluster\n");
	my @array = <FILE>;
	chomp(@array);
	my $n = @array - 1;
	for ($i = 0; $i < $n; $i++)  {
		for ($j = $i + 1; $j < @array; $j++) {
			my $CICS = $cluster;
			$CICS =~ s/\..*//g;
			$CICS =~ s/LeishCICS-//g;
			print("$array[$j]\t$CICS\t$array[$i]\n");	
		}
	}
    }
    else {
        print("Infile is not correct! Please read this script's initial commented lines.\n");
    }

}


