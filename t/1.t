use strict;
use Easy::Log qw(:all);
$log->log_file('STDERR');
use Easy::Options qw(:all);
use Test::More;

my @option_tests = (
                    [ [ sod_simple_string     => [  ':s', 'sod'  , 'simple string totally optional -- default value \'sod\''], ],
                      [ [ 1 , [ qw( --sod_simple_string  ), 'sod_simple_string'  ], {qw(getoptargs fool)}, {qw(who knows?)}, {qw(etc etc)}],
                        [ 0 , [ qw( --fsod_simple_string ), 'fsod_simple_string' ], ],
                      ],
                    ],
                    [ [ son_simple_string     => [  ':s', undef  , 'simple string totally optional -- default value \'undef\''], ],
                      [ [ 1, [ qw( --son_simple_string  ), 'son_simple_string'  ], ],
                        [ 0, [ qw( --fson_simple_string ), 'fson_simple_string' ], ],
                      ],
                    ],                    
                    [ [ ood_simple_string      => ['::s', 'ood'         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'ood\''], ],
                      [ [ 1, [ qw( --ood_simple_string  ), 'ood_simple_string'  ], ],
                        [ 0, [ qw( --food_simple_string ), 'food_simple_string' ], ],
                      ],
                    ],
                    [ [ oon_simple_string      => ['::s', undef         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --oon_simple_string  ), 'oon_simple_string'  ], ],
                        [ 0, [ qw( --foon_simple_string ), 'foon_simple_string' ], ],
                      ],
                    ],
                    
                    [ [ ord_simple_string      => [':=s', 'ord'         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'ord\''], ],
                      [ [ 1, [ qw( --ord_simple_string  ), 'ord_simple_string'  ], ],
                        [ 0, [ qw( --ford_simple_string ), 'ford_simple_string' ], ],
                      ],
                    ],
                    [ [ orn_simple_string      => [':=s', undef         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --orn_simple_string  ), 'orn_simple_string'  ], ],
                        [ 0, [ qw( --forn_simple_string ), 'forn_simple_string' ], ],
                      ],
                    ],
                    
                    [ [ rod_simple_string      => ['=:s', 'rod'         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'rod\''], ],
                      [ [ 1, [ qw( --rod_simple_string  ), 'rod_simple_string'  ], ],
                        [ 0, [ qw( --frod_simple_string ), 'frod_simple_string' ], ],
                      ],
                    ],
                    [ [ ron_simple_string      => ['=:s', undef         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --ron_simple_string  ), 'ron_simple_string'  ], ],
                        [ 0, [ qw( --fron_simple_string ), 'fron_simple_string' ], ],
                      ],
                    ],
                    
                    [ [ rrd_simple_string      => ['==s', 'rrd'         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'rrd\''], ],
                      [ [ 1, [ qw( --rrd_simple_string  ), 'rrd_simple_string'  ], ],
                        [ 0, [ qw( --frrd_simple_string ), 'frrd_simple_string' ], ],
                      ],
                    ],
                    [ [ rrn_simple_string      => ['==s', undef         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --rrn_simple_string  ), 'rrn_simple_string'  ], ],
                        [ 0, [ qw( --frrn_simple_string ), 'frrn_simple_string' ], ],
                      ],
                    ],
                    
                    [ [ srd_simple_string      => [ '=s', 'srd'         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'srd\''], ],
                      [ [ 1, [ qw( --srd_simple_string  ), 'srd_simple_string'  ], ],
                        [ 0, [ qw( --fsrd_simple_string ), 'fsrd_simple_string' ], ],
                      ],
                    ],
                    [ [ srn_simple_string      => [ '=s', undef         , 'simple string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --srn_simple_string  ), 'srn_simple_string'  ], ],
                        [ 0, [ qw( --fsrn_simple_string ), 'fsrn_simple_string' ], ],
                      ],
                    ],
                    
                    [ [ sod_array_string     => [  ':s@', 'sod'  , 'array string totally optional -- default value \'sod\''], ],
                      [ [ 1, [ qw( --sod_array_string  ), 'sod_array_string'  ], ],
                        [ 0, [ qw( --fsod_array_string ), 'fsod_array_string' ], ],
                      ],
                    ],
                    [ [ son_array_string     => [  ':s@', undef  , 'array string totally optional -- default value \'undef\''], ],
                      [ [ 1, [ qw( --son_array_string  ), 'son_array_string'  ], ],
                        [ 0, [ qw( --fson_array_string ), 'fson_array_string' ], ],
                      ],
                    ],

                    [ [ ood_array_string      => ['::s@', 'ood'         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'ood\''], ],
                      [ [ 1, [ qw( --ood_array_string  ), 'ood_array_string'  ], ],
                        [ 0, [ qw( --food_array_string ), 'food_array_string' ], ],
                      ],
                    ],
                    [ [ oon_array_string      => ['::s@', undef         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --oon_array_string  ), 'oon_array_string'  ], ],
                        [ 0, [ qw( --foon_array_string ), 'foon_array_string' ], ],
                      ],
                    ],
                    
                    [ [ ord_array_string      => [':=s@', 'ord'         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'ord\''], ],
                      [ [ 1, [ qw( --ord_array_string  ), 'ord_array_string'  ], ],
                        [ 0, [ qw( --ford_array_string ), 'ford_array_string' ], ],
                      ],
                    ],
                    [ [ orn_array_string      => [':=s@', undef         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --orn_array_string  ), 'orn_array_string'  ], ],
                        [ 0, [ qw( --forn_array_string ), 'forn_array_string' ], ],
                      ],
                    ],
                    
                    [ [ rod_array_string      => ['=:s@', 'rod'         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'rod\''], ],
                      [ [ 1, [ qw( --rod_array_string  ), 'rod_array_string'  ], ],
                        [ 0, [ qw( --frod_array_string ), 'frod_array_string' ], ],
                      ],
                    ],
                    [ [ ron_array_string      => ['=:s@', undef         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --ron_array_string  ), 'ron_array_string'  ], ],
                        [ 0, [ qw( --fron_array_string ), 'fron_array_string' ], ],
                      ],
                    ],
                    
                    [ [ rrd_array_string      => ['==s@', 'rrd'         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'rrd\''], ],
                      [ [ 1, [ qw( --rrd_array_string  ), 'rrd_array_string'  ], ],
                        [ 0, [ qw( --frrd_array_string ), 'frrd_array_string' ], ],
                      ],
                    ],
                    [ [ rrn_array_string      => ['==s@', undef         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --rrn_array_string  ), 'rrn_array_string'  ], ],
                        [ 0, [ qw( --frrn_array_string ), 'frrn_array_string' ], ],
                      ],
                    ],
                    
                    [ [ srd_array_string      => [ '=s@', 'srd'         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'srd\''], ],
                      [ [ 1, [ qw( --srd_array_string  ), 'srd_array_string'  ], ],
                        [ 0, [ qw( --fsrd_array_string ), 'fsrd_array_string' ], ],
                      ],
                    ],
                    [ [ srn_array_string      => [ '=s@', undef         , 'array string must have a value, but you don\'t have to provide one on the command line(somewhat stupid case) -- default value \'undef\''], ],
                      [ [ 1, [ qw( --srn_array_string  ), 'srn_array_string'  ], ],
                        [ 0, [ qw( --fsrn_array_string ), 'fsrn_array_string' ], ],
                      ],
                    ],
                   );

my @args = @ARGV;

if ( $ENV{EASY_OPTIONS_RUN_TESTS} ) {
    plan tests => scalar @option_tests;
    foreach my $option_test ( @option_tests ) {
        my %optargs = @{$option_test->[0]};
        $log->write($lll, ' %optargs: ',  \%optargs );
        foreach my $pass_fail_argv ( @{$option_test->[1]} ) {
            $log->write($lll, '$pass_fail_argv: ', $pass_fail_argv );
            my $pass_fail = $pass_fail_argv->[0];
            local @ARGV = @{$pass_fail_argv->[1]};
            my %options = Easy::Options->easy_options( %optargs );
            $log->write($lll, '%options: ', \%options );
        }
    }
}
else {
    plan tests => 1;
    ok(1);
}

__END__
# in the following case, Easy::Options should alert the
# user if the option is required by the program, but no
# default value is needed on the command line, and
# there is not a default value provided

