#!/usr/bin/perl
use warnings;
use strict;

use lib 'lib';
use Test::More tests => 3;

#use Log::Report mode => 3;
use Geo::GML::3_1_0;
use Geo::GML::Util    ':gml310';

my $gml = Geo::GML::3_1_0->new('RW');
isa_ok($gml, 'Geo::GML::3_1_0');

use XML::Compile::Util qw/pack_type/;
my $type = pack_type NS_GML_310, 'RectifiedGridCoverage';

my $text = $gml->template(PERL => $type); 
ok(defined $text, 'template generated');
cmp_ok(length $text, '>', 100);

#warn $text;
#$gml->printIndex(\*STDERR);
