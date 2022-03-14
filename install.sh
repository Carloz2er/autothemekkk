
set -e

# CarlozCode

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
  echo -e "* ${RED}FALHA:${RESET}: $1"
}
if [[ $EUID -ne 0 ]]; then
  echo "* Entre no modo "Sudo" para executar este script! 1>&2
  exit 1
fi
if ! [ -x "$(command -v curl)" ]; then
  echo "* "
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
echo "* CarlozCodes - AutoScitp Para Pterodactyl"
echo
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
  
  [ -z "$action" ] && error "Opção inválida!"&& continue
  
  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Não encontrei essa opção."
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
