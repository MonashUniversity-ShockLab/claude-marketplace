---
name: add-large-document
description: Index one large document (over 200 pages, e.g. a design manual, handbook, standard, book, environmental assessment or long report) into the Shock Lab paper library (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE) as a hub note plus part notes for only the chapters that matter, chosen with the user. The hub carries the chapter map, a coverage table, the figure and table index and how to search the PDF's text, so later sessions can find and read any page on demand instead of the whole document being summarised up front. Also adds a part note for one more chapter of a document already indexed. Open to any lab member (token-heavy: say so before starting); ends like /add-paper, with a pull request (members) and the PDF filed on Market. Use when the user runs /add-large-document, when /add-paper flags a PDF as too large, or when the user asks to add a handbook, manual, book or other very long document to the library.
argument-hint: "[a PDF (local path or its name in Market _Unprocessed); or <hub key> --chapter <N>[,<M>...] to add part notes to a document already indexed]"
---

# Index a large document

**Why this route.** `/add-paper` reads every page and writes one note, at roughly 5k tokens a page. For a 650-page manual that is about 3M tokens, several usage windows, much of it spent on chapters the group will never use, and the single note that comes out is either far too long or too thin. A document this size is a reference work: later sessions look things up in it rather than read it end to end. So this skill builds:

- a **hub note**, the document's one note in the usual sense (it owns the `pdf` field and the BibTeX entry): what the document is, its main results, a chapter map with printed and PDF pages, a coverage table, an index of every figure and table with its PDF page, and how to search the PDF's text;
- **part notes**, written in full, only for the chapters that matter to the group, picked with the user (`part_of` and `pdf_pages` in their frontmatter; see `<library>/SCHEMA.md`);
- nothing more for the other chapters. Anyone can find a page in them with `library.py search <hub key> "<regex>"` and read it from the PDF, and a later session can add a part note for any chapter when a question needs it (section 5).

**Who may run it, and the cost.** Any lab member, with the same member/maintainer rules as `/add-paper` (a member always ends with a pull request). Before starting, say what it costs: the map (section 2) is about 100–150k tokens; each part note is about 5k tokens per page read, more for scanned pages read as images. Section 3 gives the user a per-chapter estimate before anything expensive runs.

## Setup

`<skills>` is the folder that holds this skill's folder (its siblings include `add-paper/`). Read `<skills>/add-paper/SKILL.md` now: this skill reuses its rules and steps by name instead of repeating them. Follow its sections "Where the library is" (`<library>`, `library.py`), "Pull first" (a member's branch is `add-large-document/<github-login>-YYYY-MM-DD`), "Personal files", "Shared note queues", "Project relevance is personal", "Runs can be cut off" and "0a. Fetch requests from Market" (`<market>`, `paper_claim.py`), with these differences:

- **One document per run.**
- **Claims.** Claim the document in Market `_Unprocessed/` before reading it, as add-paper section 0a says. A document in Market `_Deferred/` (on-topic, held back) can't be claimed there: ask the user whether to move it back to `_Unprocessed/` (never overwriting), then claim it.
- **Tools.** This skill needs `library.py search` and `unindexed --pages`, and the `part_of` and `pdf_pages` fields in `SCHEMA.md`. If `library.py --help` doesn't list `search` after pulling, stop: the clone is older than this skill.
- **State folder.** All work in progress lives in `<library>/paper_notes/_incoming/<hub key>.large/` (git-ignored with the rest of `_incoming/`): `map.md`, `triage.md`, `hub.md` (the skeleton, until it moves into `paper_notes/`), `parts/<part key>.md` with `parts/<part key>.return.md`, and `hub.return.md`. A results file is written last, so a note without one is unfinished.

## 0. Resume a cut-off run

Look for `<library>/paper_notes/_incoming/*.large/` folders first. For each, pick up from the first missing piece: no `map.md` → section 2; no `triage.md` → section 3; no hub skeleton (neither `hub.md` there nor the hub in `paper_notes/`) → section 4a; part notes listed in `triage.md` that are neither in `paper_notes/` nor have a results file → section 4b (delete a part note that has no results file and redo it; fold any that have one first); no `hub.return.md` → section 4c; everything there → finish section 6. Tell the user which document and step you are resuming.

## 1. Pick the document

- **A PDF named in `$ARGUMENTS`:** use it (check its claim as add-paper section 0a says for named files).
- **`<hub key> --chapter <N>…`:** go to section 5.
- **Nothing:** run `paper_claim.py list`, then `pdfinfo` each `free` or `mine` PDF on Market (or `library.py unindexed --pages` on a local folder), and offer those over 200 pages. Say which are `taken` and by whom.

If the document has fewer than about 200 pages, say that `/add-paper` handles it (its long-document route splits by chapter into one note) and ask which the user wants.

Check for an existing note first, as add-paper section 1 "Duplicates" says, and also grep `<library>/paper_notes/` for the document's report number and title: older notes may already cite it or describe parts of it.

## 2. Map the document (cheap)

Do this in the main session, or in one `medium` subagent if the session's context is already full. Read only what the map needs (title pages, contents, chapter openings, captions), never the body.

1. `pdfinfo <pdf>`, then `pdftotext -layout <pdf> <scratchpad>/<stem>.txt` (never into the repo). Pages are separated by form feeds, so the n-th chunk is PDF page n.
2. **Identify it** from the title pages (read them as images with the Read tool and `pages` if the text is rough): title, authors or editors, organisation, report or document number, contract number, date, edition. Work out the hub key (`<firstauthor or organisation>-<year>-<short-title-slug>`, lowercase, hyphens) and rename the PDF as add-paper's "Per-paper procedure" step 4 says.
3. **Text quality.** Look at about six pages spread through the document and rate the text layer `good`, `rough` (OCR errors but readable) or `poor` (unreadable or missing on many pages). Note what is lost (equations, tables, chart labels are the usual casualties). A `rough` or `poor` layer means part writers must read the pages with equations, tables and charts as images.
4. **Chapter map** from the contents pages: number, title, printed page range, PDF page range (find each chapter's opening page in the text to get the offset; the offset often changes between chapters, and some documents number pages per chapter, e.g. 6-1). Include front matter, appendices, references and any index.
5. **Figure and table index.** Search the text page by page for captions (lines starting `FIGURE`, `Figure`, `FIG.`, `TABLE`, `Table` followed by a number) and list each: number, caption (lightly cleaned; mark guesses `(?)`), PDF page. Keep every one: this index is the cheapest, most useful lookup tool the hub gives.
6. **Overlap.** For each chapter, list existing notes that cover the same ground (`library.py find --text <term>`, `--topics`), and any later document in the library that updates or supersedes it.
7. Write `map.md` in the state folder: identity, hub key, text quality, chapter map, figure and table index, overlap.

## 3. Triage the chapters with the user

Propose a tier for every chapter, judged against the library's scope (`<library>/SCHEMA.md` and the library's `CLAUDE.md`) and the user's own projects (their `CLAUDE.md`):

- **Core:** a full part note (`high` effort): reads every page of the chapter.
- **Partial:** a short part note (`medium` effort): reads the chapter's opening pages and summary, and every page holding a key equation, design chart or table found through the map (about a third of the pages), and records what the chapter offers and where.
- **Map only:** nothing beyond the hub's map and figure index.

Show a table: chapter, title, PDF pages, proposed tier, one-line reason, estimated tokens (pages read × 5k, × 1.5 for pages read as images). Then ask (AskUserQuestion) whether to accept the tiers, take only the core chapters, or change some (the user names them). Record the decision in `triage.md`, with each part's key in the form `SCHEMA.md` gives ("Large documents"): `<hub key>-ch<NN>-<short-slug>` with a two-digit chapter number, `-app<X>-` for an appendix. Split a chapter of more than about 100 pages into two parts at a section boundary (`-ch06a-`, `-ch06b-`).

In an unattended run (no one to ask), take the core chapters only and list the proposed partial ones in the report.

## 4. Write the notes

The hub goes in first as a skeleton built from the map, so every commit passes `library.py check` (a part note's `part_of` must name an existing note). The parts follow in waves, and the hub is finished last, once it can summarise them.

### 4a. Hub skeleton

Write `<state folder>/hub.md` yourself from `map.md` and `triage.md`, in the layout of section 4c: full frontmatter, header, a Summary drawn from the document's own introduction and contents (marked `(draft: finished after the part notes)`), Coverage (planned parts named by key, unlinked, marked `(in progress)`: `check` fails on a link to a note that doesn't exist yet), How to look things up and the Figure and table index. Leave Key findings, Relevance and Key equations as one line each saying they follow with the part notes. It is moved in and committed with the first wave of parts (section 6).

### 4b. Part notes

One `general-purpose` subagent per part, `effort` by tier, in waves of about 4 as add-paper section 2 says. Fold each wave in and commit it (section 6) before the next, so a cut-off loses at most the wave in flight. Give each subagent:

- the PDF path, the hub key, the part key, the chapter's PDF page range and printed page range, and the text-quality rating;
- its chapter's entries from `map.md` (figures and tables, overlap with existing notes);
- its tier, and for a partial part the list of pages to read;
- add-paper's "Note template", "Results file" and "Rules" sections, copied out in full, the "Project relevance is personal" paragraph with the `<projects>` path and files (or "no project files: leave project-specific text out entirely"), the path of `<library>/SCHEMA.md` and of an existing note to copy the style of;
- the differences for a part note, below;
- an instruction **not** to rename the PDF, edit topic pages, data tables, `SCHEMA.md`, `INDEX.md` or `references.bib`, or commit.

**How a part note differs from a paper note:**

- **Frontmatter** as `SCHEMA.md` gives for part notes: `part_of` (the hub key), `pdf_pages` (`[first, last]`, PDF pages), `pdf: ""` and `bib: {}`. Title `<document title>, Ch. <N>: <chapter title>`; authors, year, type and venue of the document (the chapter's own authors if it names them); its own `data`, `methods`, `flow`, `phenomena` and `topics` tags for what the chapter covers; `cites` left `[]`.
- **Header**: under the title, instead of the PDF embed, a line `Part of [<document short title>](<hub key>.md), Ch. <N>, PDF pp. <a>–<b> (printed <x>–<y>)`.
- **Reading**: wherever the text layer garbles an equation, table or chart, read that page as an image (Read tool, `pages`, at most 20 per call). Always do so for pages with key equations and design charts. Design charts are often the document's real content: record each one's axes, parameters and range, and digitise a few points into a data row where a table in `<library>/data/README.md` fits (`how: figure`).
- **Page references** are PDF pages of the hub's PDF (SCHEMA "Large documents"), so `search`, `datacheck` and the Read tool all land on them directly. Where the printed page differs, add it: `(p. 214; printed 6-12)`. A data row's `page` column takes the same form.
- **Length**: core parts about 150–300 words per page read, up to about 8,000 words; partial parts 1,000–2,500 words. Never pad.
- **Overlap**: say where existing notes already cover the same material, link them, and spend the words on what this document adds or does differently (and where a later document in the library has updated it).
- **Files**: the note at `<state folder>/parts/<part key>.md`, written as if it were already in `paper_notes/` (links like `<other key>.md`), and its results file at `<state folder>/parts/<part key>.return.md`, written last.

### 4c. Finish the hub

After the last wave, finish the hub with one `high` subagent, or in the main session if its context has room. It reads the skeleton (now `<library>/paper_notes/<hub key>.md`), `map.md`, `triage.md`, the Summary and Key findings of each part note, and the document's front matter, introduction, any summary chapter and conclusions. It edits the hub in place and writes `<state folder>/hub.return.md` (add-paper's results-file items for the document as a whole; parts carry their own data rows). The finished hub has this layout:

```
---
(frontmatter: every field in SCHEMA.md, like any note; `pdf` is the renamed PDF; type `report` or `book`;
 tags covering what the whole document holds, not only the part-note chapters)
---
# <Title>
![[attachments/papers/<pdf field>]]
- **Authors / Source** (organisation, report number, contract, date) **/ PDF** (index key, page count) **/ Text layer** (good, rough or poor; what it loses) **/ Tags**
## Summary              (what the document is, who wrote it for whom and why, its era, what has since updated or replaced it)
## Key findings         (its main methods, design rules and numbers, each with a page ref and a link to the part note that covers it)
## Relevance to this project  (heading kept verbatim, as in add-paper's template)
## Coverage             (table: Ch. | title | printed pp. | PDF pp. | part note (link) or "map only" | one-line content)
## How to look things up  (`library.py search <hub key> "<regex>"` prints PDF pages with matching lines; then read the page with the Read tool and `pages`; useful search terms, and OCR misspellings seen in this document; `/add-large-document <hub key> --chapter <N>` adds a part note)
## Figure and table index  (by chapter: number, caption, PDF page; mark the ones the part notes discuss)
## Key equations and methods  (one line each: what it gives, page, part note link)
## Notation             (only if the document keeps one notation throughout)
```

The hub's page references are PDF pages too, as in the parts. Its Summary, Key findings and Relevance must stand on their own (add-paper's "Front-loaded" rule); the sections from Coverage on are reference material and can be long.

## 5. Add a chapter later

`/add-large-document <hub key> --chapter <N>[,<M>…]`, or when a `/lit` or `/research-question` session keeps needing a map-only chapter and the user agrees. Pull and branch as in Setup (no Market claim: the PDF is already filed; copy it from Market into `attachments/papers/` if this clone lacks it). Read the hub's Coverage table and check each named chapter has no part note. Agree the tier with the user (section 3, for these chapters only), write the parts (section 4b), then edit the hub yourself: the Coverage row, a Key findings line and Key equations lines pointing to the new part. Fold and commit as in section 6, with the message `Add part note: <short title>, Ch. <N>`.

## 6. Fold into the library and commit

Follow add-paper section 3 (steps 0 to 8), its "Push" and its "File the PDFs on Market", working from the results files in the state folder, with these differences:

- **Step 0:** with the first wave, move the hub skeleton in as well; then each wave's part notes (`mv -n` from the state folder into `<library>/paper_notes/`). As each part moves in, turn its Coverage row in the hub into a link (`check` warns when a hub doesn't link its part). Fold the hub's own results file after section 4c.
- **Step 0a:** rename only the hub's PDF on Market (the document has one PDF).
- **Step 2:** `library.py cites --write <hub key>` only; part notes have no reference list of their own.
- **Step 3:** queue every part's and the hub's topic contributions as usual. On each topic page, the Papers list gets one line for the document (the hub), linking the part notes that matter to that page.
- **Step 5:** `library.py file` moves the PDF and updates the hub; part notes follow automatically, having no `pdf` of their own.
- **Commit messages:** `Add part notes: <short title>, Ch. <list>` for each wave (the first adds `+ hub skeleton`), `Finish hub note: <short title> (<n> parts)` for section 4c.
- Delete the state folder once the finished hub's commit has succeeded.

## 7. Report

List the hub note (link, old → new PDF filename, page count, text quality); each part note (link, chapter, pages, tier); the chapters left map-only, with a one-line reminder that `library.py search <hub key> "<regex>"` reaches them and `/add-large-document <hub key> --chapter <N>` adds one later; the topic contributions queued; the data rows added; the parts to check against the PDF; what the run cost (tokens, if the session can tell); and the Market filing state and any claims the user still holds, as add-paper's final report does.
