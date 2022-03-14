#!/bin/bash

set -e

# CarlozCode - Ferks-FK

# Visual Functions #
print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

RESET="\e[0m"
RED='\033[0;31m'

error() {
  echo ""
  echo -e "* ${RED}ERRO${RESET}: $1"
  echo ""
}

# Check Sudo #
if [[ $EUID -ne 0 ]]; then
  echo "* Entre no modo "Sudo" para executar este script." 1>&2
  exit 1
fi
if ! [ -x "$(command -v curl)" ]; then
  echo "* "
exit 1
fi

# Check Curl #
if ! [ -x "$(command -v curl)" ]; then
  echo 
  echo "* Instalei o APT, executando apt install curl"
  exit 1
fi

cancel() {
echo
echo -e "* ${RED}Cancelando... ${RESET}"
done=true
exit 1
}

done=false

echo
print_brake 70
echo "* CarlozCodes - AutoScript Para Pterodactyl"
echo
echo "* Version 0.1 Beta"
print_brake 70
echo

Backup() {
bash <(curl -s https://raw.githubusercontent.com/Carloz2er/autothemekk/main/backup.sh)
}

Dracula() {
bash <(curl -s https://raw.githubusercontent.com/Carloz2er/autothemekkk/main/theme.sh)
}

while [ "$done" == false ]; do
  options=(
    "Restourar o backup(Caso haja algum problema)"
    "Instalar o tema(1.6.6 a 1.7.0)"
    
    
    "Cancelar"
  )
  
  actions=(
    "Backup"
    "Dracula"
    
    
    "cancel"
  )
  
  echo "* Qual tema?"
  echo
  
  for i in "${!options[@]}"; do
    echo "[$i] ${options[$i]}"
  done
  
  echo
  echo -n "* Input 0-$((${#actions[@]} - 2)):"
  read -r action
  
  [ -z "$action" ] && error "Não reconheci a oção" && continue
  
    valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 2)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Opção nao reconhecida"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
