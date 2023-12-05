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
    print "\tSkryt działa jako książka adresowa. Do zarządzania bazą adresów używamy jednego z czterech trybów: 'add', 'remove', 'search', 'list'.\n"
    . "\tAby dodać nowy kontakt (lub kontakty) należy podać argument otoczony znakiem cudzysłowu \"dane\", gdzie dane to informacje oddzielone od\n" 
    . "\tsiebie za pomocą \|. Najpierw podajemy nazwę, potem numer telefonu, a na końcu email. Nazwa jest wymagana, następne dwa elementy nie są \n"
    . "\tobowiązkowe, ale potrzebny jest przynajmniej jeden. Drugi można pominąć (zachowując strukturę podawania danych, czyli np. Imię||Email).\n"
    . "\tIstnieje możliwość dodania więcej niż jednego kontaktu na raz, w takim celu należy po wpisaniu pierwszego kompletu danych podać kolejny\n"
    . "\toddzielając go znakiem |\. Dane te są następnie przechowywane w pliku data.txt który znajduje się w tym samym folderze co skrypt. W momencie\n"
    . "\tgdy plik nie zostanie znaleziony będzie on utworzony. Aby usunąć kontakt z listy należy podać nazwę kontaktu do trybu 'remove'. Opcja 'search'\n"
    . "\tpozwala na pobranie podanego kontaktu z bazy i wyświetlenie go. Opcja 'list' jest opcją domyślną i wyświetla wszystkie zapisane kontakty -\n"
    . "\tdomyślnie wypisywana jest cała książka adresowa, aby wyświetlić mniej wystarczy podać jako argument liczbę oznaczającą limit.\n";
    print "\n";

    print "UŻYCIE\n";
    print"\t$0 [TRYBY] [ARGUMENT]\n\n";

    print "TRYBY\n";
    print "\t-h, --help\tWyświtla pomoc\n";
    print "\t-a, --add\tDodaje kontakty, przyjmuje jeden wymagany argument - kontakty do dodania w formacie opisanym wyżej\n";
    print "\t-s, --search\tWyświtla podany kontakt, przyjemuje jeden wymagany argument - nazwę kontaktu do wyświetlenia\n";
    print "\t-l, --list\tWyświetla listę kontaktów, przyjmuje jeden opcjonalny argument - liczbę kontaktów do wyświetlanie, domyślnie pokazuje wszystkie kontakty\n";
    print "\t-r, --remove\tUsuwa podany kontakt, przyjemuje jeden wymagany argument - nazwę kontaktu do usunięcia\n";
    print "\n";

    print "PRZYKŁADY\n";
    print"\t$0 -a \"Anna Lewandowska|123456789||Robert Lewandowski||robert\@gmail.com|Jan|987654321|jan\@company.com\"\n";
    print"\t$0 -l 2\n";
    print"\t$0 -s Jan\n";
    print"\t$0 -r Jan\n";
}
