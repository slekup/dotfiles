#!/bin/bash

# ANSI color codes
export BOLD='\033[1m'
export RESET='\033[0m' # No color or formatting
export RED='\033[0;31m'
export YELLOW='\033[0;33m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'

export INFO="${BLUE}INFO${RESET} "
export DONE="${GREEN}DONE${RESET} "
export FAIL="${RED}FAIL${RESET} "

# Enable the "exit on error" option, so that if any command fails, the script will exit
set -e

# Sync package database
echo -e "\n${INFO}Updating package database..."
sudo pacman -Syu --noconfirm --needed || { echo -e "${FAIL}Failed to update package database"; exit 1; }
echo -e "${DONE}Package database updated successfully"

# Install packages with pacman
echo -e "\n${INFO}Installing repo packages"
while IFS= read -r line; do
  # Skip empty lines or lines starting with #
  if [[ -n $line && ! $line =~ ^\ *# ]]; then
      # Extract package name and comment
      package=$(echo "$line" | cut -d"#" -f1 | xargs)
      comment=$(echo "$line" | cut -d"#" -f2- | xargs)
      
      # Install the package
      echo "Installing $package - $comment"
      sudo pacman -S --noconfirm --needed "$package" || { echo -e "${FAIL}Failed to install repo packages"; exit 1; }
  fi
done < ./lists/pkg
echo -e "${DONE}Installed repo packages successfully"

echo -e "${INFO}Registering fonts..."
fc-cache -f -v || { echo -e "${FAIL}Failed to register fonts"; exit 1; }
echo -e "${DONE}Registered fonts successfully"

echo -e "${INFO}Installing paru - AUR helper"
function install_paru() {
  git clone https://aur.archlinux.org/packages/paru-bin paru
  cd paru
  makepkg -sri --noconfirm --needed
  cd ..
}
install_paru || { echo -e "${FAIL}Failed to install paru"; exit 1; }
echo -e "${DONE}Installed paru successfully"

# Install packages from the AUR
echo -e "\n${INFO}Installing AUR packages..."
while IFS= read -r line; do
  # Skip empty lines or lines starting with #
  if [[ -n $line && ! $line =~ ^\ *# ]]; then
      # Extract package name and comment
      package=$(echo "$line" | cut -d"#" -f1 | xargs)
      comment=$(echo "$line" | cut -d"#" -f2- | xargs)
      
      # Install the package
      echo "Installing $package - $comment"
      # paru -S --noconfirm -needed $package || { echo -e "${FAIL}Failed to install AUR packages"; exit 1; }
  fi
done < ./lists/pkg_aur
echo -e "${DONE}Install AUR packages successfully"

echo -e "${INFO}Installing Xtreme Download Manager..."
function download_xdm() {
  mkdir xdm && cd xdm
  wget https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz
  tar -xvf xdm-setup-7.2.11.tar.xz
  chmod +x install.sh && ./install.sh
  cd ../ && sudo rm -rf xdm
}
download_xdm || { echo -e "${FAIL}Failed to install Xtreme Download Mananger"; exit 1; }
echo -e "${DONE}Successfully installed Xtreme Download Manager"

# Start the bluetooth service
echo -e "\n${INFO}Starting the Bluetooth Service..."
sudo systemctl enable --now bluetooth.service || { echo -e "${FAIL}Failed to start bluetooth service"; exit 1; }
echo -e "${DONE}Bluetooth service started successfully"

# Clean out other portals
echo -e "\n${INFO}Cleaning out conflicting xdg portals..."
paru -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk || true # Don't exit script if fail
echo -e "${DONE}Cleaned out conflicting xdg portals successfully"

# Setup ZSH
echo -e "${INFO}Setting up ZSH..."
function setup_zsh() {
  mkdir -p ~/.zsh
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh/zsh-history-substring-search
}
setup_zsh || { echo -e "${FAIL}Failed to setup zsh"; exit 1; }
echo -e "${DONE}Setup ZSH successfully"

# Setup vifm
echo -e "${INFO}Setting up vifm..."
function setup_vifm() {
  mkdir -p ~/.config/vifm
  git clone https://github.com/thimc/vifm_devicons ~/.config/vifm/vifm_devicons
}
setup_vifm || { echo -e "${FAIL}Failed to setup vifm"; exit 1; }
echo -e "${DONE}Setup vifm successfully"

# Change shell for root
echo -e "${INFO}Setting shell to ZSH..."
sudo chsh -s $(which zsh) || { echo -e "${FAIL}Failed to set shell to ZSH"; exit 1; }
echo -e "${DONE}Set shell to ZSH successfully"

# Symlink configurations
echo -e "${INFO}Symlinking configurations with stow..."
function links() {
  sudo ln -s ~/dotfiles/sddm.conf /etc/sddm.conf
  stow . 
}
links || { echo -e "${FAIL}Failed to symlink configurations";exit 1; }
echo -e "${DONE}Symlinked configurations successfully"

# Enabling services
echo -e "${DONE} Enabling services..."
function enable_services() {
  sudo systemctl enable vnstat
  sudo systemctl start vnstat
}
enable_services || { echo -e "${FAIL}Failed to enable services"; exit 1 }
echo -e "${DONE}Enabled services successfully"

# Enable sddm login manager
echo -e "${INFO}Enabling sddm..."
sudo systemctl enable sddm || { echo -e "${FAIL}Failed to enable sddm"; exit 1; }
echo -e "${DONE}Enabled sddm successfully"
