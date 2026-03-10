# ─────────────────────────────────────────────
# Starship zsh integration
# Add this block to ~/.zshrc (or source it from ~/.dotfiles)
# ─────────────────────────────────────────────

# ── Install check ─────────────────────────────
if ! command -v starship >/dev/null 2>&1; then
  echo "[WARN] starship not found. Install with: curl -sS https://starship.rs/install.sh | sh"
else

  # ── Config location ───────────────────────────
  export STARSHIP_CONFIG="$HOME/.config/starship.toml"
  export STARSHIP_CACHE="$HOME/.cache/starship"

  # ── Init ──────────────────────────────────────
  eval "$(starship init zsh)"

  # ── Transient prompt (clean history lines) ────
  # Replaces the full multi-line prompt with a minimal one after command runs.
  # Requires: starship >= 1.0 and zsh-vi-mode or manual setup below.
  #
  # Enable if you want clean scrollback history:
  # eval "$(starship init zsh --print-full-init)"

fi

# ── Vi mode + starship character sync ─────────
# Keeps starship's vimcmd_symbol in sync with zsh vi mode (optional)
# Uncomment if you use vi keybindings (bindkey -v in .zshrc)
#
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]]; then
#     STARSHIP_SHELL_AESTHETIC=vicmd
#   else
#     STARSHIP_SHELL_AESTHETIC=""
#   fi
#   zle reset-prompt
# }
# zle -N zle-keymap-select
