# Mode: `/propose-docs import` — a new member's existing knowledge and papers

(Formerly `/import-knowledge`.) New members arrive with years of notes and a folder of
papers. This onboarding step harvests what is useful to the whole lab, so it isn't lost on
one laptop, without duplicating anything the library already has and without copying
anything private. The notes go in as proposals through the core of SKILL.md (section 4); the
papers are copied to Market `_Unprocessed` (step 5).

SKILL.md section 0 has run: `<library>` is the clone, up to date on `main`, and you know the
member's login. The library's `CLAUDE.md` is the authority on where things go, naming and
provenance; read it now and follow it over anything here.

**Ground rules for this mode**

- **Read-only on the member's files.** Never move, rename, edit or delete anything in the
  folders they point you at. Papers are *copied* to Market; notes are *rewritten* into
  proposals, not moved.
- **Nothing private leaves their machine.** Skip passwords, tokens, keys, SSH configs with
  secrets, personal finances, health, reviews of people, supervisor feedback, unpublished
  results and drafts (unless they explicitly say a piece may be shared), and anything about
  a named person that isn't a lab role. If a file holds a secret, don't quote it; mention
  only that you skipped it.
- **Ask before writing anywhere shared.** Show the plan and wait for a yes before handing
  items to the core (which asks again on its approval table) and before the Market copy.
- **The paper library changes only through its own skills.** `paper_notes/`, `topics/`,
  `data/`, `INDEX.md` and `references.bib` change only through `/add-paper` (open to every
  member) and the other library skills. Papers go to Market `_Unprocessed` first; insights
  about a paper go in the proposal PR's description as "Suggested library updates", never
  straight into those folders.

## 0. Prerequisites

- A Python 3.8+ to run `"<library>/tools/paper_import.py"` (stdlib only; `pdftotext` from
  Poppler, if installed, adds DOI matching).
- Market mounted, for the papers part. Find it as the library's `CLAUDE.md` says ("Finding
  the Market drive"); if it isn't mounted, do the knowledge part and leave the papers for
  later.

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
folders: sample by name first, and ask before reading more than a few hundred files. Skip
data files (`.mat`, `.h5`, videos, raw images), build outputs and `.git`.

Group what you find into:

- **knowledge candidates**: text that holds lab- or org-specific know-how;
- **paper PDFs**;
- **private / skipped**: say how many and why, without quoting.

## 3. Knowledge: pick out what the lab can use

Worth keeping (the same bar as lab-knowledge's "Write back what you learn"): things that are
**non-obvious and specific to the lab, Monash or its tools**, which another member would
otherwise have to work out:

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

- **new**: nothing covers it (an N-point);
- **adds to** an existing page (an N-point there; say which page, and what is new);
- **conflicts** with an existing page (a C-point: quote the existing text exactly, with its
  page, heading and date, next to the member's claim and its date; don't pick a winner, the
  reviewer weighs both);
- **already covered**: drop it.

Note each kept item's **evidence**, which the proposal needs: **derived** (their notes
record running or measuring it: date, machine, job ID, command, output), **asserted** (from
a source: docs URL and date, a named colleague, a paper note) or **inferred** (their own
reading, unchecked). Most imported notes are asserted or inferred; say so rather than
upgrade them.

Where it goes (per the library's `CLAUDE.md`):

| Kind | Destination |
|---|---|
| One-line org fact | a dated line in `documentation/Org Gotchas.md`, linked to its detail |
| Workflow, script how-to, HPC procedure | `documentation/` page (Claude-authored callout and frontmatter) |
| Lab method | `methods/` (human-written: `type: note`, `owner: MonashUniversity-ShockLab`, `authors:` the member) |
| Rig, camera, nozzle, sensor | `facilities/` (human-written, as above) |
| Summary of a group code repo | `codebase_notes/` |
| Claim about a published paper | not proposed: list under "Suggested library updates" in the proposal PR |

Pages you draft from someone's notes that will be `type: note` belong to the group, with the
member credited: set `owner: MonashUniversity-ShockLab` and `authors:` to them, and tell them
they are credited as its author and should read it as their own words. Anything you
synthesise yourself is Claude-authored and follows the provenance rules (callout,
`type: generated`, `author: claude`, `sources:`; never fill `verified:`). On an existing
page, add without rewriting other text; anything that changes, removes or disagrees with
existing text, on that page or any other in the four folders, is a C-point, never an edit.

**Show the member a table** before proposing: candidate, source file, classification (N or
C), destination, evidence label, one-line content. Let them strike or edit rows.

## 4. Hand the knowledge to the core

Hand the approved items to the core (SKILL.md section 4). Each item carries its target page
(library-relative path, or a proposed new page and its folder), where on the page, the exact
proposed text, N or C, the existing text quoted (for C), the evidence label with its
specifics, and the source (file name only, not the full private path). A page drafted from
their notes (a `methods/` or `facilities/` page, a `documentation/` how-to) is a
`(new page)` target carrying the whole page, and the Org Gotchas lines that link to it are
N-points on that page.

For the batch, say the items come from a new member's notes, and suggest a split of a big
import by topic (M3 and Slurm, one rig, one processing method, ...) into proposals of up to
about 15 points each. Also pass on the `## Suggested library updates` for the paper library,
for the proposal PR's description, for whoever processes those papers. The core then
checks for conflicts, shows its approval table, writes the proposals and opens their PRs.
The papers (step 5) can be done before or after.

## 5. Papers: copy the ones the group doesn't have to Market

1. **Scan** every paper location in one go:

   ```
   python "<library>/tools/paper_import.py" scan <folder> [<folder> ...] --out <scratchpad>/papers_scan.tsv
   ```

   Each PDF gets a status: `dup-market` (byte-identical to a PDF on Market, filed or in
   `_Unprocessed`), `dup-library` (identical to one in the clone's `attachments/papers/`),
   `dup-note` (its DOI is a paper note's), `dup-scan` (identical to another PDF in this
   scan), `unreadable`, or `new`. Report the counts.

2. **Identify each `new` PDF from the paper itself**: read its first page (Read with
   `pages: "1"`, or `pdftotext -l 1`) for title, authors and year. Not a research paper
   (slides, a thesis chapter draft, a datasheet, a receipt, the member's own unpublished
   work)? Leave it out and say so. Then check for the same paper under another file:
   `python "<library>/tools/library.py" find --author <first-author surname> --since <year-1> --until <year+1>`,
   and grep `paper_notes/` for the DOI. A match is a duplicate; drop it.

3. **Name each one** `Authors_Year_Title.pdf`, the convention in the library's `CLAUDE.md`
   and `/add-paper`, using the authors, year and title printed on the paper (not the old
   filename or PDF metadata):
   - Authors: surnames joined by hyphens: one author `Tam`, two `Raiola-Kriegseis`, three
     or more `Nogueira-EtAl`. Multi-word surnames as one word (`EdgingtonMitchell`,
     `VonSaldern`).
   - Year: of publication (or the arXiv/thesis year).
   - Title: the full title, words joined by hyphens, capitalised as in the paper,
     punctuation dropped, cut at a word boundary to about 80 characters.
   - Plain ASCII (`Brès` → `Bres`); never `\ / : * ? " < > |` or spaces.
   - Example: `Raiola-Kriegseis_2025_Hilbert-POD-A-Tool-For-Educing-Advective-Wavepackets-From-Flow-Field-Data.pdf`.

4. **Write the manifest** `<scratchpad>/papers_manifest.tsv`, one line per paper:
   `<source path><TAB><new name>`. Dry-run it:

   ```
   python "<library>/tools/paper_import.py" copy <scratchpad>/papers_manifest.tsv
   ```

   The tool re-checks every row and refuses (as `skip`, with the reason) a name that breaks
   the convention, a PDF byte-identical to one on Market, a paper whose year and title match
   a note or a Market PDF (preprint vs journal version, renamed copies), and any destination
   that already exists. Fix naming mistakes and re-run; a genuine duplicate stays skipped.

5. **Show the member the plan** (count, plus the list of names) and, on their yes, run the
   same command with `--apply`. It copies into Market
   `Library_of_Shock_Lab\papers\_Unprocessed\` with exclusive create and a size check; it
   never moves, renames or overwrites anything and leaves their originals untouched.

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

Summarise: locations read; knowledge items found / approved, and the proposal threads with
their PR links (from what the core gives back); items skipped as private (counts only);
conflicts raised as C-points; papers scanned, duplicates by status, copied to `_Unprocessed`
(count), any left out (unreadable, not a paper, refused), and whether they chose to process
any with `/add-paper`. Tell them that nothing on the pages changes until a maintainer's
review (`/review-proposals`) accepts it, and that `/propose-docs proposal_response` takes
them through the response when it comes back. Offer to re-run `/propose-docs import` later
for locations they skipped. Don't record the member's private paths in the library, the
proposals or the PRs.
