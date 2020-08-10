#!/usr/bin/perl
# Programmer: Elton Vasconcelos (21.04.2020)
# Script that filters BlastHits by cutoffs of %id and alignment length (coverage) established by the user
# Usage: perl blast-id-coverage-cutoff-HASH.pl [Blast-output] [Blast2Table.pl-output] [threshold for %id, integer 1-100] [fraction of coverage, fraction 0.n - 1] >outfile

open (FILE1, "$ARGV[0]") or die ("Can't open $ARGV[0]\n");
open (FILE2, "$ARGV[1]") or die ("Can't open $ARGV[1]\n");
my $id = $ARGV[2];		# %identity cutoff
my $cov_frac = $ARGV[3];	# coverage fraction cutoff
my $cov_size;			# coverage size cutoff
my $query;			# query ID
my %hash;

while (<FILE1>) {				#Going through Blast default plain text output
	chomp($_);
	if ($_ =~ m/^Query= \S*/) {
		$query = $&;
		$query =~ s/Query= //g;		#storing query's name
	}
	if ($_ =~ m/^ +\(.+ letters\)/) {	#line that informs the query size
                $_ =~ m/\d+\,*\d+/;
                $qsize = $&;			#storing query size(pb) 
                $qsize =~ s/\,//g;    		#removing comma, in >10,000 cases
	}
	$hash{$query} = $qsize;
}
while (<FILE2>) {				#Going through Blast default tabular output
	chomp($_);
	@array = split(/\t/, $_);
	$cov_size = $hash{$array[0]} * $cov_frac; 		#coverage size cutoff (query size x user-defined fraction)
	if ($array[2] >= $id && $array[3] >= $cov_size) {	#if cutoffs are fulfilled
		print("$_\n");
	}  
}
