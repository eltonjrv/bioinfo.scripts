#!/usr/bin/perl
# Programmer: Elton Vasconcelos (04/09/2015)
# Usage: perl catching-intronic-pre-mRNA-contigs.pl [infile1.bed] [infile2.bed]
my $file1 = $ARGV[0];
my $base_name = $file1;
$base_name =~ s/\-sorted\..+$//;	#Edit this line according to your infile1 name
my $file2 = $ARGV[1];

`bedtools intersect -s -loj -f 0.99 -a $file1 -b $file2 >$base_name-SMPs-cov99.bedloj`;
`grep \'Smp_\' $base_name-SMPs-cov99.bedloj | grep -P \'\\\t0,\\\t\[CSm\]\' >$base_name-SMPs-monoexonic.bedloj`;
`cut -f 1,2,3,4,5,6,7,8,9,10,11,12 $base_name-SMPs-monoexonic.bedloj >$base_name-SMPs-monoexonic.bed`;
`bedtools intersect -v -split -a $base_name-SMPs-monoexonic.bed -b $file2 | uniq >$base_name-SMPs-monoexonic-intronic.bed`;
`bedtools intersect -s -loj -f 0.99 -a $base_name-SMPs-monoexonic-intronic.bed -b $file2 >$base_name-SMPs-monoexonic-intronic.bedloj`;
`cut -f 4,16 $base_name-SMPs-monoexonic-intronic.bedloj | sort -k 2 >$base_name-SMPs-monoexonic-intronic-IDs.tab`;
`cut -f 2 $base_name-SMPs-monoexonic-intronic-IDs.tab | uniq -c | sort -nr | sed \'s/^ *//g\' | sed \'s/ /\\\t/g\' >$base_name-SMPs-monoexonic-intronic.histog`;

