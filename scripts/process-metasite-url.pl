#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $url = "https://en.wikipedia.org/wiki/Satisfiability_modulo_theories";

my $commands =
  [
   'extract-links.pl -f -i '.shell_quote($url).' > links.txt',
   'radar-web-search --urls ./links.txt -o "satisfiability modulo theories"',
  ];

ApproveCommands
  (
   Commands => $commands,
   AutoApprove => 1,
  );
