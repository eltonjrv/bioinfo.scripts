#!/usr/bin/perl
#Programmer: Elton Vasconcelos (13/Sep/2013)
# Usage: perl calc-MFED-zScore-Apply_cutoff.pl [input.tab] [#col_MFED_25oC] [#col_z-score_25oC] [#col_MFED_37oC] [#col_z-score_37oC] [MFED_cutoof_value] [z-score_cutoff_value]
###########################################################################
# NOTE: One must choose to apply the cutoff on two different temperatures or only one
# And inform on the cmd line in which columns the MFED and z-score values are placed on the input file (starting the count from ZERO)

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line = <FILE>;
chomp($line);
my @array;
if (@ARGV == 5) {        #### Working with only one temperature
    my $MFED_cut = $ARGV[3];
    my $z_score_cut = $ARGV[4];
    while ($line ne "") {
        @array = split(/\t/, $line);
        if ($array[$ARGV[1]] >= $MFED_cut && $array[$ARGV[2]] <= $z_score_cut) {
            print("$line\n");
        }
        $line = <FILE>;
        chomp($line);
    }
}
elsif (@ARGV == 7) {    #### Working with two temperatures
    my $MFED_cut = $ARGV[5];
    my $z_score_cut = $ARGV[6];
        while ($line ne "") {
        @array = split(/\t/, $line);
        if ($array[$ARGV[1]] >= $MFED_cut && $array[$ARGV[2]] <= $z_score_cut ||
            $array[$ARGV[3]] >= $MFED_cut && $array[$ARGV[4]] <= $z_score_cut) {
            print("$line\n");
        }
        $line = <FILE>;
        chomp($line);
    }
}
else {
die ("**Error**\nThe cmd line must contain 5 or 7 arguments:\nUsage: \$perl calc-MFED-zScore-Apply_cutoff.pl [input.tab] [#col_MFED_25oC] [#col_z-score_25oC] [#col_MFED_37oC] [#col_z-score_37oC] [MFED_cutoof_value] [z-score_cutoff_value]\nRead script's initial commented lines for a better explanation\n");
}

