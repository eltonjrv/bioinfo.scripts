#!/usr/bin/perl
## Programmer: Elton Vasconcelos (25/Apr/2018)
## Usage: perl renaming-seqs_in_fastq.pl [fastq_extension] 
##############################################################
# Script that will rename the sequences within a fastq file by the file base name (initial string that comes before _1_L001_R[12]_001.fq) plus a numerical autoincrement
# The user must inform, as the first argument of the script, the extension of the fasta files within the current directory (e.g. fq, fastq, etc)
# Output(s) will be named *-nn.[your_fastq_extension_typed_as_first_argument]

if (@ARGV != 1) { die ("The user must inform, as the only argument of the script, the extension of the fasta files within the current directory (e.g. fa, fas, fasta, fna, etc...)");}

my($file, $line, $prefix, $c, $outfile);
my $m = 0;

foreach $file (<*.$ARGV[0]>) {
	if (-f $file) { 
		$prefix = $file;
		$prefix =~ s/_1_L001.*$//g;		#ATTENTION: your MiSeq file names must have the following structure: *_1_L001_R[12]_001.fq
		open (INFILE, "$file") or die ("Can't open file $file!\n");
		$line = <INFILE>;
		chomp($line);
		$outfile = $file;
		$outfile =~ s/\.\w+$/\-nn.fastq/g;	# nn stands for New Names
		open (OUTFILE, ">$outfile");
		$c = 1;
		while ($line ne "") {
			if ($line =~ m/^\@M032/) {	# ATTENTION: Check first if your MiSeq headers always start like this (@M032)
				$line =~ s/^\@//g;
				print OUTFILE ("\@$prefix"."\.$c $line\n");
				$c++;
			}
			else {
				print OUTFILE ("$line\n");
			}          
			$line = <INFILE>;
			chomp($line);
                }
	}
	#`rm $file`;
	$m = 1;
}
if ($m == 0) {
	die ("There's no file with the *** $ARGV[0] *** extension within the current directory!\n");
}
