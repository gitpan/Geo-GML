# Copyrights 2008 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.04.
use warnings;
use strict;

package Geo::GML;
use vars '$VERSION';
$VERSION = '0.11';


use Geo::GML::Util;

use Log::Report 'geo-gml', syntax => 'SHORT';
use XML::Compile::Cache ();
use XML::Compile::Util  qw/unpack_type pack_type/;

# map namespace always to the newest implementation of the protocol
my %ns2version =
  ( &NS_GML    => '3.1.1'
  , &NS_GML_32 => '3.2.1'
  );

# list all available versions
my %info =
  ( '2.0.0'   => { prefixes => {gml => NS_GML_200}
                 , schemas  => [ 'gml2.0.0/*.xsd' ] }
  , '2.1.1'   => { prefixes => {gml => NS_GML_211}
                 , schemas  => [ 'gml2.1.1/*.xsd' ] }
  , '2.1.2'   => { prefixes => {gml => NS_GML_212}
                 , schemas  => [ 'gml2.1.2/*.xsd' ] }
  , '2.1.2.0' => { prefixes => {gml => NS_GML_2120}
                 , schemas  => [ 'gml2.1.2.0/*.xsd' ] }
  , '2.1.2.1' => { prefixes => {gml => NS_GML_2121}
                 , schemas  => [ 'gml2.1.2.1/*.xsd' ] }
  , '3.0.0'   => { prefixes => {gml => NS_GML_300, smil => NS_SMIL_20}
                 , schemas  => [ 'gml3.0.0/*/*.xsd' ] }
  , '3.0.1'   => { prefixes => {gml => NS_GML_301, smil => NS_SMIL_20}
                 , schemas  => [ 'gml3.0.1/*/*.xsd' ] }
  , '3.1.0'   => { prefixes => {gml => NS_GML_310, smil => NS_SMIL_20}
                 , schemas  => [ 'gml3.1.0/*/*.xsd' ] }
  , '3.1.1'   => { prefixes => {gml => NS_GML_311, smil => NS_SMIL_20
                               ,gmlsf => NS_GML_311_SF}
                 , schemas  => [ 'gml3.1.1/{base,smil,xlink}/*.xsd'
                               , 'gml3.1.1/profile/*/*/*.xsd' ] }
  , '3.2.1'   => { prefixes => {gml => NS_GML_321, smil => NS_SMIL_20 }
                 , schemas  => [ 'gml3.2.1/*.xsd' ] }
  );

# This list must be extended, but I do not know what people need.
my @declare_always =
    qw/gml:TopoSurface/;


sub new($@)
{   my ($class, $dir) = (shift, shift);
    (bless {}, $class)->init( {direction => $dir, @_} );
}

sub init($)
{   my ($self, $args) = @_;
    $self->{GG_dir} = $args->{direction} or panic "no direction";

    my $version     =  $args->{version}
        or error __x"GML object requires an explicit version";

    unless(exists $info{$version})
    {   exists $ns2version{$version}
            or error __x"GML version {v} not recognized", v => $version;
        $version = $ns2version{$version};
    }
    $self->{GG_version} = $version;    
    my $info    = $info{$version};

    my %prefs   = %{$info->{prefixes}};
    my @xsds    = @{$info->{schemas}};

    # all known schemas need xlink
    $prefs{xlink} = NS_XLINK_1999;
    push @xsds, 'xlink1.0.0/*.xsd';

    my $undecl
      = exists $args->{allow_undeclared} ? $args->{allow_undeclared} : 1;

    my $schemas = $self->{GG_schemas} = $args->{schemas}
     || XML::Compile::Cache->new
         ( prefixes         => \%prefs
         , allow_undeclared => $undecl
         );

    (my $xsd = __FILE__) =~ s!\.pm!/xsd!;
    $schemas->importDefinitions( [map {glob "$xsd/$_"} @xsds] );
    $self;
}

sub declare(@)
{   my $self = shift;

    my $schemas   = $self->schemas;
    my $direction = $self->direction;

    $schemas->declare($direction, $_)
        for @_, @declare_always;

    $self;
}

#---------------------------------


sub schemas()   {shift->{GG_schemas}}
sub version()   {shift->{GG_version}}
sub direction() {shift->{GG_dir}}

#---------------------------------


sub template($$@)
{   my ($self, $format, $type) = (shift, shift, shift);
    $self->schemas->template($format, $type, @_);
}


sub printIndex(@)
{   my $self = shift;
    my $fh   = @_ % 2 ? shift : select;
    $self->schemas->printIndex($fh
      , kinds => 'element', list_abstract => 0, @_); 
}

1;
