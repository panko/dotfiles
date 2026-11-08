# ~/.bashrc — bash port of the zsh setup (no zsh/zinit/p10k required)

# --- global definitions -----------------------------------------------------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# --- user paths -------------------------------------------------------------
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) PATH="$PATH:$HOME/bin" ;;
esac
export PATH

# --- history ----------------------------------------------------------------
HISTSIZE=5000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:ll:la:clear:cd:..:...:....:h'
shopt -s histappend
# append immediately so parallel shells share history (zsh sharehistory)
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- options ----------------------------------------------------------------
set -o emacs
shopt -s checkwinsize

# --- keybindings ------------------------------------------------------------
bind '"\C-p": history-search-backward' 2>/dev/null
bind '"\C-n": history-search-forward' 2>/dev/null
bind '"\ew": kill-region' 2>/dev/null

# --- completion -------------------------------------------------------------
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    fi
fi
# let `sudo <TAB>` complete commands
complete -cf sudo 2>/dev/null

# --- prompt -----------------------------------------------------------------
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    . /usr/share/git-core/contrib/completion/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM=auto
    PS1='\[\e[38;5;110m\]\u@\h\[\e[0m\] \[\e[38;5;180m\]\w\[\e[38;5;150m\]$(__git_ps1 " (%s)")\[\e[0m\]\n\[\e[38;5;114m\]\$\[\e[0m\] '
else
    PS1='\[\e[38;5;110m\]\u@\h\[\e[0m\] \[\e[38;5;180m\]\w\[\e[0m\]\n\[\e[38;5;114m\]\$\[\e[0m\] '
fi

# --- tools ------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    eval "$(fzf --bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# --- optional tool completions (only if the tool is installed) --------------
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion bash)
fi
if command -v aws_completer >/dev/null 2>&1; then
    complete -C "$(command -v aws_completer)" aws
fi

# --- aliases ----------------------------------------------------------------
if [ -f "$HOME/.aliases" ]; then
    . "$HOME/.aliases"
fi

# --- per-machine overrides (not tracked in the repo) ------------------------
if [ -d "$HOME/.bashrc.d" ]; then
    for rc in "$HOME"/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
    unset rc
fi
for rc in "$HOME/.bashrc.local"; do
    [ -f "$rc" ] && . "$rc"
    unset rc
done
