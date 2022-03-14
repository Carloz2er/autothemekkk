#!/bin/bash

set -e

# Script do carlão(Modificado kkkk)

# Visual  #
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
  echo -e "* ${RED}ERRO EITA${RESET}: $1"
  echo ""
}

# Checa #
if [[ $EUID -ne 0 ]]; then
  echo "* só funfa se tiver em sudo su" 1>&2
  exit 1
fi

# Check Curl #
if ! [ -x "$(command -v curl)" ]; then
  echo "* Instala o curl antes para pegar "
  echo "* -> Instale dando apt install curl"
  exit 1
fi

cancel() {
echo
echo -e "* ${RED}cancelando ${RESET}"
done=true
exit 1
}

done=false

echo
print_brake 70
echo "* AutoTheme do Carlão (e backup em kkk)"
echo
print_brake 70
echo

Backup() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/backup.sh)
}

Dracula() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version1.x/Dracula/build.sh)
}

while [ "$done" == false ]; do
  options=(
    "Usar o backuo(To fazendo ainda n tenta usar)"
    "Tema 1"
    
    
    "Cancelar"
  )
  
  actions=(
    "Backup"
    "Tema"
    
    "Cancelar"
  )
  
  echo "* Qual tema você deseja instalar?"
  echo
  
  for i in "${!options[@]}"; do
    echo "[$i] ${options[$i]}"
  done
  
  echo
  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action
  
  [ -z "$action" ] && error "Como vou adivinhar oque você quer?" && continue
  
  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Que opção é essa?"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done