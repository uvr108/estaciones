#!/usr/bin/perl

use POSIX qw/ strftime /;
use File::Spec;
use File::Basename;
use strict;
use Getopt::Std;

use enviar_email;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime();

my $yr = $year + 1900;
$yday = sprintf "%03d", $yday;

my @stat;
my @chan;
my @wave;

my $ini = $yday - 45;
my $fin = $yday - 1;

=pod
foreach my $d ($ini..$fin) {
    genera($d, $yr);
    print "$d\n";
}
=cut

listar($yday - 1, $yr);

sub genera {

    my $yday = $_[0];
    my $yr = $_[1];

    # Si no existe año lo creo

    if ( not -d "./data/$yr") {
        mkdir "./data/$yr";
    }


    my @net = `ls /ssn/seiscomp/archive/$yr`;

    foreach my $n (@net) {
        print $n;
        chomp $n;
        # Si no existe network la creo 
        if ( not -d "./data/$yr/$n") {
            mkdir "./data/$yr/$n";
        }
    
        @stat =  `ls /ssn/seiscomp/archive/$yr/$n`;
        foreach my $st (@stat)
        {   chomp $st;
            # Si no exite estación la creo
            if ( not -d "./data/$yr/$n/$st") {
                mkdir "./data/$yr/$n/$st";
            }

            @chan = `ls /ssn/seiscomp/archive/$yr/$n/$st`;
            foreach my $ch (@chan)
            {   chomp $st;
                @wave = `ls /ssn/seiscomp/archive/$yr/$n/$st/$ch`;
            
                foreach my $wav (@wave)
                { 
                    if  ($wav =~ m/.+[H|B]H[ZNE12].D.+$yday$/) { genera_jul($n,$st,$yr,$yday,$wav); }
                    if  ($wav =~ m/.+H[N|L][ZNE].D.+$yday$/) { genera_jul($n,$st,$yr,$yday,$wav); }
                    if  ($wav =~ m/.+BN[ZNE].D.+$yday$/) { genera_jul($n,$st,$yr,$yday,$wav); }
                    if  ($wav =~ m/.+EH[ZNE].D.+$yday$/) { genera_jul($n,$st,$yr,$yday,$wav); }
                }
            }   
        }
    }
}

sub listar {

    my $yday = $_[0] - 1;
    my $yr = $_[1];
    # my $per = $_[2];
    # my $ini = $yday - $per;
    # my $fin = $yday - 1;

    my %datos = ();
    my @data = ();
    my %netw = ();
    my %dife = ();
    
      # print "$day\n";
      my @net = `ls ./data/$yr`;
      foreach my $n (@net)
      {   chomp $n;
         
         # if ($cont == 0) { $data{$n} = 0;   }
 
         my @stat = `ls ./data/$yr/$n`;
         foreach my $st (@stat)
         { 
           # print "./data/$yr/$n/$st";
           chomp $st;
           my @days  = `ls -1r ./data/$yr/$n/$st`;
           my $ant = $yday;
           foreach my $d  (@days) {
               chomp $d;
               my $diff = $yday - $d;
               if ( $d == $ant ) {
                   # print "$d  -> $ant -> $yday -> $diff\n"; 
                   $ant -= 1;
               }
               else {

                   # print "XXXXX : $d  -> $ant -> $yday -> $diff\n";

                   push @{ $datos{$n}{$st} }, $diff;
 
                   push @data , $st;
                   $netw{$st} = $n;
                   $dife{$st} = $diff;
                   last;   
               }   
           }
          
           # if ( -e  "./data/$yr/$n/$st/$day" )
           # {
           # }
           # else
           # {
           #   $data{$st} += 1;
           #   $netw{$st} = $n;
           #   # print "$n -> $st -> $day -> $data{$st}\n";
           # }
         }
       }

    # envia_email(%dife, %netw);
    my $out = "sta\tnet\tdias\n";
    foreach my $llave (sort { $dife{$b} <=> $dife{$a} } keys %dife) {
      $out .=  "$llave\t$netw{$llave}\t$dife{$llave}\n";
    #   # envia_email($llave, $data{$llave}, $netw{$llave}) if $data{$llave} == $per;
    }
    envia_email($out);
}

sub genera_jul {

    my $n = $_[0];
    my $st = $_[1];
    my $yr = $_[2];
    my $yday = $_[3];
    my $wav = $_[4];
   
    chomp $wav;
 
    if ( not -d "./data/$yr/$n/$st/$yday") {
         mkdir "./data/$yr/$n/$st/$yday";
    }

    if ( -d "./data/$yr/$n/$st/$yday" ) {
        my $out =  `echo '$wav' >> ./data/$yr/$n/$st/$yday/$st.txt`; 
    } 
}


# .+[[H|B]H[ZNE12].D.+
# .+H[N|L][ZNE].D.+
# .+BN[ZNE].D.+
# .+EH[ZNE].D.+

