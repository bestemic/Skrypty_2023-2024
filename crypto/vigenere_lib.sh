#!/bin/bash

alphabet_lowercase="aąbcćdeęfghijklłmnńoóprsśtuwyzźż"
alphabet_uppercase="AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUWYZŹŻ"

declare -A alphabet_dict

for ((i = 0; i < ${#alphabet_lowercase}; i++)); do
    char="${alphabet_lowercase:$i:1}"
    alphabet_dict["$char"]=$((i))
done

verify_key() {
    local key=$1

    if [[ ! $key =~ ^[$alphabet_lowercase$alphabet_uppercase]+$ ]]; then
        echo "Błąd: Klucz powinien składać się tylko z liter alfabetu polskiego."
        exit 1
    fi
}

encrypt() {
    local text=$1
    local key=$2
    local result=""

    key_length=${#key}
    key_iterator=0

    for ((i = 0; i < ${#text}; i++)); do
        char="${text:i:1}"

        if [[ $char =~ [[:space:]] ]]; then
            result+="$char"
        else
            lower_char=$(echo "$char" | awk '{print tolower($0)}')
            index="${alphabet_dict[$lower_char]}"

            if [ -n "$index" ]; then
                key_char="${key:((key_iterator % key_length)):1}"
                key_index="${alphabet_dict[$key_char]}"
                new_index=$(((index + key_index) % 32))
                ((key_iterator++))

                if [[ "$char" =~ [A-ZĘÓĄŚŁŻŹĆŃ] ]]; then
                    result+="${alphabet_uppercase:$new_index:1}"
                else
                    result+="${alphabet_lowercase:$new_index:1}"
                fi

            else
                result+="$char"
            fi
        fi

    done

    echo "$result"
}

decode() {
    local text=$1
    local key=$2

    reversed_key=""

    for ((i = 0; i < ${#key}; i++)); do
        char="${key:i:1}"

        lower_char=$(echo "$char" | awk '{print tolower($0)}')
        index="${alphabet_dict[$lower_char]}"
        new_index=$(((32 - index) % 32))

        if [[ "$char" =~ [A-ZĘÓĄŚŁŻŹĆŃ] ]]; then
            reversed_key+="${alphabet_uppercase:$new_index:1}"
        else
            reversed_key+="${alphabet_lowercase:$new_index:1}"
        fi

    done

    echo "$(encrypt "$text" $reversed_key)"
}
