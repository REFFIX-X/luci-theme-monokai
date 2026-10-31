# Security Policy

`luci-theme-footstrap` is the package name of REFFIX Monokai Pro, a theme for LuCI. It runs in the
browser tab that administers a router.

## Supported versions

Only the latest published release receives security fixes.

| Version           | Supported |
| ----------------- | --------- |
| Latest release    | yes       |
| Any older release | no        |

The current release is on the [Releases page](https://github.com/REFFIX-X/luci-theme-monokai/releases).

## Reporting a vulnerability

**Do not open a public issue for a security vulnerability.**

Report privately through GitHub's private vulnerability reporting:

1. Go to the [Security tab](https://github.com/REFFIX-X/luci-theme-monokai/security).
2. Click **Report a vulnerability**.
3. Fill in the advisory form.

### What is in scope

- The theme assets served to the browser (JavaScript, CSS, `ucode` templates) in `luci-theme-footstrap/`.
- `install.sh` and `install-online.sh`, which download a release APK, check its SHA-256, and install it as root.

Vulnerabilities in OpenWrt, LuCI itself, `rpcd`, `uhttpd`, or third-party `luci-app` packages are out of scope here. Report those to their respective projects.

## Response

- The report will be acknowledged, typically within a few days.
- If accepted, a fix will be prepared and released, and a GitHub Security Advisory will be published crediting the reporter unless anonymity is requested.
- If the report is declined, the reasoning will be explained.

Please give a reasonable window to release a fix before disclosing details publicly.
