# Copyrights 2008 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.04.
use warnings;
use strict;

package Geo::GML::2_1_2_0;
use vars '$VERSION';
$VERSION = '0.10';

use base 'Geo::GML';

use Geo::GML::Util qw/:gml2120/;
use Log::Report 'geo-gml', syntax => 'SHORT';

my $xsd = __FILE__;
$xsd    =~ s!/[0-9_]+\.pm$!/xsd!;
my @xsd = ( glob("$xsd/gml2.1.2.0/*.xsd")
          , glob("$xsd/xlink1.0.0/*.xsd")
          );


sub init($)
{   my ($self, $args) = @_;
    $args->{version} ||= '2.1.2.0';
    my $pref = $args->{prefixes} ||= {};
    $pref->{gml}   ||= NS_GML_2120;
    $pref->{xlink} ||= NS_XLINK_1999;

    $self->SUPER::init($args);
    $self->schemas->importDefinitions(\@xsd);
    $self;
}

1;
