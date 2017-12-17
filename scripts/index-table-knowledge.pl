#!/usr/bin/perl -w

use BOSS::Config;
use KBS2::ImportExport;
use PerlLib::Cacher;
use PerlLib::IE::MDR;
use PerlLib::SwissArmyKnife;

$specification = q(
	-f <file>	File to process
	-u <url>	URL to process

	-m <file>	Use MDR results file
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $ie = KBS2::ImportExport->new;
my $c;
if ($conf->{'-f'}) {
  $contents = read_file($conf->{'-f'});
} elsif ($conf->{'-u'}) {
  # cache it and get the results
  my $cacher = PerlLib::Cacher->new;
  $cacher->get($conf->{'-u'});
  $contents = $cacher->content;
} elsif ($conf->{'-m'}) {
  die "No data!\n" unless -f $conf->{'-m'};
  $c = read_file($conf->{'-m'});
} else {
    die "No data!\n";
}

my $results;
unless ($c) {
  my $mdr = PerlLib::IE::MDR->new
    (
     Contents => $contents,
     Silent => 1,
    );
  $results = $mdr->Results;
  # print Dumper({Results => $results});
} else {
  eval $c;
  $results = [$VAR1];
}

# there are a few things that we have to do here

# first, fix the MDR results to be more normal, that means iterate
# over and get rid of the accidental meta-groupings

my $x = -1;
foreach my $data (@$results) {
  ++$x;
  my @entries;
  foreach my $entry (@$data) {
    push @entries, @$entry;
  }

  # now replace nested parens with the string contents of them
  my @entries2;
  foreach my $entry (@entries) {
    my @e;
    foreach my $subentry (@$entry) {
      my $ref = ref $subentry;
      if ($ref eq "ARRAY") {
	push @e, GetStringForArray($subentry);
      } elsif ($ref eq "") {
	push @e, $subentry;
      } else {
	print "ERROR\n";
      }
    }
    push @entries2, \@e;
  }

  # now verify all items have the same count

  my $counts = {};
  foreach my $entry (@entries2) {
    my $count = scalar @$entry;
    $counts->{$count}++;
  }

  my $differentcounts = scalar keys %$counts;
  my $maxkey;
  if ($differentcounts != 1) {
    my $max = 0;
    foreach my $key (keys %$counts) {
      if ($counts->{$key} > $max) {
	$max = $counts->{$key};
	$maxkey = $key;
      }
    }
  } else {
    $maxkey = [keys %$counts]->[0];
  }

  my @fomrulae;
  # now we can use these
  # extract the first row as the table of contents
  my $tableofcontents = shift @entries2;
  my $entryid = 0;
  foreach my $entry (@entries2) {
    my $size = scalar @$entry;
    if ($size == $maxkey) {
      my $entryrelation = ["entry-fn","dataset-$x",$entryid++];
      my $j = 0;
      foreach my $item (@$entry) {
	if ($tableofcontents->[$j] ne "") {
	  my $predicate = "has-".Clean($tableofcontents->[$j]);
	  my $formula = [$predicate, $entryrelation, Clean($item)];
	  push @formulae, $formula;
	}
	++$j;
      }
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
}

sub Clean {
  my $item = shift;
  $item =~ s/^\s*//;
  $item =~ s/\s*$//;
  return $item;
}

sub GetStringForArray {
  my $entry = shift;
  my @string;
  foreach my $subentry (@$entry) {
    my $ref = ref $subentry;
    if ($ref eq "") {
      push @string, $subentry;
    } elsif ($ref eq "ARRAY") {
      push @string, GetStringForArray($subentry);
    } else {
      print "ERROR2\n";
    }
  }
  return join(" ", @string);
}
