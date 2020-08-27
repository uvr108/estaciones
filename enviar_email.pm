use strict;
use POSIX;
use DBI;
use Time::Local;
use POSIX::strptime;
use Text::Unidecode;

sub envia_email
{
    my $st = $_[0];
    my $nm = $_[1];
    my $net = $_[2];

    my $message;
    my $from;
    my $subject;
    my $subject_decoded;

    $from    = "From: noreply\@csn.uchile.cl\n";
    $subject = "Subject: ($st) alerta estacion caida\n";
    {
            use utf8;
            $subject_decoded = $subject;
            utf8::decode($subject_decoded);
            $subject = unidecode($subject_decoded);
    }

    $message .= "Network :  $net\nStation : $st\nNumero de dias caida : $nm\n";

    my @lista = ();

    push @lista , "uvergara\@csn.uchile.cl";
    # push @lista , "ramenabar\@csn.uchile.cl";

    foreach my $send (@lista)
    {
        # print $send;
        open(SENDMAIL, "|/usr/sbin/sendmail -f preliminar\@csn.uchile.cl $send") or die "Cannot open sendmail : $!";
        print SENDMAIL $subject;
        print SENDMAIL $from;
        print SENDMAIL "Content-Type: text/plain; charset=utf-8\n\n";
        print SENDMAIL $message;
        close(SENDMAIL);

    }
}

return 1;
