use strict;
use warnings;
use utf8;

use Encode;
use Test::Deep;
use Test::More;
use Text::CSV::Easy_PP qw(csv_parse);

cmp_deeply( [ csv_parse(q{}) ], [], 'empty' );
cmp_deeply(
    [ csv_parse(q{,,1,}) ],
    [ undef, undef, 1, undef ],
    'support for undef values'
);

cmp_deeply( [ csv_parse(q{1,2,3}) ], [ 1, 2, 3 ], 'simple integers' );

eval { csv_parse(q{one}) };
like( $@, qr/invalid line: one/, 'correct exception for unquoted string' );

eval { csv_parse(q{1one}) };
like( $@, qr/invalid line: 1one/, 'exception for string in numeric field' );

cmp_deeply( [ csv_parse(q{"one","two","three"}) ],
    [qw( one two three )], 'quoted strings' );

eval { csv_parse(q{"one","two,}) };
like( $@, qr/invalid line: "one","two,/, 'exception for unterminated string' );

cmp_deeply(
    [ csv_parse(q{"one","two ""2""","three"}) ],
    [ 'one', 'two "2"', 'three' ],
    'complex quoted strings'
);

cmp_deeply(
    [ csv_parse(qq{1,"two ""2""","three\nfour"}) ],
    [ 1, 'two "2"', "three\nfour" ],
    'complex line'
);

cmp_deeply(
    [ csv_parse(qq{"",,"",}) ],
    [ '', undef, '', undef ],
    'undef and empty values'
);

eval { csv_parse(q{"one","two"3}) };
like( $@, qr/invalid line: "one","two"3/, 'exception for invalid string' );

subtest 'UTF-8 Support' => sub {
    my ($str) = csv_parse(qq{"not utf-8"});
    ok( !Encode::is_utf8($str), 'simple string is not utf-8' );

    ($str) = csv_parse(qq{"not ""utf-8"""});
    ok( !Encode::is_utf8($str),
        'simple string with escape quote is not utf-8' );

    ($str) = csv_parse(qq{"✓"});
    ok( Encode::is_utf8($str), encode_utf8('✓ is utf-8') );

    ($str) = csv_parse(qq{"""✓"""});
    ok( Encode::is_utf8($str), encode_utf8('✓ with escape quote is utf-8') );

    cmp_deeply( [ csv_parse(qq{"✓"}) ], ["✓"], 'UTF-8 support' );
};

done_testing();
