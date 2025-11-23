#!/bin/bash

# Define paths
THEME_DIR="$HOME/.config/themes"
WALL_BASE="$HOME/Pictures/base.jpg"
WALL_OUT="$HOME/Pictures/wallpaper.png"

# 1. List themes (folders in your theme dir)
# We pipe them into rofi
get_themes() {
  ls -1 "$THEME_DIR"
}

# 2. Select theme
CHOSEN=$(get_themes | rofi -dmenu -p "Select Theme")

# If nothing selected, exit
if [[ -z "$CHOSEN" ]]; then
  exit 0
fi

# 3. The Switching Logic
apply_theme() {
  TARGET="$THEME_DIR/$CHOSEN"

  # --- DUNST ---
  ln -sf "$TARGET/dunstrc" "$HOME/.config/dunst/dunstrc"
  killall dunst

  # --- Wallpaper ---
  notify-send "Generating wallpaper for $CHOSEN..."
  if [[ -f "$TARGET/palette.json" ]]; then
    dipc "$TARGET/palette.json" "$WALL_BASE" --output "$WALL_OUT" --method de1976
  else
    dipc "$CHOSEN" "$WALL_BASE" --output "$WALL_OUT" --method de1976
  fi
  hyprctl hyprpaper unload all
  hyprctl hyprpaper preload "$WALL_OUT"
  for monitor in $(hyprctl monitors | grep "Monitor" | awk '{print $2}'); do
    hyprctl hyprpaper wallpaper "$monitor,$WALL_OUT"
  done

  # --- Neovim ---
  ln -sf "$TARGET/nvim.lua" "$HOME/.config/nvim/lua/current_theme.lua"

  # --- Kitty ---
  ln -sf "$TARGET/kitty.conf" "$HOME/.config/kitty/current-theme.conf"
  kill -SIGUSR1 $(pidof kitty)

  # --- Waybar ---
  ln -sf "$TARGET/waybar.css" "$HOME/.config/waybar/current-theme.css"
  pkill waybar && hyprctl dispatch exec waybar

  # --- Rofi ---
  ln -sf "$TARGET/theme.rasi" "$HOME/.config/rofi/theme.rasi"

  # --- GTK ---
  GTK_FILE="$TARGET/gtk.txt"
  GTK_THEME=$(cat "$GTK_FILE")
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  export GTK_THEME="$GTK_THEME"

  # --- Yazi ---
  ln -sf "$TARGET/yazi.toml" "$HOME/.config/yazi/theme.toml"

  # --- btop ---
  mkdir -p "$HOME/.config/btop/themes"
  ln -sf "$TARGET/btop.theme" "$HOME/.config/btop/themes/current.theme"

  # Notification
  notify-send "Theme Changed" "Active theme: $CHOSEN"
}

apply_theme
