# GEMINI.md

## Project Overview

This repository contains a comprehensive Nix configuration for managing multiple systems and user environments. It leverages Nix Flakes for reproducibility and modularity. The configuration is structured to support both macOS (via `nix-darwin`) and NixOS systems, as well as different hardware architectures.

The core of the configuration is divided into:

*   **System Configurations:** Managed by `nix-darwin` for macOS and NixOS for Linux systems. These are defined in the `hosts` directory, with each host having a `configuration.nix` file.
*   **Home Manager Configurations:** Used to manage user-level packages and dotfiles. These are also defined in the `hosts` directory, with each host having a `home.nix` file.
*   **Modules:** Reusable modules for system and home-manager configurations are located in the `modules` directory.
*   **Features:** A wide range of applications and tools are configured as individual "features" in the `home-manager/features` directory. This allows for easy enabling, disabling, and customization of different software packages.

## Building and Running

To apply a configuration, you need to use the `nixos-rebuild`, `darwin-rebuild`, or `home-manager` commands with the appropriate flake output.

**System Configuration:**

*   **NixOS:** `sudo nixos-rebuild switch --flake .#<host>`
*   **macOS:** `darwin-rebuild switch --flake .#<host>`

For example, to apply the system configuration for the `dragon` host:

```bash
darwin-rebuild switch --flake .#dragon
```

**Home Manager Configuration:**

*   `home-manager switch --flake .#<user>@<host>`

For example, to apply the home-manager configuration for the user `erning` on the `dragon` host:

```bash
home-manager switch --flake .#erning@dragon
```

## Development Conventions

*   **Modularity:** The configuration is highly modular. New features or applications should be added as separate files in the `home-manager/features` directory.
*   **Host-Specific Configurations:** Host-specific settings are kept in the `hosts` directory. This includes system-level configurations in `configuration.nix` and user-level configurations in `home.nix`.
*   **Secrets Management:** Secrets are managed using `agenix`, as indicated by the `agenix.url` in `flake.nix`.
*   **Dotfiles:** The `dotfiles` directory contains various configuration files that are likely symlinked or managed by home-manager.
