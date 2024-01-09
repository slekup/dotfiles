ln -s ~/dotfiles/.config/hypr/laptop.conf ~/.config/hypr/hyprland.conf

### Install software for Asus ROG laptops ###
echo -e "Adding Keys... \n"
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35

LOC="/etc/pacman.conf"
echo -e "Updating $LOC with g14 repo.\n"
echo -e "\n[g14]\nServer = https://arch.asus-linux.org" | sudo tee -a $LOC
echo -e "\n"
echo -e "Update the system...\n"
sudo pacman -Suy

echo -e "Installing ROG pacakges...\n"
sudo pacman -S --noconfirm asusctl supergfxctl rog-control-center
echo -e "Activating ROG services...\n"
sudo systemctl enable --now power-profiles-daemon.service
sleep 2
sudo systemctl enable --now supergfxd
sleep 2
