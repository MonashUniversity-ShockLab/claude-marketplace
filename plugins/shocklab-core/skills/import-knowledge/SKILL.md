---
name: import-knowledge
description: Onboarding step that brings what a lab member already knows into the ShockLab library. Ask where their existing knowledge lives (notes, Obsidian/OneNote exports, project CLAUDE.md and READMEs, Claude memory, paper folders, Zotero storage), pull out what is useful to the whole lab into the library's group sections by pull request, and copy their paper PDFs that the group doesn't already hold to Market _Unprocessed in the Authors_Year_Title.pdf naming convention. Use when the user runs /import-knowledge, when onboarding (claude-marketplace setup) reaches that step, or when someone asks to "add my notes/papers to the lab library".
---

# Import a member's existing knowledge

New members arrive with years of notes and a folder of papers. This step harvests what is
useful to the whole lab, so it isn't lost on one laptop, without duplicating anything the
library already has and without copying anything private.

The library's `CLAUDE.md` (in `$SHOCKLAB_KNOWLEDGE`) is the authority on where things go,
naming and provenance; read it first and follow it over anything here.

**Ground rules for the whole skill**

- **Read-only on the member's files.** Never move, rename, edit or delete anything in the
  folders they point you at. Papers are *copied* to Market; notes are *rewritten* into the
  library, not moved.
- **Nothing private leaves their machine.** Skip passwords, tokens, keys, SSH configs with
  secrets, personal finances, health, reviews of people, supervisor feedback, unpublished
  results and drafts (unless they explicitly say a piece may be shared), and anything about
  a named person that isn't a lab role. If a file holds a secret, don't quote it; mention
  only that you skipped it.
- **Ask before writing anywhere shared.** Show the plan and wait for a yes before the pull
  request and before the Market copy.
- **This skill doesn't edit the paper library.** `paper_notes/`, `topics/`, `data/`,
  `INDEX.md` and `references.bib` change only through `/add-paper` (open to every member)
  and the other library skills. Papers go to Market `_Unprocessed` first; insights about a
  paper go in the PR description as "Suggested library updates", never straight into those
  folders.

## 0. Prerequisites

- `SHOCKLAB_KNOWLEDGE` points at a clone of `Library_of_Shock_Lab` (if not, run the
  setup in `CLAUDE.md` of `MonashUniversity-ShockLab/claude-marketplace` first).
  `git -C "$SHOCKLAB_KNOWLEDGE" pull --ff-only`.
- A Python 3.8+ to run `"$SHOCKLAB_KNOWLEDGE/tools/paper_import.py"` (stdlib only;
  `pdftotext` from Poppler, if installed, adds DOI matching).
- Market mounted, for the papers part. Find it as the library's `CLAUDE.md` says
  ("Finding the Market drive"); if it isn't mounted, do the knowledge part and leave the
  papers for later.

## 1. Ask where their knowledge is

Ask the member to list the places, and offer the usual suspects so they don't forget any:

- note folders or vaults (Obsidian, Markdown, Word/OneNote exports, a lab notebook scan
  folder), wikis and READMEs in their code repos, `CLAUDE.md` files in their projects;
- Claude's own memory for their projects (`~/.claude/projects/*/memory/*.md`) and their
  user `~/.claude/CLAUDE.md`: often the densest record of hard-won cluster and rig facts;
- HPC job-script folders and setup notes (M3/Gadi), lab rig logs, calibration sheets;
- paper folders: a `Literature`/`Papers` folder, Zotero's `storage/`, Mendeley, Downloads.

Also ask which of these are off-limits or private. Then confirm the list back.

On OneDrive or Dropbox, files may be online-only and unreadable until downloaded. If the
scan reports them `unreadable`, ask the member to right-click the folder → *Always keep on
this device* (or download it), then re-run.

## 2. Inventory (read-only)

For each location, list files by type and size; don't read everything blindly. Large
folders: sample by name first, and ask before reading more than a few hundred files.
Skip data files (`.mat`, `.h5`, videos, raw images), build outputs and `.git`.

Group what you find into:

- **knowledge candidates**: text that holds lab- or org-specific know-how;
- **paper PDFs**;
- **private / skipped**: say how many and why, without quoting.

## 3. Knowledge: pick out what the lab can use

Worth keeping (the same bar as lab-knowledge's "Write back what you learn"): things that
are **non-obvious and specific to the lab, Monash or its tools**, which another member
would otherwise have to work out:

- M3/MASSIVE, Gadi, Slurm, Strudel, Market, licence and module facts that work (with the
  date and versions observed);
- how a rig, camera, nozzle, sensor or calibration is set up and its quirks;
- how a processing method is run in the lab (schlieren, PIV, SPOD, acoustics, pressure),
  with the settings that matter;
- workflows for the group's codes; gotchas and their fixes.

Not worth it: generic textbook or public-docs material that works first time, personal
to-do lists and plans, project-private results, opinions about people.

**Check against the library before proposing anything.** For each candidate, grep the
clone (`documentation/Org Gotchas.md` first, then `methods/`, `facilities/`,
`documentation/`, `codebase_notes/`). Classify it:

- **new**: nothing covers it;
- **adds to** an existing page (say which, and what is new);
- **conflicts** with an existing page (both claims, both dates; don't pick a winner);
- **already covered**: drop it.

Where it goes (per the library's `CLAUDE.md`):

| Kind | Destination |
|---|---|
| One-line org fact | a dated line in `documentation/Org Gotchas.md`, linked to its detail |
| Workflow, script how-to, HPC procedure | `documentation/` page (Claude-authored callout and frontmatter) |
| Lab method | `methods/` (human-owned: `type: note`, `owner:` the member) |
| Rig, camera, nozzle, sensor | `facilities/` (human-owned, as above) |
| Summary of a group code repo | `codebase_notes/` |
| Claim about a published paper | not written: list under "Suggested library updates" in the PR |

Pages you draft from someone's notes that will be `type: note` belong to that member:
set `owner:` to them and tell them they own it. Anything you synthesise yourself is
Claude-authored and follows the provenance rules (callout, `type: generated`,
`author: claude`, `sources:`; never fill `verified:`). An existing page someone else owns:
don't reword it; add an `## Open questions` entry or a task, or note the addition in the
PR for its owner. A conflict goes in as an open question on the existing page, citing both.

**Show the member a table** before writing: candidate, source file, classification,
destination, one-line content. Let them strike or edit rows.

## 4. Write the knowledge PR

Work in a separate worktree so their own clone's uncommitted edits are never swept in:

```
git -C "$SHOCKLAB_KNOWLEDGE" fetch origin
git -C "$SHOCKLAB_KNOWLEDGE" worktree add -b import/<github-login>-<YYYY-MM-DD> ../lib-import-<login> origin/main
```

Write the approved items there, stage files by name, run
`python tools/library.py check` and fix any `ERROR`, show the member the diff, then (on
their yes) commit, push and open a PR titled `Import <name>'s knowledge (<n> items)`. The
PR description lists each item with its source (file name only, not the full private
path), the classification, and a final `## Suggested library updates` section for
paper-library changes for whoever processes those papers. The org's PR agent reviews it. Remove
the worktree afterwards (`git worktree remove`).

## 5. Papers: copy the ones the group doesn't have to Market

1. **Scan** every paper location in one go:

   ```
   python "$SHOCKLAB_KNOWLEDGE/tools/paper_import.py" scan <folder> [<folder> ...] --out <scratchpad>/papers_scan.tsv
   ```

   Each PDF gets a status: `dup-market` (byte-identical to a PDF on Market, filed or in
   `_Unprocessed`), `dup-library` (identical to one in the clone's `attachments/papers/`),
   `dup-note` (its DOI is a paper note's), `dup-scan` (identical to another PDF in this
   scan), `unreadable`, or `new`. Report the counts.

2. **Identify each `new` PDF from the paper itself**: read its first page (Read with
   `pages: "1"`, or `pdftotext -l 1`) for title, authors and year. Not a research paper
   (slides, a thesis chapter draft, a datasheet, a receipt, the member's own unpublished
   work)? Leave it out and say so. Then check for the same paper under another file:
   `python "$SHOCKLAB_KNOWLEDGE/tools/library.py" find --author <first-author surname> --since <year-1> --until <year+1>`,
   and grep `paper_notes/` for the DOI. A match is a duplicate; drop it.

3. **Name each one** `Authors_Year_Title.pdf`, the convention in the library's
   `CLAUDE.md` and `/add-paper`, using the authors, year and title printed on the paper
   (not the old filename or PDF metadata):
   - Authors: surnames joined by hyphens: one author `Tam`, two `Raiola-Kriegseis`,
     three or more `Nogueira-EtAl`. Multi-word surnames as one word (`EdgingtonMitchell`,
     `VonSaldern`).
   - Year: of publication (or the arXiv/thesis year).
   - Title: the full title, words joined by hyphens, capitalised as in the paper,
     punctuation dropped, cut at a word boundary to about 80 characters.
   - Plain ASCII (`Brès` → `Bres`); never `\ / : * ? " < > |` or spaces.
   - Example: `Raiola-Kriegseis_2025_Hilbert-POD-A-Tool-For-Educing-Advective-Wavepackets-From-Flow-Field-Data.pdf`.

4. **Write the manifest** `<scratchpad>/papers_manifest.tsv`, one line per paper:
   `<source path><TAB><new name>`. Dry-run it:

   ```
   python "$SHOCKLAB_KNOWLEDGE/tools/paper_import.py" copy <scratchpad>/papers_manifest.tsv
   ```

   The tool re-checks every row and refuses (as `skip`, with the reason) a name that breaks
   the convention, a PDF byte-identical to one on Market, a paper whose year and title
   match a note or a Market PDF (preprint vs journal version, renamed copies), and any
   destination that already exists. Fix naming mistakes and re-run; a genuine duplicate
   stays skipped.

5. **Show the member the plan** (count, plus the list of names) and, on their yes, run the
   same command with `--apply`. It copies into Market `Library_of_Shock_Lab\papers\_Unprocessed\`
   with exclusive create and a size check; it never moves, renames or overwrites anything
   and leaves their originals untouched.

6. **Offer to process them, with the cost up front.** The papers are now queued in
   `_Unprocessed`, where anyone in the lab can index them with `/add-paper`. Tell the member
   they can do that themselves, now or later, but that it is token-heavy: each paper is read
   in full, written up as a long note and worked into the topic pages, so a few papers can
   use a large share of a session's usage limit. Suggest starting with the handful most
   relevant to their own work. If they want to go ahead, run `/add-paper` on the ones they
   pick (in a new session if this one is already long); it ends with a pull request. If
   not, the papers wait in `_Unprocessed` for whoever processes them next, and their notes
   reach everyone with `git pull`.

## 6. Finish

Summarise: locations read; knowledge items proposed / accepted and the PR link; items
skipped as private (counts only); conflicts raised; papers scanned, duplicates by status,
copied to `_Unprocessed` (count), any left out (unreadable, not a paper, refused), and
whether they chose to process any with `/add-paper`.
Offer to re-run later for locations they skipped. Don't record the member's private paths
in the library or the PR.
