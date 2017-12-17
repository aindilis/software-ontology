#!/usr/bin/perl -w

use BOSS::Config;

use Data::Dumper;
use Text::CSV;

$specification = q(
	-c <columns>	Number of columns
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

use PerlLib::SwissArmyKnife;

use Lingua::EN::Tagger;
my $nps = {};
my $p = new Lingua::EN::Tagger;
my $c = read_file("data.txt");
my $count = {};
my $allcount = 0;
foreach my $line (split /\n/, $c) {
  $allcount++;
  if ($line =~ /^(.*?) - (.+)$/) {
    my ($name,$desc) = ($1,$2);
    # print $desc."\n";
    # now attempt to extract coreferent noun phrases and build a matrix
    my $t = $p->add_tags($desc);
    $nps->{$name} = {$p->get_noun_phrases($t)};
    foreach my $key (keys %{$nps->{$name}}) {
      $count->{$key}++;
    }
  }
}

# now generate the spreadsheet
my $csv = Text::CSV->new;

# we want to select items that have a $count->{item} / $allcount closest to 0.5

# abs($count->{$item}/$allcount - 0.5) will give you a scale for farthest away
# so  1 - abs... will give you 

my $idealratio = 0.2;
my @order = sort {(1 - abs($idealratio - $count->{$b}/$allcount)) <=> (1 - abs($idealratio - $count->{$a}/$allcount))} keys %$count;
my @columns = splice @order, 0, ($conf->{'-c'} - 1);
my @lines;
$status = $csv->combine("NAME", map {uc($_)} @columns);
push @lines, $csv->string;

foreach my $name (sort keys %$nps) {
  my @values;
  foreach my $column (@columns) {
    if (exists $nps->{$name}->{$column}) {
      push @values, 1;
    } else {
      push @values, undef;
    }
  }
  $status = $csv->combine($name, @values);
  # push @lines, "----------\n";
  push @lines, $csv->string;
}

# print "\n********************\n";
print join("\n",@lines);
# print "\n********************\n";

# PrintScores(Scores => $count, Descending => 1);

sub PrintScores {
  my (%args) = @_;
  my $s = $args{Scores};
  if ($args{Descending}) {
    foreach my $key (sort {$s->{$b} <=> $s->{$a}} keys %$s) {
      print $s->{$key}."\t".$key."\n";
    }
  } elsif ($args{Ascending}) {
    foreach my $key (sort {$s->{$a} <=> $s->{$b}} keys %$s) {
      print $s->{$key}."\t".$key."\n";
    }
  }
}


