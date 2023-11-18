#!/bin/bash

alphabet="aąbcćdeęfghijklłmnńoóprsśtuwyzźż0123456789"
declare -A alphabet_dict

for ((i = 0; i < ${#alphabet}; i++)); do
  char="${alphabet:$i:1}"
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
    index="${alphabet_dict[$char]}"

    if [ -n "$index" ]; then
      new_index=$(((index + key) % 42))
      result+="${alphabet:$new_index:1}"
    else
      result+="$char"
    fi

  done

  echo "$result"
}
