#!/bin/bash
# shellcheck source=/dev/null

set -e

########################################################
# 
#        Pterodactyls-AutoThemes Installation
#
#         Created and maintained by Ferks-FK
#
#            Protected by MIT License
#             Edited By: CarlozCodes
########################################################

get_release() {
curl --silent \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/Ferks-FK/Pterodactyl-AutoThemes/releases/latest |
  grep '"tag_name":' |
  sed -E 's/.*"([^"]+)".*/\1/'
}

# Fixed Variables #
SCRIPT_VERSION="$(get_release)"
SUPPORT_LINK="https://discord.gg/buDBbSGJmQ"
INFORMATIONS="/var/log/Pterodactyl-AutoThemes-informations"

# Update Variables #
update_variables() {
CONFIG_FILE="$PTERO/config/app.php"
PANEL_VERSION="$(grep "'version'" "$CONFIG_FILE" | cut -c18-25 | sed "s/[',]//g")"
}

# Visual Functions #
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
print "Procurando sua instalação de pterodactyl..."

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
# Update the variables after detection of the pterodactyl installation #
update_variables
}

# Verify Compatibility #
compatibility() {
print "Verificando se o addon é compatível com o seu painel..."

sleep 2
if [ "$PANEL_VERSION" == "1.6.6" ] || [ "$PANEL_VERSION" == "1.7.0" ]; then
    print "Versão compatível!"
  else
    print_error "Versão incompatível"
    exit 1
fi
}


# Install Dependencies #
dependencies() {
print "Instalando alguns pacotes ou atualizando..."

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
print "Criando um backup."

if [ -d "$PTERO/PanelBackup[Auto-Themes]" ]; then
    print "Backup já detectado, pulando..."
  else
    cd "$PTERO"
    if [ -d "$PTERO/node_modules" ]; then
        tar -czvf "PanelBackup[Auto-Themes].tar.gz" --exclude "node_modules" -- * .env
        mkdir -p "PanelBackup[Auto-Themes]"
        mv "PanelBackup[Auto-Themes].tar.gz" "PanelBackup[Auto-Themes]"
      else
        tar -czvf "PanelBackup[Auto-Themes].tar.gz" -- * .env
        mkdir -p "PanelBackup[Auto-Themes]"
        mv "PanelBackup[Auto-Themes].tar.gz" "PanelBackup[Auto-Themes]"
    fi
fi
}

# Download Files #
download_files() {
print "Baixando arquivos do tema..."

cd "$PTERO"
mkdir -p temp
cd temp
curl -sSLo unix.zip https://raw.githubusercontent.com/Carloz2er/autothemekk/main/unix.zip
tar -xzvf unix.zip
cd unix.zip
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
print "Produzindo painel..."
print_warning "Este processo leva alguns minutos, por favor, não o cancele."

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
echo -e "${GREEN}* O Tema ${YELLOW}Unix${GREEN} foi instalado com sucesso."
echo -e "* Backup criado."
echo -e "* Obrigado por usar o script editado"
echo -e "* Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${RESET}"
echo
print_brake 50
}

# Exec Script #
check_distro
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
    print "Painel Pterodactyl encontrado, continuando."

    compatibility
    dependencies
    backup
    download_files
    configure
    production
    bye
  elif [ "$PTERO_INSTALL" == false ]; then
    print_warning "A instalação do painel não pôde ser localizada."
    echo -e "* ${GREEN}EXAMPLE${RESET}: ${YELLOW}/var/www/mypanel${RESET}"
    echo -ne "* Digite o diretório de instalação pterodactyl manualmente: "
    read -r MANUAL_DIR
    if [ -d "$MANUAL_DIR" ]; then
        print "Diretório encontrado!"
        PTERO="$MANUAL_DIR"
        echo "$MANUAL_DIR" >> "$INFORMATIONS/custom_directory.txt"
        update_variables
        compatibility
        dependencies
        backup
        download_files
        configure
        production
        bye
      else
        print_error "O diretório que você inseriu não existe."
        find_pterodactyl
    fi
fi
