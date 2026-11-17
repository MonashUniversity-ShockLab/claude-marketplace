---
name: make-reference
description: Turn a file or folder the user points at (their notes, scripts, a project folder, a report, a set of how-tos, an HPC setup) into one reference document for other lab members, recommend where it belongs in the ShockLab library (Library_of_Shock_Lab), let the user approve or change the location, and add it by pull request. Use when the user runs /make-reference, or asks to "write this up for the lab", "make a reference doc / guide from this folder", or "synthesise these notes for others".
argument-hint: "<file or folder> [what the document is for, or who it's for]"
---

# Make a reference document for the lab

The user points at a file or folder; you read it and write **one** document that another lab
member could pick up cold and use. Then you recommend where it goes in the library, the user
approves or redirects, and it goes up as a pull request.

The library's `CLAUDE.md` (in `$SHOCKLAB_KNOWLEDGE`) is the authority on layout, naming,
provenance and frontmatter. Read it first, and follow it over anything here.

**Ground rules**

- **Read-only on the source.** Never move, edit or delete anything the user pointed at.
- **Nothing private goes in.** Skip and don't quote passwords, tokens, keys, `.env` files,
  private SSH config, personal or supervisor feedback, reviews of people, and unpublished
  results unless the user says that part may be shared. Paths into someone's personal
  folders become generic (`<your project folder>/...`). Mention what you left out, by kind
  and count only.
- **Ask before writing anywhere shared**: once on the outline and location, once on the
  final diff before the PR.
- **Never into the paper library.** `paper_notes/`, `topics/`, `data/`, `INDEX.md` and
  `references.bib` change only through `/add-paper` and the other library skills. If the
  source holds claims about published papers, cite the paper notes that exist
  (`python tools/library.py find ...`), and list anything that should change in a paper note
  or topic page under "Suggested library updates" in the PR.

## 0. Setup

- `SHOCKLAB_KNOWLEDGE` points at a clone of `Library_of_Shock_Lab` (else offer the setup in
  `CLAUDE.md` of `MonashUniversity-ShockLab/claude-marketplace`).
  `git -C "$SHOCKLAB_KNOWLEDGE" pull --ff-only`.
- The source path comes from `$ARGUMENTS`; if there is none, ask for it. If it is
  outside the working directory and access is refused, ask the user to grant it.

## 1. Understand the source and the reader

1. **Inventory first.** For a folder, list files by type and size; skip data (`.mat`, `.h5`,
   `.tdms`, videos, raw images), build outputs, `.git`, environments. More than ~200 text files:
   sample by name and ask which parts matter before reading everything. For code, read
   READMEs, entry-point scripts and config blocks before helpers.
2. **Ask two short questions** if `$ARGUMENTS` doesn't answer them: *who* is it for (a new
   student, someone running the code, someone using the rig) and *what should they be able
   to do after reading it*. Offer your guess from the inventory so they can just say yes.
3. **Check the library already covers it.** Grep the clone for the main terms
   (`documentation/Org Gotchas.md` first, then `documentation/`, `methods/`, `facilities/`,
   `codebase_notes/`, `generated/`, `onboarding/`). If an existing page covers most of it,
   say so: recommend adding to that page (or an `## Open questions` entry or task if someone
   else owns it) rather than a near-duplicate.

## 2. Recommend a location

Pick the folder from what the document *is*, using the library's layout:

| The document is... | Folder | Provenance |
|---|---|---|
| A workflow, script or HPC how-to that will be kept up to date | `documentation/` (in a thread subfolder if one fits, e.g. `documentation/LES/`) | Claude-authored |
| A one-off explainer, derivation or code/maths breakdown, not kept current | `generated/` | Claude-authored |
| How the lab does a technique (schlieren, PIV, calibration, ...) | `methods/` | human-written: `type: note`, `owner: MonashUniversity-ShockLab`, `authors:` the user |
| A rig, nozzle, camera or sensor: specs, settings, quirks | `facilities/` | human-written, as above |
| A summary of one of the group's code repos | `codebase_notes/` | Claude-authored |
| Something every new member needs first | `onboarding/` | human-written, as above |
| An app (player, viewer, exporter) other members should install | not this skill: `/publish-app` gives it an org repo, releases and its `applets/` card | |
| One-line org facts it turned up | also a dated line each in `documentation/Org Gotchas.md`, linking to the new page | |

Human-written folders hold documents in a person's own words, owned by the group: put one
there only if the user will stand behind it as its author (`authors:` them). Otherwise use
the Claude-authored folder that fits.

Name it as the library's "Naming" section says (title case for `documentation/` and
`generated/`, prefixed by thread when there is one; sentence case for `methods/`,
`facilities/`, `onboarding/`). Check the name is free.

**Show the user, then wait:** the proposed path and title, one line on why that folder, the
runner-up location and why not, an outline (section headings with a line each), what you'll
leave out (private, out of scope), and any Org Gotchas lines. They can approve, pick another
folder or name, or change the outline. Repeat until they approve.

## 3. Write it

Work in a separate worktree so their clone's uncommitted edits are never swept in:

```
git -C "$SHOCKLAB_KNOWLEDGE" fetch origin
git -C "$SHOCKLAB_KNOWLEDGE" worktree add -b reference/<github-login>-<short-slug> ../lib-reference-<slug> origin/main
```

- **Claude-authored folders** (`documentation/`, `generated/`, `codebase_notes/`): start from
  `_templates/generated.md`: the `> [!warning] Claude-authored` callout, `type: generated`,
  `author: claude`, `tags` including `generated`, `generated:` today, `sources:` the paper
  notes any literature claims came from, and `verified:`/`verified_by:` left **empty**
  (only a person fills them). Mark **derived**, **asserted** and **inferred** where it isn't
  obvious.
- **Human-written folders**: `type: note`, `owner: MonashUniversity-ShockLab`, `authors:` the user, written in
  their voice from their material; tell them they are credited as its author and should
  read it as their own.
- **Write for the reader you agreed**: what it's for and when to use it at the top; then the
  steps, settings and decisions that matter, with the reasons; the gotchas and how to get
  out of them; where the code, data or rig lives (repo names, Market paths, M3 paths, not
  private ones); what is still unknown. Concrete values with the date and version they were
  seen. Prefer a table or numbered steps to prose where a reader will follow along.
- **Link, don't copy**: link to existing library pages (`[[Page]]`), paper notes and the
  group's repos rather than repeating them; don't paste whole scripts (link the repo and
  file, quote only the lines that matter).
- **Figures**: only small ones that earn their place, into `attachments/images/`, with a
  source line. No data files.
- **Index pages**: if the folder's index page keeps a hand-written table (e.g.
  `documentation/_Documentation.md`), add a row; Dataview indexes (e.g.
  `generated/_Generated.md`) need nothing.
- Add the agreed Org Gotchas lines, dated.

## 4. Check and open the PR

Run `python tools/library.py check` in the worktree and fix any `ERROR`. Show the user the
diff (or the new file in full if short) and, on their yes: stage the files by name, commit
(`Add reference: <title>`), push, and open a PR to
`MonashUniversity-ShockLab/Library_of_Shock_Lab` titled `Reference: <title>`. The description
says what the document is for and who it's for, where the material came from (file and folder
names only, no private paths), what was left out and why (kinds and counts), and any
`## Suggested library updates` for the paper library. Leave merging to the PR agent. Remove the
worktree afterwards (`git worktree remove`).

Tell the user the PR link, that the document reaches everyone with `git pull` once merged,
and, for a Claude-authored page, that a lab member who checks it can fill in `verified:`
and `verified_by:`.
