# Mode: `/propose-docs <file or folder>` — a reference page for the lab

(Formerly `/make-reference`.) The user points at a file or folder; you read it and write
**one** document that another lab member could pick up cold and use. Then you recommend
where it goes in the library, the user approves or redirects, and it goes in as a
`(new page)` proposal through the core of SKILL.md (section 4), which a maintainer reviews
before the page is added. (`generated/` and `onboarding/` are outside the proposal process;
a page there goes up as an ordinary pull request, step 4 below.)

SKILL.md section 0 has run: `<library>` is the clone, up to date on `main`, and you know the
member's login. The library's `CLAUDE.md` is the authority on layout, naming, provenance and
frontmatter; read it now and follow it over anything here.

**Ground rules for this mode**

- **Read-only on the source.** Never move, edit or delete anything the user pointed at.
- **Nothing private goes in.** Skip and don't quote passwords, tokens, keys, `.env` files,
  private SSH config, personal or supervisor feedback, reviews of people, and unpublished
  results unless the user says that part may be shared. Paths into someone's personal
  folders become generic (`<your project folder>/...`). Mention what you left out, by kind
  and count only.
- **Ask before writing anywhere shared**: once on the outline and location, once on the
  finished document (then on the core's approval table, or on the diff before a
  `generated/` or `onboarding/` PR).
- **Never into the paper library.** `paper_notes/`, `topics/`, `data/`, `INDEX.md` and
  `references.bib` change only through `/add-paper` and the other library skills. If the
  source holds claims about published papers, cite the paper notes that exist
  (`python tools/library.py find ...`), and list anything that should change in a paper note
  or topic page under "Suggested library updates" in the PR description.

## 1. Understand the source and the reader

The source path comes from `$ARGUMENTS`; if there is none, ask for it. If it is outside the
working directory and access is refused, ask the user to grant it.

1. **Inventory first.** For a folder, list files by type and size; skip data (`.mat`, `.h5`,
   `.tdms`, videos, raw images), build outputs, `.git`, environments. More than ~200 text
   files: sample by name and ask which parts matter before reading everything. For code,
   read READMEs, entry-point scripts and config blocks before helpers.
2. **Ask two short questions** if `$ARGUMENTS` doesn't answer them: *who* is it for (a new
   student, someone running the code, someone using the rig) and *what should they be able
   to do after reading it*. Offer your guess from the inventory so they can just say yes.
3. **Check the library already covers it.** Grep the clone for the main terms
   (`documentation/Org Gotchas.md` first, then `documentation/`, `methods/`, `facilities/`,
   `codebase_notes/`, `generated/`, `onboarding/`). If an existing page covers most of it,
   say so: recommend adding to that page instead of a near-duplicate, as N-points (C-points
   where it changes or disagrees with what the page says), handed to the core as in step 4.

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
| An app (player, viewer, exporter) other members should install | not this mode: `/publish-app` gives it an org repo, releases and its `applets/` card | |
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

For `documentation/`, `methods/`, `facilities/` and `codebase_notes/`, draft the document
in your scratchpad, not in the library: it goes in as proposal text (step 4). For
`generated/` or `onboarding/`, work in a worktree off `origin/main` as SKILL.md section 0
sets out, on branch `reference/<login>-<short-slug>` (folder `../lib-reference-<slug>`).

- **Claude-authored folders** (`documentation/`, `generated/`, `codebase_notes/`): start from
  `_templates/generated.md`: the `> [!warning] Claude-authored` callout, `type: generated`,
  `author: claude`, `tags` including `generated`, `generated:` today, `sources:` the paper
  notes any literature claims came from, and `verified:`/`verified_by:` left **empty**
  (only a person fills them). Mark **derived**, **asserted** and **inferred** where it isn't
  obvious.
- **Human-written folders**: `type: note`, `owner: MonashUniversity-ShockLab`, `authors:` the
  user, written in their voice from their material; tell them they are credited as its
  author and should read it as their own.
- **Write for the reader you agreed**: what it's for and when to use it at the top; then the
  steps, settings and decisions that matter, with the reasons; the gotchas and how to get
  out of them; where the code, data or rig lives (repo names, Market paths, M3 paths, not
  private ones); what is still unknown. Concrete values with the date and version they were
  seen. Prefer a table or numbered steps to prose where a reader will follow along.
- **Link, don't copy**: link to existing library pages (`[[Page]]`), paper notes and the
  group's repos rather than repeating them; don't paste whole scripts (link the repo and
  file, quote only the lines that matter).
- **Figures**: only small ones that earn their place (PNG or SVG under about 1 MB), with a
  source line. No data files. For a proposal, keep them in your scratchpad, embed them in
  the draft (`![[<name>.png]]`) and hand them over with the points that embed them (step 4);
  the core adds them under `attachments/images/` in the proposal PR. For `generated/` or
  `onboarding/`, put them in the worktree's `attachments/images/`.
- **Index pages**: if the folder's index page keeps a hand-written table (e.g.
  `documentation/_Documentation.md`), draft a row; Dataview indexes (e.g.
  `generated/_Generated.md`) need nothing.
- Draft the agreed Org Gotchas lines, dated.

## 4. Submit it

**`documentation/`, `methods/`, `facilities/`, `codebase_notes/`: as a proposal.** Show the
user the finished document (in full if short) and, on their yes, hand it to the core
(SKILL.md section 4) as a `(new page)` target in its folder: one point per section, the
first giving the path, frontmatter, callout and index row; the Org Gotchas lines as
N-points on that page; for each point the evidence label (derived, asserted, inferred, as
marked in the document) with its specifics; the source (file and folder names only, no
private paths); and the figures it embeds. For the batch: what the document is for and who
it's for, what was left out and why (kinds and counts), and any `## Suggested library
updates`. The core checks all four folders for conflicts, shows the approval table, writes
the proposal and opens its PR.

**`generated/`, `onboarding/`: by pull request.** Run `python tools/library.py check` in the
worktree and fix any `ERROR`. Show the user the diff (or the new file in full if short) and,
on their yes: stage the files by name, commit (`Add reference: <title>`), push, and open a
PR to `MonashUniversity-ShockLab/Library_of_Shock_Lab` titled `Reference: <title>`. The
description says what the document is for and who it's for, where the material came from
(file and folder names only, no private paths), what was left out and why (kinds and
counts), and any `## Suggested library updates` for the paper library. Org Gotchas lines
for it go to the core (section 4) as N-points. Leave merging to the PR agent. Remove the
worktree afterwards (`git -C <library> worktree remove <path>`) and leave the clone on `main`.

## 5. Finish

Tell the user the PR link. A proposal's page is added once a maintainer's review
(`/review-proposals`) accepts it, and `/propose-docs proposal_response` takes them through
the response; a PR's page reaches everyone with `git pull` once merged. For a
Claude-authored page, a lab member who checks it can later fill in `verified:` and
`verified_by:`.
