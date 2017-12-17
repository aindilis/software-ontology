#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use KBS2::ImportExport;

my $ie = KBS2::ImportExport->new;

# turn into a freekbs thing

my $data;
GetData();

# there are a few things that we have to do here

# first, fix the MDR results to be more normal, that means iterate
# over and get rid of the accidental meta-groupings

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

my @formulae;
# now we can use these
# extract the first row as the table of contents
my $tableofcontents = shift @entries2;
my $entryid = 0;
foreach my $entry (@entries2) {
  my $size = scalar @$entry;
  if ($size == $maxkey) {
    my $entryrelation = ["entry-fn","dataset",$entryid++];
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

sub GetData {
  $data = [
	   [
	    [
	     'Resource ',
	     'Type ',
	     'Author ',
	     'Brief description ',
	     [
	      [
	       [
		'[1]'
	       ]
	      ]
	     ],
	     [
	      [
	       [
		'[2]'
	       ]
	      ]
	     ],
	     [
	      [
	       [
		'[3]'
	       ]
	      ]
	     ],
	     [
	      'Usage info'
	     ]
	    ],
	    [
	     [
	      'WordNet'
	     ],
	     ' Lexical DB ',
	     ' Princeton University ',
	     ' Lexical database of English nouns, verbs, adjectives and adverbs ',
	     '3 ',
	     '21 ',
	     '18 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'eXtended Wordnet'
	     ],
	     ' Lexical DB ',
	     ' Human Language Technology Research Institute, University of Texas at Dallas ',
	     ' Extension of WordNet based on the exploitation of the information contained in WordNet definitional glosses: the glosses are syntactically parsed, transformed into logic forms and content words are semantically disambiguated. The Extended Wordnet is an ongoing project. ',
	     '0 ',
	     '0 ',
	     '2 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'Augmented Wordnet'
	     ],
	     ' Lexical DB ',
	     ' Stanford University ',
	     ' The resource is the result of the application of a learning algorithm for inducing semantic taxonomies from parsed text. The algorithm automatically acquires items of world knowledge, and uses these to produce significantly enhanced versions of WordNet (up to 40,000 synsets more). ',
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Verbnet'
	     ],
	     ' Lexical DB ',
	     ' University of Colorado Boulder ',
	     ' Lexicon for English verbs organized into classes extending Levin (1993) classes through refinement and addition of subclasses to achieve syntactic and semantic coherence among members of a class ',
	     '2 ',
	     '2 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'VerbOcean'
	     ],
	     ' Lexical DB ',
	     ' Information Sciences Institute, University of Southern California ',
	     ' Broad-coverage semantic network of verbs ',
	     '2 ',
	     '3 ',
	     '6 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'FrameNet'
	     ],
	     ' Lexical DB ',
	     ' ICSI (International Computer Science Institute) - Berkley University ',
	     ' Lexical resource for English words, based on frame semantics (valences) and supported by corpus evidence ',
	     '1 ',
	     '1 ',
	     '2 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'NomBank'
	     ],
	     ' Lexical DB ',
	     ' New York University ',
	     ' Lexical resource containing syntactic frames for nouns, extracted from annotated corpora ',
	     '2 ',
	     '1 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'PropBank'
	     ],
	     ' Lexical DB ',
	     ' University of Colorado Boulder ',
	     ' Lexical resource containing syntactic frames for verbs, extracted from annotated corpora ',
	     '2 ',
	     '1 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'Nomlex'
	     ],
	     ' Lexical DB ',
	     ' New York University ',
	     ' Dictionary of English nominalizations: it describes the allowed complements for a nominalization and relates the nominal complements to the arguments of the corresponding verb ',
	     '0 ',
	     '1 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Dekang Lin’s Thesaurus'
	     ],
	     ' Thesaurus ',
	     ' University of Alberta ',
	     ' Thesaurus automatically constructed using a parsed corpus, based on distributional similarity scores ',
	     '0 ',
	     '1 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Grady Ward\'s Moby Thesaurus'
	     ],
	     ' Thesaurus ',
	     ' University of Sheffield ',
	     ' Thesaurus containing 30,260 root words, with 2,520,264 synonyms and related terms. Grady Ward placed this thesaurus in the public domain in 1996. ',
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'Roget\'s Thesaurus'
	     ],
	     ' Thesaurus ',
	     ' Peter Mark Roget (Electronic version distributed by University of Chicago) ',
	     [
	      'version 1.02'
	     ],
	     '1 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Wikipedia'
	     ],
	     ' Encyclopedia ',
	     ' Free encyclopedia. Used for extraction of lexical-semantic rules (from its more structured parts), named entity recognition, geographical information etc. ',
	     '0 ',
	     '3 ',
	     '6 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Umbel'
	     ],
	     ' Ontology ',
	     ' Structured Dynamics LLC, Coralville, IA ',
	     ' UMBEL stands for Upper Mapping and Binding Exchange Layer and is a lightweight ontology structure for relating Web content and data to a standard set of subject concepts ',
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'YAGO'
	     ],
	     ' Ontology ',
	     ' Max-Planck Institute for Informatics, Saarbrücken, Germany ',
	     ' Light-weight and extensible ontology. It contains more than 2 million entities and 20 million facts about these entities. The facts have been automatically extracted from Wikipedia and unified with WordNet. ',
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'DBpedia'
	     ],
	     ' Ontology ',
	     ' Open community project ',
	     ' DBpedia is a community effort to extract structured information from Wikipedia and to make this information available on the Web. The DBpedia knowledge base currently describes more than 2.9 million things in 91 different languages and consists of 479 million pieces of information. ',
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'DIRT Paraphrase Collection'
	     ],
	     ' Collection of paraphrases ',
	     ' University of Alberta ',
	     ' DIRT (Discovery of Inference Rules from Text) is both an algorithm and a resulting knowledge collection. The DIRT knowledge collection is the output of the DIRT algorithm over a 1GB set of newspaper text. ',
	     '2 ',
	     '4 ',
	     '3 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'TEASE'
	     ],
	     ' Collection of Entailment Rules ',
	     ' Bar-Ilan University ',
	     ' Output of the TEASE algorithm ',
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'BADC Acronym and Abbreviation List'
	     ],
	     ' Word List ',
	     ' BADC (British Atmospheric Data Centre) ',
	     ' Acronym and Abbreviation List ',
	     '0 ',
	     '1 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Acronym Guide'
	     ],
	     ' Word List ',
	     ' Acronym-Guide.com ',
	     ' Acronym and Abbreviation Lists for English, branched in thematic directories ',
	     '1 ',
	     '1 ',
	     '3 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'Web1T 5-grams'
	     ],
	     ' Word list ',
	     ' Linguistic Data Consortium, University of Pennsylvania; Google Inc. ',
	     ' Data set containing English word n-grams and their observed frequency counts. The n-gram counts were generated from approximately 1 trillion word tokens of text from publicly accessible Web pages ',
	     '0 ',
	     '1 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Normalized Google Distance (RTE3&RTE4)'
	     ],
	     ' Word Pair Co-occurrence ',
	     ' Saarland University ',
	     [
	      'Yahoo!'
	     ],
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Normalized Google Distance (RTE5)'
	     ],
	     ' Word Pair Co-occurrence ',
	     ' Saarland University ',
	     [
	      'Yahoo!'
	     ],
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'GNIS - Geographic Names Information System'
	     ],
	     ' Gazetteer ',
	     ' USGS (United States Geological Survey) ',
	     ' Database containing the Federal and national standard toponyms for USA, associated areas and Antarctica ',
	     '0 ',
	     '1 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Geonames'
	     ],
	     ' Gazetteer ',
	     ' Database containing eight million geographical names. It is integrating geographical data such as names of places in various languages, elevation, population and others from various sources. ',
	     '0 ',
	     '1 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Sekine\'s Paraphrase Database'
	     ],
	     ' Collection of paraphrases ',
	     ' Department of Computer Science, New York University ',
	     ' Data-base created using Sekine\'s method, NOT cleaned up by human. It includes 19,975 sets of paraphrases with 191,572 phrases. ',
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'Microsoft Research Paraphrase Corpus'
	     ],
	     ' Collection of paraphrases ',
	     ' Microsoft Research ',
	     ' Text file containing 5800 pairs of sentences which have been extracted from news sources on the web, along with human annotations indicating whether each pair captures a paraphrase/semantic equivalence relationship. ',
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'Downward entailing operators'
	     ],
	     ' Collection of entailing operators ',
	     ' Department of Computer Science, Cornell University, Ithaca NY ',
	     ' System output of an unsupervised algorithm recovering many Downward Entailing operators, like \'doubt\'. ',
	     '0 ',
	     '0 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'WikiRules!'
	     ],
	     ' Lexical Reference rule-base ',
	     ' Bar-Ilan University ',
	     ' Extraction of about 8 million lexical reference rules from the text body (first sentence) and from metadata (links, redirects, parentheses) of Wikipedia. Provides better performance than other automatically constructed resources and comparable performance to WordNet. Offers complementary knowledge to WordNet. ',
	     '0 ',
	     '1 ',
	     '1 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'DART'
	     ],
	     ' Collection of "world knowledge" propositions ',
	     ' Boeing Research and Technology ',
	     ' 23 million tuples such as "airplanes can fly to airports", "rivers can flood" collected from abstracted parse trees. ',
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'FRED'
	     ],
	     ' FrameNet-derived entailment rule-base ',
	     ' Bar-Ilan University ',
	     ' This package contains the outputs of the FRED algorithm, an algorithm which extracts entailment rules from FrameNet. ',
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'DIRECT'
	     ],
	     ' Directional Distributional Term-Similarity Resource ',
	     ' Bar-Ilan University ',
	     ' This is a resource of directional distributional term-similarity rules (mostly lexical entailment rules) automatically extracted using the inclusion relation as described in (Kotlerman et.al., ACL-09). ',
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ]
	   ],
	   [
	    [
	     [
	      'binaryDIRT'
	     ],
	     ' Entailment rules between binary templates using DIRT algorithm ',
	     ' Bar-Ilan University ',
	     [
	      'the DIRT algorithm of Lin and Pantel. '
	     ],
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users'
	     ]
	    ],
	    [
	     [
	      'unaryBInc'
	     ],
	     ' Entailment rules between unary templates using BInc algorithm ',
	     ' Bar-Ilan University ',
	     [
	      'the BInc algorithm of Szpektor and Dagan (2008). '
	     ],
	     '0 ',
	     '0 ',
	     '0 ',
	     [
	      'Users',
	      []
	     ]
	    ],
	    [
	     [
	      'New resource'
	     ],
	     [
	      'Participants are encouraged to contribute'
	     ],
	     [
	      'Users'
	     ]
	    ]
	   ]
	  ];
}
