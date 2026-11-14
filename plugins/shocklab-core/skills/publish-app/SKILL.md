---
name: publish-app
description: Publish an app a lab member built (a viewer, player, exporter or other tool, e.g. one based on FieldsPlayer) as its own private repo in the MonashUniversity-ShockLab org, set up for releases the way FieldsPlayer is - history kept, the folder left where it is as a clone of the new repo, README with install/contract/contributing/releasing sections, CLAUDE.md, CHANGELOG, a built release on GitHub Releases - and add its card to the library's applets/ folder by PR. Also cuts a new release of an app that is already published. Use when the user runs /publish-app, or asks to "put my app in the org", "share my app with the lab", "set up releases for <app>" or "release <app> <version>".
argument-hint: "<app folder> [repo name] [version]"
---

# Publish a lab app

The user points at an app; you turn it into an org repo that any member can install from
a release, and add it to the library's list of apps. FieldsPlayer
(`MonashUniversity-ShockLab/FieldsPlayer`) is the reference: when unsure how something
should look, read its README, `CLAUDE.md`, `CHANGELOG.md` and v1.0.0 release, and its card
`applets/FieldsPlayer.md` in the library.

The user doesn't need to know git or GitHub. You drive; they approve.

**Ground rules**

- **Ask before each outward step**: creating the repo, the first push, the release, the
  library PR. Show what will happen first. One approval of the plan in step 2 covers the
  local steps; each outward step still gets its own yes.
- **Private, in the org.** `gh repo create MonashUniversity-ShockLab/<name> --private`, never
  public, never on a personal account.
- **Never commit secrets, data or binaries.** No `.env`, keys, tokens, passwords; no
  `.mat`/`.h5`/video/raw images; no `dist/`, `build/`, venvs, exes. Builds go on a Release.
- **Don't change what the app does.** Docs, `.gitignore`, a version string and pinned
  dependencies only. If something must change to build or install it, say so and ask.
- **Don't delete the user's files, and leave the folder where it is.** If the app sits
  inside a bigger repo, that repo stops tracking it; the files stay on disk.
- **Never touch the user's other uncommitted work** in a parent repo.
- **The user becomes the maintainer**: they merge PRs and publish releases. Changes from
  others come by pull request.

## 0. Setup and mode

- `gh auth status` works and the user is an org member
  (`gh api user/memberships/orgs/MonashUniversity-ShockLab --jq .state` is `active`); else
  point them at the marketplace setup.
- `SHOCKLAB_KNOWLEDGE` points at the library clone; `git -C "$SHOCKLAB_KNOWLEDGE" pull --ff-only`.
- The folder comes from `$ARGUMENTS`; if missing, ask "Which folder holds the app?"
- **Already published?** If the folder's `origin` is already
  `MonashUniversity-ShockLab/<name>`, this is a **new release**: skip to step 5 (bump the
  version and changelog), then 6, then update the card's `release:` and anything that
  changed (step 7). Check they are the maintainer named in the README first; if not, offer
  a pull request instead.

## 1. Look at the app (read-only)

Find out, and summarise for the user in a short table:

- **What it is**: language and framework (Python + PySide6/Qt/Tk, MATLAB App Designer
  `.mlapp`, a MATLAB GUI, a script with a CLI), the entry point, how it is run today.
- **What it reads**: which files and which variables or fields it needs (for a
  `*_Fields.mat` app: `im_data`, `im_mean`, `x`, `y`, `fps`, ...). This becomes the
  README's "What it reads" section: the data contract with whatever produces its input.
- **Headless interface**: any command-line entry point (like FieldsPlayer's
  `make_video.py`), its options, exit codes and output format. Scripts and Claude agents
  will call this, so record it exactly.
- **How it builds**: an existing build script (PyInstaller, `build_exe.ps1`), MATLAB
  packaging (`.prj` → `.mlappinstall`, or `mcc`/Application Compiler), or none.
- **Dependencies**: `requirements*.txt` / `pyproject.toml` (pinned or not), MATLAB version
  and toolboxes.
- **Tests**, an existing README, version string (an About box, `--version`, a constant).
- **Git state**: not in git; its own repo (`git -C <folder> rev-parse --show-toplevel` is the
  folder; note any remote, e.g. on a personal account); or a **subfolder of a bigger repo**
  (top-level is a parent folder).
- **What must stay out**: file count and size by type, the largest files, data, build
  outputs, venvs, secrets (names only, never contents). For a repo, also check its history:
  `git log --all --stat -- <folder>` for data or secrets ever committed, and
  `git rev-list --objects --all` plus `git cat-file --batch-check` for blobs over 50 MB.
- **Bundled third-party binaries** (ffmpeg, DLLs) and their licences; trademarked logos or
  icons. Fine inside the lab; note them in the README like FieldsPlayer's "Bundled ffmpeg"
  and "App icon".
- **Overlap**: read `applets/_Applets.md` in the library. If it was built from another
  lab app (often FieldsPlayer), say so: the README and card should credit the original.
  If an existing app already does nearly the same job, say which and ask whether a pull
  request to that app would serve better than a new repo. Their call.

## 2. Propose the plan; wait for approval

Show:

- **Repo name** (default: the app's name as the user writes it, e.g. `FieldsPlayer`; check
  it's free with `gh repo view MonashUniversity-ShockLab/<name>`), a one-line description,
  private, `shocklab` team (the org's members team) with push access, maintainer = the user's GitHub login.
- **History**: kept (subfolder split or the existing repo pushed as-is) or a fresh first
  commit (not in git, or secrets/large files in the history: then **don't** push the old
  history; start fresh from the cleaned working tree, and say why).
- **First version**: `1.0.0` if people already use it for real work, `0.1.0` if it's early.
- **Release artefact**: e.g. `<Name>-v<version>-win64.zip` of a PyInstaller one-folder build;
  a `.mlappinstall`; or source only (no build: install = run from source, and the release
  still marks the version).
- **What stays out** (the `.gitignore`), and which files you will add or edit: README
  sections, `CLAUDE.md`, `CHANGELOG.md`, the version string.

Let them change anything. Nothing outward happens until they say yes.

## 3. Create the org repo with the history

Pick the case:

- **Subfolder of a bigger repo** (FieldsPlayer's case): from the parent repo,
  `git subtree split -P <subfolder> -b publish-<name>`, and check `git log --oneline
  publish-<name>` holds only the app's commits.
- **Its own repo**: use it as-is. If it has a remote on a personal account, ask what to do
  with that afterwards (keep it as a second remote `personal`, or archive it on GitHub).
- **Not in git**: `git init -b main`, write the agreed `.gitignore` first, show
  `git status --porcelain --ignored`, then the first commit. Set `user.name`/`user.email` if
  empty (ask).

Then, on the user's yes:

```
gh repo create MonashUniversity-ShockLab/<name> --private --description "<one line>"
git push https://github.com/MonashUniversity-ShockLab/<name>.git <branch>:main
gh api -X PUT orgs/MonashUniversity-ShockLab/teams/shocklab/repos/MonashUniversity-ShockLab/<name> -f permission=push
```

## 4. Point the folder at the new repo (it stays where it is)

- **Subfolder case.** Inside the app folder: `git init -b main`,
  `git remote add origin https://github.com/MonashUniversity-ShockLab/<name>.git`,
  `git fetch origin`, `git reset origin/main` (mixed: files untouched),
  `git branch -u origin/main`; `git status` must be clean. Then in the **parent** repo:
  1. `git rm -r --cached <subfolder>` (removes it from the index only).
  2. Add `<subfolder>/` to the parent's `.gitignore` with a comment naming the org repo.
  3. Update pointers in the parent's `CLAUDE.md` / README to say it's now its own repo.
  4. Check `git diff --cached --name-only` holds only those paths, then `git commit`
     **without a pathspec** (`git commit -- <subfolder>` re-adds the files you just
     untracked). If the user had other changes staged, stop and ask instead.
  5. Delete the temporary split branch. Don't push the parent repo unless the user asks:
     a `git pull` of the parent elsewhere (e.g. on M3) **deletes** the folder there, so
     tell them to clone the new repo in its place first.
- **Own repo.** Set `origin` to the org repo (`git remote set-url origin ...`, keeping the
  old one as `personal` if they chose that), `git branch -u origin/main`.
- **Fresh start.** Add the org remote and push.

## 5. Make it release-ready

Edit in the app folder, matching FieldsPlayer:

- **README.md**: a one-paragraph intro (what it's for; credit the app it was built from);
  **Installing** (download from the latest release, where to unzip, the "Windows protected
  your PC → More info → Run anyway" note for unsigned exes, how to update, *Watch → Custom →
  Releases*, where the version shows); **What it reads** (the data-contract table);
  **Running from source**; **Command line** if it has one (options, exit codes, output);
  **Contributing** (PRs to `main`, the maintainer's login merges); **Releasing
  (maintainer)** (semver rules and the exact steps of step 6). Replace personal paths
  (`C:\Users\<them>\...`, their OneDrive) with `%LOCALAPPDATA%`/`%USERPROFILE%` or
  `<your folder>`. Keep everything else they wrote.
- **CLAUDE.md**: layout, how to run, test and build, the rules that must not break (frame
  numbering, the data contract), where build outputs and venvs live (never in a OneDrive
  source folder), PRs only, the maintainer publishes releases, binaries never committed.
- **CHANGELOG.md**: `## <version> (<date>)` with what the app does today.
- **Version string** set to the release version where the user sees it (About box,
  `--version`, window title). Add one only if there is none, and ask first.
- **Dependencies pinned** (`pip freeze` from the venv that builds it, trimmed to direct
  dependencies); MATLAB version and toolboxes in the README.
- `.gitignore` covers build output, venvs, caches, logs and data.

Run the tests if there are any. Commit (`Prepare <version>: release docs, CLAUDE.md,
changelog`) and push to `main`; this first setup goes straight to `main` because the user is
the maintainer. Later changes go by PR.

## 6. Build and publish the release

1. Build with the app's own script, output outside OneDrive (e.g.
   `%LOCALAPPDATA%\<Name>\dist`). With no build script for a Python Qt/Tk app, offer a
   PyInstaller one-folder `--windowed` build script modelled on FieldsPlayer's
   `build_exe.ps1`, and ask first; it becomes part of the repo.
2. **Smoke-test the build**: its self-test or `--help` if it has one; otherwise ask the user
   to launch it and open a file. Don't publish a build nobody has started.
3. Zip the build folder itself (so the zip holds `<Name>\<Name>.exe`) as
   `<Name>-v<version>-win64.zip`, outside the repo. It must be under 2 GB.
4. Notes: that version's `CHANGELOG.md` section, plus one line on installing and the
   SmartScreen note.
5. On the user's yes:
   `gh release create v<version> <zip> --title "<Name> <version>" --notes-file <notes> --target main`.
   Check it with `gh release view v<version>`.

Never move a published tag; fix a bad release with a new patch version.

## 7. Add the app's card to the library

In a worktree of the library on `applets/<login>-<name>`:

- Write `applets/<Name>.md` in the format set out in `applets/_Applets.md`, modelled on
  `applets/FieldsPlayer.md`: what it is and who it's for, Install, What it reads,
  Command line / for agents, Changing it, Related. Frontmatter `owner:` = maintainer's
  login, `repo:`, `release:`.
- Add its row to the table in `applets/_Applets.md`.
- `python tools/library.py check`, show the diff, commit `Add applet: <Name>`, push, and
  open a PR `Applet: <Name>`. Remove the worktree.

If `applets/` doesn't exist on the library's `main` yet, stop and tell the user.

## 8. Finish

Report in plain words: the repo and release links, the library PR, what other members do
to install it, and what the user does from now on:

- They merge pull requests and publish releases. To release, they ask Claude
  "release <Name> <version>" (this skill, release mode).
- Anyone can propose changes by PR.
- If they (or anyone) write a Claude agent that runs the app (like a video-making agent
  driving FieldsPlayer's `make_video.py`), it should call the documented command line, and
  can be offered to the lab as a PR to `MonashUniversity-ShockLab/claude-marketplace`.
