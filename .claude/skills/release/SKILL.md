---
name: release
description: Cut a REFFIX Monokai Pro release — the checks, the changelog rename, and the main commit that publishes the 25.12 APK. Use when asked to cut or ship a release, or to check whether a release is ready.
---

# Cutting a release

`docs/releasing.md` is the authority. **The order is load-bearing** — the commit that publishes
already contains its own changelog entry. The workflow creates the tag from that commit.

Nothing below is optional because a cheap gate went green. `npm run computed-diff` and
`npm run smoke` are early detectors on a static gallery; they do not stand in for a userland.

## 1. Scope the diff

```sh
git status --short | awk '{print $2}' | sed 's#/.*##' | sort -u
git status --short | grep -E 'styles/|menu-footstrap|\.ut$|fs-sheets|fs-select|fs-fit' \
  || echo 'no CSS / renderer / template / fence changes'
```

The diff touching `styles/`, the renderer, the templates or the fence makes the live check for
issues #1–#5 and #7–#11 mandatory. **Always mandatory regardless of the diff:** the whole automatic
section, plus issue #6 (packaging and asset selection), because #6 breaks at the release level and
nothing fails until a router in the field pulls the update.

## 2. The full pre-tag matrix

All four, and every one of them read rather than merely started. The three long ones are T2: start
them detached with `tools/bg.sh` and report the run-ids, then read the logs.

| Must be green | How |
|---|---|
| `npm run check` | one run, exit 0. Every static gate |
| `owlab test`, **both formats** | two invocations, one per format — never one run with two `--release` flags |
| the wide live gates | one call per gate — `npm run live -- …` does not forward its flags, `docs/releasing.md` |
| `/security-review` | on the final branch diff, **before** the tag |

```sh
npm run check
node tools/jsmin-verify.mjs
```

The published package is one OpenWrt 25.12 APK. There is no IPK leg. A local `./tools/stage.sh && owfeed build` is not the file GitHub publishes.

`--install` is a host-side glob evaluated per router, so `dist/*/…` hands the apk box an ipk as well
and the install fails on both (measured: `0 of 2 routers passed`). The five assertions and the exact
flags: `docs/development.md`. `tools/jsmin-verify.mjs` is not in `check` — CI runs it.

**A release is not cut until every log above has been read.** A detached run nobody opened is not a
green gate, and the tier a check sits in never changes what the release requires.

## 3. Asset selection (issue #6), separately and always

The most fragile part of every release and the only one that fails silently: the notes and the asset
choice are evaluated at tag time, in the field, months later. The `build` job asserts exactly N
assets per format, each resolving through its own name-anchored regex `^<name>[-_][^/]*\.EXT$` to
exactly one. Simulate it against the shape of the coming release — the loop is in
`docs/releasing.md` step 3.

## 4. The runbook

0. `node tools/size-budget.mjs --pin` — re-pins the size ceiling to this build plus 2 %. This is
   the ONLY time the numbers in `tools/size-budget.mjs` change; between releases a change that
   crosses them removes something instead. Goes into the same commit as the rename below.
1. Rename `[Unreleased]` to `## [x.y.z] — YYYY-MM-DD` in `CHANGELOG.md`, and add the `compare/`
   link at the bottom. Leave `CHANGELOG_ru.md` empty. Canonical section order, every bullet with a
   bold lead.
2. In the same commit, set `.github/workflows/build.yml` so `build-package` and `publish-release`
   match `release: vX.Y.Z`, and set `FOOTSTRAP_VERSION` to that version. The workflow creates the
   tag. Do not create the tag by hand, and do not use a `release:` subject for any other commit.
3. `npm run changelog` — green.
4. Commit on `main`. Conventional Commits, English, **no AI attribution**. The subject starts with
   `release: vX.Y.Z`.
5. **Before pushing, read the recent runs on `main`**: `gh run list --limit 6`. A run already red
   before your push is still red after it. `validate` runs on every push. The APK jobs run only
   when the head commit message starts with the version string in the workflow.
6. Push `main` to `origin`.
7. **The release is not cut until that run is read, job by job** — `validate`, `build-package`,
   `publish-release`. `gh run view <id>` for the job list, `gh run view --job <id> --log-failed`
   for a failing step. The release assets are `reffix-luci-theme-footstrap-openwrt-25.12.apk` and
   `SHA256SUMS-openwrt-25.12.txt`. There is no feed publish and no `.sig` asset.

The commit and the push need an explicit instruction from the maintainer, each time. `git commit` and
`git push` are `ask` in `.claude/settings.json` for exactly this reason.
