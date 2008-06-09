# Copyrights 2008 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.04.
use warnings;
use strict;

package Geo::GML::3_2_1;
use vars '$VERSION';
$VERSION = '0.10';

use base 'Geo::GML';

use Geo::GML::Util qw/:gml321/;
use Log::Report 'geo-gml', syntax => 'SHORT';

my $xsd = __FILE__;
$xsd    =~ s!/[0-9_]+\.pm$!/xsd!;
my @xsd = (glob("$xsd/gml3.2.1/*.xsd"), glob("$xsd/xlink1.0.0/*.xsd"));


sub init($)
{   my ($self, $args) = @_;
    $args->{version} ||= '3.2.1';
    my $pref = $args->{prefixes} ||= {};
    $pref->{gml}   ||= NS_GML_321;
    $pref->{gmd}   ||= NS_GMD_2005;
    $pref->{smil}  ||= NS_SMIL_20;
    $pref->{xlink} ||= NS_XLINK_1999;

    $self->SUPER::init($args);
    $self->schemas->importDefinitions(\@xsd);
    $self;
}

1;
