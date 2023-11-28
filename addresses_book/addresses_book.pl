#!/usr/bin/perl
# Przemysław Pawlik PJS1

use strict;
use warnings;

use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));

for my $arg (@ARGV) {
    if ($arg eq '-h' || $arg eq '--help') {
        show_help();
        exit 0;
    }
}

eval { 
    require Logic 
};

if ($@) {
    print "Błąd: Nie znaleziono modułu logic.pm w katalogu ze skryptem. $@\n";
    exit 1;
}

Logic::create_database();
my @contacts = Logic::load_contacts();

use Data::Dumper;
print Dumper(@contacts);


sub show_help {
    print "Skrypt do zarządzania książką adresową.\n\n";

    print "OPIS\n";
    print "\tSkryt działa jako książka adresowa.  Do zarządzania bazą adresów wymaga jednego z trzech argumentów: 'add', 'remove', 'show'.\n"
    . "\t\n" 
    . "\t\n";
    print "\n";

    print "UŻYCIE\n";
    print"\t$0 [OPCJE] PLIK\n\n";

    print "OPCJE\n";
    print "\t-h, --help\tWyświtla pomoc\n";
    print "\n";

    print "PRZYKŁADY\n";
}
