# NixOS Config — Claude Working Instructions

## Self-Improvement Rule
**Whenever a bug takes more than one exchange to resolve, Claude MUST add it to
the "Known Pitfalls" section before ending the session.** Format:
```
### [Short title]
**Symptom**: exact error message or behavior
**Cause**: why it happens
**Fix**: exact command or change
```
This file is the long-term memory of this repository. Keep it accurate and concise.

---

## Repository Structure
```
/etc/nixos/
├── flake.nix                       # Inputs: nixpkgs (unstable), home-manager, nixvim
├── hosts/
│   ├── default/configuration.nix   # Base: hardware, LUKS+LVM boot, services
│   └── pc/configuration.nix        # Profile: autoUpgrade, machine-specific
├── home/seth/
│   ├── home.nix                    # Entry point: imports all modules + CLAUDE.md deploy
│   └── modules/
│       ├── base.nix                # Packages, zsh, git, secrets sourcing
│       ├── desktop.nix             # Wayland/Hyprland desktop services
│       ├── kitty.nix               # Terminal emulator
│       ├── nixvim.nix              # Neovim (nixvim), codecompanion, Claude CLI, LSP, cmp
│       └── hypr/                   # Hyprland compositor config
└── modules/illogical-impulse/      # External: quickshell UI shell (WaffleFamily / ii)
```

## Rebuild Commands
```bash
switch                              # nixos-rebuild switch --flake /etc/nixos#pc
nrt                                 # nixos-rebuild test  --flake /etc/nixos#pc  (no bootloader)
nix flake check --no-build          # Validate Nix syntax (fast, run this first)
sudo nixos-rebuild switch --show-trace  # Full stack trace for deep errors
```
**Always prefer `nrt` before `switch`** — it's reversible, doesn't touch the bootloader.

## Key Conventions
- **Secrets**: never in the Nix store. API keys go in `~/.secrets/*.env` (chmod 600),
  sourced by zsh `initContent`. Pattern: `[[ -f ~/.secrets/foo.env ]] && source ~/.secrets/foo.env`
- **Unfree packages**: allowed globally (`nixpkgs.config.allowUnfree = true`).
- **nixvim**: Neovim is configured declaratively. Raw Lua goes in `extraConfigLua`.
  home-manager is NixOS-integrated (not standalone) — changes to `home/seth/` need a full `switch`.
- **autoUpgrade**: the `pc` host auto-upgrades daily 03–05h.
  Check `journalctl -u nixos-upgrade.service` after any unexpected system change.
- **Claude tools in Neovim**: codecompanion (`<leader>cc`) + Claude Code CLI (`<leader>cl`).
  Model: `claude-opus-4-5`. Key loaded from `~/.secrets/anthropic.env`.

## Hardware Context (pc host)
- Boot: systemd-boot + LUKS full disk encryption (LVM: crypted--vg-{root,home,swap})
- Display: Wayland-only (no Xorg), Hyprland compositor
- Login: greetd + tuigreet → `start-hyprland` script
- Locale: `fr_FR.UTF-8`, timezone `Europe/Paris`

## Debugging Workflow
1. `nix flake check --no-build` — catches syntax before slow evaluation
2. `nrt` — test mode, no bootloader write, safe to iterate
3. `sudo nixos-rebuild switch --show-trace` — full trace for attribute errors
4. `journalctl -b -p err` — boot-time errors
5. `systemctl --failed` — failed services
6. `sudo nixos-rebuild switch --rollback` — revert to previous generation

## What Claude Must NOT Do
- Never put API keys or secrets in any `.nix` file (world-readable via /nix/store)
- Never run `nix-collect-garbage -d` (destroys all rollback generations)
- Never `git push` without explicit confirmation
- Never use `--impure` without explaining the trade-off

---

## Known Pitfalls

### Lua empty-string comparison inside Nix heredoc
**Symptom**: `syntax error, unexpected THEN` pointing at a `~=` in extraConfigLua
**Cause**: `~= ''` — Nix interprets `''` as the end of the `''...''` string literal
**Fix**: use `~= '''` (the Nix escape sequence for a literal `''`)

### `$$` in writeShellScript breaks regex extraction
**Symptom**: pattern variable is empty or equals the shell PID
**Cause**: `$$` expands to the current process PID in double-quoted shell strings
**Fix**: assign the pattern to a named variable first, then reference it as `$pattern`

### nmcli status fails on non-English locale (quickshell Network.qml)
**Symptom**: network widget always shows disconnected
**Cause**: nmcli outputs state strings in the system locale, not English
**Fix**: set `LANG=C LC_ALL=C` on the nmcli subprocess inside the QML service

### home-manager backup conflict blocks rebuild
**Symptom**: rebuild fails with "would be overwritten by home-manager"
**Cause**: a file managed by home-manager already exists outside of it
**Fix**: `find ~ -name "*.hm-backup"` to locate conflicts; remove or reconcile them.
  The flake sets `backupFileExtension = "hm-backup"` so collisions are visible.
