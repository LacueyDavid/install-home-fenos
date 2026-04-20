#!/usr/bin/env bash

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

term_alpha=100 #Set this to < 100 make all your terminals transparent
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$STATE_DIR"/user/generated ]; then
  mkdir -p "$STATE_DIR"/user/generated
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

colornames=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f1)
colorstrings=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
IFS=$'\n'
colorlist=($colornames)     # Array of color names
colorvalues=($colorstrings) # Array of color values

apply_term() {
  # Check if terminal escape sequence template exists
  if [ ! -f "$SCRIPT_DIR/terminal/sequences.txt" ]; then
    echo "Template file not found for Terminal. Skipping that."
    return
  fi
  # Copy template
  mkdir -p "$STATE_DIR"/user/generated/terminal
  cp "$SCRIPT_DIR/terminal/sequences.txt" "$STATE_DIR"/user/generated/terminal/sequences.txt
  # Apply colors
  for i in "${!colorlist[@]}"; do
    sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$STATE_DIR"/user/generated/terminal/sequences.txt
  done

  sed -i "s/\$alpha/$term_alpha/g" "$STATE_DIR/user/generated/terminal/sequences.txt"

  for file in /dev/pts/*; do
    if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
      {
      cat "$STATE_DIR"/user/generated/terminal/sequences.txt >"$file"
      } & disown || true
    fi
  done
}

apply_qt() {
  sh "$CONFIG_DIR/scripts/kvantum/materialQT.sh"          # generate kvantum theme
  python "$CONFIG_DIR/scripts/kvantum/changeAdwColors.py" # apply config colors
  apply_kde_colorscheme
}

get_material_color() {
  local key="$1"
  awk -F': ' -v lookup="$key" '
    $1 == "$" lookup {
      gsub(/;/, "", $2)
      print $2
      exit
    }
  ' "$STATE_DIR/user/generated/material_colors.scss"
}

apply_kde_colorscheme() {
  local scheme_dir="$HOME/.local/share/color-schemes"
  local scheme_file="$scheme_dir/MaterialAdw.colors"
  local kdeglobals_file="$HOME/.config/kdeglobals"

  mkdir -p "$scheme_dir"
  mkdir -p "$(dirname "$kdeglobals_file")"

  local bg fg surf surf_hi surf_lo primary primary_cont onprimary_cont
  local secondary secondary_cont onsecondary_cont outline err onerr
  bg="$(get_material_color background)"
  fg="$(get_material_color onBackground)"
  surf="$(get_material_color surfaceContainer)"
  surf_hi="$(get_material_color surfaceContainerHigh)"
  surf_lo="$(get_material_color surfaceContainerLow)"
  primary="$(get_material_color primary)"
  primary_cont="$(get_material_color primaryContainer)"
  onprimary_cont="$(get_material_color onPrimaryContainer)"
  secondary="$(get_material_color secondary)"
  secondary_cont="$(get_material_color secondaryContainer)"
  onsecondary_cont="$(get_material_color onSecondaryContainer)"
  outline="$(get_material_color outline)"
  err="$(get_material_color error)"
  onerr="$(get_material_color onError)"

  # Skip if generated palette is not ready yet.
  if [ -z "$bg" ] || [ -z "$fg" ] || [ -z "$primary" ]; then
    echo "Material colors are incomplete. Skipping KDE colorscheme generation."
    return
  fi

  cat > "$scheme_file" <<EOF
[General]
Name=MaterialAdw

[KDE]
contrast=4

[WM]
activeBackground=${primary_cont}
activeForeground=${onprimary_cont}
inactiveBackground=${surf_hi}
inactiveForeground=${fg}

[Colors:Window]
BackgroundNormal=${bg}
BackgroundAlternate=${surf_lo}
ForegroundNormal=${fg}
ForegroundInactive=${outline}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:View]
BackgroundNormal=${bg}
BackgroundAlternate=${surf}
ForegroundNormal=${fg}
ForegroundInactive=${outline}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:Button]
BackgroundNormal=${surf}
BackgroundAlternate=${surf_hi}
ForegroundNormal=${fg}
ForegroundInactive=${outline}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:Selection]
BackgroundNormal=${primary_cont}
BackgroundAlternate=${secondary_cont}
ForegroundNormal=${onprimary_cont}
ForegroundInactive=${onsecondary_cont}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:Tooltip]
BackgroundNormal=${surf_hi}
BackgroundAlternate=${surf}
ForegroundNormal=${fg}
ForegroundInactive=${outline}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:Complementary]
BackgroundNormal=${surf_hi}
BackgroundAlternate=${surf}
ForegroundNormal=${fg}
ForegroundInactive=${outline}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:Header]
BackgroundNormal=${surf_hi}
BackgroundAlternate=${surf}
ForegroundNormal=${fg}
ForegroundInactive=${outline}
DecorationFocus=${primary}
DecorationHover=${secondary}

[Colors:Negative]
BackgroundNormal=${err}
BackgroundAlternate=${err}
ForegroundNormal=${onerr}
ForegroundInactive=${onerr}
DecorationFocus=${err}
DecorationHover=${err}
EOF

  cat > "$kdeglobals_file" <<EOF
[KDE]
widgetStyle=kvantum

[General]
ColorScheme=MaterialAdw
Name=MaterialAdw
shadeSortColumn=true

[Icons]
Theme=OneUI-dark
EOF
}

# Check if terminal theming is enabled in config
CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
if [ -f "$CONFIG_FILE" ]; then
  enable_terminal=$(jq -r '.appearance.wallpaperTheming.enableTerminal' "$CONFIG_FILE")
  enable_qt_apps=$(jq -r '.appearance.wallpaperTheming.enableQtApps' "$CONFIG_FILE")
  if [ "$enable_terminal" = "true" ]; then
    apply_term &
  fi
  if [ "$enable_qt_apps" = "true" ]; then
    apply_qt &
  fi
else
  echo "Config file not found at $CONFIG_FILE. Applying terminal theming by default."
  apply_term &
  apply_qt &
fi
