# Build notes

## Current tooling status

The repository does not yet contain editable `.xui` or `.xur` sources. The first skin build will use an Aurora 0.7b-compatible glass skin as an attributed base.

Expected tools for full skin work:

- XZP Tool v2 for extracting and rebuilding `.xzp`
- Xbox 360 XUI authoring tooling for `.xui` to `.xur` export
- AuroraElements XML extensions

These tools are not committed to this repository. Keep proprietary SDK components outside the project.

## Console deployment paths

```text
Hdd:\Aurora\Skins\TraylorGlass.xzp
Hdd:\Aurora\Media\Layouts\Traylor Glass.cfljson
Hdd:\Aurora\User\Backgrounds\Traylor Family Game Station.png
```

Always preserve `Hdd:\Aurora\Skins\Default.xzp` as the fallback skin.

