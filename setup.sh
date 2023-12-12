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

# Sync package databasde
echo -e "\n${INFO}Updating package database..."
sudo pacman -Syu || echo -e "${FAIL}Failed to update package database"
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
      sudo pacman -S --no-confirm --needed "$package" || echo -e "${FAIL}Failed to install repo packages"
  fi
done < ./lists/pkg
echo -e "${DONE}Installed repo packages successfully"

echo -e "${INFO}Registering fonts..."
fc-cache -f -v || echo -e "${FAIL}Failed to register fonts"
echo -e "${DONE}Registered fonts successfully"

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
      paru -S --no-confirm -needed $package || echo -e "${FAIL}Failed to install AUR packages"
  fi
done < ./lists/pkg_aur
echo -e "${DONE}Install AUR packages successfully"

echo -e "${INFO}Installing Xtreme Download Manager..."
function download_xdm() {
  mkdir xdm && cd xdm
  wget https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz
  tar -xvf xdm-setup-7.2.11.tar.xz
  sudo sh install.sh
  cd ../ && sudo rm -rf xdm
}
download_xdm || echo -e "${FAIL}Failed to install Xtreme Download Mananger"
echo -e "${DONE}Successfully installed Xtreme Download Manager"

# Start the bluetooth service
echo -e "\n${INFO}Starting the Bluetooth Service..."
sudo systemctl enable --now bluetooth.service || echo -e "${FAIL}Failed to start bluetooth service"
echo -e "${DONE}Bluetooth service started successfully"

# Clean out other portals
echo -e "\n${INFO}Cleaning out conflicting xdg portals..."
yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk || echo -e "${FAIL}Failed to clean out conflicting xdg portals"
echo -e "${DONE}Cleaned out conflicting xdg portals successfully"

# Setup ZSH
echo -e "${INFO}Setting up ZSH..."
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
echo -e "${DONE}Set up ZSH successfully"

# Change shell for root
echo -e "${INFO}Setting shell to ZSH..."
sudo chsh -s $(which zsh) || echo -e "${FAIL}Failed to set shell to ZSH"
echo -e "${DONE}Set shell to ZSH successfully"

# Symlink configurations
echo -e "${INFO}Symlinking configurations with stow..."
stow .
echo -e "${DONE}Symlinked configurations successfully"
