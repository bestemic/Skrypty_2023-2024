#!/bin/bash
# Przemysław Pawlik PJS1

show_help() {
    echo -e "Skrypt pozwalający na szyfrowanie i deszyfrowanie plików tekstowych przy użyciu prostych szyfrów podstawieniowych.\n"

    echo "OPIS"
    echo -e "\tSkrypt słyży do szyfrowania i deszyfrowania zawartości dowolnych plików tekstowych zakodowanych systemem UTF-8. Aby przejrzeć dostępne algorytmy należy użyć\n\
    \topcji -a lub --available. Do poprawnego działania wymagane jest podanie tryby pracy określającego czy chcemy podane pliki zakodować czy odkodować. Kolejnym\n\
    \twymaganym argumentem jest określenie metody szyfrującej poprzez flagę -m lub --method po których należy podać jedną z dostępnych metod. Do każdej z metod\n\
    \tnależy podać też klucz który zostanie użyty w trakcie przetwarzania plików. Aby tego dokonać należy po fladze -k lub --key podać odpowiedni klucz zgodnie z\n\
    \tinformacjami opisanymi na liście dostępnych metod. Skrypt umożliwia operację na kilku plikach jednocześnie. Każdy plik zakodowany w systemie UFT-8\n\
    \tpoprzedzony musi być przez opcję -f lub --file. Pliki zapisane zostaną w katalogu z którego wywołano skrypt, a ich nowa nazwa będzie składać się\n\
    \tz oryginalnej nazwy pliku i przyrostków: _encrypted dla plików zakodowanych oraz _decoded dla plików odkodowanych.\n"

    echo "UŻYCIE"
    echo -e "\t$0 [OPCJE] [ARGUMENTY]\n"

    echo "OPCJE"
    echo -e "\t-h, --help\twyświtla pomoc"
    echo -e "\t-a, --available\twyświtla dostępne metody szyfrowania wraz z opisami"
    echo -e "\t-f, --file\twczytuje plik, należy go umieścić jako kolejny argument po fladze"
    echo -e "\t-k, --key\tpobiera klucz używany do algorytmów, należy go umieścić jako kolejny argument po fladze"
    echo -e "\t-m, --method\tpozwala na wybór algorytmu szyfrowania, należy umieścić nazwę szyfru jako kolejny argument po fladze, dostępna lista metod po użyciu\n\
    \t\t\tflagi -a lub --available"
    echo -e "\t-e, --encrypt\tustawia skrypt w trybie szyfrowania, sprzeczne z flagami -d oraz --decode"
    echo -e "\t-d, --decode\tustawia skrypt w trybie deszyfrowania, sprzeczne z flagami -e oraz --encrypt\n"

    echo "PRZYKŁADY"
    echo -e "\t$0 -d -m cezar -k 15 -f tajne.txt"
    echo -e "\t$0 -e -m vigenere -k tojestklucz -f tajne.txt -f przykład.txt"
}

show_available() {
    echo "Dostępne opcje:"
    echo -e "cezar \t\tSzyfr Cezara to szyfr, w którym każda litera tekstu jawego jest zamieniana na literę przesuniętą o stałą liczbę miejsc w alfabecie.\n\
    \t\tKlucz powinien być liczbą naturalną z zakresu od 0 do 32."
    echo -e "vigenere \tSzyfr Vigenere'a to szyfr, w którym każda litera tekstu jawego jest szyfrowana za pomocą przesunięcia wyznaczanego na podstawie elementów klucza.\n\
    \t\tKlucz powinien zawierać co najmniej dwie litery."

}

show_multiple_operation_error() {
    echo "Błąd: Należy wybrać tylko jedną operację: szyfrowanie [-e, --encrypt] lub deszyfrowanie [-d, --decode]."
}

show_no_operation_error() {
    echo "Błąd: Nie podano żadnej z operacji [-e, --encrypt, -d, --decode]."
}

show_bad_method_error() {
    echo "Błąd: Podana metoda: '$1' nie jest obsługiwana. Dostępne można znaleźć pod opcją -a lub --available."
}

show_no_method_error() {
    echo "Błąd: Nie podano metody. Dostępne można znaleźć pod opcją -a lub --available."
}

show_no_key_error() {
    echo "Błąd: Nie podano klucza."
}

show_bad_file_error() {
    echo "Błąd: Podany plik: '$1' nie jest zakodowany w UTF-8."
}

show_no_files_error() {
    echo "Błąd: Nie podano żadnego pliku."
}

show_file_not_found_error() {
    echo "Błąd: Podany plik: '$1' nie istnieje."
}

show_no_lib_error() {
    echo "Błąd: Nie znaleziono modułu: '$1' w katalogu ze skryptem."
}

show_no_write_error() {
    echo "Błąd: Brak uprawnień do zapisu w bieżącym folderze."
}

METHODS=("cezar" "vigenere")

num_args=$#
operation=""
method=""
key=""
files=()

for arg in "$@"; do
    if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
        show_help "$0"
        exit 0
    fi
done

for arg in "$@"; do
    if [ "$arg" == "-a" ] || [ "$arg" == "--available" ]; then
        show_available
        exit 0
    fi
done

for ((i = 0; i <= $num_args; i++)); do
    arg="${!i}"

    if [ "$arg" == "-e" ] || [ "$arg" == "--encrypt" ]; then
        if [ -z "$operation" ]; then
            operation="encrypt"
        else
            if [ "$operation" != "encrypt" ]; then
                show_multiple_operation_error
                exit 1
            fi
        fi
    fi

    if [ "$arg" == "-d" ] || [ "$arg" == "--decode" ]; then
        if [ -z "$operation" ]; then
            operation="decode"
        else
            if [ "$operation" != "decode" ]; then
                show_multiple_operation_error
                exit 1
            fi
        fi
    fi

    if [ "$arg" == "-m" ] || [ "$arg" == "--method" ]; then
        next=$(($i + 1))

        if [ -z "$method" ]; then
            if [ $next -le $num_args ]; then
                value=$(echo ${!next} | awk '{print tolower($0)}')

                for m in "${METHODS[@]}"; do
                    if [[ $m == $value ]]; then
                        method=$value
                    fi
                done

                if [ -z "$method" ]; then
                    show_bad_method_error $value
                    exit 1
                fi
            fi
            ((i += 1))
        fi
    fi

    if [ "$arg" == "-k" ] || [ "$arg" == "--key" ]; then
        next=$(($i + 1))

        if [ -z "$key" ]; then
            if [ $next -le $num_args ]; then
                key="${!next}"
            fi
        fi
        ((i += 1))
    fi

    if [ "$arg" == "-f" ] || [ "$arg" == "--file" ]; then
        next=$(($i + 1))

        if [ $next -le $num_args ]; then
            file="${!next}"
            files+=(${!next})
        fi
        ((i += 1))
    fi

done

if [ -z "$operation" ]; then
    show_no_operation_error
    exit 1
fi

if [ -z "$method" ]; then
    show_no_method_error
    exit 1
fi

if [ -z "$key" ]; then
    show_no_key_error
    exit 1
fi

if [ ${#files[@]} -eq 0 ]; then
    show_no_files_error
    exit 1
fi

if ! [ -w "." ]; then
    show_no_write_error
    exit 1
fi

for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        show_file_not_found_error $file
        exit 1
    fi

    encoding=$(file --mime-encoding "$file")

    if [[ ! "$encoding" =~ "utf-8" ]]; then
        show_bad_file_error $file
        exit 1
    fi
done

lib_name="${method}_lib.sh"
main_dir=$(dirname "$0")

if [ -e "$main_dir/$lib_name" ]; then
    source "$main_dir/$lib_name"
    verify_key "$key"

    for file in "${files[@]}"; do
        text=$(
            cat "$file"
            printf x
        )

        target_file=$(basename -- "$file")

        if [ "$operation" == "encrypt" ]; then
            text=$(encrypt "$text" "$key")
            target_file="${target_file%.*}_encrypted.txt"

        else
            text=$(decode "$text" "$key")
            target_file="${target_file%.*}_decoded.txt"
        fi

        text=${text%x}
        echo -n "$text" >"$target_file"

    done
else
    show_no_lib_error $lib_name
    exit 1
fi
