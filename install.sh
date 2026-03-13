#!/bin/bash

# Renk tanımlamaları
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- River Dotfiles Kurulum Scripti Başlatılıyor ---${NC}"

# Scriptin bulunduğu dizini al
DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# 1. Native Paketleri Yükle (pacman)
echo -e "\n${CYAN}[1/5] Native paketler yükleniyor...${NC}"
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
    sudo pacman -S --needed - < "$DOTFILES_DIR/pkglist.txt"
else
    echo -e "${RED}Hata: pkglist.txt bulunamadı!${NC}"
fi

# 2. Paru (AUR Helper) Kurulumu
echo -e "\n${CYAN}[2/5] Paru kontrol ediliyor...${NC}"
if ! command -v paru &> /dev/null; then
    echo -e "${CYAN}Paru bulunamadı, kuruluyor...${NC}"
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
else
    echo -e "${GREEN}Paru zaten yüklü.${NC}"
fi

# 3. AUR Paketlerini Yükle (paru)
echo -e "\n${CYAN}[3/5] AUR paketleri yükleniyor...${NC}"
if [ -f "$DOTFILES_DIR/aur-pkglist.txt" ]; then
    paru -S --needed - < "$DOTFILES_DIR/aur-pkglist.txt"
else
    echo -e "${RED}Hata: aur-pkglist.txt bulunamadı!${NC}"
fi

# 4. Config Dosyalarını Kopyala
echo -e "\n${CYAN}[4/5] Yapılandırma dosyaları kopyalanıyor...${NC}"

# .config klasörü
mkdir -p ~/.config
if [ -d "$DOTFILES_DIR/config" ]; then
    cp -rv "$DOTFILES_DIR/config"/* ~/.config/
    echo -e "${GREEN}Config dosyaları ~/.config altına kopyalandı.${NC}"
fi

# .local/share klasörü (Wallpapers vb.)
mkdir -p ~/.local/share
if [ -d "$DOTFILES_DIR/local/share" ]; then
    cp -rv "$DOTFILES_DIR/local/share"/* ~/.local/share/
    echo -e "${GREEN}Local share dosyaları kopyalandı.${NC}"
fi

# .icons klasörü
mkdir -p ~/.icons
if [ -d "$DOTFILES_DIR/icons" ]; then
    cp -rv "$DOTFILES_DIR/icons"/* ~/.icons/
    echo -e "${GREEN}İkonlar kopyalandı.${NC}"
fi

# .bashrc
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    cp -v "$DOTFILES_DIR/.bashrc" ~/
    echo -e "${GREEN}.bashrc kopyalandı.${NC}"
fi

# 4.1 Sistem Dosyaları (sudo yetkisi gerekir)
echo -e "\n${CYAN}[4.1/5] Sistem yapılandırmaları kopyalanıyor...${NC}"
if [ -d "$DOTFILES_DIR/system" ]; then
    echo -e "${CYAN}Sistem dosyaları için sudo yetkisi istenebilir...${NC}"
    sudo mkdir -p /etc/systemd/coredump.conf.d/
    if [ -f "$DOTFILES_DIR/system/etc/systemd/coredump.conf.d/99-antigravity.conf" ]; then
        sudo cp -v "$DOTFILES_DIR/system/etc/systemd/coredump.conf.d/99-antigravity.conf" /etc/systemd/coredump.conf.d/
        echo -e "${GREEN}Coredump yapılandırması /etc altına kopyalandı.${NC}"
    fi
fi

# 5. Son Ayarlar
echo -e "\n${CYAN}[5/5] Son dokunuşlar...${NC}"
# Fish shell default yapma (isteğe bağlı)
if command -v fish &> /dev/null; then
    echo -e "${CYAN}Fish shell varsayılan yapılıyor...${NC}"
    chsh -s $(which fish)
fi

echo -e "\n${GREEN}--- Kurulum Başarıyla Tamamlandı! ---${NC}"
echo -e "River dünyasına hoş geldin fıstık. Sistemi yeniden başlatman veya çıkış yapıp girmen gerekebilir."
