autoload -Uz compinit && compinit -C
# ---------- fzf-tab: Tab jadi menu interaktif + preview ----------
source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always --group-directories-first $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --icons --color=always --group-directories-first $realpath'
zstyle ':fzf-tab:complete:(cat|bat|nano|vim|code):*' fzf-preview 'bat --color=always --style=numbers --line-range=:40 $realpath 2>/dev/null || eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# ---------- Warna fzf (Ctrl+R, Tab, zi) ----------
export FZF_DEFAULT_OPTS="--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' \
--color=bg+:#1A1830,bg:-1,fg:#D6D3F5,fg+:#FFFFFF,hl:#5EEAF2,hl+:#5EEAF2 \
--color=border:#4B4580,prompt:#A99CFF,pointer:#FF4D6D,marker:#7DF9C8,info:#F2C46D,header:#A99CFF"

# ---------- Prediksi lebih pintar ----------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
