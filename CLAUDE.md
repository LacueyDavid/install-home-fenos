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

See `ARCHITECTURE.md` at the repo root for the full layout and the reasoning.
Short version:

```
/etc/nixos/
├── flake.nix                 # Inputs + three outputs: pc / vm / default
├── hosts/                    # One .nix per host — composes system modules
├── modules/
│   ├── system/               # NixOS modules (boot, network, audio, desktop, ...)
│   ├── home/                 # Home-manager modules (shell, editor, hyprland, ...)
│   └── illogical-impulse/    # Vendored third-party HM module (patched upstream dots)
├── home/                     # Home-manager entry per user (seth.nix, root.nix)
└── dotfiles/                 # Raw .conf / .qml files (consumed by home-manager)
```

Rule of thumb:
- `.nix` files describe *configuration* and live under `modules/` or `hosts/`.
- Non-Nix configs (Hyprland .conf, Quickshell QML, scripts) live under `dotfiles/`.
- `modules/` is composable (each file a single concern); `hosts/` picks a combo.

## Rebuild Commands
```bash
fss                                     # fenos_switch → nixos-rebuild switch --flake /etc/nixos#pc
fst                                     # fenos_test   → nixos-rebuild test   --flake /etc/nixos#pc
nix flake check --no-build              # Validate Nix syntax (fast, run this first)
sudo nixos-rebuild switch --show-trace  # Full stack trace for deep errors
```
**Always prefer `fst` before `fss`** — test mode is reversible, doesn't touch the bootloader.

## Key Conventions
- **Secrets**: never in the Nix store. API keys go in `~/.secrets/*.env` (chmod 600),
  sourced by zsh `initContent`. Pattern: `[[ -f ~/.secrets/foo.env ]] && source ~/.secrets/foo.env`
- **Unfree packages**: allowed globally (`nixpkgs.config.allowUnfree = true`).
- **nixvim**: Neovim is configured declaratively. Raw Lua goes in `extraConfigLua`.
  home-manager is NixOS-integrated (not standalone) — changes to `modules/home/` need a full `fss`.
- **autoUpgrade**: the `pc` host auto-upgrades daily 03–05h.
  Check `journalctl -u nixos-upgrade.service` after any unexpected system change.
- **Dotfile overrides vs upstream**: illogical-impulse ships a config bundle; we
  override individual files in `modules/home/hyprland.nix` + `modules/home/quickshell.nix`
  using `lib.mkForce`, pointing at our patched copies under `dotfiles/hypr/`.

## Hardware Context (pc host)
- Boot: systemd-boot + LUKS full disk encryption (LVM: `crypted--vg-{root,home,swap}`)
- Display: Wayland-only (no Xorg), Hyprland compositor
- Login: greetd + tuigreet → `dbus-run-session start-hyprland`
- Locale: `fr_FR.UTF-8`, timezone `Europe/Paris`

## Debugging Workflow
1. `nix flake check --no-build` — catches syntax before slow evaluation
2. `fst` — test mode, no bootloader write, safe to iterate
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

### Hyprland "not started with start-hyprland" warning
**Symptom**: top-right notification on login: "hyprland was not started with start-hyprland, not recommended!"
**Cause**: `start-hyprland`, when launched without a D-Bus session, does `exec dbus-run-session Hyprland` —
  replacing itself. Hyprland's parent is then `dbus-run-session`, so its "started by start-hyprland" check fails.
**Fix**: launch `start-hyprland` *inside* a D-Bus session: `dbus-run-session start-hyprland`.
  See `modules/system/desktop.nix` → `sessionLauncher`.

### Quickshell "Could not find 'default' config directory or shell.qml"
**Symptom**: running `quickshell` (no `-c`) at a shell errors out.
**Cause**: quickshell defaults to looking for a config dir named `default`; our upstream bundle only ships `ii`.
**Fix**: `modules/home/quickshell.nix` links both `quickshell/ii` and `quickshell/default` to the same QML source.

### `exec-once = qs ...` silently fails
**Symptom**: quickshell never starts on Hyprland login.
**Cause**: `qs` is a zsh alias, not a binary. Hyprland runs exec-once commands without a shell/alias context.
**Fix**: call `quickshell -c ii` directly in `dotfiles/hypr/hyprland/execs.conf`.

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

### `xdg.configFile` subpath conflict: "outside $HOME"
**Symptom**: rebuild fails with `Error installing file '.config/quickshell/default' outside $HOME`
**Cause**: home-manager installs `xdg.configFile."quickshell"` as a symlink to the Nix store (read-only).
  When it then resolves `xdg.configFile."quickshell/default"`, it follows that symlink and lands in `/nix/store/...`,
  which is outside `$HOME`.
**Fix**: don't mix a parent directory entry with child entries.  Instead, build a derivation
  that contains all needed subdirs and use `lib.mkForce { source = derivation; }` on the parent:
  ```nix
  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    ln -s ${shellConfig} $out/ii
    ln -s ${shellConfig} $out/default
  '';
  xdg.configFile."quickshell" = lib.mkForce { source = quickshellConfig; };
  ```

### Emergency mode at first boot after `feninstall-home` (root mount fails)
**Symptom**: first reboot after `feninstall-home` drops to emergency mode, stalling
  in initrd while trying to mount `/dev/mapper/crypted--vg-root`.
**Cause**: `create_feniso`'s disko layout (`create_feniso/nixos/disks.nix`) formats
  root/home as **btrfs** with `compress=zstd:1,noatime,ssd,space_cache=v2`, but this
  repo's `modules/system/boot.nix` previously declared them as `ext4`. `nixos-rebuild
  boot` succeeds (Nix evaluation doesn't see the mismatch), then the next boot's
  initrd asks the kernel to mount btrfs as ext4 → failure → emergency.
**Fix**: keep `fsType = "btrfs"` and the matching mount options in `modules/system/boot.nix`,
  and ship `boot.supportedFilesystems = [ "btrfs" ]` so initrd carries btrfs userland.
  If already broken: in systemd-boot, pick the generation 1 entry (the bootstrap
  install), then `cd /etc/nixos && git pull && nixos-rebuild switch --flake .#pc`.

### `claude-code` or `claude-code-bin` build fails with 404
**Symptom**: `curl: (22) The requested URL returned error: 404` on npm or Google Storage during rebuild
**Cause**: nixpkgs pins a specific version whose upstream tarball/binary has since been deleted.
  Both `pkgs.claude-code` (npm) and `pkgs.claude-code-bin` (GCS binary) can hit this.
**Fix**: `cd /etc/nixos && nix flake update nixpkgs && git add flake.lock` then `switch`
  This bumps nixpkgs to a commit with a newer working version.
  Always `git add` after updating flake.lock — Nix reads the git index, not the filesystem.
