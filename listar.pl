#!/usr/bin/perl

use POSIX qw/ strftime /;
use File::Spec;
use File::Basename;
use strict;
use Getopt::Std;

use enviar_email;

my $yday = $ARGV[0];
my $yr = $ARGV[1]; 

$yday = sprintf "%03d", $yday;

my @stat;
my @chan;
my @wave;

genera($yday, $yr);
sleep(5);
listar($yday , $yr);

sub genera {

    my $yday = $_[0];
    my $yr = $_[1];

    # Si no existe año lo creo

    print "[$yday|$yr]"; 

    if ( not -d "./data/$yr") {
        mkdir "./data/$yr";
    }

    my @net = `ls /ssn/seiscomp/archive/$yr`;  # OJO EN DURO

    foreach my $n (@net) {
        chomp $n;
        print "NET : $n\n";
        @stat =  `ls /ssn/seiscomp/archive/$yr/$n`;
        foreach my $st (@stat)
        {   chomp $st;
             # Si no exite estación la creo
             print "STAT : $st\n";
             @chan = `ls /ssn/seiscomp/archive/$yr/$n/$st`;
             foreach my $ch (@chan)
             {   chomp $ch; 
           
                 if ( $ch =~ m/[H|B|N]H[ZNE12].D$/ )
                 {        
                     @wave = `ls /ssn/seiscomp/archive/$yr/$n/$st/$ch`;
            
                     foreach my $wav (@wave)
                     {   chomp $wav;
                         genera_jul($n, $st, $yr, $yday, $wav) if $wav =~ m/\d{3}$/;
                     }
                }   
            }
        }
   }
}

sub genera_jul {

    my $n = $_[0];
    my $st = $_[1];
    my $yr = $_[2];
    my $yday = $_[3];
    my $wav = $_[4];
   
    my $dia = substr $wav , -3;
    
    if ( int($dia) > 0 and int($dia) == $yday  )
    {

        chomp $wav;

        print "./data/$yr/$n/$st/$dia   |   $wav\n";

        if ( not -d "./data/$yr/$n") {
            mkdir "./data/$yr/$n";
        }
 
        if ( not -d "./data/$yr/$n/$st") {
            mkdir "./data/$yr/$n/$st";
        }

        if ( not -d "./data/$yr/$n/$st/$dia") {
            mkdir "./data/$yr/$n/$st/$dia";
        }

        if ( -d "./data/$yr/$n/$st/$dia" ) {
            my $out =  `echo '$wav' >> ./data/$yr/$n/$st/$dia/$st.txt`; 
        }
    } 
}

sub listar {

    my $yday = $_[0];
    my $yr = $_[1];

    my %datos = ();
    my @data = ();
    my %netw = ();
    my %dife = ();
    
      my @net = `ls ./data/$yr`;
      foreach my $n (@net)
      {   chomp $n;
         
         my @stat = `ls ./data/$yr/$n`;
         foreach my $st (@stat)
         { 
           # print "./data/$yr/$n/$st";
           chomp $st;
           my @days  = `ls -1r ./data/$yr/$n/$st`;
           my $ant = $yday;

           foreach my $d  (@days) {

               chomp $d;

               my $diff = $ant - $d;

               if ($diff  == 0) {
               }
               else  {
                     # print "NO -> $yr $n $st $d $ant $diff\n";
                     # push @{ $datos{$n}{$st} }, $diff;
 
                     push @data , $st;
                     $netw{$st} = $n;
                     $dife{$st} = $diff;
               }
               $ant -= 1;
               last;

           }
         }
       }

    my $out = "sta\tnet\tdias\n";
    foreach my $llave (sort { $dife{$b} <=> $dife{$a} } keys %dife) {
      $out .=  "$llave\t$netw{$llave}\t$dife{$llave}\n";
    }
    envia_email($out);
}



# .+[[H|B]H[ZNE12].D.+
# .+H[N|L][ZNE].D.+
# .+BN[ZNE].D.+
# .+EH[ZNE].D.+

