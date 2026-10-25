# Build notes

## Current tooling status

`src/skin/` holds the Liquid Glass 1.0.0 skin unpacked from `vendor/`: compiled `.xur` scenes, `skin.xml`, `skin.meta`, fonts, shaders, and every texture. Textures, fonts, shaders and the two config files are directly editable; the `.xur` scenes are compiled and still need XUI tooling to change layout or colours baked into them.

### Packing and unpacking

`tools/xzp.py` reads and writes the `.xzp` container (no external tools needed):

```sh
python3 tools/xzp.py list    vendor/liquid-glass-v1.0.0/Aurora/Skins/LiquidGlass.xzp
python3 tools/xzp.py extract vendor/liquid-glass-v1.0.0/Aurora/Skins/LiquidGlass.xzp src/skin
python3 tools/xzp.py pack    src/skin build/TraylorGlass.xzp
```

`extract` writes `src/skin/manifest.txt` with the original entry order; `pack` follows it, so repacking an untouched tree reproduces the upstream file byte for byte. New files are appended in sorted order. Entry names are limited to 255 UTF-16 characters and use backslashes inside the package.

Still needed for scene-level changes:

- Xbox 360 XUI authoring tooling for `.xui` to `.xur` export
- AuroraElements XML extensions

These tools are not committed to this repository. Keep proprietary SDK components outside the project.

### What lives where in the skin

- `skin.meta` — name, author, description shown in Aurora's skin picker; `skin.xml` — font registration and per-control texture mapping
- `Images/PolarGlass/` — the glass material: `HomeChrome.png` (1280x720 home overlay), `DetailsBackdrop.png` (details screen panels), `Ground.png`, capsule and button pieces, `ng/rr_*.png` rounded-rect nine-grid slices
- `Images/Background/Aurora.Background.jpg` — default wallpaper when game backgrounds are off
- `Images/Aurora.Skin.Scenes.Splash.Logo.Alternate.png` — 900x235 splash wordmark slot for the Traylor branding
- `Images/Visuals/` — stock control states (buttons, checkboxes, sliders, gamepad glyphs)
- `Fonts/` — Inter Regular/Medium/SemiBold/Bold/Light (OFL)
- `Shaders/` — CoverFlow and wallpaper HLSL; `Textures/Coverflow.xpr`, `Meshes/GameCover.xbg` — cover case model

## Console deployment paths

```text
Hdd:\Aurora\Skins\TraylorGlass.xzp
Hdd:\Aurora\Media\Layouts\Traylor Glass.cfljson
Hdd:\Aurora\User\Backgrounds\Traylor Family Game Station.png
```

Always preserve `Hdd:\Aurora\Skins\Default.xzp` as the fallback skin.

