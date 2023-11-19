#!/bin/bash
# Przemysław Pawlik PJS1

# TODO
show_help() {
    echo "Help"
}

# TODO
show_available() {
    echo "Dostępne opcje"
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
    echo "Błąd: Podany plik: '$1' nie posiada rozszerzenia '.txt'."
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

METHODS=("cat" "dog" "cezar")

num_args=$#
operation=""
method=""
key=""
files=()

for arg in "$@"; do
    if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
        show_help
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

            if [[ $file == *.txt ]]; then
                files+=(${!next})
            else
                show_bad_file_error $file
                exit 1
            fi
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
done

lib_name="${method}_lib.sh"
main_dir=$(dirname "$0")

if [ -e "$main_dir/$lib_name" ]; then
    source "$main_dir/$lib_name"
    verify_key $key

    for file in "${files[@]}"; do
        text=$(<"$file")
        target_file=$(basename -- "$file")

        if [ "$operation" == "encrypt" ]; then
            text=$(encrypt "$text" $key)
            target_file="${target_file%.*}_encrypted.txt"

        else
            text=$(decode "$text" $key)
            target_file="${target_file%.*}_decoded.txt"

        fi

        echo -n "$text" >"$target_file"
    done
else
    show_no_lib_error $lib_name
    exit 1
fi
