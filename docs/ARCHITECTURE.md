# Architecture

## Suite Dependency Graph

```mermaid
graph TD
    subgraph "Every Machine"
        common["common<br/>zsh, cli, nvim"]
    end

    subgraph "Desktop Infrastructure (DE-agnostic)"
        desktop["desktop<br/>xdg enable, pavucontrol, playerctl"]
    end

    subgraph "Hyprland Ecosystem"
        hyprland["hyprland<br/>kitty + terminal config, tomat, fcitx"]
    end

    subgraph "Plasma Ecosystem"
        plasma["plasma<br/>konsole + terminal config, fcitx,<br/>plasma-manager panels, touch keyboard"]
        kde["kde<br/>dolphin, gwenview, haruna, okular, ark,<br/>konsole, spectacle, elisa, filelight,<br/>KDE runtime, Konsole profile, MIME globs"]
    end

    subgraph "Universal Apps"
        apps_light["apps-light<br/>firefox, vscode, thunderbird, bitwarden,<br/>chat, mpv, mission-center, nvim MIME globs"]
    end

    subgraph "Workstation Only"
        apps_heavy["apps-heavy<br/>blender-bin+MCP, kicad, libreoffice+MCP,<br/>kdenlive, krita, inkscape, zotero, bottles"]
        nvidia["profiles/nvidia<br/>NVIDIA driver (no CUDA)"]
        docker["program/docker<br/>btrfs"]
        wireshark["program/wireshark"]
    end

    common --> desktop
    desktop --> hyprland
    desktop --> plasma
    hyprland --> kde
    hyprland --> apps_light
    plasma --> kde
    plasma --> apps_light
    apps_light --> apps_heavy
    apps_heavy --> nvidia
    apps_heavy --> docker
    apps_heavy --> wireshark
```

## Multi-Device Strategy

```mermaid
graph LR
    subgraph "vix-cpd5s (Workstation)"
        cpd5s["common → desktop → hyprland → kde → apps-light → apps-heavy"]
    end

    subgraph "vix-sp6 (Surface Pro 6, touch-first)"
        sp6["common → desktop → plasma → kde → apps-light"]
    end
```

`desktop`, `apps-light` and `kde` are shared across DEs. `kde` bundles the KDE app ecosystem (Dolphin, Konsole, Okular, ...) plus MIME defaults and the Konsole profile; `desktop/plasma` auto-enables `kde` and handles DE wiring (plasma6 module, powerdevil), while plasma-manager owns layout/behavior (panels, kwinrc). Touch-specific bits — bottom dock panel, kwinrc virtual keyboard (fcitx5 wayland launcher), and touch apps (angelfish/koko/tokodon) — are gated behind `desktop.plasma.mobile.enable` / `suites.kde.mobile.enable`. Stylix remains the single theme source.

Host-level hardware integration (not repo modules):
- `vix-sp6` imports `nixos-hardware.nixosModules.microsoft-surface-pro-intel` (linux-surface patched kernel, firmware, thermald, surface-control) and defines its disks declaratively via `disko.devices` — install-time partitioning is a single `disko --mode disko --flake .#vix-sp6` command.

## Session Management

Display manager (SDDM) and the default session are **not** chosen by the suites or desktop modules — each device opts in explicitly at the top of its `systems/.../default.nix`:

- `vix-cpd5s` → SDDM + `defaultSession = "hyprland-uwsm"` (Hyprland wrapped by [uwsm]).
- `vix-sp6` → SDDM + `defaultSession = "plasma"` (Plasma's native systemd session).

[uwsm] (Universal Wayland Session Manager) wraps standalone compositors in systemd user units, binding them into `graphical-session.target` so the session tears down cleanly on logout — this fixes stale-login and tty-switch greeter issues. `desktop/hyprland` sets `programs.hyprland.withUWSM = true` and `home/desktop/hyprland` disables Hyprland's own `systemd.enable` (they conflict). Plasma 6 already manages its session via `startplasma-wayland`, so it does not use uwsm.

## Module Layout

```mermaid
graph TD
    subgraph "modules/nixos/"
        ns["suites/ common, desktop, hyprland, plasma, apps-light, apps-heavy, theme-*"]
        ns2["system/ boot, core, kmscon, locale, network, nix, performance, sddm, ssh, user"]
        ns3["program/ zsh, docker, wireshark"]
        ns4["profiles/ nvidia, virtualization"]
        ns5["desktop/ hyprland, plasma"]
        ns6["theme"]
    end

    subgraph "modules/home/"
        hs["suites/ common, desktop, hyprland, plasma, kde, apps-light, apps-heavy, theme-*"]
        hs2["program/ zsh, cli, nvim, tomat, fcitx, xdg, firefox, bitwarden, thunderbird, vscode, blender, kicad, libreoffice"]
        hs3["desktop/ hyprland, plasma"]
        hs4["profiles/ nvidia"]
    end
```

## Producer / Consumer Pattern

```mermaid
sequenceDiagram
    participant DS as desktop suite
    participant XDG as xdg module
    participant HS as hyprland suite
    participant PS as plasma suite
    participant KDE as kde
    participant AL as apps-light
    participant FF as firefox module

    Note over DS,FF: Terminal
    DS->>XDG: enable = true
    HS->>XDG: terminal = { kitty, kitty.desktop }
    PS->>XDG: terminal = { konsole, org.kde.konsole.desktop }
    Note over XDG: writes kdeglobals

    Note over DS,FF: MIME (native globs via xdg.mimeApps)
    AK->>XDG: image/* → gwenview, video/* → haruna, application/pdf → okular
    AK->>XDG: application/*archive* → ark, application/*compressed* → ark
    AL->>XDG: text/* → nvim, application/json → nvim
    FF->>XDG: text/html → firefox, x-scheme-handler/http → firefox
    Note over XDG: Nix attrset merge combines all entries

    Note over DS,FF: Fonts
    Note over XDG: Konsole profile font from config.stylix.fonts.monospace
    Note over XDG: kdeglobals terminal from vix.program.xdg.terminal
```

## Design Principles

1. **DE-agnostic modules don't reference specific apps.** `xdg` exposes `terminal` option but doesn't set it. `desktop` has pavucontrol but not kitty. `apps-light` has mpv but not haruna.

2. **DE-specific bundles own their ecosystem.** `kde` bundles all KDE apps + MIME + Konsole config. A future `apps-gnome` would do the same with GNOME apps.

3. **MIME uses native globs.** `xdg.mimeApps.defaultApplications` supports `image/*` natively, no external tool needed.

4. **Stylix is the single source of truth for theming.** Fonts, colors, cursors flow from `config.stylix.fonts` and `config.lib.stylix.colors`.

5. **Heavy apps are opt-in via `apps-heavy` suite.** Blender, KiCad, LibreOffice, Kdenlive, Krita only on workstation.

6. **Suites mirror at NixOS and Home levels.** Each logical concept (common, desktop, hyprland, apps-light, apps-heavy, theme-*) exists at both `modules/nixos/suites/` and `modules/home/suites/`.
