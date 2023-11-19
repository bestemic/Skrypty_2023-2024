#!/bin/bash

alphabet_lowercase="aąbcćdeęfghijklłmnńoóprsśtuwyzźż0123456789"
alphabet_uppercase="AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUWYZŹŻ0123456789"

declare -A alphabet_dict

for ((i = 0; i < ${#alphabet_lowercase}; i++)); do
  char="${alphabet_lowercase:$i:1}"
  alphabet_dict["$char"]=$((i))
done

verify_key() {
  local key=$1

  if [[ ! $key =~ ^[0-9]+$ ]] || ((key < 0 || key > 42)); then
    echo "Błąd: Klucz powinien być liczbą naturalną z zakresu od 0 do 42."
    exit 1
  fi
}

encrypt() {
  local text=$1
  local key=$2
  local result=""

  for ((i = 0; i < ${#text}; i++)); do
    char="${text:i:1}"

    if [[ $char =~ [[:space:]] ]]; then
      result+="$char"
    else
      lower_char=$(echo "$char" | awk '{print tolower($0)}')
      index="${alphabet_dict[$lower_char]}"

      if [ -n "$index" ]; then
        new_index=$(((index + key) % 42))

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
