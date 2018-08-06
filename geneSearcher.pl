#!/usr/bin/perl
###########################################################################
# Programmer: Elton J R Vasconcelos (21/Nov/2005)
# A program that creates individual fasta files for patterns that you're searching within the sequences' headers
# Usage: perl geneSearcher.pl [one_or_two_word(s)_search] [DB-file.fasta]
###########################################################################

# usage: geneSearcher.pl gene_name db-fasta_format
use strict;
use Getopt::Long;
use Pod::Usage;
use Carp ();
eval { Carp::confess("init") };

# Process command line options
my $opt_help = 0;  #parametro --help

my $result = GetOptions("help"   =>  \$opt_help);

# Caso argumento seja "--help" ou não passou argumento necessario 
pod2usage({-exitval => 0, -verbose => 2}) if $opt_help; 

my $input1;
my $input2;
my $db;
my $outfile;

if (@ARGV == 3) {
    $input1 = "$ARGV[0]" ;
    $input2 = "$ARGV[1]" ;
    $db = $ARGV[2];
    my $db_to_outfile = $db;
    $db_to_outfile =~ s/\.\w+//g;
    $outfile = $ARGV[0]."_".$ARGV[1]."_from_".$db_to_outfile.".fasta";
    
open (SEARCHFILE, "$db") ||
			     die ("Can't open $db\n");

open (OUTFILE, ">$outfile") ||
                             die ("Can't open file $outfile\nPlease put the database.fasta in the current directory\n");

my $line = <SEARCHFILE>;

    while ($line ne "") {

       if ($line =~ /$input1.*$input2/ || $line =~ /$input2.*$input1/)  {

                print OUTFILE ("$line");
                $line = <SEARCHFILE>;
                while ($line !~ /^\>\w+/ && $line ne "") {
                        print OUTFILE ("$line");
                        $line = <SEARCHFILE>;
                 }
        }
        else   {
                    $line = <SEARCHFILE>;
        }
    }
}

elsif (@ARGV ==2) {
    $input1 = $ARGV[0];
    $db = $ARGV[1];
    my $db_to_outfile = $db;
    $db_to_outfile =~ s/\.\w+//g;
    $outfile = $input1."_from_".$db_to_outfile.".fasta";


open (SEARCHFILE, "$db") ||
			     die ("Can't open $db\n");

open (OUTFILE, ">$outfile") ||
                             die ("Can't open file $outfile\nPlease put the database.fasta in the current directory\n");

my $line = <SEARCHFILE>;

    while ($line ne "") {

        if ($line =~ /$input1/) {

                print OUTFILE ("$line");
                $line = <SEARCHFILE>;
                while ($line !~ /^\>\w+/ && $line ne "") {
                        print OUTFILE ("$line");
                        $line = <SEARCHFILE>;
                }
        }
        else   {
                    $line = <SEARCHFILE>;
        }
    }
}

else {
    print STDERR ("**Error**\nThe cmd line must have at maximum three arguments:\n\$ perl GeneSearcher.pl [search_string_1] [search_string_2] [file.fasta]\n");
}

close(SEARCHFILE);
close(OUTFILE);




__END__

=head1 NAME

B<geneSearcher.pl> 

=head1 SYNOPSIS

usage: perl geneSearcher.pl [one_or_two_word(s)_search] [DB-file.fasta]

one_or_two_word_search = 1 or 2 word(s) presents in the information line of
a sequence (after the '>' symbol) that you want to search in the DB

DB-file.fasta = a fasta file with multiple sequences (i.e.: nr.fasta)

Obs-1: An outfile will be created automatically with the name "[one_word_search]_from_[DB-file.fasta]"
Obs-2: The DB-file.fasta must exist in the current directory that you will run Gene_Searcher.pl

=head1 OPTIONS

=over 2

=item B<--help>

show this page

=back

=head1 DESCRIPTION

This is a script that creates FASTA file containing genes or proteins that you are searching in a DataBase in FASTA format

=head1 BUGS

Please report them to Elton Vasconcelos <eltonjrv@gmail.com>

=cut


