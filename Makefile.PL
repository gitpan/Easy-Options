use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              AUTHOR            => 'Theo Lengyel <dirt@cpan.org>',
              NAME		=> 'Easy::Options',

              VERSION_FROM	=> 'lib/Easy/Options.pm',
              ABSTRACT_FROM     => 'lib/Easy/Options.pm',

              PREREQ_PM		=> { qw( Easy::Log .02 ) },
             );
