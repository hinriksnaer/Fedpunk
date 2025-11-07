#!/bin/bash

# Set install mode to online since boot.sh is used for curl installations
export FEDPUNK_ONLINE_INSTALL=true

ansi_art='
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
'

clear
echo -e "\n$ansi_art\n"

sudo dnf install -y git

# Use custom repo if specified, otherwise default to your repo
FEDPUNK_REPO="${FEDPUNK_REPO:-hinriksnaer/Fedpunk}"

echo -e "\nCloning Fedpunk from: https://github.com/${FEDPUNK_REPO}.git"
rm -rf ~/.local/share/fedpunk/
git clone "https://github.com/${FEDPUNK_REPO}.git" ~/.local/share/fedpunk

# Use custom branch if instructed, otherwise default to main
FEDPUNK_REF="${FEDPUNK_REF:-main}"
if [[ $FEDPUNK_REF != "main" ]]; then
  echo -e "\e[32mUsing branch: $FEDPUNK_REF\e[0m"
  cd ~/.local/share/fedpunk
  git fetch origin "${FEDPUNK_REF}" && git checkout "${FEDPUNK_REF}"
  cd -
fi

echo -e "\nInstallation starting..."
source ~/.local/share/fedpunk/install.sh
