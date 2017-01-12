bindkey "^K"      kill-whole-line

bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "\e[3~" delete-char

bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^T' history-incremental-search-backward

# Jumping with ctrl+arrows
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
