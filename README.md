# dotfiles

Cross-platform dotfiles: bash (primary on Linux), zsh (kept for macOS), tmux,
Neovim (LazyVim) and WezTerm.

## What's here

| Path | What it configures |
|---|---|
| `.bashrc`, `.bash_profile` | bash: history, fzf, zoxide, completion, git prompt |
| `.zshrc`, `.zprofile` | zsh + zinit + powerlevel10k (macOS) |
| `.aliases` | aliases shared by both shells |
| `.config/tmux/tmux.conf` | tmux: `C-Space` prefix, vim pane nav, catppuccin, TPM |
| `.config/nvim` | LazyVim, pinned by `lazy-lock.json` |
| `.config/nvim/lua/plugins/lang.lua` | Python LSP via jedi + ruff (no npm) |
| `.wezterm.lua` | WezTerm |

## Install on Fedora Kinoite / Silverblue

Atomic desktops have no `dnf` on the host, so layer the packages:

```bash
sudo rpm-ostree install tmux neovim fzf zoxide ripgrep fd-find stow gcc make unzip python3-pip
systemctl reboot
```

`gcc`/`make` are needed by nvim-treesitter, `python3-pip` lets mason create the
jedi venv, `unzip` is used by mason installers.

Clone and deploy:

```bash
git clone git@github.com:panko/dotfiles.git ~/dotfiles
cd ~/dotfiles
mv ~/.bashrc ~/.bashrc.pre-dotfiles          # back up whatever stow would overwrite
mv ~/.bash_profile ~/.bash_profile.pre-dotfiles
stow --target="$HOME" .
```

Notes:

- Run `stow` from inside the repo. `stow -d ~ -t ~ dotfiles` fails because the
  package would be its own target.
- `~/.config` is a real directory full of KDE configs; stow descends into it and
  links only `nvim/` and `tmux/`.

## Per-machine settings

Host-specific config is not tracked. Put it in `~/.bashrc.local` (sourced by
`.bashrc` if present) or `~/.bashrc.d/*`:

```bash
export PATH="$HOME/.opencode/bin:$PATH"
```

## First launch

- Neovim installs ~43 plugins plus the mason tools on first start; `:Lazy sync`
  re-runs it. Python gets jedi-language-server + ruff.
- tmux plugins live in `~/.tmux/plugins` (pinned in `tmux.conf`, because TPM 3.x
  otherwise defaults to `~/.config/tmux/plugins`, i.e. inside this repo). Install
  them with `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
  then `prefix + I`.
- Terminal needs JetBrainsMono Nerd Font for the icons (Konsole profile:
  `Dotfiles.profile`, WezTerm: set in `.wezterm.lua`).
- The Python setup deliberately avoids npm/node and a Go toolchain: `pyright`,
  `jsonls` and `gopls` are not used, ruff handles lint/format.

## macOS / zsh

The zsh config is kept for macOS (oh-my-zsh snippets, zinit, powerlevel10k) and
is not used on Fedora.

## Extras

### GNOME Terminal catppuccin colour

```bash
curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v1.0.0/install.py | python3 -
```
