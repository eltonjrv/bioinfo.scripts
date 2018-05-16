#!/usr/bin/perl
#Programmer: Elton Vasconcelos (14/Aug/2013)
#Script that calculates the MFED and Z-Score for your target RNA molecule structure
#It takes as input the output file from the standalone RNAfold software (see example below)
#Usage: perl calc-MFED-zScore.pl [infile.txt] [number_of_scrambled_sequences_for_each_RNA] >outfile.tab
###############################################

#Note: To get scrambled sequences use the SSE sequence editor program (http://www.virus-evolution.org/Downloads/Software/)
#Go to the tab Research > Scramble Sequences

################## INFILE example (standalone RNAFold output) ####################
#>Lm21.0250_3p Frag=1^Start=1^End=1791 ^Length=1790^3'UTR :86663..88453 _3'UTR:86663..88453 undefined product 86663:88453 forward
#GCAGCACGUCAGCAGCAGCAGCAGCACGCGUAUAUGCCCCUUUUAUAGGGGGGGGAAACGGUUUGAGAUUUGGUGCCGGCUAUAGACAAGCGGUAUUGACGGUCGCGCGGCAUGUGCCGCCGACGCAUCGUAGCGGAGGGGGAAGCCUCUUGCAGACGAACGCGCAUGGGUUCUGCCCCCUCUCCCUCUGAAGCUGCUUUGGACGCACACAUCGUGUACCACUAUGGGUGUGUGAGUCUCCUGAUUCUCCGUAACGAGCUCGUGCCCUUCCUCUCUUUCCUUAGCGGGCACGUCUUCGACGUUUGCGCUUCUGCGGUGGCGGUGACGACGAUGAAGACGCACCCGUUGAGGUGCGCAUGCGUAUCGAUGCGUGUCAGGGCGCGGAGGGUAAGGAGUCAGUGCCCCCCCCCUCUCUCUCCCAUAUUCAGCUCCGUCAGGGAGCGUGGUCUCUUUUUUCUCGGGAGUCACACUAUCCGCGGACACCCGUCAAUGGCGGUGAGGGAGAGGGAGUGGGGGUGUGAAAGGUGGACAUCCCGCCUGUGCACGUCGUGCGUCGAUGCUUCUACCCUCGAAUCACCUCCACCAUCACCACCGCCGCGGCGCCUCCCGCGUGAAACGCGCACAGCUGACGAUCGCAUGGCACCCUCCCACUCCACCCUCCCCUGCUCUCCCUUUCUUUGCGUACGAAGGCGUCUCUCGUUUCGUAAUUCGCUGGUCUUCAGCGUGCGCGACUCUCUUCCUCUGCUUGACCUUUCUGAGAACGUGGAGACGGGGGACAAGGUGGGAACGGCGACGGAGCUGCUAGCGAGCACCGCCUCCACUUUCUUGGGCAGCCGUCAGCUUGCCACCACCACCACCACCCCCUCUCGCUCAUUCUCUGUCGAUAUAACGCCUAUGCGUUUUGUCUUCGGAUUCCUUCUCCCUGUCCUCCCGCCGUCCGCCGUGCCGCGCAUCACCGCACACGGCGGCCUGCAUGAGGGACGAUCGACUGGGACAACACAUAAAGAGACACUCAACGGCGCUCGCAUGAGCAGGAACAAAUCGUGGCGCGGCCCGAUGGGAGAGGAUGGGAGGAGGGCACCGCCCACCCACCCACCCCUCUCUUUCCUUCGCCUCUGUCUCUUAGCUACCGGCCCUCUUUUUCGUGGCCAUGUCUCCAUACGAUGCUUCUCGUCGGUGUGCUCGCUGCCGCUCCACAGCCCUUCCCCCCCUCCCUCUCUCUCAUUGCUCCGCGACUCGAACGCCCACGGUUGACAUGCACGCGGACACAUGCGAAAGGUUGUGUGACGAUGGAUCGCAAGGCUGCUCAGCUGUGUGCAUGAGUGGCACUGUGUCCGCGUGUGUCUGUGGACCUUGUCCAGCUACUCGAGGACAUCGUUGUGUCUGGUUUCUGUGCUCCUAGCGACGGCGCUCCUUUCUCUUUUCCGUCUCGUUGUUGCCCCUUCUUCCUUCCCCGUGAUGACGGGCGAAGGUGAAGGUAGGGGGCACACACGCCUCCGUGCGCGGUGUCUCAGGGCCCAGUGACCCCCACUCUGUCUGGGGAGGCCAACCAACCAACCCUAUCCUCUGACGAGUGCCGAGCCACUUCUGCUGGUAACAGGCGCGAGCACCCACGAAGUGAGGAUGUCAGAGCGAUACAUCGAGGGAAACGAAAGGCGAACAAGGCGUUGGCAUUGUCGAACUGCUACUCGCUCCCCCCUCCUCGUGUGUGUGUGUGUGUGUGUGUGCGUGUGUGUGUGCUUGUUAGUGUUAUCCUCAGUAUUCUGAAACAAGCGAUGCGUACACGGUUGA
#((.((......)).))..((((.(((((((((((((((.(...(((((((((((((..(((((..(...)..).))))......((..((((((.(((((.((((.(((((....)))))))))...((((...((((((((.(((((..(((.(.(....))))).)))))...))))))))......(((((.....(.(((((((....((((((((((...(((..(.(((..(((((.(((((((((.(((....)))(((((..........((((((((((..((((((((.((((..((((.((.....)).))))..)))).))))))))..))))))))))...((((((((....)))))))).)))))))))))))).)))))))))..)))((((((((((((((((.......(.(((((..(((((.((((.(((((.......))))))))).)).))))))))).(((((.....)))).).))))))))))).))))).)))..((((((.....)))))))))))))..))))))).).)))))..(((((((....(((((.((.....(((((((((((.(((((..(((((...)))))..(((((.(((((((..((((................(((((((.((((((.(((((.((((((((((.((.....)))))))))...))).((((...((((.(.(.((......))).))))).)))).....))))).).))))))))))))...((.(((((.(((...(((((.((.(((((((((.(((.((((......(((..((((..(((....................(((..(((.((....((((..((((.(((((....))))).))))..)))).............(((((..((.(.((((((((..(((......))).)))))))).).))..)))))..)).)))..)))..........((((((((......(((((((....)))).((((...((((.(((...))))))).(((((((.((((.((.((((...))))..)).))))..)))))))))))...)))..)))))))).)))..)))).)))......))))............((((......)))).)))))))))))))).)))))...))).)))))))................))))..)))).)))......((.((((.(((.((((((((((((.(((((...((((.....))))...)))))..((((((((((.....)).))))))))...))))))))))))...))).)))).))..)))))....)))).)............(((...(((((((((.(((((((((....................))))))))).(((((..((((((((((....))))).))))).)))))..)))))))))...))).))))).)))))).....((((..((((.....))))..)))))))))))...............(((((((((((..(((((..(((((....).))))....))))).....(((((...))).))..))))))).))))..)))))))..))))...((.(((.....))).))...)))))))))))..))..))))))).))).)))...).).))))))))))))))(((((((((((((((((..........((((....))))))))))).)))))))))).)))). (-957.89)
#>Copy_1 ^Length=1790^3'UTR :86663..88453 _3'UTR:86663..88453 undefined product 86663:88453 forward
#GCAGUAGGUCAGCAGUAGGAGCACCACGCGUCUACGCCCCUUGUACAGCGGGGGGACACAGAUGCACACUUUCUGCCGCCUAAACAAAAGGGGUAUGGAAGCUGGCGCUGCAUGUGCGGUCGACGCAUCGUGGGGCAGGCGGGAGCGUCGUUCGGGUGUAGGGGCCUGGGUUCAGCGCCCUCUCCCUGUGCAGGUGCGUCGCACGCUCACUCCCUCUCCAAUUACGGAUCUGUCAGUCCCCGGAUUCUUCGCAACGAGUUGGUGCCAUUCCUCUCUUUCAUUUGCCGUCAGGACCUUGACGUUUGAGCUCCUGCGCUAGUGGUAAUGACUAUGACGACGGACCCGAUCACGUGCGCAAGCCUAGCGUUGCCUCUUGGGGCGCGGAGGCUGAGGACUGAGUGCCCCUCCCCUCCCUCUCCGAAAGUGAGCCCCGACUGGCAGCGUCGUCUCUGUUGUGUGGGGAGUCAUACCAUUCGCCGUCGCCAGUCUAUGUCUGCGAUGGAUAGGGAUUGCGCGUUUCAAGGUUCGACGUCCCGCCUGUACACGUGGUGCUUCGACGCUCCUACUCUCGACUGACCACCAGCAUCAUCACCGUCGCUGCGCCUUCUGCGUGAUAGGGGCAAAGCUGACGGUCGCAUCGCAACCUUCGACUCAAUCCACCCUUUCUAUGCCUUUCUUCGUGUGCGAUGAUGUCCCUCGGUUUGUAAUUCGAUGUUGUCCCGCGUCCUCGCCCCUGUUCCUCUGGUCGACCUUACCGCGACCAUGGACACGGGGGAGAAUGUCGGCACGGCGGCGGAGCUGCCAUCCAGCACCGCCUCCACUUUCUGGGGCAGUCGUGAGCUUCCAACCGCGAGCAGCGCCCCCUCUCCCUCAGUGUCUGCCGCUGUGACGCCGAGGCGUUCUCUGUUCAGGGCCCUCCUCCCUGUCUUCCGGCCGGUCGACGUACCGCGCCUGACCGCACAGGCCGCCCCGCAUGAGGGACGCUCCAUUGCGACACCACAUAAUGUGACACUCAACCGCGUUCUCUUGACCAGGAACAUAACGUGGAGGGGCGCAAUUGGCGACGCUAGAAGGACGACACUGCCCACCCAGCCACCUCUCUGUUUACGUCGCAUCAGUCUAUUAGAUCCCGGCCCUCCUCUCCGUGGCCACGGCUCGAUGCGUUUCUUUUGGGCGGUGCGCUUGCGGACGAUCCACAGCCCUACACCCCCUGCCUCUGUCUCAUUGGUGCCCCACUUGAAGGGCGAGGGCUCACAUUCACGCGGACAAAUGCUACAGGUUGUCUCAGGAAGCAACGCUACGGUGCUGACCGGGGUGGAAGACUGGAAAUCUCUGCUCGUGUGUCGGCGGACCUUGUUCUACCAGUCCAGGACAUCGUGGAGUCUUGAUGCUGUUCUCCUAGCGCCGGCGCUCCCUUCUGUUUUCUGUCCCGAUAUGGUCCUUCCACCCUCCCCCUUCAUAACAGGCGAUGGUGCAGGUAGGUGGAAGAAACGCGUGCGUGCGCGCUGCCUGAAGGCCCGUUGCCGCCCAUUCUGUCAAGGGAUGCGAUCCGACGAACUCUAUUCUGUCACGAGUGGCCACCCAGUGCUGGUGGGAGCACGCGUGUGAACCCACGAACUGAGGCUUUCGGAGCGAGAAAUCGAGUGACACAAGACGCGAACGAGGCGCUCGAAUUCUCCAACUGCUUCUCUCUACCACCCCCUCGAGUGUGUGGGUCUUUGUGUGUGCGCGUGUGUUUGUUUCUUCGUGUCGUCCUGAGCACUCUGACACCAGCGAUGCGUCCACUGUUGA
#(((((.((((((((((((((((.....((((((..((((((((.....))))))).)..)))))).(((((((((((.(((.......))))))).))))).))((((.....)))).(((((.((((((((..((((((((((.(((((..(.((.(..((((((((....))).)))))..))).(((((.(.(((.....))).)..(((((.((((.....(((((((........))))))).((((((((((((((((.(.................((.(.(((((.(((((...))))).)))))))).(((((((.(((((.((((((((((..((.....(.((....)))..((((((((..(((((((.((((((..((((...(((.....))).))))..)))))).......)))))))..))))))))))..)))))))).))...))))))))))))....).)))))).)).))).))))))))).))))).)))))........)..)))))))))))))))...)))))))).))))))))))))))...).))))))....(((((......(((((((((((((((((((...((((((.(((((((.((.(((((((((.....(((.......((.........)).......)))..))))))).)).)).))))))).......(((((......)))))...))))))((((((..((((((...(((..(((((..((((((((((((((..........((.(((((.((((.....)))).))))).)).......(((((.((.((..((........))..)).))))))).)))))))).))))))((((....((((..((((.(..((((....))))..).))))..))))...)))).)))))..)))..(((((((......)))).)))..(((.((((...(((......)))....(((.....)))...))))...))).....))))))))))))...))))))).))))))....))))))(((...((((((((((..((((((..(((((.((.........((((((((...((..((((....(((((........).)))).((((.....(((...((((((((((((((((..(((.(((.(((((...(((.((((...(((((.........(((....)))..(((((((.(((((...........(.((((((.((...))..))))))).(((((((.(((....))).))..((((..(((((((.((((...(((((.((.....)))))))...((((((........))))))....(((((.(((..((((......))))..))).))))).)))))))))))..))))........))))).))))).)))))))....)))))..)))).)))...))))).......))).)))))))))))))))))))..))).)))).....))))...)).))))))))..((((((.....))).)))..)))))))(((...)))..)))))).((((((((((..((.((((((..(((((....(..(.(((((.(((((((.(......((....))..)))))))).))))))..).)))))..((((((((........))).)))))..)))))).))))))))))))..........)))))))))).)))...(((....))).)))))....)))))... (-925.81)
##################################################################################

open (FILE, "$ARGV[0]") or die ("Can't open file $ARGV[0]\n");
my $line = <FILE>;
chomp($line);
my $num_scrambSeq = $ARGV[1];
my $seq_name;
my @array;
my $MFEs;
my $original_MFE;
my $ave; my $MFED;
my $std; my $zScore;

print("rnaID\tMFE(kcal/mol)\tMFED(%)\tz-Score\n");
      
while ($line ne "") {
    if ($line =~ m/^>[\w\d\._\-\:]+/) {       #Taking the first sequence, which is the original RNA molecule
        $seq_name = $&;                    #storing the name of the RNA
        $seq_name =~ s/^>//g;
        while ($line ne "" && @array < $num_scrambSeq) {
            if ($line =~ m/\( *\-*\d+\.*\d*\)$/) {    #regular expression for the MFE value at the end of the line
                $MFEs = $&;
                $MFEs =~ s/[ \(\)]//g;        #excluding the parenthesis and white spaces from the MFE string
                push(@array, $MFEs);         #catching all the MFE values into an array
            }                                #the first one is from the original sequence, and the rest from the scrambled ones
            $line = <FILE>;
            chomp($line);
        }
        $original_MFE = shift(@array);        #removing the original MFE from the array and storing it in a scalar
        $ave = &average(\@array);             #executing sub-routine average on the @array data, and storing the result in a scalar
        $std = &stdev(\@array);               #executing sub-routine stdev on the @array data, and storing the result in a scalar
        if ($std != 0) {
            $MFED = (($original_MFE / $ave) - 1) * 100;
            $zScore = ($original_MFE - $ave) / $std;
            #print("$seq_name\t$original_MFE\t$ave\t$std\n");
            print("$seq_name\t$original_MFE\t$MFED\t$zScore\n");
        }
        else {    # if $std is equal to ZERO, the script would stop running if I tryed to calcute z-score (Illegal division by zero)
            print("$seq_name\t$original_MFE\t0\t\-\n");
        }
        @array = ();
    }
    $line = <FILE>;
    chomp($line); 
}

############## Sub-routines
# Taken from http://edwards.sdsu.edu/labsite/index.php/kate/302-calculating-the-average-and-standard-deviation
sub average{
        my($data) = @_;
        if (not @$data) {
                die("Empty array\n");
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}

