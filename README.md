# Traylor Family Game Station

A custom Aurora 0.7b interface for the Traylor family Xbox 360. The visual direction is a dark, television-first design with restrained glass surfaces, a single horizontal row of game covers, and minimal chrome.

## Current state

- Working Xbox 360 boot chain: ABadAvatar 1.3 beta -> XeUnshackle/DashLaunch -> Aurora 0.7b.2
- Generated 16:9 background and branded splash concepts
- Console-safe 1280x720 background export
- Verified Liquid Glass 1.0.0 package imported as an attributed visual/structural base
- Base skin unpacked into `src/skin/` with `tools/xzp.py` (extract and pack, byte-identical round trip)
- First `TraylorGlass.xzp` build: renamed skin metadata, Traylor wallpaper as the default background, Traylor wordmark on the splash screen, matching `Traylor Glass.cfljson` layout
- Deployed to the target Xbox 360 for visual validation; `.xur` scenes are still the unmodified upstream compiled files

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

## Test the preview

1. In Aurora, press **B**, open **Skin -> Change**, and select **Traylor Glass**. Restart Aurora if prompted.
2. Open **B -> Skin -> Options** and enable **Alternate Splash Screen** to show the Traylor wordmark on startup.
3. Press **B -> View -> Theme**, select **Traylor Glass**, and press **A**.
4. Refresh the background list with **X** and select **Traylor Family Game Station**.

Aurora should remember these selections on later launches. `Default.xzp` remains installed as the recovery skin.

## Next milestone

1. Validate the first branded package on real hardware.
2. Refine the main dashboard and one-row CoverFlow layout from test feedback.
3. Restyle menus, dialogs, game details, and utilities.
4. Rebuild scene-level `.xur` files when suitable XUI authoring tools are available.

## Upstream base

The initial exploration uses [Liquid Glass for Aurora](https://github.com/ammarsi274/liquid-glass-aurora-skin) by ammarsi274. Its original artwork and layout are licensed CC BY-NC-SA 4.0; bundled fonts retain their respective licenses. The verified v1.0.0 package and notices are preserved under `vendor/liquid-glass-v1.0.0/`.

