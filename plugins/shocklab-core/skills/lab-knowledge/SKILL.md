---
name: lab-knowledge
description: Check the ShockLab knowledge base BEFORE working out anything specific to the lab, Monash or its infrastructure — M3/MASSIVE, Slurm/sbatch/srun requests, Strudel desktops, the Market drive, MATLAB on the cluster, licences, lab rigs, cameras, schlieren/PIV/calibration, SPOD processing, the lab's standard analysis code (schlieren, acoustics, PIV and LES processing repos, schlieren tutorial), the lab's paper notes and topic pages (for a literature question, use /lit from the shocklab-library plugin if it is installed). Also use AFTER solving something non-obvious and org-specific, to offer to record it so nobody has to work it out again, and when asked to add a note, paper or method page.
---

# ShockLab knowledge base

The lab's shared knowledge lives in the private repo
`MonashUniversity-ShockLab/Library_of_Shock_Lab` (formerly `knowledge`; GitHub redirects
the old name), an Obsidian vault of Markdown notes that is also the group's paper library.
Its `CLAUDE.md` is the authority on layout, naming and provenance rules, and `SCHEMA.md`
on the paper notes' frontmatter; read them before writing anything, and follow them over
anything here.

The point of it: **nobody in the lab should have to work out the same org-specific thing
twice.** So look first, and write back what you learn.

## 1. Find the local clone

Check in this order and use the first that exists:

1. The path in the environment variable `SHOCKLAB_KNOWLEDGE`.
2. `./Library_of_Shock_Lab` in the working directory, or a sibling or parent folder named
   `Library_of_Shock_Lab` (or `knowledge`, an older clone), that contains `SCHEMA.md` or
   the vault's `CLAUDE.md`.
3. Otherwise, read without cloning:
   `gh api repos/MonashUniversity-ShockLab/Library_of_Shock_Lab/contents/<path> -H "Accept: application/vnd.github.raw"`
   and search with `gh search code --repo MonashUniversity-ShockLab/Library_of_Shock_Lab "<term>"`.
   If the user wants to write to it, offer to clone it
   (`gh repo clone MonashUniversity-ShockLab/Library_of_Shock_Lab`) and suggest they set
   `SHOCKLAB_KNOWLEDGE`.

With a clone, run `git pull --ff-only` first (skip quietly if it fails, e.g. offline).

## 2. Look before working it out

Keep this quick — a few seconds, not a research project:

1. Read `documentation/Org Gotchas.md`: one line per hard-won fact, each linking to the
   full page. Most "why is the cluster doing X" questions are answered there.
2. If not, grep the clone for the key terms (`grep -ril "cpus-per-task" .` or similar)
   and read the hits. Use the "Where to look for what" table in the vault's `CLAUDE.md`
   to pick folders: `methods/`, `facilities/`, `documentation/`, `onboarding/`.
   For the literature: `INDEX.md` lists every paper and topic page with a one-line
   scope; `topics/` holds the cross-paper reviews (read `topics/_queue/<topic>.md` too,
   if present), `paper_notes/` one note per paper, and `data/` numbers collected across
   papers. For anything more than a quick lookup, use `/lit` (shocklab-library plugin).
3. If you find it, use it and tell the user which note it came from. Treat anything with
   `type: generated` and an empty `verified:` as unverified, and say so.
4. If nothing covers it, say that briefly and carry on with the task.

**Paper PDFs.** Each member keeps their own PDFs in `attachments/papers/` in their clone
(git ignores it), copied from the Market folder `Library_of_Shock_Lab\papers`. Market's drive letter differs between PCs (`Z:` on some, `Y:` on others), so never assume one: use `SHOCKLAB_MARKET_PAPERS` if set, else look for `Library_of_Shock_Lab\papers` on every mounted drive (PowerShell: `Get-PSDrive -PSProvider FileSystem | ForEach-Object { Join-Path $_.Root 'Library_of_Shock_Lab\papers' } | Where-Object { Test-Path $_ }`). If no mounted drive has it, tell the user Market isn't mounted on this machine and ask them to connect it or say where it is; never guess a path. If several do, ask which. A paper note's `pdf:` field and its `![[...]]` embed point there. If the
user asks about a paper and its PDF is present, you can read it. If it's missing, that's
normal: work from the note, tell the user the PDF isn't in their copy (suggest re-copying
from Market), and give them the `doi:`/`url:` so they can save it under the `pdf:` path. Never remove or change an
embed because the file is missing.

## 3. Write back what you learn

When a task turns up something **non-obvious and specific to the org** — a Slurm flag M3
needs, a Strudel quirk, a mount trick, a licence or module version that works, a rig
setting — then, once the user's task is done, offer to record it. Don't interrupt the task
to do it.

- Short, single fact → a line in `documentation/Org Gotchas.md` under the right heading,
  with a link to where the detail lives.
- Needs explanation → add to the existing page that covers it, or a new
  `documentation/` page, and link it from `Org Gotchas.md`.
- Lab method or hardware → `methods/` or `facilities/`, owned by the user (human-written
  notes; you draft, they own).
- Record what was observed, when (`YYYY-MM-DD`), and on what (e.g. Slurm version,
  module), because cluster behaviour changes.

Not worth recording: things in the public docs that worked first time, personal
preferences, anything project-private.

## 4. The lab's code repos

The org also holds the group's standard analysis code. Before writing new processing code
for schlieren, acoustic, PIV or LES data, or before debugging someone's copy of these
scripts, check the matching repo: the lab's conventions (array layouts, units, Strouhal
and wavenumber definitions, file naming) live there.

| Repo | What it is | Read first |
|---|---|---|
| `Schlieren_Processing_Scripts` | Standard MATLAB toolbox for time-resolved schlieren of jets: load `.mraw`/`.slow` to `_Fields.mat`, then SPOD, POD, BMD, instantaneous frequency, twin-jet coupling, wavenumber and time–frequency analyses, figures and videos. v2.0; projects started earlier can stay on tag `v1.0` | `README.md` (pipeline), `CONVENTIONS.md`, `Archive/README.md` (what replaced each retired script) |
| `Schlieren_Tutorial` | Step-by-step tutorial for the schlieren scripts (v2.0+): load to `.mat` → SPOD → plots, with answers in `Finished_Scripts/Run_Tutorial.m`. Default branch `master` | `Tutorial_Guide.md` |
| `Acoustics_Processing_Scripts` | Microphone-array acoustics from `.tdms`: calibration, `Raw_tdms_to_mat`, processing (Nfft etc.), plots, SPOD and time–frequency analyses. `Raw_tdms_to_mat.m` doesn't work on Linux (M3) before MATLAB R2026a; run it locally | `README.md` (steps 1–5) |
| `PIV_Processing_Scripts` | Standard PIV processing (PIVlab-based), including stereo 3C reconstruction, pair checking, outlier removal, statistics and POD | `README.md` |
| `LES_Processing_Scripts` | Processing and analysis of LES data from NRL and UCS: POD, Hilbert-POD, BMD (incl. symmetry-enforced and pseudo-3D), videos, LES–PIV comparison | `README.md` |

How to use them:

- **Read without cloning:** `gh api repos/MonashUniversity-ShockLab/<repo>/contents/<path> -H "Accept: application/vnd.github.raw"`
  (list a folder by leaving off the header), or `gh search code --repo MonashUniversity-ShockLab/<repo> "<term>"`.
- **To run them**, the user clones the repo next to their own project, not inside it
  (`gh repo clone MonashUniversity-ShockLab/<repo>`), and runs the scripts from there,
  editing the settings block at the top of each script.
- **Library notes on the code:** `codebase_notes/` in the library summarises some repos
  (e.g. `schlieren-processing-scripts.md`). It records the commit it describes; if the
  repo has moved on, re-check the files you rely on.
- **Changes** go by pull request to that repo, like everything else in the org. Don't edit
  a member's local copy of these scripts unless they ask; many people keep modified copies
  inside their own project repos, which are theirs.
- Other repos may be added to the org later: `gh repo list MonashUniversity-ShockLab`
  shows the current set.

## 5. Rules for any write

- Follow the vault's `CLAUDE.md`: templates in `_templates/`, naming rules, frontmatter.
- Anything you author is Claude-authored: `generated/` or `documentation/`, with the
  `> [!warning] Claude-authored` callout — **never** in `paper_notes/`, which only the
  library skills (`/add-paper`, `/paper-audit`, `/restructure-note`) write, following
  `SCHEMA.md`.
- Never fill in `verified:` or `verified_by:`.
- Don't reword notes other people own; add tasks or open questions instead.
- Never commit PDFs, `.mat`, video or raw data.
- Show the user the diff and ask before committing or pushing; it's a repo the whole lab
  shares. Pull, commit small on a branch, push it and open a PR; the org has a PR agent
  that reviews PRs against the repo's `CLAUDE.md`.
- **Leave merging to the PR agent.** It reviews and merges PRs hourly on weekdays, so don't
  merge into `main` yourself or suggest the user does. If they ask to, first show what the
  merge brings in (`gh pr view <n> --json files,additions,deletions`), and offer to merge only
  part (e.g. just one `.md`) by moving those files into their own PR. If they still want to
  merge, that's allowed: do it. (The plugin's merge-guard hook also asks them before any
  `gh pr merge` on an org repo.) Maintainers' direct pushes of library changes, as the
  library's `CLAUDE.md` allows, are unaffected.
- `Misc/` in a clone is the member's personal working space; never commit it.
  `research_questions/` is shared: any member may add one (with `/research-question`, on a
  branch with a PR); don't edit another member's question without asking them.
