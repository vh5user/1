#!/usr/bin/env bash
# SAINTEDLITTLE
 
set -euo pipefail
 
if [[ $EUID -eq 0 ]]; then
    echo "Не запускай через sudo/root. Запусти от обычного пользователя."
    exit 1
fi
 
USER_NAME="$USER"
HOME_DIR="$HOME"
 
if ! ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
    echo "Нет подключения к интернету."
    exit 1
fi
 
sudo pacman -Syu --noconfirm
 
sudo pacman -S --needed --noconfirm \
    base-devel git curl wget unzip zip tar nano vim neovim \
    htop btop fastfetch man-db man-pages bash-completion \
    openssh sudo \
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
    xorg-xprop xorg-xinput \
    awesome \
    lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
    networkmanager network-manager-applet \
    pipewire pipewire-alsa pipewire-pulse wireplumber \
    alsa-utils pavucontrol playerctl \
    bluez bluez-utils blueman \
    rofi picom feh flameshot xclip xdotool brightnessctl \
    acpi upower jq inotify-tools polkit-gnome lxappearance \
    thunar thunar-volman gvfs gvfs-mtp tumbler file-roller \
    kitty firefox mpv \
    noto-fonts noto-fonts-emoji ttf-dejavu ttf-liberation \
    ttf-jetbrains-mono-nerd papirus-icon-theme
 
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable sshd
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target
 
if ! command -v paru >/dev/null 2>&1; then
    TMPDIR_PARU="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$TMPDIR_PARU/paru"
    cd "$TMPDIR_PARU/paru"
    makepkg -si --noconfirm
    cd "$HOME_DIR"
    rm -rf "$TMPDIR_PARU"
fi
 
paru -S --needed --noconfirm picom-git mpdris2 || true
 
mkdir -p "$HOME_DIR/.config"
 
if [[ -d "$HOME_DIR/.config/awesome" ]]; then
    mv "$HOME_DIR/.config/awesome" \
       "$HOME_DIR/.config/awesome.backup.$(date +%s)"
fi
 
YORU_DIR="$HOME_DIR/.local/src/yoru"
 
mkdir -p "$HOME_DIR/.local/src"
rm -rf "$YORU_DIR"
 
git clone \
    --depth 1 \
    --recurse-submodules \
    https://github.com/raexera/yoru.git \
    "$YORU_DIR"
 
cd "$YORU_DIR"
git submodule update --init --recursive
 
cp -r config/* "$HOME_DIR/.config/"
 
mkdir -p "$HOME_DIR/.local/share/fonts"
 
if [[ -d "$YORU_DIR/misc/fonts" ]]; then
    cp -r "$YORU_DIR/misc/fonts/"* \
        "$HOME_DIR/.local/share/fonts/" || true
fi
 
fc-cache -fv
 
mkdir -p "$HOME_DIR/.config/autostart"
mkdir -p "$HOME_DIR/.config/awesome"
 
sudo chown -R "$USER_NAME:$USER_NAME" \
    "$HOME_DIR/.config" \
    "$HOME_DIR/.local"
 
echo
echo "SAINTEDLITTLE"
echo "Installation complete."
echo "Reboot with: sudo reboot"
