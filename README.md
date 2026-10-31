![luci-theme-monokai — Monokai Pro for OpenWrt LuCI](docs/img/readme-banner.png)

# REFFIX Monokai Pro for LuCI

A REFFIX-maintained Monokai Pro colour edition of the Footstrap-based OpenWrt LuCI theme, tuned to match the REFFIX Firewall Log dashboard.

**Release:** [v2.1.0 for OpenWrt 25.12/APK](https://github.com/REFFIX-X/luci-theme-monokai/releases/tag/v2.1.0)

## Features

- Monokai Pro in both modes. Dark uses the Log Viewer hues. Light uses the same hues darkened so text and fills clear WCAG AA. Orange marks pending configuration changes. Purple marks the active command-palette row.
- Responsive Footstrap layout and LuCI-wide styling, including third-party LuCI applications.
- Appearance controls, browser-local preferences, and the same choices applied in other open tabs. Router-wide defaults stay optional.
- Command palette (`Ctrl+K` or `/`) finds pages and can switch the theme, collapse the sidebar, and open the pending-changes list.
- In-place navigation asks before leaving a form that still has unsaved field edits. Save and Apply stay on screen on long forms.
- Designed to pair with [REFFIX Log Viewer](https://github.com/REFFIX-X/luci-app-log).

## Navigation performance

Supported LuCI pages use in-place navigation: the theme keeps the LuCI shell loaded and renders
the next view without a full page reload. In the repository's 1 August 2026 OpenWrt 25.12.2
benchmark, this covered 38 stock pages and was 2.29× faster by total median time than stock
Bootstrap; each transition made 0–7 requests instead of 15–47. Results depend on the router and
page: views that spend most of their time rendering large datasets have less room to improve.
See the [benchmark method and per-page results](docs/benchmark.md), and measure again on your own
router before comparing changes.

## Compatibility

This release targets **OpenWrt 25.12 using APK**. The workflow builds the package with the official OpenWrt SDK. IPK/opkg packages are not published in this release.

## Installation

OpenWrt 25.12 with APK. A MediaTek Filogic snapshot is accepted too. The package name stays `luci-theme-footstrap`. LuCI lists it as **Monokai Pro**.

### One-line install

Run this over SSH as root:

```sh
uclient-fetch -qO- https://raw.githubusercontent.com/REFFIX-X/luci-theme-monokai/main/install-online.sh | sh
```

The script downloads the latest release APK, checks its SHA-256 with `sha256sum` or `openssl`, and installs it. If that download fails, it retries the [v2.1.0](https://github.com/REFFIX-X/luci-theme-monokai/releases/tag/v2.1.0) files.

### Update

Run the same command again. It reads the installed `luci-theme-footstrap` version and replaces that package with the verified APK. The same version is left as it is. A Design you already chose is not changed.

### Choose the design

Open LuCI at the router's address, for example `http://192.168.1.1`. Go to **System → System → Language and Style** and choose **Monokai Pro** under **Design**. The package selects Monokai Pro only when LuCI has no Design set. If the old stylesheet is still on screen, hard-refresh with **Ctrl+F5**.

### Install by hand

1. From the [v2.1.0 release](https://github.com/REFFIX-X/luci-theme-monokai/releases/tag/v2.1.0), download `reffix-luci-theme-footstrap-openwrt-25.12.apk` and `SHA256SUMS-openwrt-25.12.txt`. Language packages are optional: `luci-i18n-footstrap-es-0.apk` and `luci-i18n-footstrap-ru-0.apk`.
2. Copy the files to the router. From Windows PowerShell, in the folder that contains the download, use the router's address in place of `192.168.1.1`:

   ```powershell
   scp .\reffix-luci-theme-footstrap-openwrt-25.12.apk .\SHA256SUMS-openwrt-25.12.txt root@192.168.1.1:/tmp/
   ```

3. On the router, compare the checksum, then install. BusyBox `sha256sum -c` checks every name in the file, so compare the one package you copied:

   ```sh
   cd /tmp
   sha256sum reffix-luci-theme-footstrap-openwrt-25.12.apk
   grep reffix-luci-theme-footstrap-openwrt-25.12.apk SHA256SUMS-openwrt-25.12.txt
   apk add --repositories-file /dev/null --allow-untrusted --upgrade /tmp/reffix-luci-theme-footstrap-openwrt-25.12.apk
   ```

   The two hashes must match before `apk add`. `--allow-untrusted` is required because the APK is not signed by an OpenWrt build key. `--upgrade` replaces a copy that is already installed. `--repositories-file /dev/null` stops the package manager from picking a different build of the same name from another feed.

   A language package uses the same comparison and the same `apk add` flags, with its exact filename.

## Palette (dark)

| Token | Hex |
|---|---|
| Background | `#2D2A2E` |
| Panel | `#221F22` |
| Surface | `#333035` |
| Border | `#514D52` |
| Text | `#FCFCFA` |
| Yellow | `#FFD866` |
| Orange | `#FC9867` |
| Pink | `#FF6188` |
| Green | `#A9DC76` |
| Cyan | `#78DCE8` |
| Purple | `#AB9DF2` |

## Credits and licensing

This is a colour and branding adaptation of [VizzleTF/luci-theme-footstrap](https://github.com/VizzleTF/luci-theme-footstrap). Upstream code and license notices are retained. Licensed under Apache-2.0 where stated by the source project.
