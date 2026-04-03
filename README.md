# config-install

This repository contains the post-install NixOS configuration.

It is intended to be cloned by `feninstall-home` from the bootstrap system.

Main scope:

- system configuration for the installed machine
- Home Manager configuration for user `seth`
- Home Manager configuration for user `root`

Compatibility contract:

- This repo exposes `.fenos-compat.env` consumed by bootstrap `feninstall-home`.
- `FENOS_CONFIG_COMPAT_VERSION` must match the expected version in bootstrap.
- `FENOS_CONFIG_MIN_BOOTSTRAP_VERSION` allows this repo to require a newer bootstrap.
