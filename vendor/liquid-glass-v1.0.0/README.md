# Liquid Glass — Aurora Skin

> Frosted glass capsules over a vivid wallpaper.

A glass-style skin for the **Aurora** dashboard on modded Xbox 360 consoles, with a matching **Liquid Glass** CoverFlow layout.

![Liquid Glass home screen](docs/home.jpg)

![Liquid Glass game details](docs/game-details.jpg)

*Photos taken on a real console.*

| | |
|---|---|
| **Skin name** | Liquid Glass |
| **Version** | 1.0.0 |
| **Built for** | Aurora 0.7b |
| **Files** | `LiquidGlass.xzp` (skin) · `Liquid Glass.cfljson` (CoverFlow layout) |

## Features

- **Home:** big game title over the game's own artwork, a single row of covers, and glass capsules for your profile, Quick View and button hints.
- **Launch / Details buttons:** a solid green Launch, and a glass Details with a yellow **Y**.
- **Game details:** the cover on the left, then the title, overview, rating and banner, with all actions in a glass side panel.
- **Profile:** your gamer picture or avatar (head and shoulders) in a round frame.
- **Restyled screens:** settings, file manager, utilities and dialogs all match.
- **Type:** set in **Inter**, with thin, light button hints.
- **Covers:** the companion CoverFlow layout shows a single row of 13 covers with the selected one raised.

## Download

Get the latest zip from the [**Releases**](../../releases/latest) page. Don't use **Code → Download ZIP**, which includes repo extras you don't need.

## Installation

The release zip mirrors Aurora's own folder structure:

```
Aurora/
├── Skins/
│   └── LiquidGlass.xzp
└── Media/
    └── Layouts/
        └── Liquid Glass.cfljson
```

1. **Copy the files to your console.** Extract the zip and copy the `Aurora` folder over your Aurora install folder (for example `Hdd1:\Apps\Aurora\`), merging folders when asked. Use FTP (FileZilla, etc.) or a USB drive with Aurora's file manager.
   - Skin → `Aurora\Skins\LiquidGlass.xzp`
   - Layout → `Aurora\Media\Layouts\Liquid Glass.cfljson`
2. **Apply the skin.** In Aurora, open **Settings → Appearance → Skin**, select **Liquid Glass**, and restart Aurora if it asks.
3. **Apply the CoverFlow layout.** Press **B** → **View → Theme**, choose the **Liquid Glass** CoverFlow layout, and press **A**.

> The skin is designed to be used **together with** the Liquid Glass CoverFlow layout. Other layouts will work, but covers may overlap the panels.

**Tip:** turn on game backgrounds (**B → View**) so each game's artwork shows behind the glass, as in the screenshots.

### Uninstall

Switch to another skin in Aurora's settings, then delete `LiquidGlass.xzp` and `Liquid Glass.cfljson`.

## Compatibility

| Aurora version | Status |
|---|---|
| 0.7b | ✅ Supported |
| 0.6b and older | ❌ Not supported (skin format differs) |

## Known limitations

- **Greek:** the **Details** button shows "Λεπτο…". It is sized for every other language so it doesn't look oversized in English.
- **Glass:** the Xbox 360 UI can't blur what's behind a panel, so the glass is a tinted see-through layer, not true frosted blur.

## Troubleshooting

- **Skin doesn't appear in the list:** make sure the file ends in `.xzp` and sits directly in `Aurora\Skins\`, not in a subfolder.
- **Layout doesn't appear:** make sure the `.cfljson` is in `Aurora\Media\Layouts\`, then restart Aurora.
- **Covers look misplaced:** select the Liquid Glass CoverFlow layout (see step 3).
- **Anything else:** [open an issue](../../issues) with your Aurora version and a photo or screenshot.

## Credits

- **Aurora** dashboard by the Phoenix team. Aurora, Phoenix and related logos belong to their respective owners. This skin is an unofficial, fan-made project.
- **Inter** font © The Inter Project Authors, used under the [SIL Open Font License 1.1](licenses/OFL.txt). See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

The original artwork and layout in this repo are licensed under [CC BY-NC-SA 4.0](LICENSE). You may share and remix them for non-commercial use, with credit, under the same license. The bundled font remains under the SIL OFL 1.1.

---

*Use at your own risk. This project is for modded consoles running homebrew software and is not affiliated with or endorsed by Microsoft or Apple.*
