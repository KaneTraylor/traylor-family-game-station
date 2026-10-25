# Traylor Family Game Station

A custom Aurora 0.7b interface for the Traylor family Xbox 360. The visual direction is a dark, television-first design with restrained glass surfaces, a single horizontal row of game covers, and minimal chrome.

## Current state

- Working Xbox 360 boot chain: ABadAvatar 1.3 beta -> XeUnshackle/DashLaunch -> Aurora 0.7b.2
- Generated 16:9 background and branded splash concepts
- Console-safe 1280x720 background export
- Verified Liquid Glass 1.0.0 package imported as an attributed visual/structural base
- No editable XUI/XUR skin source yet
- No custom XZP build yet

## Repository layout

```text
assets/                     Original and presentation-ready artwork
aurora/                     Files copied over the Aurora install directory
  Media/Layouts/            CoverFlow layouts
  Skins/                    Compiled .xzp skins
  User/Backgrounds/         Selectable Aurora wallpapers
src/
  layout/                   Editable CoverFlow sources
  skin/                     Editable XUI/XUR skin sources
docs/                       Design and build notes
vendor/                     Attributed upstream material used as a base
```

## Working agreement

Keep editable sources under `src/`, generated console artifacts under `aurora/`, and reference exports under `assets/`. Do not commit Xbox SDK binaries, proprietary Microsoft tools, console keys, NAND dumps, profiles, or other device-specific data.

## Next milestone

1. Import an Aurora 0.7b glass-style skin as an attributed base.
2. Establish the color, typography, spacing, and glass-material tokens.
3. Build the main dashboard and matching one-row CoverFlow layout.
4. Restyle menus and dialogs.
5. Add the branded splash and verify it on real hardware.

## Upstream base

The initial exploration uses [Liquid Glass for Aurora](https://github.com/ammarsi274/liquid-glass-aurora-skin) by ammarsi274. Its original artwork and layout are licensed CC BY-NC-SA 4.0; bundled fonts retain their respective licenses. The verified v1.0.0 package and notices are preserved under `vendor/liquid-glass-v1.0.0/`.

