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

if (@ARGV == 0) {
    print "Błąd: Podaj plik jako ostatni argument.\n";
    exit 1;
}

my $file_name = pop @ARGV;

if (-e $file_name) {
    my $mime = qx{file --mime-type  "$file_name"};
    if (!($mime && $mime =~ /application\/json/) ){
        print "Błąd: Plik nie posiada MIME application/json lub jego zawartość jest niezgodna z tym typem.\n";
        exit 1;
    }
} else {
    print "Plik '$file_name' nie istnieje.\n";
    exit 1;
}

eval { 
    require JSON::MaybeXS;
};

if ($@) {
    print "Błąd: Nie znaleziono wymaganego modułu JSON. Należy go zainstalować.\n";
    exit 1;
}

eval { 
    require Logic 
};

if ($@) {
    print "Błąd: Nie znaleziono modułu logic.pm w katalogu ze skryptem.\n";
    exit 1;
}

my $json_data = Logic::load_json_file($file_name);

my $decoded_data;
eval { 
    $decoded_data = JSON::MaybeXS::decode_json($json_data);
};

if ($@) {
    print "Błąd: Niepoprawny JSON, nie udało się wczytać. $@\n";
    exit 1;
}

Logic::convert($decoded_data);

sub show_help {
    print "Konwersja plików JSON do plików XML.\n\n";

    print "OPIS\n";
    print "\tGłównym zadaniem skryptu jest konwersja pliku w formacie JSON do pliku w formacie XML. Domyślnie, bez podania żadnych opcji skrypt dokonuje walidacji\n"
    . "\tstruktury JSON podanego pliku a następnie przekształca ją do postaci XML. Walidacja polega na sprawdzeniu domknięć nawiasów klamrowych i kwadratowych,\n"
    . "\tsprawdza też czy klucze oraz wartości będące napisami są otoczone cudzysłowami. Inne możliwe wartości to: liczby, true, false, null oraz tablice i obiekty.\n"
    . "\tZawartość plików JSON musi mieć typ MIME application/json. Plik podajemy zawsze po opcjach, na końcu\n"
    . "\targumentów wywołania. Domyślnie wyjściowy plik XML ma taką samą nazwę jak wejściowy plik JSON. Używając opcji -o lub --out można podać własną nazwę pliku\n"
    . "\twynikowego, należy umieścić ją jako kolejny argument. Używająć flagi -v lub --validate skrypt poinformuje użytkownika czy podany plik JSON jest poprawny\n"
    . "\tczy nie, a następnie zakończy działanie bez przechodzenia do konwersji.\n";
    print "\n";

    print "UŻYCIE\n";
    print"\t$0 [OPCJE] PLIK\n\n";

    print "OPCJE\n";
    print "\t-h, --help\tWyświtla pomoc\n";
    print "\t-v, --validate\tUruchamia skrypt w trybie walidacji.\n";
    print "\t-o, --out\tPozwala na podanie nazwy pliku wynikowego. Nazwę należy podać jako kolejny argument po fladze.\n";
    print "\n";

    print "PRZYKŁADY\n";
    print "\t$0 -v plik.json\n";
    print "\t$0 -o wynik.xml plik.json\n";
}
