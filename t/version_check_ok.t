#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Test::More;

SKIP: {
    my $xs_ok = eval { require Text::CSV::Easy_XS };
    skip "Install Text::CSV::Easy_XS to test", 1 unless $xs_ok;

    {
        no warnings 'once';
        $Text::CSV::Easy_XS::TCE_VERSION = 2;
    }

    require Text::CSV::Easy;

    is( Text::CSV::Easy::module(), 'Text::CSV::Easy_XS',
        'XS module used when TCE_VERSIONs match' );
}

done_testing();
