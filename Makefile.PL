use ExtUtils::MakeMaker;
WriteMakefile(
    NAME          => 'Enbugger',
    VERSION_FROM  => 'lib/Enbugger.pm',
    ABSTRACT_FROM => 'lib/Enbugger.pm',
    AUTHOR        => 'Josh ben jore <jjore@cpan.org>',
    LICENSE       => 'perl',
    PREREQ_PM     => { 'B::Utils' => 0, },
);
