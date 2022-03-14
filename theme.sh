#!/bin/bash
# shellcheck source=/dev/null

set -e


# CarlozCode

update_variables() {
CONFIG_FILE="$PTERO/config/app.php"
PANEL_VERSION="$(grep "'version'" "$CONFIG_FILE" | cut -c18-25 | sed "s/[',]//g")"
}

print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

print_warning() {
  echo ""
  echo -e "* ${YELLOW}WARNING${RESET}: $1"
  echo ""
}

print_error() {
  echo ""
  echo -e "* ${RED}ERROR${RESET}: $1"
  echo ""
}

print() {
  echo ""
  echo -e "* ${GREEN}$1${RESET}"
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

GREEN="\e[0;92m"
YELLOW="\033[1;33m"
RED='\033[0;31m'
RESET="\e[0m"

# OS check #
check_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

# Find where pterodactyl is installed #
find_pterodactyl() {
print "Procurando o seu Pterodactyl Panel..."

sleep 2
if [ -d "/var/www/pterodactyl" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/pterodactyl"
  elif [ -d "/var/www/panel" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/panel"
  elif [ -d "/var/www/ptero" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/ptero"
  else
    PTERO_INSTALL=false
fi

update_variables
}


dependencies() {
print "Instalando pacotes adicionais..."

case "$OS" in
debian | ubuntu)
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && apt-get install -y nodejs
;;
centos)
[ "$OS_VER_MAJOR" == "7" ] && curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && sudo yum install -y nodejs yarn
[ "$OS_VER_MAJOR" == "8" ] && curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && sudo dnf install -y nodejs
;;
esac
}

# Panel Backup #
backup() {
print "Fazendo um backup, caso algo não aconteça como o esperado..."

if [ -d "$PTERO/PanelBackup[Auto-Themes]" ]; then
    print "Você já tem um backup, pulando..."  
   else
    cd "$PTERO"
    if [ -d "$PTERO/node_modules" ]; then
        tar -czvf "backupcarlozcode.tar.gz" --exclude "node_modules" -- * .env
        mkdir -p "CarlozCode"
        mv "backupcarlozcode.tar.gz" "CarlozCode"
      else
        tar -czvf "PanelBackup[Auto-Themes].tar.gz" -- * .env
        mkdir -p "CarlozCode"
        mv "backupcarlozcode.tar.gz" "CarlozCode"
    fi
fi
}

# Download Files #
download_files() {
print "Baixando os arquivos do tema..."

cd "$PTERO"
mkdir -p temp
cd temp
curl -sSLo Dracula.tar.gz https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoThemes/themes/version1.x/Dracula/Dracula.tar.gz
tar -xzvf Dracula.tar.gz
cd Dracula
cp -rf -- * "$PTERO"
cd "$PTERO"
rm -r temp
}

# Configure #
configure() {
sed -i "5a\import './user.css';" "$PTERO/resources/scripts/index.tsx"
sed -i "32a\{!! Theme::css('css/admin.css?t={cache-version}') !!}" "$PTERO/resources/views/layouts/admin.blade.php"
}

# Panel Production #
production() {
print "Reconstruindo o painel"
print_warning "O processo pode demorar um pouco, não o cancele."

if [ -d "$PTERO/node_modules" ]; then
    cd "$PTERO"
    yarn add @emotion/react
    yarn build:production
  else
    npm i -g yarn
    cd "$PTERO"
    yarn install
    yarn add @emotion/react
    yarn build:production
fi
}

bye() {
print_brake 50
echo
echo -e "${GREEN}* O Tema${YELLOW}Dracula${GREEN} foi instalado com sucesso!"
echo -e "* O Backup foi criado."
echo
print_brake 50
}

# Exec Script #
check_distro
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
    print "Instalação do painel encontrado, continuando a instalação..."
    
    dependencies
    backup
    download_files
    configure
    production
    bye
  elif [ "$PTERO_INSTALL" == false ]; then
    print_warning "Pasta do pterodactyl não foi encontrada."
    echo -e "* ${GREEN}EXAMPLE${RESET}: ${YELLOW}/var/www/mypanel${RESET}"
    echo -ne "* Insitra manualmente as pastas: "
    read -r MANUAL_DIR
    if [ -d "$MANUAL_DIR" ]; then
        print "Encontrado!"
        PTERO="$MANUAL_DIR"
        echo "$MANUAL_DIR" >> "$INFORMATIONS/custom_directory.txt"
        update_variables
        dependencies
        backup
        download_files
        configure
        production
        bye
      else
        print_error "As pastas que inseriu não existe."
        find_pterodactyl
    fi
fi
