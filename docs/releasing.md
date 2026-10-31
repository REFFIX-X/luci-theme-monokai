# Releasing REFFIX Monokai Pro

## Supported package line

The theme is built for OpenWrt **25.12** using APK only. The package is architecture-independent. The release workflow writes `dist/reffix-luci-theme-footstrap-openwrt-25.12.apk` and `SHA256SUMS-openwrt-25.12.txt`. No IPK/opkg package is published.

## Before a release

Run the same checks the `validate` job runs:

```sh
npm ci
npm run check:fast
npm run check:mid
npm run check:slow
node tools/jsmin-verify.mjs
```

## Release pipeline

`.github/workflows/build.yml` publishes only when a push to `main` has a head commit message that
starts with `release: v2.1.0`. That string is in the workflow file. `validate` runs the source
gates. `build-package` builds the APK with the OpenWrt SDK. `publish-release` checks
`SHA256SUMS-openwrt-25.12.txt` and creates the GitHub release. It does not install the package on
a router, and it refuses to overwrite an existing `v2.1.0` tag or release.

A documentation commit must not use a subject that starts with `release:`.

The release package keeps the established identifier `luci-theme-footstrap` for upgrade compatibility. LuCI presents it as **Monokai Pro** and the Appearance link identifies REFFIX.

## Package contents

- `luci-theme-footstrap`: the theme.
- `luci-i18n-footstrap-<lang>`: one translation catalogue per supported language.

The generated stylesheet is built from `luci-theme-footstrap/styles/`; do not edit the generated `cascade.css` directly.

## Licensing

This project is a REFFIX colour and branding adaptation of Footstrap. Preserve the upstream attribution and license notices in source and release artifacts.


## Changelog mirror

`CHANGELOG.md` is required. `CHANGELOG_ru.md` is optional: leave it empty when no Russian mirror is maintained. If it contains content, the version list, dates, section order and bullet counts must match the English changelog, and the current release notes must have a Russian section. The release-note generator appends the Russian summary only when that mirror is non-empty.
