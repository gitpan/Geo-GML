# Copyrights 2008-2009 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.05.
use warnings;
use strict;

# extends the implementation of Geo::GML, autoloaded
package Geo::GML;
use vars '$VERSION';
$VERSION = '0.13';


use Log::Report 'geo-gml', syntax => 'SHORT';
use Geo::Point         ();


#---------------------------------


sub GPtoGML($@)
{   my ($self, $object, %args) = @_;

    UNIVERSAL::isa($object, 'Geo::Shape')
        or error __x"GPtoGML requires Geo::Shape objects, not `{got}'"
             , got => (ref $object || $object);

    my $srs = $args{srs} || $object->proj || 'EPGS:4326';

    my $data;
    if($self->version lt 3)
    {   local $args{_srsName} = $srs;
        $data
        = $object->isa('Geo::Surface') ? $self->_gml2_surface($object, \%args)
        : $object->isa('Geo::Line')    ? $self->_gml2_line($object, \%args)
        : $object->isa('Geo::Point')   ? $self->_gml2_point($object, \%args)
        : $object->isa('Geo::Shape')   ? $self->_gml2_shape($object, \%args)
        : panic("GPtoGML does not understand {type} yet", type => ref $object);

    }
    else
    {   $data
        = $object->isa('Geo::Surface') ? $self->_gml3_surface($object, \%args)
        : $object->isa('Geo::Line')    ? $self->_gml3_line($object, \%args)
        : $object->isa('Geo::Point')   ? $self->_gml3_point($object, \%args)
        : $object->isa('Geo::Shape')   ? $self->_gml3_shape($object, \%args)
        : panic("GPtoGML does not understand {type} yet", type => ref $object);

        my ($k, $v) = %$data;   # always only one element
        $v->{srsName} = $srs;
    }

#warn Dumper $data;
    $data;
}

#
## GML2
#

sub _gml2_surface($$)
{   my ($self, $surface, $args) = @_;

    my @members;
    foreach my $c ($surface->components)
    {   my $outer = $self->_gml2_line($c->outer, $args);
        my @inner = map { $self->_gml2_line($_, $args) } $c->inner;
        my %poly  = ( gml_outerBoundaryIs => $outer
                    , gml_innerBoundaryIs => \@inner);
        push @members, +{ gml_polygonMember => {gml_Polygon => \%poly} };
    }

   +{ gml_MultiPolygon =>
      { seq_gml_polygonMember => \@members
      , srsName => $args->{_srsName}
      }
    };
}

sub _gml2_line($$)
{   my ($self, $line, $args) = @_;
    defined $line or return;

    my ($cs, $ts) = (',', ' ');
    my $coords = join $ts, map {$_->[0].$cs.$_->[1] } $line->points;

   +{ gml_LinearRing =>
      { gml_coordinates =>
         { _ => $coords
         , ts => $ts
         , cs => $cs
         }
      , srsName => $args->{_srsName}
      }
    };
}

sub _gml2_point($$)
{   my ($self, $point, $args) = @_;

   +{ gml_Point =>
      { gml_coord => { gml_X => $point->x, gml_Y => $point->y }
      , srsName => $args->{_srsName}
      }
    };
}

sub _gml2_shape($$)
{   my ($self, $shape, $args) = @_;
    panic "GML2 shape not implemented yet";
}

#
## GML3
#

sub _gml3_surface($$)
{   my ($self, $surface, $args) = @_;
    my @members;

    foreach my $c ($surface->components)
    {   my $outer = $self->_gml3_line($c->outer, $args);
        my @inner = map { $self->_gml3_line($_, $args) } $c->inner;
        my %poly  = (gml_exterior => $outer, gml_interior => \@inner);
        push @members, +{ gml_Polygon => \%poly };
    }

    my $surftype =
       $self->version lt '3.2' ? 'gml__Surface' : 'seq_gml_AbstractSurface';

   +{ gml_MultiSurface =>
      { gml_surfaceMembers =>
        { $surftype => \@members }
      }
    };
}

sub _gml3_line($$)
{   my ($self, $line, $args) = @_;
    $line or return;

    my @points = $line->points;
    my @coords = $line->proj4->isLatlong
       ? (map { ($_->[1], $_->[0]) } @points)
       : (map { ($_->[0], $_->[1]) } @points);

   +{ gml_LinearRing =>
      { gml_posList => { _ => \@coords, count => scalar(@points) } }
    };
}

sub _gml3_point($$)
{   my ($self, $point, $args) = @_;
    $point or return;

   +{ gml_Point =>
      { gml_pos => { _ => [$point->coordsUsualOrder] }
      }
    };
}

sub _gml3_shape($$)
{   my ($self, $shape, $args) = @_;
    panic "Not implemented yet";
}

1;
