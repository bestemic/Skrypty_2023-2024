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

my $file_name;
my $working_mode="list";
my $argument;
my $data;

if (@ARGV >= 1) {
    my $mode = $ARGV[0];
    if ($mode eq "-a" || $mode eq "--add") {
        $working_mode="add";
        if (@ARGV >= 2 && $ARGV[1] ne "-f" && $ARGV[1] ne "--file") {
            $argument = decode_utf8($ARGV[1]);
            if (@ARGV >= 3 && ($ARGV[2] eq "-f" || $ARGV[2] eq "--file")) {
                if (@ARGV >= 4 && $ARGV[3] ne "") {
                    $file_name = decode_utf8($ARGV[3]);
                } else {
                    print "Błąd: Brak nazwy pliku z danymi.\n";
                    exit 1;
                }
            }
        } else {
            print "Błąd: Brak danych do dodania.\n";
            exit 1;
        }
    } elsif ($mode eq "-r" || $mode eq "--remove") {
        $working_mode="remove";
        if (@ARGV >= 2 && $ARGV[1] ne "-f" && $ARGV[1] ne "--file") {
            $argument = decode_utf8($ARGV[1]);
            if (@ARGV >= 3 && ($ARGV[2] eq "-f" || $ARGV[2] eq "--file")) {
                if (@ARGV >= 4 && $ARGV[3] ne "") {
                    $file_name = decode_utf8($ARGV[3]);
                } else {
                    print "Błąd: Brak nazwy pliku z danymi.\n";
                    exit 1;
                }
            }            
        } else {
            print "Błąd: Brak kontaktu do usunięcia.\n";
            exit 1;
        }
    } elsif ($mode eq "-s" || $mode eq "--search") {
        $working_mode="search";
        if (@ARGV >= 2 && $ARGV[1] ne "-f" && $ARGV[1] ne "--file") {
            $argument = decode_utf8($ARGV[1]);
            if (@ARGV >= 3 && ($ARGV[2] eq "-f" || $ARGV[2] eq "--file")) {
                if (@ARGV >= 4 && $ARGV[3] ne "") {
                    $file_name = decode_utf8($ARGV[3]);
                } else {
                    print "Błąd: Brak nazwy pliku z danymi.\n";
                    exit 1;
                }
            }
        } else {
            print "Błąd: Brak nazwy kontaktu do wyszukania.\n";
            exit 1;
        }
    } elsif ($mode eq "-l" || $mode eq "--list") {
        $working_mode="list";
        if (@ARGV >= 2 && $ARGV[1] ne "-f" && $ARGV[1] ne "--file") {
            $argument = decode_utf8($ARGV[1]);
            if (@ARGV >= 3 && ($ARGV[2] eq "-f" || $ARGV[2] eq "--file")) {
                if (@ARGV >= 4 && $ARGV[3] ne "") {
                    $file_name = decode_utf8($ARGV[3]);
                } else {
                    print "Błąd: Brak nazwy pliku z danymi.\n";
                    exit 1;
                }
            }
        } elsif (@ARGV >= 2 && ($ARGV[1] eq "-f" || $ARGV[1] eq "--file")) {
            if (@ARGV >= 3 && $ARGV[2] ne "") {
                $file_name = decode_utf8($ARGV[2]);
            } else {
                print "Błąd: Brak nazwy pliku z danymi.\n";
                exit 1;
            }
        }
    } elsif ($mode eq "-p" || $mode eq "--pattern") {
        $working_mode="pattern";
        if (@ARGV >= 2 && $ARGV[1] ne "-f" && $ARGV[1] ne "--file") {
            $argument = decode_utf8($ARGV[1]);
            if (@ARGV >= 3 && ($ARGV[2] eq "-f" || $ARGV[2] eq "--file")) {
                if (@ARGV >= 4 && $ARGV[3] ne "") {
                    $file_name = decode_utf8($ARGV[3]);
                } else {
                    print "Błąd: Brak nazwy pliku z danymi.\n";
                    exit 1;
                }
            }
        } else {
            print "Błąd: Brak patternu do wyszukania.\n";
            exit 1;
        }
    } elsif ($mode eq "-e" || $mode eq "--edit") {
        $working_mode="edit";
        if (@ARGV >= 2 && $ARGV[1] ne "-f" && $ARGV[1] ne "--file") {
            $argument = decode_utf8($ARGV[1]);
            if (@ARGV >= 3 && $ARGV[2] ne "-f" && $ARGV[2] ne "--file") {
                $data = decode_utf8($ARGV[2]);
                if (@ARGV >= 4 && ($ARGV[3] eq "-f" || $ARGV[3] eq "--file")) {
                    if (@ARGV >= 5 && $ARGV[4] ne "") {
                        $file_name = decode_utf8($ARGV[4]);
                    } else {
                        print "Błąd: Brak nazwy pliku z danymi.\n";
                        exit 1;
                    }   
                }
            } else {
                print "Błąd: Brak danych do edycji kontaktu.\n";
                exit 1;
            }
        } else {
            print "Błąd: Brak nazwy kontaktu do edycji.\n";
            exit 1;
        }
    } elsif ($mode eq "-f" || $mode eq "--file") {
        if (@ARGV >= 2 && $ARGV[1] ne "") {
            $file_name = decode_utf8($ARGV[1]);
        } else {
            print "Błąd: Brak nazwy pliku z danymi.\n";
            exit 1;
        }
    } else {
        print "Błąd: Wprowadzono nieznany tryb pracy.\n";
        exit 1;
    }
}

Logic::create_database($file_name);

if ($working_mode eq "add") {
    Logic::add_contact($argument);
} elsif ($working_mode eq "remove") {
    Logic::remove_contact($argument);
} elsif ($working_mode eq "search") {
    Logic::list_one($argument);
} elsif ($working_mode eq "pattern") {
    Logic::find_contacts($argument);
} elsif ($working_mode eq "edit") {
    Logic::edit_contact($argument, $data);
} else {
    Logic::list_all($argument);
} 

sub show_help {
    print "Skrypt do zarządzania książką adresową.\n\n";

    print "OPIS\n";
    print "\tSkryt działa jako książka adresowa. Do zarządzania bazą adresów używamy jednego z czterech trybów: 'add', 'remove', 'search', 'list'.\n"
    . "\tAby dodać nowy kontakt (lub kontakty) należy podać argument otoczony znakiem cudzysłowu \"dane\", gdzie dane to informacje oddzielone od\n" 
    . "\tsiebie za pomocą \|. Najpierw podajemy nazwę, kolejno opis, potem numer telefonu, a na końcu email. Nazwa jest wymagana i musi być jednoczłonowa,\n"
    . "\topis jest opcjonalny, a dwa ostatnie elementy nie są obowiązkowe, ale potrzebny jest przynajmniej jeden. Drugi można pominąć (zachowując\n"
    . "\tstrukturę podawania danych, czyli np. Nick|Opis||Email). Istnieje możliwość dodania więcej niż jednego kontaktu na raz, w takim celu należy\n"
    . "\tpo wpisaniu pierwszego kompletu danych podać kolejny oddzielając go znakiem |\. Dane te są następnie domyślnie przechowywane w pliku data.txt\n"
    . "\tktóry znajduje się w tym samym folderze co skrypt. Możemy jednak ręcznie wskazywać na plik który przechowuje dane używająć flagi 'file' jako\n"
    . "\tprzedostatni argument wywołania skryptu i podająć po niej nazwę pliku. W momencie gdy plik nie zostanie znaleziony będzie on utworzony. Aby\n"
    . "\tusunąć kontakt z listy należy podać nazwę kontaktu do trybu 'remove'. Opcja 'search' pozwala na pobranie na podstawie podanej nazwy, kontaktu\n"
    . "\tz bazy i wyświetlenie go. Opcja 'list' jest opcją domyślną i wyświetla wszystkie zapisane kontakty - domyślnie wypisywana jest cała książka\n"
    . "\tadresowa, aby wyświetlić mniej wystarczy podać jako argument liczbę oznaczającą limit.\n";
    print "\n";

    print "UŻYCIE\n";
    print"\t$0 [TRYBY] [ARGUMENT] [FLAGI] [PLIK]\n\n";

    print "TRYBY\n";
    print "\t-a, --add\tDodaje kontakty, przyjmuje jeden wymagany argument - kontakty do dodania w formacie opisanym wyżej\n";
    print "\t-s, --search\tWyświtla podany kontakt, przyjemuje jeden wymagany argument - jednoczłonową nazwę kontaktu do wyświetlenia\n";
    print "\t-l, --list\tWyświetla listę kontaktów, przyjmuje jeden opcjonalny argument - liczbę kontaktów do wyświetlanie, domyślnie pokazuje wszystkie kontakty\n";
    print "\t-r, --remove\tUsuwa podany kontakt, przyjemuje jeden wymagany argument - jednoczłonową nazwę kontaktu do usunięcia\n";
    print "\t-p, --pattern\t\n";
    print "\t-e, --edit\t\n";
    print "\n";

    print "FLAGI\n";
    print "\t-h, --help\tWyświtla pomoc\n";
    print "\t-f, --file\tWskazuje nazwę pliku używaną do zadządzania książką adresową, przyjmuje jeden wymagany argument - nazwę pliku\n";
    print "\n";

    print "PRZYKŁADY\n";
    print"\t$0 -a \"alewa|Anna Lewandowska|123456789||robercik|Robert Lewandowski||robert\@gmail.com|JAN||987654321|jan\@company.com\"\n";
    print"\t$0 -l 2 -f nowa_baza.txt\n";
    print"\t$0 -s Jan\n";
    print"\t$0 -r Jan -f nowa_baza.txt\n";
    print"\t$0 -p \"Lewa\"\n";
}
