#!/bin/sh
# REFFIX Monokai Pro for LuCI installer: OpenWrt 25.12 / APK.
set -eu

REPO="REFFIX-X/luci-theme-monokai"
FALLBACK_VERSION="v2.1.0"
PACKAGE="reffix-luci-theme-footstrap-openwrt-25.12.apk"
SUMS="SHA256SUMS-openwrt-25.12.txt"
TMP="/tmp/reffix-theme-install.$$"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT INT TERM

fetch() {
  url="$1"
  dest="$2"
  if command -v uclient-fetch >/dev/null 2>&1; then
    uclient-fetch -q -O "$dest" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$dest" "$url"
  else
    echo "ERROR: install uclient-fetch or wget first." >&2
    return 1
  fi
}

command -v apk >/dev/null 2>&1 || {
  echo "ERROR: this release requires OpenWrt 25.12/APK. IPK/opkg is not supported." >&2
  exit 1
}

if [ -r /etc/openwrt_release ]; then . /etc/openwrt_release; fi
case "${DISTRIB_RELEASE:-}:${DISTRIB_TARGET:-}" in
  25.12*:*) ;;
  SNAPSHOT:mediatek/filogic*) ;;
  *)
    echo "ERROR: expected OpenWrt 25.12/APK (or a MediaTek Filogic snapshot). Detected release=${DISTRIB_RELEASE:-unknown}, target=${DISTRIB_TARGET:-unknown}." >&2
    exit 1
    ;;
esac

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
    return
  fi
  if command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$1" | awk '{ print $NF }'
    return
  fi
  echo "ERROR: sha256sum or openssl is required to verify the release download." >&2
  exit 1
}

download_release() {
  base="$1"
  fetch "$base/$PACKAGE" "$TMP/$PACKAGE" &&
    fetch "$base/$SUMS" "$TMP/$SUMS"
}

LATEST="https://github.com/$REPO/releases/latest/download"
if download_release "$LATEST"; then
  echo "Using the latest REFFIX Monokai Pro release."
else
  rm -f "$TMP/$PACKAGE" "$TMP/$SUMS"
  BASE="https://github.com/$REPO/releases/download/$FALLBACK_VERSION"
  echo "Latest download failed; trying the $FALLBACK_VERSION release." >&2
  download_release "$BASE" || {
    echo "ERROR: could not download the theme APK and checksum from GitHub Releases." >&2
    echo "Check router DNS/TLS access and visit https://github.com/$REPO/releases." >&2
    exit 1
  }
fi

EXPECTED="$(awk -v f="$PACKAGE" '$2 == f { print $1; exit }' "$TMP/$SUMS")"
ACTUAL="$(hash_file "$TMP/$PACKAGE")"
[ -n "$EXPECTED" ] || {
  echo "ERROR: the release checksum file does not name $PACKAGE." >&2
  exit 1
}
[ "$EXPECTED" = "$ACTUAL" ] || {
  echo "ERROR: SHA-256 mismatch for $PACKAGE; refusing to install." >&2
  exit 1
}

# apk-tools 3 `apk adbdump` writes YAML (serialize_yaml.c). The package identity is
# info's own name and version, at two spaces. A path or a dependency also has
# name/version, nested deeper or behind "- ", and those are not the package.
# Older index text uses P: and V:. The download filename is not the package name:
# the APK is reffix-luci-theme-footstrap-*.apk, the package is luci-theme-footstrap.
meta="$(apk adbdump "$TMP/$PACKAGE")" || {
  echo "ERROR: could not read the package name and version from $PACKAGE." >&2
  exit 1
}
parsed="$(printf '%s\n' "$meta" | awk '
function unquote(s, n, q) {
  gsub(/\r/, "", s)
  sub(/^[ \t]+/, "", s)
  sub(/[ \t]+$/, "", s)
  n = length(s)
  q = sprintf("%c", 39)
  if (n >= 2 && substr(s, n, 1) == substr(s, 1, 1) &&
      (substr(s, 1, 1) == "\"" || substr(s, 1, 1) == q))
    s = substr(s, 2, n - 2)
  return s
}
{
  sub(/\r$/, "", $0)
  if ($0 ~ /^P:/) { name = unquote(substr($0, 3)); next }
  if ($0 ~ /^V:/) { ver = unquote(substr($0, 3)); next }
  if ($0 ~ /^info:[ \t]*$/ || $0 ~ /^info:[ \t]*#/) { in_info = 1; next }
  if (!in_info) next
  if ($0 ~ /^[ \t]*$/ || $0 ~ /^[ \t]*#/) next
  if ($0 !~ /^ /) { in_info = 0; next }
  if (name == "" && $0 ~ /^  name:/) { name = unquote(substr($0, 8)); next }
  if (ver == "" && $0 ~ /^  version:/) { ver = unquote(substr($0, 11)); next }
}
END { printf "%s\n%s\n", name, ver }
')"
pkg_name="$(printf '%s\n' "$parsed" | awk 'NR == 1 { print; exit }')"
pkg_ver="$(printf '%s\n' "$parsed" | awk 'NR == 2 { print; exit }')"
[ "$pkg_name" = "luci-theme-footstrap" ] && [ -n "$pkg_ver" ] || {
  echo "ERROR: $PACKAGE is not luci-theme-footstrap (name=${pkg_name:-missing}, version=${pkg_ver:-missing})." >&2
  echo "apk adbdump (first 30 lines):" >&2
  printf '%s\n' "$meta" | awk 'NR <= 30 { print }' >&2
  exit 1
}

# `apk list --installed --manifest` prints "name version" for one installed package.
# An absent package prints nothing. This is the older release the re-run has to replace.
installed_ver() {
  apk list --installed --manifest 2>/dev/null | awk '$1=="luci-theme-footstrap" { print $2; exit }'
}

before="$(installed_ver)"
if [ -n "$before" ]; then
  echo "Found installed luci-theme-footstrap $before."
else
  echo "luci-theme-footstrap is not installed."
fi

echo "Checksum verified. Installing luci-theme-footstrap $pkg_ver..."
# A file argument pins that exact APK in /etc/apk/world, which is what replaces an
# older install. `apk add` without --upgrade does not change a package that is already
# installed (measured on apk 3: the old version stayed and the command exited 0).
# --repositories-file /dev/null keeps the solver off the distfeeds, so a LuCI build
# whose version sorts above 2.x is not chosen instead of this file.
# stdin is /dev/null because this script is often run as `fetch | sh`, and apk must
# not read the rest of the script. apk del is not used: postrm treats a real removal
# as "switch Design back to Bootstrap and delete /etc/footstrap".
if ! apk add --repositories-file /dev/null --allow-untrusted --upgrade "$TMP/$PACKAGE" </dev/null; then
  echo "ERROR: apk could not install luci-theme-footstrap $pkg_ver." >&2
  exit 1
fi

after="$(installed_ver)"
if [ "$after" != "$pkg_ver" ]; then
  echo "ERROR: luci-theme-footstrap is ${after:-not installed}; the verified package is $pkg_ver." >&2
  echo "The package was not deleted. Design and /etc/footstrap were left as they were." >&2
  exit 1
fi

if [ -z "$before" ]; then
  echo "Installed luci-theme-footstrap $after."
elif [ "$before" = "$after" ]; then
  echo "Already current: luci-theme-footstrap $after."
else
  echo "Replaced luci-theme-footstrap $before with $after."
fi
echo "Done. Open LuCI → System → System → Language and Style, then select Monokai Pro."
echo "A design that is already set is left as it is. Monokai Pro is selected only when LuCI has no Design set."
echo "Run this installer again to replace whatever luci-theme-footstrap is installed."
