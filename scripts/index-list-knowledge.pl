#!/usr/bin/perl -w

use BOSS::Config;
use KBS2::ImportExport;
use PerlLib::Cacher;
use PerlLib::SwissArmyKnife;

$specification = q(
	-f <file>	File to process
	-u <url>	URL to process
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $ie = KBS2::ImportExport->new;

if ($conf->{'-f'}) {
  $contents = read_file($conf->{'-f'});
} elsif ($conf->{'-u'}) {
  # cache it and get the results
  my $cacher = PerlLib::Cacher->new;
  $cacher->get($conf->{'-u'});
  $contents = $cacher->content;
} else {
  die "No data!\n";
}

# extract out the
my @list = $contents =~ /<li>(.*?)<\/li>/sg;

# print Dumper(\@list);
my @formulae;
my $x = 0;
my $entryid = 0;
foreach my $entry (@list) {
  my $entryrelation = ["entry-fn","dataset-$x",$entryid++];
  if ($entry =~ /^(.*?)<a href=\"(.*?)\".*?>(.*?)<\/a>(.*?)$/s) {
    my $beginning = Clean($1);
    my $link = Clean($2);
    my $subject = Clean($3);
    my $ending = Clean($4);
    # print Dumper([$beginning, $link, $subject, $ending]);
    my $entries =
      [
       ["has-link", $entryrelation, $link],
       ["has-subject", $entryrelation, $subject],
       ["has-description", $entryrelation, $ending],
      ];
    push @formulae, @$entries;
  } else {
    print "ERROR\n";
  }
}

my $res = $ie->Convert
  (
   Input => \@formulae,
   InputType => "Interlingua",
   OutputType => "Emacs String",
  );
if ($res->{Success}) {
  print $res->{Output};
}


sub Clean {
  my $item = shift;
  $item =~ s/^\s*//;
  $item =~ s/\s*$//;
  return $item;
}
