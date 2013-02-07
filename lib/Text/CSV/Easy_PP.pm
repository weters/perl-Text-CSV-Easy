package Text::CSV::Easy_PP;
use 5.010;
use strict;
use warnings FATAL => 'all';

use Carp;
use Exporter qw(import);

our @EXPORT_OK = qw(csv_build csv_parse);

=head1 NAME

Text::CSV::Easy_PP - Easy CSV parsing and building implemented in Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Text::CSV::Easy_PP qw(csv_build csv_parse);

  my @fields = csv_parse($string);
  my $string = csv_build(@fields);

=head1 DESCRIPTION

Text::CSV::Easy_PP is a simple module for parsing and building simple CSV fields.

Integers do not need to be quoted, but strings must be quoted:

    1,"two","three"     OK
    "1","two","three"   OK
    1,two,three         NOT OK

If you need to use a literal quote ("), escape it with another quote:

    "one","some ""quoted"" string"

=head1 SUBROUTINES

=head2 csv_build( List @fields ) : Str

Takes a list of fields and will generate a csv string. This subroutine will raise an exception if any errors occur.

=cut

sub csv_build {
    my @fields = @_;
    return join ',', map {
        if (/^\d+$/) {
            $_
        }
        else {
            (my $str = $_) =~ s/"/""/g;
            qq{"$str"}
        }
    } @fields;
}

=head2 csv_parse( Str $string ) : List[Str]

Parses a CSV string. Returns a list of fields it found. This subroutine will raise an exception if a string could not be properly parsed.

=cut

sub csv_parse {
    my ( $str ) = @_;

    return () unless $str;

    my $last_pos = 0;

    my @fields;
    while ( $str =~ / (?:^|,) (?: "(.*?)"(?=,|$) | (\d*)(?=,|$) ) /xsg ) {
        my $field = ($1 || $2) || undef; 

        croak( "invalid line: $str" ) if pos($str) > $last_pos + length($&) + ( $last_pos != 0 ? 1 : 0 );
        $last_pos = pos($str);

        if ($field) {
            if ( $field =~ /(?<!")"(?!")/ ) {
                croak( "quote is not properly escaped" );
            }

            $field =~ s/""/"/g;
        }
        push @fields, $field;
    }

    croak( "invalid line: $str" ) if $last_pos != length($str);

    return @fields;
}

1;

=head1 SEE ALSO

=over 4

=item L<Text::CSV>

=item L<Text::CSV::Easy_XS>

=back

=head1 AUTHOR

Thomas Peters, E<lt>weters@me.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Thomas Peters

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
