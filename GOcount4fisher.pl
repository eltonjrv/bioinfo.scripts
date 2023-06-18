#!/usr/bin/perl 
# Programmer: Elton Vasconcelos (08/Mar/2016)
# Usage: perl GOcount4fisher.pl [list_of_DiffExp_gene_ids.txt] [list_of_genes_and_their_respective_GOterms.tab] [number_of_DiffExp_genes_on_list]  [total_number_of_genes_with_GOterms]
################################################################################################################
# Note 1: Both assign-GO2VGs.pl and fisher_auto.R scripts must exist in the current directory, and the machine must have R installed.
# Note 2: Four outputs will be generated: They will have same prefix of the first input with different sufixes (*-GOs.tab, *-GOs.ids, *-GOs.count, *-GOs-fisher.tab)
##### Example of input1 --> [list_of_DiffExp_gene_ids.txt]:
#Smp_000530
#Smp_005790
#Smp_008620
#Smp_011100
#Smp_013150
#Smp_014780.2
#Smp_015020
##### Example of input2 --> [list_of_genes_and_their_respective_GOterms.tab]:
#Smp_000030      GO:0000502,GO:0030234,GO:0042176
#Smp_000070      GO:0008152,GO:0016746
#Smp_000075      GO:0003677
#Smp_000100      GO:0051015
#Smp_000110      GO:0003924,GO:0005525
#Smp_000130      GO:0008152,GO:0016787,GO:0008203,GO:0016042,GO:0016298
#Smp_000150      GO:0005515


if (@ARGV != 4) {
die ("**Error**\nThe cmd line must contain 4 arguments: 2 files and 2 integers\nUsage: $ perl GOcount4fisher.pl [list_of_DiffExp_gene_ids.txt] [list_of_genes_and_their_respective_GOterms.tab] [number_of_DiffExp_genes_on_list]  [total_number_of_genes_with_GOterms]\nRead script's initial commented lines for a better explanation\n");
}

my $outfile1 = $ARGV[0];
$outfile1 =~ s/\.\w+$/\-GOs\.tab/g;
my $outfile2 = $ARGV[0];
$outfile2 =~ s/\.\w+$/\-GOs\.ids/g;
my $outfile3 = $ARGV[0];
$outfile3 =~ s/\.\w+$/\-GOs\.count/g;
my $outfile4 = $ARGV[0];
$outfile4 =~ s/\.\w+$/\-GOs\-fisher\.tab/g;

`perl assign-GO2VGs.pl $ARGV[0] $ARGV[1] >$outfile1`;
`cut -f 2 $outfile1 >x`;
`perl -pi -e 's/^\n//g' x`;
`perl -pi -e 's/\,/\n/g' x`;
`sort -u x >$outfile2`;
`cat $outfile2 | xargs -i grep -c -P '{}\,|{}\$' $outfile1 >x`;
`cat $outfile2 | xargs -i grep -c -P '{}\,|{}\$' $ARGV[1]  >y`;
`paste $outfile2 x y >$outfile3`;
`Rscript fisher_auto.R $outfile3 $ARGV[2] $ARGV[3] >z`;
`perl -pi -e 's/^\\\[1\\\] //g' z`;
`paste $outfile3 z >$outfile4`;
`rm x y z`;
