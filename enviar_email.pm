use strict;
use POSIX;
use DBI;
use Time::Local;
use POSIX::strptime;
use Text::Unidecode;

sub envia_email
{
    my $da = $_[0];
    my $message = $_[1];

    my $from;
    my $subject;
    my $subject_decoded;

    $from    = "From: noreply\@csn.uchile.cl\n";
    $subject = "Subject: Alerta estaciones caida\n";
    {
            use utf8;
            $subject_decoded = $subject;
            utf8::decode($subject_decoded);
            $subject = unidecode($subject_decoded);
    }

    my @lista = ();
    if (int($da) == 4) {
        push @lista , "uvergara\@csn.uchile.cl";
        push @lista , "ramenabar\@csn.uchile.cl";
        push @lista , "sebastian\@csn.uchile.cl";
        push @lista , "acastro\@csn.uchile.cl";
    } else {
        push @lista , "uvergara\@csn.uchile.cl";
    }
      

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
