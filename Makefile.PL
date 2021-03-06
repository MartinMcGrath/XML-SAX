use ExtUtils::MakeMaker;
use File::Basename ();
use File::Spec ();


WriteMakefile(
    'NAME'	=> 'XML::SAX',
    'VERSION_FROM' => 'SAX.pm', # finds $VERSION
    META_MERGE => {
        resources => {
            repository => 'https://github.com/grantm/XML-SAX',
        },
    },
    'PREREQ_PM' => { 
        'File::Temp' => 0,
        'XML::SAX::Base' => 1.05,
        'XML::NamespaceSupport' => 0.03,
    },    
);

sub MY::install {
    package MY;
    my $script = shift->SUPER::install(@_);

    # Only modify existing ParserDetails.ini if user agrees

    my $write_ini_ok = 0;

    eval { require XML::SAX };
    if ($@) {
        $write_ini_ok = 1;
    }
    else {
        my $dir = File::Basename::dirname($INC{'XML/SAX.pm'});
        if (-e File::Spec->catfile($dir, 'SAX', 'ParserDetails.ini')) {
            $write_ini_ok =
                ExtUtils::MakeMaker::prompt(
                    "Do you want XML::SAX to alter ParserDetails.ini?", "Y"
                ) =~ /^y/i;
        }
        else {
            $write_ini_ok = 1;
        }
    }
    
    if ($write_ini_ok) {
        $script =~ s/install :: (.*)$/install :: $1 install_sax_pureperl/m;
        $script .= <<"INSTALL";

install_sax_pureperl :
\t\@\$(PERL) -MXML::SAX -e "XML::SAX->add_parser(q(XML::SAX::PurePerl))->save_parsers()"

INSTALL

    }

    return $script;
}

