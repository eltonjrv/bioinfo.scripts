#!/usr/bin/perl
## Programmer: Elton Vasconcelos (23/Jan/2017)
## Usage: perl renaming-seqs.pl [fasta_extension] 
# Script that will rename the sequences within a fasta file by the file's name plus a numerical autoincrement
# The user must inform, as the first argument of the script, the extension of the fasta files within the current directory (e.g. fa, fas, fasta, fna, etc)

if (@ARGV != 1) { die ("The user must inform, as the only argument of the script, the extension of the fasta files within the current directory (e.g. fa, fas, fasta, fna, etc...)");}

my($file, $line, $prefix, $c, $outfile);
my $m = 0;

foreach $file (<*.$ARGV[0]>) {
	if (-f $file) { 
		$prefix = $file;
		$prefix =~ s/\.\w+$//g;
		open (INFILE, "$file") or die ("Can't open file $file!\n");
		$line = <INFILE>;
		chomp($line);
		$outfile = $file;
		$outfile =~ s/\.\w+$/\-nn.fasta/g;	# nn stands for New Names
		open (OUTFILE, ">$outfile");
		$c = 1;
		while ($line ne "") {
			if ($line =~ m/^>/) {
				$line =~ s/^>//g;
				#print OUTFILE (">$prefix-s$c $line\n");
				print OUTFILE (">$prefix"."_$c $line\n");
				$c++;
			}
			else {
				print OUTFILE ("$line\n");
			}          
			$line = <INFILE>;
			chomp($line);
                }
	}
	`rm $file`;
	$m = 1;
}
if ($m == 0) {
	die ("There's no file with the *** $ARGV[0] *** extension within the current directory!\n");
}
