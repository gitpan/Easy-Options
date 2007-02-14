package Easy::Options;
use strict;

use Easy::Log qw(:all);

use Getopt::Long;

use Exporter;
our ( %EXPORT_TAGS, @ISA, @EXPORT_OK, @EXPORT, $VERSION );
@ISA = qw( Exporter );

$VERSION = '0.01_00';

%EXPORT_TAGS = (
                usage           => [ qw( easy_options get_options optargs_missing usage) ],
               );

$EXPORT_TAGS{all}        = [ map {@{$_}} values %EXPORT_TAGS ];
@EXPORT_OK = @{$EXPORT_TAGS{'all'}};
@EXPORT = ();

use File::Spec;
my @pathinfo = (File::Spec->splitpath( File::Spec->rel2abs( $0 )));
$log->write({prefix=>undef},$sll, '@pathinfo: ', \@pathinfo );


sub get_options {
    # this sub is for backwards compatibility with the version of this routine that formerly lived in Log::Easy (which is now re-named Easy::Log)
    my $optargs_orig = shift;
    my $optargs = { %$optargs_orig };
    my $getoptconfig = ref $_[0] eq 'HASH' ? (shift) : {};
    my $easyconfig   = ref $_[0] eq 'HASH' ? (shift) : {};
    
    return easy_options( %$easyconfig,
                         optargs      => $optargs,
                         getoptconfig => $getoptconfig,
                         easyconfig   => $easyconfig,
                       );
}

sub easy_options {
    my ( $self, %args ) = @_;
    $log->write($dll, '%args: ', \%args );
    $log->write($all, '@ARGV: ', \@ARGV );
    my %options;
    
    my $optargs_orig = $args{optargs} || \%args;
    $log->write($dll, '$optargs_orig: ', $optargs_orig );
    my $optargs = $log->clone( $optargs_orig ); # a deep copy of the original arguments to avoid messing with them if we need to refer back to the original values
    $log->write($dll, '$optargs: ', $optargs );
    
    #    $options{options_meta}{canonical_opts} = [ map { $_ =~ /^([^|]+)/ ?   $1     : ( die "problem with canonical option list: $_" ); } sort keys %$optargs ];
    #    $log->write($all, '$options{options_meta}{canonical_opts}: ', $options{options_meta}{canonical_opts} );
    $options{options_meta}{canonical_opts} = [ map { $_ =~ /^([^|]+)/ ? {($1, $_)} : ( die "problem with canonical option list: $_" ); } sort keys %$optargs ] ;
    $log->write($all, '$options{options_meta}{canonical_opts}: ', $options{options_meta}{canonical_opts} );
    
    $options{options_meta}{match_string} = join('|', keys %{$options{options_meta}{canonical_opts}} );
    #$options{options_meta}{match_string} = join('|', keys %$optargs);
    $options{options_meta}{match_string} =~ s/\|.\|/\|/g;
    $options{options_meta}{match_string} =~ s/\|+/\|/g;
    $log->write($all, '$options{options_meta}{match_string}: ', $options{options_meta}{match_string} );
    
    
    $options{options_meta}{match_regex}  = qr/$options{options_meta}{match_string}/i;
    $log->write($dl4, '$options{options_meta}{match_regex}: ', $options{options_meta}{match_regex} );
    
    my $getoptconfig = $args{getoptconfig}; # settings affecting Getopt::Long
    
    my $target  = $args{target}  || \%options;
    my $default = $args{default} || $target;
    my $easyconfig = $args{easyconfig} || $optargs_orig;
    
    # give some easy usage/help options
    if ( not $args{nohelp} or exists $args{help} and $args{help} ) {
        $optargs->{help}  ||= $optargs->{usage} ||= [''   , sub { usage( $optargs, \%options, $getoptconfig, $easyconfig ) }, 'print help message and exit'];
        $optargs->{usage} ||= $optargs->{help}  ||= [''   , sub { usage( $optargs, \%options, $getoptconfig, $easyconfig ) }, 'print help message and exit'];
    }
    my $no_usage    = $easyconfig->{no_usage}   || scalar (grep { /no_usage/   } @_) ? 1 : 0;
    $log->write($sll, '$no_usage: ', $no_usage );
    my $no_missing  = $easyconfig->{no_missing} || scalar (grep { /no_missing/ } @_) ? 1 : 0;
    $log->write($sll, '$no_missing: ', $no_missing );
    my $p = new Getopt::Long::Parser config => [ map { ($getoptconfig->{$_} ? $_ : ($_ =~ /^no_/ ? $_ : "no_$_")); } keys %$getoptconfig ];
    my %GetOptions = map {  my $optname = $_;
                            $log->write($dll, '$optname: ', $optname );
                            my $progopt = $optargs->{$_}[0];
                            $log->write($dll, '$progopt: ', $progopt );
                            my $argspec = '';
                            my $optspec  = '';
                            my $type;
                            if ( $progopt =~ /^([:=]+)([ifs][@%]?)$/ ) {
                                my $spec = $1;
                                $type     = $2;
                                $argspec = substr($spec, 0 , 1);
                                $optspec  = substr($spec, 1 , 1) || $argspec;
                                $argspec .= $type;
                                $optspec  .= $type;
                            } else {
                                $argspec = $progopt;
                                $optspec  = $progopt;
                            }
                            #("$_$optargs->{$_}[0]" => ref $optargs->{$_}[1] ? $optargs->{$_}[1] : \$optargs->{$_}[1])
                            $log->write($dll, '$optspec: ', $optspec );
                            $log->write($dll, '$argspec: ', $argspec );
                            my @opt = ( "$optname$optspec" => ref $optargs->{$_}[1] ? $optargs->{$_}[1] : \$optargs->{$_}[1] );
                            $log->write($dll, '@opt: ', \@opt );
                            @opt;
                        } keys %$optargs;
    
    $log->write($dll, '%GetOptions: ', \%GetOptions);
    #local $SIG{__WARN__} = sub { &failed_options(@_) };# may want to add some additional arguments to pass to failed_options
    $log->write($dll, '@ARGV: ', \@ARGV );
    my $opt = $p->getoptions( %GetOptions );
    $log->write($dll, '%GetOptions: ', \%GetOptions);
    $log->write($dll, '@ARGV: ', \@ARGV );
    $log->write($dll, '$opt: ', $opt );
    $log->write($dl7, '$optargs: ', $optargs );
    $log->write($dl7, '$opt: ', $opt);
    # check that all required options have been provided
    my @missing = $no_missing ? () : optargs_missing( $optargs );
    $log->write($sll, "\@missing: ($no_missing)", \@missing );
    #return () if (scalar @missing and $no_usage);
    
    foreach my $key ( keys %$optargs ) {
        $log->write($dll, '$key: ', $key );
        my $value = defined $optargs->{$key}[1] ? $optargs->{$key}[1] : $default->{$key};
        $log->write($dll, '$value: ', $value );
        my @aliases = ();# = ( $key );
        if ( $key =~ /\|/ ) {
            push  @aliases, split /\|/, $key;
        } else {
            push  @aliases, $key;
        }
        $log->write($dll, '@aliases: ', \@aliases );
        foreach my $alias ( @aliases ) {
            if (  ref $value eq 'SCALAR' ) {
                $options{$alias} = $$value;
            } elsif ( ref $value eq 'CODE' ) {
                #$options{$alias} = $value;
            } elsif ( ref $value eq 'ARRAY' ) {
                my $final_value = [];
                foreach my $item ( @$value ) {
                    if ( ref $item eq 'ARRAY' ) {
                        push @$final_value, @$item;
                    }
                    else {
                        push @$final_value, $item;
                    }
                }
                $options{$alias} = $final_value;
            } else {
                $options{$alias} = $value;
            }
            $target->{$alias} = $options{$alias};
        }
    }
    
    # when this routine is separated into its own package (Getargs::Long ???), the %options should
    # probably be a tied hash with a canonical set of key names and a 'hidden' set of aliases as
    # specified by the $key of %optargs (eg my %o = ( 'foo|bar|baz' => [ '!', undef, 'some flag'] );
    # would have a canonical name 'foo' (returned by keys %o) and aliases 'bar' and 'baz'
    
    if ( $options{help} ) {
        usage( $optargs, \%options, undef, undef, { brief_info => ' [OPTIONS] ["SQL STRING"|"SQL_FILENAME" [ ...] ] '} );
    }
    
    return usage( $optargs, \%options, $getoptconfig, $easyconfig ) if (scalar @missing and not $no_usage);
    $log->write($dl7, '%options: ', \%options);
    $log->write($lll, '%options: ', \%options);
    return %options;
}

sub failed_options {
    $log->write({EXIT => 1, prefix => ''}, EXIT, @_);
}

sub optargs_missing {
    my $optargs = shift;
    $log->write($dl7, '$optargs: ', $optargs );
    my $options = shift || {};
    $log->write($dl7, '$options: ', $options );
    my @missing;
    my %options;
    my @aliases = ();
    my %aliases = ();
    foreach my $key ( keys %$optargs ) {
        next if $key =~ /^(usage|help)$/;
        $log->write($dl7, '$key: ', $key );
        my @a;
        my $value = $optargs->{$key}[1];
        ref $value eq 'SCALAR' and $value = $$value;
        $log->write($dl7, '$value: ', $value );
        if ( $key =~ /\|/ ) {
            push  @a, split /\|/, $key;
        } else {
            push  @a, $key;
        }
        push  @aliases, @a;
        $aliases{$key} = \@a;
        foreach my $alias ( @a ) {
            $log->write($dl7, '$alias: ', $alias );
            $options{$alias} = defined $options->{$alias} ? $options->{$alias} : $value;
            $log->write($dl7, qq'\$options{$alias}: ', $options{$alias} );
        }
    }
    $log->write($dl7, '%options: ', \%options );
    foreach my $opt (keys %$optargs ) {
        $log->write($dl7, '$opt: ', $opt );
        my $optspec = $optargs->{$opt}[0];
        $log->write($dl7, '$optspec: ', $optspec );
        next if not $optspec;
        my $a     = $aliases{$opt};
        $log->write($dl7, '$a: ', $a );
        my $alias = $a->[0];
        $log->write($dl7, '$alias: ', $alias );
        my $value = $options{$alias};
        $log->write($dl7, '$value: ', $value );
        my $optval = (ref $value eq 'ARRAY' ? join("", @$value) : $value );
        $log->write($dl7, '$optval: ', $optval );
        if ( $optspec =~ /^\=/ ) {
            $log->write(D_SPEW, 'REQUIRED: ', $opt );
            if ( not defined $optval or ($optval ne '0' and not $optval) ) {
                $log->write(D_SPEW, 'REQUIRED AND MISSING: ', $opt );
                push @missing, $opt;
            }
        }
    }
    $log->write($dl7, '%options: ', \%options );
    $log->write($dll, '@missing: ', \@missing );
    return @missing;
}
use Text::Wrap;
$Text::Wrap::columns = 70;
$Text::Wrap::huge = 'overflow';
my %already_decoded;
sub usage {
    # I really need to clean up how this gets its arguments, prubably aught to have the @_ be HASHable { optargs => \%optargs, ... } instead of trying to rely on this ordering crap
    my $optargs_orig = shift;
    my $optargs = { %$optargs_orig };
    $log->write($dll, '$optargs: ', $optargs );
    
    my $options = ref $_[0] eq 'HASH' ? (shift) : {};
    $log->write($dll, '$options: ', $options );
    my $optconfig = ref $_[0] eq 'HASH' ? (shift) : {};
    $log->write($dll, '$optconfig: ', $optconfig );
    my $config    = ref $_[0] eq 'HASH' ? (shift) : {};
    $log->write($dll, '$config: ', $config );
    # give some easy usage/help options
    if ( not $config->{nohelp} or exists $config->{help} and $config->{help} ) {
        $optargs->{help}  ||= $optargs->{usage} ||= [''   , sub { usage( $optargs, $options, $optconfig, $config ) }, 'print help message and exit'];
        $optargs->{usage} ||= $optargs->{help}  ||= [''   , sub { usage( $optargs, $options, $optconfig, $config ) }, 'print help message and exit'];
    }
#    if ( not $config->{nohelp} or exists $config->{help} and $config->{help} ) {
#        $optargs->{help}  ||= $optargs->{usage} ||= [''   , sub { usage( $optargs ) }, 'print help message and exit'];
#        $optargs->{usage} ||= $optargs->{help}  ||= [''   , sub { usage( $optargs ) }, 'print help message and exit'];
#    }
    my $no_missing  = scalar (grep { /no_missing/ } map { defined $_ ? $_ : (); } @_) ? 1 : 0;
    my $usage_args  = ref $_[0] eq 'HASH' ? (shift) : $_[0] ? $_[0] : {};
    $log->write($dll, '$usage_args: ', $usage_args );
    ref $usage_args eq 'HASH' or $usage_args = { $usage_args => (scalar @_ ? @_ : 1 )};
    my %options = $options ? %$options : map { ($_ => $optargs->{$_}[1]) } keys %$optargs;
    $log->write($dll, '$optargs: ', $optargs );
    my @missing = optargs_missing( $optargs, $options );
    $log->write($dll, '@missing: ', \@missing);
    my @required = map { my $a = $optargs->{$_}[0];
                         $a =~ /^\=/ ? $_ : ();
                     } sort { $a cmp $b } keys %$optargs;
    
    my @optional = map { my $a = $optargs->{$_}[0];
                         $a =~ /^\=/ ? () : $_;
                     } sort { $a cmp $b } keys %$optargs;
    
    my $missing = scalar @missing ? "MISSING REQUIRED ARGUMENT(S): ( " . join(', ', map { ($optargs->{$_} ? "--$_" : $_); } sort @missing ) . " ) ... \n" : '';
    my $base_name = $pathinfo[2];
    $log->write($dll, '$base_name: ', $base_name );
    my %type_spec = qw( f FLOAT
                        i INTEGER
                        s STRING
                      );
    my $indent = '     |  ';
    my $sep = ( ' ' x ((length $indent) - 4) ) . ('-' x ( $Text::Wrap::columns - ((length $indent) + 2)));
    $sep = '    ';
    $usage_args->{brief_info} ||= $config->{brief_info} || '';
    $log->write(CLEAN,(#'_' x ($Text::Wrap::columns + 3),
                          "\n",
                          ($config->{usage_message} ? $config->{usage_message} : () ),
                          "\n",
                          $no_missing ? () : ($missing,"\n"),
                          space("usage: $base_name $usage_args->{brief_info}", ), "\n",
                          $sep,#"\n    ",
                          join("\n" . '    ', #(' ' x (length "usage: $base_name")),
                               map {
                                   my $val = ( defined $options{$_}
                                               ? $options{$_}
                                               : $optargs->{$_}[1]
                                             );
                                   ref $val eq 'SCALAR' and $val = $$val;
                                   ref $val eq 'ARRAY'  and $val = join(', ', @$val);
                                   ref $val eq 'HASH'   and $val = join(', ', map { "$_ => $val->{$_}" } keys %$val);
                                   
                                   my $label = $_;
                                   $label =~ /\|/ and $label = '(' . $label . ')';
                                   my $required = $optargs->{$_}[0] =~ /^\=/ ? 1 : 0;
                                   #my $boolean  = $optargs->{$_}[0] =~ /(^$)|(\+)/ ? 1 : 0;
                                   $optargs->{$_}[0] =~ /([fis])/;
                                   my $type     = $1;
                                   my $boolean  = $type ? 0 : 1;
                                   $type = $boolean ? 'BOOLEAN' : $type_spec{$type};
                                   my $desc     = $optargs->{$_}[2] || $_; #'NO DESCRIPTION PROVIDED';
                                   my @desc = split ('\s+', $desc );
                                   my $show_req = ($required ? "REQUIRED($type)" : "OPTIONAL($type)");# . "\n";
                                   my @wrap = wrap( $indent, $indent, @desc);
                                   if( scalar @wrap == 1 ) {
                                       @wrap = split("\n", $wrap[0]);
                                   }
                                   $log->write($dll, '@wrap: ', \@wrap );
                                   $desc = "\n" . join( "\n", map { space($_, $Text::Wrap::columns ) . ' |'; } @wrap ) . "\n" . (' ' x length $indent ) . ('-' x ($Text::Wrap::columns - length $indent)) . $sep;
                                   if ( 'CODE' eq ref $val
                                        and $_ !~ /(usage|help)/
                                        and not $already_decoded{$val}++
                                      ) {
                                       $val = &$val( $_, $options{$_} );
                                   }
                                   if ( defined $val and ( $val or $val eq '0' ) ) {
                                       $val = $boolean ? $val : "'$val'";
                                   }
                                   my $onoff = ($boolean and $val) ? '#ON#' : '#OFF#';
                                   my @opt = ( $required
                                               ? ( space($show_req, 25), '   ', ( '--', space($_, 25),($val ? '   ': '***'), space($val ? ($boolean ? $onoff : $val) : ($boolean ? $onoff : uc "<$_>***"), 15)) , '   ', $desc )
                                               : ( space($show_req, 25), ' [ ', ( '--', space($_, 25),                       space($val ? ($boolean ? $onoff : $val) : ($boolean ? $onoff : uc "<$_>"),    15)) , ' ] ', $desc )
                                             );
                                   join('', @opt);
                               } #( sort
                               ( # sort here to make required options come first, and sort alphabetically in each sub-category: (required, not-required)
                                ( sort @required ),
                                ( sort @optional ),
                               )
                               #)
                              ),
                          "\n",
                          #'_' x ($Text::Wrap::columns + 3),
                         )
                  );
    %already_decoded = ();
    exists $config->{exit} or exit -1;
    $config->{exit} and exit -1;
}

END {
}

1;
__END__

=head1 NAME Easy::Options

Easy::Options - Easy to use, feature rich general purpose option processing using Getopt::Long as the underlying options processing package.
Contrary to the Getopt::Long package, and despite the fact that this refers to "options", it will also process required arguments. This is distinct from the '=' options specifier in Getopt::Long, which states that __IF__ the option is listed on the command line, then it must have a value. With Easy::Options you may specify also that a program requires the argument to have a value even if it isn't specified on the command line.


Please don't flame me for the lame documentation here. I banged out this little bit of documentation just so there would be __something__. I intend to add more for later releases.

Also, please don't flame me about the tests. I have partially completed tham, and I am working on finishing. Right now, there are no real tests run.
=head1 SYNOPSIS

  use Easy::Options;
  my @mama_is = qw( sweet );
  my %optargs = (
                 'mama|mom|mother' => [ ':=s@',
                                        \@mama_is,
                                        "Characteristics of 'mama'. Default value is qw(" . join(' ', @mama_is ) . ")"
                                      ],
                );

  my %options_target = ();
  my %options = easy_options( optargs => \%optargs, target => \%options_target )

=head1 NOTABLE

If you do not specify a 'usage' or 'help' options in your %optargs, then one will be inserted for you. When invoked, the usage() routine will print out a usage message(somewhat verbose) which includes information about the available options, listing REQUIRED options first followed by OPTIONAL options (alphabetically within their respective groups). For each option, the options type is listed along with its current value, followed by the <DOC_STRING> (see below).

=head1 OPTARGS

The %optargs are a modified form of the options processing arguments to GetOpt::Long, and are converted to GetOpt::Long argument form. There are two additions to the 

  The %optargs from above take the following form:

  '<OPTION_NAME>' => [ '<OPTION_SPEC>', <DEFAULT_VALUE>, "<DOC_STRING>" ]

'OPTION_NAME'  may ba a pipe delimited list of alternate names for an option. The first alernate listed becomes the canonical name for the option.

'OPTIONS_SPEC' is essentially the Getopt::Long form of option specification with one addition in terms of required vs optional parameters. You may add an additinoal options/required specifier character at the beginning of the options spec to indicate whether this option (or argument if you prefer) is required/optional for the program itself.

An example would help:

  'this|that:s=@'

This is a standard Getopt::Long options specifier that says I am expecting string values if values are provided, but values need not be privided. The option may be repeated on the command line and the results will be put into an array.

You would specify this like so for Easy::Options:

       ( 'this|that' => [ ':s=@', [], "--this <XX> is the same as --that <XX>" )

Supposing you program REQUIRED that --this be set. You would add a n equal sign to the options spec:

       ( 'this|that' => [ '=:s=@', [], "--this <XX> is the same as --that <XX>" )

Which would indicate that the program required the array (or string or int, as the case may be) to be non-empty, yet you wouldn't necessarily need to list it on the command line if there were defaults already set.

These are all the possibilities include: '==', ':=', '=:', '::'

If there is only a single optional/required specifier it is used for BOTH purposes. That is to say a single '=' would make the parameter value necessary if indeed the option were specified on the command line, and it would make the parameter values required to be defined for the program to continue. Like wise, a single ':' would make the parameter optional on all accounts.

'DEFAULT_VALUE'  Can be
       0) undef
       1) scalar literal
       2) SCALAR reference - in which case the variable referred to will be set to the value of the option as given on the command line
       3) CODE   reference - treated the same way Getopt::Long treats CODE references
       4) ARRAY  reference - treated the same way Getopt::Long treats ARRAY references
       5) HASH   reference - treated the same way Getopt::Long treats HASH references

'DOC_STRING'  Is a brief description of the purpose of the option. This is ised in a --help printout.


=head1 TODO

  Add more docs to cover topics about: 
      overriding the help/usage builtin
      avoiding triggering the help/usage on failure
      providing a brief_usage argument
      using passthroughs to do partial option processing
      additional arguments that can be passed to easy_options():
        configuration parameters for Getopt::Long
        configuration parameters for Easy::Options;
        `target' parameter
        etc ..

I would like to have the options be returned as a tied hash. In this way, one could step through the keys of the hash and be certain only to get the canonical names for options. Currently, alternate names are inserted into the %options alongside the canonical names. With a tied hash, one could obscure the fact that there are alternate names, but could make the tied hash return the appropriate value when an alternate name is used to retrieve a value from the %options hash, and possiblly issue a warning about the alternate name being depricated.

=head1 BUGS

Because the alternate names are inserted into the %options alongside the canonical names, the values can get out of sync if you change a value in the %options hash which has alternative names (because the alternate names duplicate the values in the %options hash)

=head1 AUTHOR

Theo Lengyel, E<lt>dirt@cpan.org<gt>

=head1 SEE ALSO
  Getopt::Long
L<perl>.

=cut
