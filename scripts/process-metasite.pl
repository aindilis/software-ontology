#!/usr/bin/perl -w

use PerlLib::IE::MDR;
use PerlLib::SwissArmyKnife;

# my $url = 'http://www.aclweb.org/aclwiki/index.php?title=RTE_Knowledge_Resources';
# my $file = "RTE_Knowledge_Resources";

my $file = "Satisfiability_modulo_theories";

my $mdr = PerlLib::IE::MDR->new
  (
   File => $file,
   Silent => 1,
  );

print Dumper($mdr->Results);

# go ahead and process with MDR
# first cache it in case we lose it
