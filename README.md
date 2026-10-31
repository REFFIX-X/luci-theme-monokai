# REFFIX Monokai Pro for LuCI

A REFFIX-maintained Monokai Pro colour edition of the Footstrap-based OpenWrt LuCI theme, tuned to match the REFFIX Firewall Log dashboard.

**Release:** [v2.0.2 for OpenWrt 25.12/APK](https://github.com/REFFIX-X/luci-theme-footstrap/releases/tag/v2.0.2)

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

### One-line installation (OpenWrt 25.12/APK)

Run this over SSH as root on the router:

```sh
uclient-fetch -qO- https://raw.githubusercontent.com/REFFIX-X/luci-theme-footstrap/main/install-online.sh | sh
```

The installer checks that the router is OpenWrt 25.12/APK (a MediaTek Filogic snapshot is also accepted), downloads the latest release APK, verifies its SHA-256 checksum with `sha256sum` or `openssl`, and installs or upgrades `luci-theme-footstrap`. It installs the theme package only. Language catalogues are optional and are installed manually below. If the latest release URL cannot be fetched, it retries the v2.0.2 assets.

### Manual APK installation

1. Open the [v2.0.2 release](https://github.com/REFFIX-X/luci-theme-footstrap/releases/tag/v2.0.2) and download `reffix-luci-theme-footstrap-openwrt-25.12.apk`, `SHA256SUMS-openwrt-25.12.txt`, and any `luci-i18n-footstrap-*.apk` you need.
2. Copy those files to the router. From Windows PowerShell, in the folder that contains the download:

   ```powershell
   scp .\reffix-luci-theme-footstrap-openwrt-25.12.apk .\SHA256SUMS-openwrt-25.12.txt root@192.168.1.1:/tmp/
   ```

3. On the router, verify the checksum before installing. BusyBox `sha256sum -c` checks every name in the file, so run it against the one package you copied, or compare the hash by hand:

   ```sh
   cd /tmp
   sha256sum reffix-luci-theme-footstrap-openwrt-25.12.apk
   grep reffix-luci-theme-footstrap-openwrt-25.12.apk SHA256SUMS-openwrt-25.12.txt
   apk add --allow-untrusted /tmp/reffix-luci-theme-footstrap-openwrt-25.12.apk
   ```

   The two hashes must match. `--allow-untrusted` is required because the APK is not signed by an OpenWrt build key; the checksum is the check. Install a language package the same way, after the same comparison, using its exact filename.

4. Open LuCI at `http://192.168.1.1` (use the router's address). Go to **System → System → Language and Style** and choose **Monokai Pro** under **Design**. The package registers that design and does not change a design that is already set. It selects Monokai Pro only when LuCI has no Design set at all. If the previous stylesheet is still on screen, hard-refresh with **Ctrl+F5**.

**Upgrade note:** the package identifier remains `luci-theme-footstrap`, so `apk add` upgrades an existing install in place. An upgrade does not change the theme you already selected.

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
