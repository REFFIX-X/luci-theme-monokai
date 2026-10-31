# CI and packaging

How this repository checks a change and publishes an OpenWrt 25.12 APK. The theme is noarch
(`LUCI_PKGARCH:=all`). The published installer is APK only.

What the Makefile and the install scripts do: [package.md](package.md). The release runbook:
[releasing.md](releasing.md).

## What runs

`.github/workflows/build.yml`. Triggers: push to `main`, any pull request, or a manual dispatch.
There is no tag trigger. `permissions: contents: read` at workflow level; only `publish-release`
sets `contents: write`.

| Job | When | What it does |
|---|---|---|
| `validate` | every run | `npm ci`, `npm run check:fast`, `npm run check:mid`, Playwright via `tools/ci-playwright.sh`, `npm run check:slow`, then `node tools/jsmin-verify.mjs` |
| `build-package` | push to `main` whose head commit message starts with `release: v2.1.0` | OpenWrt SDK build (`luci-theme-footstrap/build-apk.sh`, release `25.12.5` unless overridden) and `dist/reffix-luci-theme-footstrap-openwrt-25.12.apk` plus `SHA256SUMS-openwrt-25.12.txt` |
| `publish-release` | same condition, after both jobs | checks those checksums, then `gh release create v2.1.0`. Refuses if that tag or release already exists |

The version string `v2.1.0` is written in the workflow. A later version does not publish until that
string, `FOOTSTRAP_VERSION`, and the release-notes body are updated in the same commit. The subject
must start with `release: v2.1.0`. A trailer after the subject still matches. Do not use that
subject for a documentation commit.

`build-package` does not boot a router. `validate` is the gate that runs on an ordinary push.

## Pages

`.github/workflows/pages.yml` publishes `docs/devkit.html` (generated, not committed) and
`docs/gallery.html` with a freshly built `cascade.css`. It does not mirror a package feed and it
does not fetch a playground recording.

## Installation

`install.sh` and `install-online.sh` download `reffix-luci-theme-footstrap-openwrt-25.12.apk` from
[REFFIX-X/luci-theme-monokai](https://github.com/REFFIX-X/luci-theme-monokai/releases), check its
SHA-256 with `sha256sum` or `openssl`, then `apk add --upgrade` that file over any
`luci-theme-footstrap` already on the router. There is no package
feed step and no IPK. The steps a router admin follows are in the
[repository README](../README.md).

`--allow-untrusted` means the APK is not signed by an OpenWrt build key. The checksum, compared
before install, is the check.
