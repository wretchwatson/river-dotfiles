#!/bin/bash

# Configuration
WP_DIR="$HOME/.local/share/wallpapers"
MAKO_CONFIG="$HOME/.config/mako/config"

# Templates
WOFI_TEMPLATE="$HOME/.config/wofi/style.css.template"
WLOGOUT_TEMPLATE="$HOME/.config/wlogout/style.css.template"
WAYBAR_TEMPLATE="$HOME/.config/waybar/style.css.template"
STARSHIP_TEMPLATE="$HOME/.config/starship.toml.template"

# Real files
WOFI_CSS="$HOME/.config/wofi/style.css"
WLOGOUT_CSS="$HOME/.config/wlogout/style.css"
WAYBAR_CSS="$HOME/.config/waybar/style.css"
STARSHIP_TOML="$HOME/.config/starship.toml"

# Check if an argument is passed (from waypaper)
if [ -n "$1" ]; then
    WP_PATH="$1"
else
    # Fallback to azote if no argument is passed (Açılan pencereden duvar kağıdı seçin)
    azote
    
    # Uyarı: Azote kapandıktan sonra seçilen duvar kağıdını ~/.azotebg dosyasından alıyoruz
    if [ -f "$HOME/.azotebg" ]; then
        # Azote çift tırnak veya tek tırnakla yol kaydedebilir, ikisini de yakala
        WP_PATH=$(grep -oP '(?<=-i ")[^"]*' "$HOME/.azotebg" | head -n 1)
        if [ -z "$WP_PATH" ]; then
            WP_PATH=$(grep -oP "(?<=-i ')[^']*" "$HOME/.azotebg" | head -n 1)
        fi
        if [ -z "$WP_PATH" ]; then
            WP_PATH=$(grep -oP "(?<=-i )[^ ]*" "$HOME/.azotebg" | head -n 1)
        fi
    fi

    if [ -z "$WP_PATH" ] || [ ! -f "$WP_PATH" ]; then
        exit
    fi
fi

# Apply Wallpaper (via swaybg)
killall swaybg
swaybg -m fill -i "$WP_PATH" &

# Kalıcı olması için River init dosyasını güncelle
sed -i "s|swaybg -m fill -i .* &|swaybg -m fill -i $WP_PATH \&|g" "$HOME/.config/river/init"

# Update Pywal Colors
wal -i "$WP_PATH" -n

# Source the colors from pywal's shell file
source "$HOME/.cache/wal/colors.sh"

# -----------------------------------------------------------------------------
# DYNAMIC COLOR UPDATES (TEMPLATE SYSTEM)
# -----------------------------------------------------------------------------

# Function to copy template and replace placeholders
apply_template() {
    local template=$1
    local target=$2
    
    [ -f "$template" ] || return
    cp "$template" "$target"
    
    sed -i "s/@BACKGROUND@/$background/g" "$target"
    sed -i "s/@FOREGROUND@/$foreground/g" "$target"
    sed -i "s/@COLOR0@/$color0/g" "$target"
    sed -i "s/@COLOR1@/$color1/g" "$target"
    sed -i "s/@COLOR2@/$color2/g" "$target"
    sed -i "s/@COLOR3@/$color3/g" "$target"
    sed -i "s/@COLOR4@/$color4/g" "$target"
    sed -i "s/@COLOR5@/$color5/g" "$target"
    sed -i "s/@COLOR6@/$color6/g" "$target"
    sed -i "s/@COLOR7@/$color7/g" "$target"
    sed -i "s/@COLOR8@/$color8/g" "$target"
    sed -i "s/@COLOR9@/$color9/g" "$target"
}

# Update all CSS files from templates
apply_template "$WOFI_TEMPLATE" "$WOFI_CSS"
apply_template "$WLOGOUT_TEMPLATE" "$WLOGOUT_CSS"
apply_template "$WAYBAR_TEMPLATE" "$WAYBAR_CSS"
apply_template "$STARSHIP_TEMPLATE" "$STARSHIP_TOML"

# Update Mako specifically (Different format)
if [ -f "$MAKO_CONFIG" ]; then
    sed -i "s/^background-color=.*/background-color=${background}D9/" "$MAKO_CONFIG"
    sed -i "s/^border-color=.*/border-color=${color1}/" "$MAKO_CONFIG"
    sed -i "s/^text-color=.*/text-color=${foreground}/" "$MAKO_CONFIG"
fi

# -----------------------------------------------------------------------------
# RELOAD SERVICES
# -----------------------------------------------------------------------------

# Update River Colors dynamically (translating #RRGGBB to 0xRRGGBB)
riverctl background-color "0x${background:1}"
riverctl border-color-focused "0x${color1:1}"
riverctl border-color-unfocused "0x${color8:1}"

# Kalıcı olması için River init dosyasındaki renkleri de güncelle
sed -i "s/riverctl background-color .*/riverctl background-color 0x${background:1}/g" "$HOME/.config/river/init"
sed -i "s/riverctl border-color-focused .*/riverctl border-color-focused 0x${color1:1}/g" "$HOME/.config/river/init"
sed -i "s/riverctl border-color-unfocused .*/riverctl border-color-unfocused 0x${color8:1}/g" "$HOME/.config/river/init"

# Reload Waybar
pkill waybar
waybar &

# Reload Mako
makoctl reload || mako &

# Reload Kitty colors
pkill -USR1 kitty

# Send notification
notify-send "🖼️ Tema Yenilendi" "Yeni renkler ve duvar kağıdı başarıyla uygulandı!"
