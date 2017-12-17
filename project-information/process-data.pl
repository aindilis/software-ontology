#!/usr/bin/perl -w

#  EXISTING CAPABILITIES:

#  	(Non-exhaustive) List of the Capabilities of the FRDCSA

#  	KEY:
#  	(#system) -> not fully implemented
#  	(%system) -> partially performs capability
#  	(!system) -> integrated but not available due to licensing
#  	()	  -> no system implements this capability yet



use PerlLib::SwissArmyKnife;

use KBS2::ImportExport;

my @assertions;
my $c = read_file("data.txt");
foreach my $line (split /\n/, $c) {
  if ($line =~ /^\t\t(.+)$/) {
    my $data = $1;
    my ($feature,$systems);
    if ($data =~ /^(.+)\s\((.+)\)$/) {
      $feature = $1;
      $systems = $2;
    } else {
      $feature = $data;
    }
    if ($systems) {
      my @systems = split /[\/\|]/, $systems;
      # print Dumper([$feature,\@systems]);
      foreach my $system (@systems) {
	my $flag;
	if ($system =~ /^\#(.+)$/) {
	  $flag = "not fully implemented";
	  $sys = $1;
	} elsif ($system =~ /^\%(.+)$/) {
	  $flag = "partially performs capability";
	  $sys = $1;
	} elsif ($system =~ /^\!(.+)$/) {
	  $flag = "integrated but not available due to licensing";
	  $sys = $1;
	} else {
	  $sys = $system;
	}
	push @assertions,
	  ["isa", $sys, "system"],
	    ["contains-system","FRDCSA", $sys],
	      ["has-capability", $sys, $feature];
	if ($flag) {
	  $flag =~ s/ /-/g;
	  push @assertions,
	    [$flag, $sys];
	}
      }
    }
  }
}

my $convert = KBS2::ImportExport->new();
my $res = $convert->Convert
  (
   Input => \@assertions,
   InputType => "Interlingua",
   OutputType => "Emacs String",
  );
if ($res->{Success}) {
  print $res->{Output}."\n";
}

