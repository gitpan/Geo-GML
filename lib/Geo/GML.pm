# Copyrights 2008 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.04.
use warnings;
use strict;

package Geo::GML;
use vars '$VERSION';
$VERSION = '0.10';


use Geo::GML::Util qw/:protocols/;

use Log::Report 'geo-gml', syntax => 'SHORT';
use XML::Compile::Cache ();
use XML::Compile::Util  qw/unpack_type pack_type/;

# map namespace always to the newest implementation of the protocol
my %ns2version =
  ( &NS_GML    => '3.1.1'
  , &NS_GML_32 => '3.2.1'
  );

# list all available versions
my %version2pkg =
  ( '2.0.0'   => 'Geo::GML::2_0_0'
  , '2.1.1'   => 'Geo::GML::2_1_1'
  , '2.1.2'   => 'Geo::GML::2_1_2'
  , '2.1.2.0' => 'Geo::GML::2_1_2_0'
  , '2.1.2.1' => 'Geo::GML::2_1_2_1'
  , '3.0.0'   => 'Geo::GML::3_0_0'
  , '3.0.1'   => 'Geo::GML::3_0_1'
  , '3.1.0'   => 'Geo::GML::3_1_0'
  , '3.1.1'   => 'Geo::GML::3_1_1'
  , '3.2.1'   => 'Geo::GML::3_2_1'
  );

# This list must be extended, but I do not know what people need.
my @declare_always =
    qw/gml:TopoSurface/;


sub new(@)
{   my $class = shift;
    return +(bless {}, $class)->init( {direction => @_} )->declare
        if $class ne __PACKAGE__;

    my ($direction, %args) = @_;

    # having a default here cannot be maintained over the years.
    my $version = delete $args{version}
        or error __x"a GML object needs to have an explicit version\n";

    $version    = $ns2version{$version} || $version;

    my $pkg     = $version2pkg{$version}
        or error __x"no GML implementation for version '{version}'"
             , version => $version;

    eval "require $pkg";
    $@ and die $@;

    $pkg->new($direction, %args);
}

sub init($)
{   my ($self, $args) = @_;
    $self->{GG_dir}     = $args->{direction} or panic "no direction";
    $self->{GG_version} = $args->{version}   or panic "no version";

    my $undecl
      = exists $args->{allow_undeclared} ? $args->{allow_undeclared} : 1;

    $self->{GG_schemas} = $args->{schemas}
     || XML::Compile::Cache->new
         ( prefixes         => $args->{prefixes}
         , allow_undeclared => $undecl
         );
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
