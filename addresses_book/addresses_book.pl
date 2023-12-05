#!/usr/bin/perl
# Przemysław Pawlik PJS1

use strict;
use warnings;

use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use utf8;
use open qw(:std :utf8);
use Encode;

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
    print "Błąd: Nie znaleziono modułu logic.pm w katalogu ze skryptem.\n";
    exit 1;
}

Logic::create_database();

if (@ARGV >= 1) {
    my $mode = $ARGV[0];
    if ($mode eq "-a" || $mode eq "--add") {
        if (@ARGV >= 2) {
            my $contact_info = decode_utf8($ARGV[1]);
            Logic::add_contact($contact_info);
        } else {
            print "Błąd: Brak danych do dodania.\n";
            exit 1;
        }
    } elsif ($mode eq "-r" || $mode eq "--remove") {
        if (@ARGV >= 2) {
            my $contact_name = decode_utf8($ARGV[1]);
            Logic::remove_contact($contact_name);
        } else {
            print "Błąd: Brak kontaktu do usunięcia.\n";
            exit 1;
        }
    } elsif ($mode eq "-s" || $mode eq "--search") {
        if (@ARGV >= 2) {
            my $contact_name = decode_utf8($ARGV[1]);
            Logic::listOne($contact_name);
        } else {
            print "Błąd: Brak nazwy kontaktu do wyszukania.\n";
            exit 1;
        }
    } elsif ($mode eq "-l" || $mode eq "--list") {
        if (@ARGV >= 2) {
            my $max_contacts = decode_utf8($ARGV[1]);
            Logic::listAll($max_contacts);
        } else {
            Logic::listAll();
        }
    } else {
        print "Błąd: Wprowadzono nieznany tryb pracy.\n";
        exit 1;
    }
} else {
    Logic::listAll();
}

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
