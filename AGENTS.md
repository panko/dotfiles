# AGENTS.md — vago home lab

Scope: OpenCode sessions started in `/var/home/prike` and its subdirectories.
Canonical copy lives in `~/dotfiles/AGENTS.md`; `~/AGENTS.md` is a symlink to it.
Edit the dotfiles copy, then commit it. Project-specific instructions belong in
that project's own `AGENTS.md`.

## Host

- `vago`: Fedora Kinoite 45 (atomic), KDE Plasma on Wayland, x86-64.
- User `prike`; home is LUKS-encrypted, ~950 GB with ~680 GB free.
- The host has no `dnf`. Do **not** layer/remove packages with `rpm-ostree`
  unless the user explicitly asks; use a toolbox instead.
- Layered host packages include: `fd-find`, `ffmpeg`, `fzf`, `gcc`, `make`,
  `mesa-va-drivers-freeworld`, `neovim`, `openh264`, `python3-pip`, `radeontop`,
  `ripgrep`, `stow`, `tailscale`, `tmux`, `zoxide`.
- Primary shell is bash; zsh is kept for macOS. Shared aliases: `~/.aliases`
  (`ll`, `gs`, `g`, `vim`→`nvim`, `dl`, …). Machine-specific settings live in
  `~/.bashrc.local` and `~/.bashrc.d/` and are not tracked.

## Keyboard (macOS-style remap)

- The keyboard is shared with a Mac through a KVM; the Linux side reproduces
  the macOS layout and shortcut feel on vago. The Mac side is untouched.
- Done with **kanata 1.12.0** (`~/.local/bin/kanata`, userspace via `/dev/uinput`),
  not xkb: plain xkb cannot make one key act as both Command and Ctrl.
  Tracked in dotfiles:
  - `.config/kanata/kanata.kbd` — the remap config
  - `.config/systemd/user/kanata.service` — enabled user service,
    `Restart=always` because the device disappears on every KVM switch
- Requires `prike` in the `input` group (`/dev/input/event*` is `root:input`
  0660 with **no** uaccess ACL): `sudo usermod -aG input prike`, then re-login.
  `/dev/uinput` itself is writable via the uaccess ACL from
  `40-kdeconnect-uinput.rules`.
- Positions: far-left `Ctrl`→Control, middle `Win`→Option/Alt, key next to
  spacebar (`Alt`)→Command, emitted as Ctrl so app shortcuts work. Right side
  mirrored (`RAlt`=Command, `RWin`=Option, `RCtrl`=Control). `Caps Lock` tap =
  Caps Lock, hold = Super (KDE Meta shortcuts).
- macOS-isms layered on top: `Cmd+Tab`→`Alt+Tab`, `Cmd+`` ` ``→`Alt+`` ` ``,
  `Cmd+Space`→`Alt+F1` (launcher), `Cmd+←/→`→`Home`/`End`, `Cmd+↑/↓`→
  `Ctrl+Home/End`, `Option+←/→`→`Ctrl+←/→` (word jump), `Option+Backspace`/
  `Option+Delete`→`Ctrl+Backspace`/`Ctrl+Delete` (word delete).
- `~/.config/kxkbrc` must **not** set xkb Alt/Ctrl options anymore — that would
  remap kanata's output a second time. It was deleted (KDE defaults: us/pc105).
- Ops: `systemctl --user status kanata`, `journalctl --user -u kanata`,
  validate edits with `kanata --check --cfg ~/.config/kanata/kanata.kbd`,
  list grabbable devices with `kanata -l`. Emergency exit is
  `LCtrl+Space+Esc` (kanata quits, keyboard reverts to stock until restarted).
- Undo: `systemctl --user disable --now kanata`.
- Earlier xkb-only attempts (superseded, kept for reference): `altwin:ctrl_win`,
  `ctrl:swap_lwin_lctl`, `ctrl:swap_lalt_lctl`.

## Ground rules

- Prefer read-only inspection first. Ask before state-changing or destructive
  operations (`podman rm/prune`, `systemctl stop/restart`, `adb uninstall`,
  `settings put`, `rpm-ostree`, `flatpak uninstall`, network/DNS changes).
- Keep the host immutable: install build/runtime tools in a toolbox.
- Never print, copy, or commit secrets. Specifically avoid:
  `~/.ssh/`, `~/.config/syncthing/config.xml` (API key),
  `~/.config/opencode/service.json`, `Projects/tuya-plug-lab/secrets/`,
  `containers/*/*.env`, `containers/qbittorrent/webui-password.txt`.
- Ignore/generated data stays out of git: `dumps/`, `.venv/`, `build-dir/`,
  `.flatpak-builder/`, caches, captures.
- Keep commits small and focused. Do not reformat unrelated files.
- Verify claims with the real command output; don't guess service state, ports,
  IPs, or versions.

## Dotfiles and OpenCode

- `~/dotfiles` is a GNU Stow package; the dotfiles in `~` are symlinks into it.
  Edit the canonical file in `~/dotfiles`, then from that directory run:
  `stow --target="$HOME" .` (dry run first: `stow -n -v .`).
- Tracked: bash/zsh, `.aliases`, tmux, LazyVim, WezTerm, kanata. `.stow-local-ignore`
  excludes README/LICENSE/git metadata.
- OpenCode config: `~/.config/opencode/` (`cli.json`, `service.json`, `skills/`).
  Skills are `~/.config/opencode/skills/<id>/SKILL.md` with frontmatter
  (`name`, `description`); supporting scripts go beside it.
- This file is the home-workspace instruction file. The global fallback is
  `~/.config/opencode/AGENTS.md`; project files go at the project root.
- Existing skill: `torrentdeck-flatpak-update`. Keep skill commands aligned with
  the current toolbox name (`adb-fold6`).

## Toolboxes

- `toolbox list` shows `adb-fold6` (renamed from `fedora-toolbox-45`) and
  `rust-toolbox`, both Fedora 45.
- `adb-fold6` holds `android-tools`/adb and the TorrentDeck Flatpak build tools.
  Run tools with `toolbox run -c adb-fold6 <cmd>`; the fold6-lab wrapper is
  `Projects/fold6-lab/scripts/adb`.
- `rust-toolbox` is for Rust work that should not touch the host.
- Do not run a second adb server on the host; the toolbox shares the host
  network namespace.

## Phone / adb

- Device: Samsung Galaxy Z Fold6 (`SM-F956B`, `q6q`), serial `RFCX71CPK4R`.
- Tailnet: `peters-z-fold6-1` = `100.127.109.115`. The old node
  `peters-z-fold6` = `100.81.8.127` is offline/stale — do not target it.
- SSH to Termux: `ssh fold` (also `ssh fold6`), port 8022, user `u0_a401`
  (Termux app UID, not root; `dumpsys`/`settings`/`am` will not work there).
- adb over Tailscale: `Projects/fold6-lab/scripts/adb-connect.sh` connects to
  `100.127.109.115:5555`. It survives Wi-Fi/mobile changes but **not a reboot**;
  after reboot run `adb tcpip 5555` once over USB.
- Android work is read-only by default. Never unlock the bootloader, flash, or
  uninstall packages without explicit confirmation. Use the fold6-lab `notes/`
  and `docs/` before changing the setup.

## Containers and user services

- Rootless Podman quadlets live in `~/.config/containers/systemd/*.container`
  plus `vago.network`; systemd generates the user units. Config/data lives in
  `~/containers/<name>/`. The quadlets themselves are tracked in dotfiles
  (`.config/containers/systemd/`) and stow-linked — edit there, then
  `stow --target="$HOME" .` from `~/dotfiles` and `systemctl --user daemon-reload`.
  `~/containers` is the separate private repo `vago-containers` (app config,
  homepage generator, timers).
- Running: `homepage` (Caddy, 127.0.0.1:8080), `gatus` (8082), `qbittorrent`
  (8081), `dozzle` (8083, `/logs`), `diun`, `beszel` (8090), `beszel-agent`.
- `dozzle` runs on 8083 with `DOZZLE_BASE=/logs` and `SecurityLabelDisable=true`
  (quadlet `label=type:disable` does not work on this host).
  `llamacpp` (tailnet :8088) and `ollama` (11434) quadlets exist but are
  inactive. `librechat*` and `zeroclaw` are disabled, so their homepage cards
  stay red (502).
- Homepage extras: `homepage-stats.timer` (30s) writes
  `~/containers/homepage/site/host.json` (CPU/mem/disk/temp/containers, plus
  the newest Beszel sample); `homepage-uptime.timer` (5min) writes
  `site/uptime.json` from Gatus' `endpoint_uptimes`. `generate.py` rebuilds
  `site/index.html` and the Caddyfile from `services.list`; reload Caddy with
  `podman exec homepage caddy reload --config /etc/caddy/Caddyfile`.
  qBittorrent's WebUI whitelists `10.89.0.0/24` (the podman bridge), so the
  homepage can read `/torrent/api/v2/*` without credentials.
- Manage via quadlets, not ad-hoc `podman run`:
  `systemctl --user status <name>`, edit the `.container`, then
  `systemctl --user daemon-reload && systemctl --user restart <name>`.
  Images carry `io.containers.autoupdate=registry`; don't prune images blindly.
- Important user services: `syncthing.service` (active), `tuya-meter-rs.service`
  (active, 127.0.0.1:8787), `tuya-meter.service` (inactive fallback).
- Phone/tailnet access is one hostname, no per-app ports:
  `https://vago.tail601dbf.ts.net/` (homepage), `/gatus`, `/meter`, `/beszel/`,
  `/torrent/` (last two proxied by the homepage Caddy). `tailscale serve --bg
  --set-path /meter http://127.0.0.1:8787` etc.; the old `:8443` qbittorrent
  mount is gone. Keep new apps on paths, not ports.
  Bitwarden autostarts via XDG autostart.

## Projects

- `Projects/fold6-lab` — Android/Fold6 lab: adb wrapper, `net-check.sh`,
  `adb-connect.sh`, baseline dumps, session notes and Syncthing/Tailscale docs.
  `dumps/` is git-ignored.
- `Projects/tuya-plug-lab` — Tuya smart-plug metering, Python + Rust.
  **SAFETY:** this plug powers the PC. Never toggle DP 1, never send OFF, never
  re-pair in Smart Life. Scripts are read-only unless explicitly told.
  `secrets/local_key` is private.
- `Projects/tft` — TFT Deck (`tftdeck`) for scrcpy mirroring, and `mactician`.
  Vendored adb/scrcpy under `Projects/tft/vendor/`; no root/system packages.
- `~/torrentdeck-flatpak` — locally built per-user Flatpak
  `io.github.pramodbutte.TorrentDeck`; use the `torrentdeck-flatpak-update`
  skill. Builder: `adb-fold6`.
- `~/dotfiles` — shell/editor/terminal config (see above).
- `~/vago` and `~/trading-bot` are currently empty/scratch.

## Network and tailnet

- Tailnet: `tail601dbf.ts.net`. `vago` = `100.121.176.29`; `fold6` =
  `100.127.109.115`; `pluto` (Raspberry Pi) = `100.77.129.83`; MacBook =
  `100.114.196.1`. `pluto` runs Syncthing in Docker; `s23` is long offline.
- Use `tailscale status` / `tailscale ping <name>` before assuming a peer is
  reachable. MagicDNS names work inside the tailnet.
- Do not expose services publicly or change ACLs/exit-node/DNS settings without
  asking. The phone's mobile-data DNS issue is a known Tailscale Android bug;
  see `Projects/fold6-lab/notes/2026-11-18-tailscale-dns.md`.

## Syncthing

- User service: `systemctl --user status syncthing`; config
  `~/.config/syncthing/config.xml`; GUI/API on `127.0.0.1:8384` (API key in the
  config — don't print it). Logs: `journalctl --user -u syncthing`.
- Folders: `erihw-rs3ab` (`pluto`) phone ↔ vago `~/Obsidian/Vault` ↔ pluto;
  `fold6-camera` receive-only phone → `~/Pictures/fold6-camera` (~40 GB).
- Peers are pinned to static `100.x` addresses; see
  `Projects/fold6-lab/docs/syncthing.md` before touching listen addresses,
  discovery, or the boot-order caveats.

## Safety and data

- Live data: `~/Obsidian/Vault` (synced notes), `~/Pictures/fold6-camera`
  (~40 GB camera backup), `~/torrents` (qBittorrent data, uid 525287),
  `~/backups/`. Never delete or bulk-move these without confirmation.
- The Syncthing config backup zip contains device keys and API credentials;
  keep it private.
- Don't run `podman system prune`, `rm -rf` on home paths, or `rpm-ostree`
  rollbacks just to "clean up".
- When in doubt, take a read-only snapshot (`dumps/`, `systemctl status`,
  `podman ps`, `journalctl`) before changing anything.

## Verification cheat-sheet

```bash
hostnamectl
rpm-ostree status --booted
toolbox list
podman ps --format '{{.Names}}\t{{.Status}}'
systemctl --user --failed
tailscale status
ssh fold 'hostname; whoami'
Projects/fold6-lab/scripts/adb-connect.sh
cd ~/dotfiles && stow -n -v .
```

For fold6-lab changes, run `scripts/net-check.sh` after network/Tailscale work
and add a dated note under `Projects/fold6-lab/notes/`.
