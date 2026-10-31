# REFFIX Monokai Pro packaging

## Supported build

The theme is built and published for **OpenWrt 25.12 and newer using APK only**. IPK/opkg packages are no longer generated or published.

The package is architecture-independent. The GitHub release builds it with the OpenWrt SDK (`luci-theme-footstrap/build-apk.sh`). `tools/stage.sh` and `owfeed.yml` are a local staging path; they are not the release job.

## Package names

- Main theme: `luci-theme-footstrap`
- Translations: `luci-i18n-footstrap-<lang>`

The installed package identifier remains `luci-theme-footstrap` for upgrade compatibility. The LuCI-visible name is **Monokai Pro**, and the version/About link identifies REFFIX Monokai Pro.

## Build and validation

On every push and pull request, CI runs the static, CSS and browser gates. The APK build and GitHub release run only for a push to `main` whose message starts with `release: v2.1.0`, which is the version string in `.github/workflows/build.yml`. That job does not install the package on a router.

Local build outline:

```sh
npm ci
npm run check:fast
./tools/stage.sh
owfeed plan
owfeed check
owfeed build
sh tools/check-packages.sh
```

`owfeed build` writes under `dist/noarch/`. The release workflow writes `dist/reffix-luci-theme-footstrap-openwrt-25.12.apk` instead. `tools/check-packages.sh` verifies a staged theme package and fails if an IPK is present.

## Install

On OpenWrt 25.12/APK, `install.sh` downloads the release APK from GitHub, checks its SHA-256, then runs `apk add --allow-untrusted`. It also accepts a MediaTek Filogic snapshot. It rejects opkg and any other release line. The steps are in the repository README.

## Upstream and license

This is a palette and branding adaptation of Footstrap. Upstream source and license notices are retained. Review the repository's `LICENSE` and upstream attribution before redistributing the code.
