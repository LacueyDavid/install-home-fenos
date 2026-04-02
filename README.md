# config-install

This repository contains the post-install NixOS configuration.

It is intended to be cloned by `install-home-fenos` from the bootstrap system.

Main scope:

- system configuration for the installed machine
- Home Manager configuration for user `seth`
- Home Manager configuration for user `root`

Compatibility contract:

- This repo exposes `.fennos-compat.env` consumed by bootstrap `install-home-fenos`.
- `FENNOS_CONFIG_COMPAT_VERSION` must match the expected version in bootstrap.
- `FENNOS_CONFIG_MIN_BOOTSTRAP_VERSION` allows this repo to require a newer bootstrap.
