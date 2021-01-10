#!/usr/bin/perl

use POSIX qw/ strftime /;
use File::Spec;
use File::Basename;
use strict;
use Getopt::Std;

use enviar_email;

my $yday = $ARGV[0];
my $yr = $ARGV[1]; 
my $da = $ARGV[2];

$yday = sprintf "%03d", $yday;

my @stat;
my @chan;
my @wave;

my %estaciones = (
   'IN42'  =>  ['C1',344],
   'GO02'  =>  ['C',301],
   'AY01'  =>  ['C1',231],
   'HMBCX' =>  ['CX',211],
   'PATCX' =>  ['CX',203],
   'MG04'  =>  ['C1',186],
   'VA06'  =>  ['C1',185],
   'MG01'  =>  ['C1',185],
   'LC02'  =>  ['C1',142],
   'AY06'  =>  ['C1',133],
   'GO09'  =>  ['C',110],
   'AY02'  =>  ['C1',34],
   'AC07'  =>  ['C1',31],
   'GO03'  =>  ['C',21],
   'PX06'  =>  ['CX',8],
   'PB10'  =>  ['CX',1],
   'MG02'  =>  ['C1',1]
);


# print "$lista\n";

genera($yday, $yr);
sleep(5);
listar($yday , $yr, $da);

sub genera {

    my $yday = $_[0];
    my $yr = $_[1];

    # Si no existe año lo creo

    print "[$yday|$yr]"; 

    if ( not -d "./data/$yr") {
        mkdir "./data/$yr";
    }

    my @net = grep { /^C/  } `ls /ssn/seiscomp/archive/$yr`;

    foreach my $n (@net) {
        chomp $n;
        # print "NET : [$n]\n";
        @stat =  `ls /ssn/seiscomp/archive/$yr/$n`;
        foreach my $st (@stat)
        {   chomp $st;
             # Si no exite estación la creo
             # print "STAT : $n $st\n";
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
    my $da = $_[2];

    my %datos = ();
    my @data = ();
    my %netw = ();
    my %dife = ();

    my @todos = ();
    
      my @net = `ls ./data/$yr`;
      foreach my $n (@net)
      {   chomp $n;
         
         my @stat = `ls ./data/$yr/$n`;
         foreach my $st (@stat)
         { 
           # print "./data/$yr/$n/$st";
           chomp $st;
           push(@todos, $st);
           my @days  = `ls -1r ./data/$yr/$n/$st`;
           my $ant = $yday;

           foreach my $d  (@days) {

               chomp $d;

               my $diff = $ant - $d;
               if ($diff  == 0) {
               }
               else  {
                     push @data , $st;
                     # print "diff -> $diff data  [@data]\n";
                     $netw{$st} = $n;
                     $dife{$st} = $diff; 
               }
               $ant -= 1;
               last;

           }
         }
       }



    while ( my ($clave, $valor) = each %estaciones )
    {
        # print "$clave  => $valor->[0] $valor->[1]\n"  if !examina($clave);
        if (!examina($clave)) {
          $netw{$clave} = $valor->[0];
          $dife{$clave} = $valor->[1] + $yday;
        }
    }             

    my $out = "sta\tnet\tdias\n";

    foreach my $llave (sort { $dife{$b} <=> $dife{$a} } keys %dife) {
      $out .=  "$llave\t$netw{$llave}\t$dife{$llave}\n";
    }

    print "$da | [$out]\n";

    sub examina {

        my $st = $_[0];
        chomp($st);
        if (grep $_ eq $st, @todos) {
            return 1;
        } else {
            return 0; 
        } 
        
    } 
    # while ( my ($clave, $valor) = each %estaciones )
    # {
    #     print $clave . " => " . $valor . "\n";
    # }             
    
    # my $lista = $$puntero{$st}; 
    # print "lista $st -> $lista (int($lista)+int($yday))\n" if defined($lista);


    envia_email($da, $out);
}



# .+[[H|B]H[ZNE12].D.+
# .+H[N|L][ZNE].D.+
# .+BN[ZNE].D.+
# .+EH[ZNE].D.+

