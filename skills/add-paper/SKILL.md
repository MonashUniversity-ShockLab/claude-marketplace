---
name: add-paper
description: Index every PDF in a folder (default <library>/attachments/papers in the Shock Lab paper library found via $SHOCKLAB_KNOWLEDGE, or any folder the user names) that has no note yet. Each paper is read once, its PDF renamed to Authors_Year_Title.pdf, and turned into a structured Markdown note with frontmatter; the paper is then worked into the topic pages and data tables, and the index and BibTeX are rebuilt, so later sessions never need the PDF. Maintainers only: ends with a push to the shared Library_of_Shock_Lab repo and the filed PDFs copied to the Market folder. Students request papers by putting the PDF in Market _Unprocessed instead. Use when the user runs /add-paper, says "add/index the new papers", or points at a folder of papers.
argument-hint: "[optional: a folder to scan, or specific PDF file(s) to (re)index]"
---

# Index new papers

**Maintainers only.** A maintainer is someone with push access to the shared library repo who says so, or whose own `CLAUDE.md` says so. If the user is not a maintainer, don't run this skill: tell them to put the PDF in the Market folder `Z:\Library_of_Shock_Lab\papers\_Unprocessed\`, where a maintainer will process it, and stop. If it isn't clear, ask once.

Goal: read each PDF **once**, carefully, and capture everything a later session would need, so the PDF only has to be reopened for exact wording or figures. Then fold the paper into the library's synthesis (topic pages, data tables), so the library keeps getting more useful rather than just longer.

## Where the library is

`<library>` in this skill is the root of the group's paper library: the folder that holds `SCHEMA.md`, `paper_notes/`, `topics/`, `data/` and `tools/` (normally your clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`). Resolve it once at the start and use the absolute path everywhere:

1. the path in the environment variable `SHOCKLAB_KNOWLEDGE`, if it is set;
2. otherwise `./Library_of_Shock_Lab` in the working directory, if it exists;
3. otherwise the working directory itself, if it contains `SCHEMA.md`.

If none of these exists, stop and tell the user to clone the library and set `SHOCKLAB_KNOWLEDGE` (see "Setting up a new lab member" in the `MonashUniversity-ShockLab/claude-marketplace` repo). `<library>/SCHEMA.md` and the library's own `CLAUDE.md` (if present) are the authority on layout, frontmatter and naming; follow them over anything here.

The helper scripts need only standard Python 3: run them as `python <library>/tools/library.py <command>`. If `python` is not on PATH, try `python3` or `py -3`, or the `python` of any conda env; ask the user once if none works.

The library layout, frontmatter fields, controlled vocabulary and topic-page structure are in `<library>/SCHEMA.md`. Read it first. Below, `library.py` means `python <library>/tools/library.py`. The PDFs live in `<library>/attachments/papers/` (git-ignored), whose layout matches the group's Market folder `Z:\Library_of_Shock_Lab\papers` exactly: topic folders plus `_Unprocessed/`, `_Off_Topic/` and `_Deferred/`. Students' paper requests arrive in Market `_Unprocessed/`.

**Pull first.** Before writing anything, pull (`git -C <library> pull --ff-only`). Commit on the current branch (normally `main`) and push at the end. If the maintainer prefers a pull request, create a branch now (e.g. `add-paper/YYYY-MM-DD-<short>`) and put all the commits below on it. A maintainer who works in their own repo and reaches the shared repo through a weekly sync just commits there.

**Personal files.** `<personal>` is the user's personal folder for these files, outside the shared repo: the path in the environment variable `SHOCKLAB_PERSONAL` if it is set, else `My_Knowledgebase/` next to the library (`<library>/../My_Knowledgebase`) if it exists, else `<library>` itself (the old layout, where `Misc/` is git-ignored). Research questions are not personal: they are shared in `<library>/research_questions/`, each with its `author`. The library tools find it the same way (`library.personal_dir()` in `<library>/tools/library.py`). `<personal>/Misc/` (e.g. `Papers_to_get.md`, `notes_to_update.md`, `group_papers.md`) holds the user's own working files: not part of the shared repo, never committed to it. Create a file there when a step needs it and it is missing; skip a step whose file the user doesn't keep.

**Runs can be cut off** (usage limit, app closed, crash), so all work in progress lives on disk, never only in a session's context. New notes are written to `<library>/paper_notes/_incoming/` (git-ignored, and not seen by `library.py`, so their PDFs still count as unindexed) with a results file next to each, and are only moved into `<library>/paper_notes/` when the main session folds them in. Commit after every wave.

## 0. Resume a cut-off run

Before anything else, look in `<library>/paper_notes/_incoming/`:
- `<key>.return.md` (with or without `<key>.md` beside it): a paper whose note was finished but not yet folded in. Fold these in first (section 3), before starting new papers. If `<key>.md` is no longer there, the note was already moved into `<library>/paper_notes/`; carry on with the fold, which is safe to repeat.
- `<key>.md` with no `<key>.return.md`: an unfinished note (results files are written last). Delete it; its PDF shows up as unindexed again and is redone. Keep a `<key>.parts/` folder of chapter drafts, though, and let the redo reuse finished chapters.
- If a topic page (`<library>/topics/*.md`, not `_queue/`) has uncommitted changes (`git status`), a page revision was cut off, or the user has been editing it. Don't revise or discard that page; leave it and report it.

## 0a. Fetch requests from Market

**Where Market is.** `<market>` below is the group's Market papers folder: the path in the environment variable `SHOCKLAB_MARKET_PAPERS` if set, else a path the user gives, else `Z:\Library_of_Shock_Lab\papers` (the usual Windows mapping; `/z/Library_of_Shock_Lab/papers` in Git Bash). If none of these is reachable (e.g. a cloud sandbox, or a Linux machine without the share mounted), say so and skip this step and the final Market step; the final report then lists the PDFs a maintainer must file on Market by hand. Use whichever shell is available (PowerShell or POSIX); the steps below say what to do, not which command.

Unless `$ARGUMENTS` names a folder or files, list the PDFs in `<market>/_Unprocessed/`. If any are not already in `<library>/attachments/papers/_Unprocessed/`, offer to copy them there. **Copy, don't move**, and don't overwrite local files: the Market originals stay until the final step. Skip this if the user declines.

## 1. Find unindexed PDFs

**Index key.** Each note's frontmatter `pdf` field holds its PDF's key, and that is how indexed papers are recognised:
- PDFs under `<library>/attachments/papers/`: the path relative to that folder (just the filename for top-level files).
- PDFs anywhere else: the absolute Windows path with forward slashes, e.g. `D:/Papers/Screech/Tam 1986.pdf`. Such a key only works on one machine, so for the shared library first copy the PDF into `<library>/attachments/papers/_Unprocessed/` (ask the user) and index it from there.

**What to process**, depending on `$ARGUMENTS`:
- **Empty or a folder:** run `library.py unindexed ["<folder>"]` (default `<library>/attachments/papers`, searched recursively; new papers normally sit in `<library>/attachments/papers/_Unprocessed/`). Each output line is `<index key><TAB><path to read>`. `<library>/attachments/papers/_Off_Topic/` and `_Deferred/` are skipped: they hold papers the user set aside (off-topic, or on-topic but held back for later), and are indexed only when the user names that folder or a file in it directly. If the folder is outside the working directory and access is refused, ask the user to grant access to it (the app will prompt) rather than copying files.
- **Specific PDF file(s):** process those even if already indexed, replacing their note. Work out each key using the rule above.

If nothing is printed, say every paper in that folder is already indexed and stop. Otherwise, list the files you are about to process. Many files will have publisher names (`016105_1_online.pdf`, `annurev-fluid-…pdf`); read the first page to identify them.

**Off-topic papers:** if a paper seems outside the library's scope (the scope in `<library>/SCHEMA.md` and the library's `CLAUDE.md`: jet screech, jet noise, impinging and non-axisymmetric jets, modal methods, rocket noise, diagnostics; plus the user's own research as described in their `CLAUDE.md`), don't index it without asking. List the likely off-topic files and ask the user (AskUserQuestion), with an option to move them to `<library>/attachments/papers/_Off_Topic/` (`mv -n`) and not process them.

**Duplicates:** the same paper can sit in two folders, or twice under different names, or as both a preprint and the journal version. Before writing a note, check for one already in the library: `library.py find --author <surname> --since <year-1> --until <year+1>`, and grep `<library>/paper_notes/` for the DOI. If one exists, don't write a second note: report it to the user and ask whether to keep the existing key, switch the note's `pdf` to the new file, or delete the redundant copy (deleting is the user's call).

## 2. Write one note per paper

Name notes by paper, not by folder, so a note's path doesn't change if its PDF moves.

**Reasoning effort.** Papers are read once and every later session trusts the note, but usage limits are tight, so match effort to the paper. Before launching subagents, skim each paper's abstract, section headings and equations (first pages or `pdftotext` output) and set the Agent tool's `effort` for it:
- **`high`** for anything where the note depends on following an argument rather than recording results:
  - theory- or modelling-heavy papers: linear stability (local, Floquet, global), resolvent, PSE/OWNS, vortex-sheet or guided-jet-wave theory, acoustic analogies and source models, shock-cell models, resonance/phase-criterion models, numerical-method papers with derivations;
  - method papers whose algorithm the note must capture exactly (SPOD and variants, BMD, DMD, HPOD, EMD, wavelets, and similar);
  - reviews and theses (including each chapter subagent of a long document), since they feed the topic pages;
  - papers central to the group's research threads (screech closure and staging, impinging-jet feedback, non-axisymmetric jets, SP-8072/SATURN-type rocket-noise models) or to the user's own projects in their `CLAUDE.md`;
  - any PDF whose extraction garbles equations or tables, or that is scanned.
- **`medium`** for every other paper, e.g. mainly experimental or measurement papers with light modelling. Never use less than `medium` for writing a note.
- When unsure, use `high`.

The main session's own effort is whatever the session runs at. If you would process a single paper yourself (below) and it falls in the `high` list, or this session runs below the effort that paper needs, give it to one subagent at the right effort instead. Likewise, when section 3 step 3 revises topic pages, delegate each page's revision to its own subagent at `high` (one per page, so edits can't collide), passing it that page's queue file.

- **One paper:** follow "Per-paper procedure" yourself (see "Reasoning effort" for when to use a subagent instead).
- **Long documents** (theses, reports, books; roughly 80+ pages): map chapters to PDF pages from the contents, then give one subagent per chapter range (effort `high`), in parallel. Each writes a draft section to `<library>/paper_notes/_incoming/<key>.parts/<chapter>.md`, and the main session merges the drafts into **one** note (then writes its results file and deletes the `.parts/` folder). Cite printed page numbers and record the offset between printed and PDF pages in the note's header. If a thesis contains published papers, list them, and mark any that already have their own note.
- **Two or more papers:** launch one `general-purpose` subagent per paper, with `effort` set as above, in parallel in a single message. Run them in waves of about 4 (queue the rest), because larger waves at high effort tend to hit usage limits mid-batch. Separate subagents also keep the full texts out of this session's context. Give each subagent:
  - the PDF path (to read) and its index key
  - the note path
  - the "Per-paper procedure", "Note template", "Results file" and "Rules" sections below, copied out in full, plus the path of `<library>/SCHEMA.md`
  - the path of an existing note in `<library>/paper_notes/`, to copy its style
  - an instruction to rename the PDF (Per-paper procedure step 4) but **not** to edit topic pages, data tables, `SCHEMA.md`, `INDEX.md` or `references.bib`, and **not** to commit

  Fold each wave in and commit it (section 3) before launching the next, so a cut-off loses at most the wave in flight.

## 3. Fold the papers into the library and commit

Only the main session edits topic pages, data tables, `SCHEMA.md` and the generated files, so parallel subagents can't collide. Do this once per wave, working from the results files in `<library>/paper_notes/_incoming/` (not from what the subagents said in their replies). Every step must be safe to repeat after a cut-off: before appending anything, check it isn't there already (a `## <note key>` heading in the queue file, the key in the Papers list, rows with that `note` key in the CSV). For the wave:

0. **Move the notes in:** `mv -n <library>/paper_notes/_incoming/<key>.md <library>/paper_notes/` for each finished paper.
1. **Vocabulary:** if a subagent proposed a new vocabulary value, either add it to `SCHEMA.md` (with a one-line meaning) or change the note to an existing value. If a note carries a topic listed under "Retired topic names" in `SCHEMA.md`, replace it as listed there; never recreate a retired topic page.
2. **Citations:** `library.py cites --write <key> …` for the new notes. This fills their `cites` from their reference lists. Also run plain `library.py cites --write` (all notes) when several papers were added, since older preprints sometimes cite newer versions.
3. **Topic pages (batched).** Revising a topic page costs about as much as writing a note, so pages are revised in batches, not per paper:
   - **Always, per paper (cheap):** append each topic contribution to the queue file `<library>/topics/_queue/<topic>.md` as a section headed `## <note key> (queued YYYY-MM-DD)`, and add the paper's one-line entry to the page's "Papers" list (sorted by year) ending in "(synthesis pending)". If a topic page doesn't exist yet, create it from the SCHEMA template (and make sure the topic is in the vocabulary).
   - **Revise a page only when** its queue holds 10 or more contributions, its oldest queued item is more than 3 weeks old, the user asks ("update the topic pages"), or a queued contribution would overturn a claim on the page. In that last case mark the contribution's heading line or correction item `**major.**` (say so in the report) and revise the page once, at the end of this run, not straight away. `library.py check` prints the queue sizes, the pages due and the pages with a major correction queued. Until a page is revised, `/lit` and `/research-question` read its queue alongside it, so nothing queued is lost.
   - **To revise:** one `high` subagent per page works the queued contributions into the right thread sections (not appended), revises "Current understanding" and "Disagreements and open questions" where they change, removes "(synthesis pending)" from those Papers lines, and updates the "Last updated" line and paper count. Sections headed `## audit: <note key>` come from `/paper-audit`, which re-read an existing note's paper: treat them like paper contributions, but the paper is already on the page, so correct or reweight the claims they point to and update its Papers line's role text only if it changed. Apply their **Corrections** first: each gives the exact current page text and its replacement (if the text has since changed, make the same fix in the new wording). Queue files sit one folder deeper than the page, so rewrite their `../../paper_notes/` links as `../paper_notes/`. Sections headed `## research-question: <slug>` come from `/research-question`, not a new paper: there is no Papers line to update; work in the change they describe, cite the notes they cite (not the question file), and check those notes support it before adding it. A point marked as the question's own reasoning goes in only as a labelled hypothesis or open question, with a link to `../research_questions/<slug>.md`. Then delete the processed sections from the queue file (delete the file when empty). Revise pages only after the wave's commit (step 7), and commit each revised page with its queue file as soon as its subagent finishes (`Revise topic page: <topic>`), so a cut-off leaves at most one page half-done (see section 0).
3a. **Queued note updates.** When the user's personal `<personal>/Misc/notes_to_update.md` lists 10 or more notes (`library.py check` prints the count), or the user asks, apply them after the wave's commit (step 7), before or alongside the topic-page revisions (never to a note a page subagent is editing, since those only edit topic pages). Make the edits that need no PDF yourself; give each note with `[PDF]` items to its own `high` subagent, which checks the PDF and edits only that note. Check each change against the notes it cites before making it, and skip (and report) any that turn out to be wrong. Delete each note's section from the file once done, run `library.py build` and `check`, and commit the notes with the file: `Apply queued note updates: <n> notes`.
4. **Data tables:** append the subagent's data rows to `<library>/data/*.csv` (columns in `<library>/data/README.md`). Check that the header matches and the `note` key is right. Then run `library.py datacheck --quiet --note <key>` for each note that gained rows. For every value it reports as not found, look at the PDF page. If the value came from a figure, fix `how`. If it was copied wrongly, fix the value. If pdftotext garbled it, leave it.
5. **File the PDFs:** `library.py file` moves each new PDF in `attachments/papers/` into `attachments/papers/<first topic>/` and updates the note's `pdf` field and PDF line. Order each note's `topics` most significant first before this.
5a. **Fix existing mentions of each new paper.** Older notes, topic pages and research questions may mention the paper before it had a note. For each new paper, grep `<library>/paper_notes/`, `topics/` and `research_questions/` (in a research question whose `author` is not the user, don't edit: list the stale mention in the reply for its author) for its old PDF filename and stem (from the results file), its DOI, and its first author's surname on the same line as its year. Also grep for `_Unprocessed` and `_Off_Topic` in case older notes still name folders. Confirm each hit is this paper (match venue or title, not just author and year), then rewrite it in place to link the new note, e.g. `Suzuki & Lele 2003 (JFM 490, now [indexed](suzuki-2003-….md))`. Do this for "Candidates for `/add-paper`" items, "not in the library" remarks, "PDF held, not yet indexed" remarks and stray filenames. Add the key to `related` only when the note discusses the paper, not when it just lists it as a candidate. Edit only the lines that mention the paper. If a change needs more than a link (for example, a note's claim about the paper turns out to be wrong), queue it in `notes_to_update.md` instead. Remove the paper from `<personal>/Misc/Papers_to_get.md`, and if it is a group paper, update its row in `<personal>/Misc/group_papers.md` (both personal; skip if absent). Rerunning this is safe: an existing link is no longer a stale mention.
6. `library.py build` (regenerates `INDEX.md` and `references.bib`), then `library.py check`. Fix every ERROR; fix WARNs about the new notes.
7. Commit the new notes, the notes and topic pages changed in step 5a, queue files, data tables, `SCHEMA.md` (if changed), `INDEX.md` and `references.bib` together, on the run's branch. Stage these files by name, never `git add -A` or `git add .`, so nothing else in the working tree is swept in. Never stage anything under `Misc/` (personal; see above); stage a research question only if step 5a changed one of the user's own. Use `Add reference note: <short title>` for one paper, or `Add reference notes: <n> papers` for several. The PDFs stay untracked because `.gitignore` excludes `*.pdf*`, and PDFs outside the repo are never copied in.
8. Only after the commit succeeds, delete the wave's `<key>.return.md` files.

**Push.** When the run is done, show the user the changes (`git -C <library> log --stat @{u}..HEAD`) and ask before pushing. Then `git -C <library> pull --rebase` and push. If the maintainer chose a branch, push it and open a PR to `MonashUniversity-ShockLab/Library_of_Shock_Lab` instead (`gh pr create --fill`, adding the list below to the body). A maintainer working through the weekly sync stops at the commit.

**File the PDFs on Market.** Run this only after the library changes are pushed (or committed, for the weekly sync), so Market never gets ahead of the notes. If `<market>` isn't reachable (step 0a), skip it and list each PDF with its destination path for a maintainer to file by hand. Otherwise use the library's mirror tool, never hand-written copy commands:
1. **Dry run:** `python <library>/tools/market_sync.py --market <market> --clear-unprocessed`. It plans, for every note, putting its PDF at `<market>/<rel>` (`<rel>` = the note's `pdf` field): `MOVE` a same-named PDF from elsewhere on Market (e.g. its old topic folder), `COPY` the local PDF (size checked), or nothing if it is already there; `COLLIDE` is a different file in the way (never overwritten), `MISSING` a PDF found nowhere. `CLEAR` lists the Market `_Unprocessed/` originals that are byte-identical to a filed copy. Nothing changes in a dry run.
2. Show the user the plan (the action lines and the summary) and ask before applying. Report each `COLLIDE` and `MISSING` for the maintainer to sort out by hand; don't work around them.
3. Once the user agrees, run the same command with `--apply` and report its result line and any `FAILED` lines. The tool only ever touches PDFs inside `<market>`, never overwrites, and removes nothing except the identical `_Unprocessed/` originals.
4. The tool does not handle PDFs this run moved to `_Off_Topic/` or `_Deferred/` (they have no note): move each Market `_Unprocessed/` original to the same folder on Market, never overwriting, after asking.

Finish by listing each paper with its note link, its old → new PDF filename (and any rename that was skipped or failed), its Market copy (filed and removed from `_Unprocessed`, or the collision or failure), the existing mentions rewritten in step 5a (which files), the topic contributions queued (with the queue sizes now), any topic pages revised (and any change to the consensus or open questions), and the parts to check against the PDF.

## Per-paper procedure

1. Run `pdfinfo <pdf>` to get the page count and metadata.
2. **Extract the text.** Try the Read tool with `pages` (max 20 per call). If it fails (some PDFs are reported as "password-protected" even when they aren't), run `pdftotext -layout <pdf> <scratchpad>/<name>.txt` and read that. Write to the scratchpad, never into the repo. If the extracted text is empty, the PDF is scanned and needs OCR; report this instead of guessing.
3. Read the **entire** paper, including tables, figure captions and the conclusion.
4. **Rename the PDF** to `Authors_Year_Title.pdf`, using the authors, year and title from the paper itself (not the old filename or `pdfinfo` metadata, which are often wrong). Underscores separate the three fields only, so:
   - **Authors:** surnames joined by hyphens: one author `Tam`, two `Raiola-Kriegseis`, three or more `Nogueira-EtAl`. Keep multi-word surnames as one word (`EdgingtonMitchell`, `VonSaldern`).
   - **Year:** of publication (or the arXiv/thesis year).
   - **Title:** the full title, words joined by hyphens, first letter of each word capitalised as in the paper; drop punctuation; cut at a word boundary to keep the title part to about 80 characters.
   - Transliterate accents to plain ASCII (`Brès` → `Bres`) and never use `\ / : * ? " < > |`.
   - Example: `Raiola-Kriegseis_2025_Hilbert-POD-A-Tool-For-Educing-Advective-Wavepackets-From-Flow-Field-Data.pdf`.

   Rename in place in the same folder with `mv -n` (quote both paths; UNC paths like `//server/share/...` work from Git Bash). Skip this if the file already has the right name. If a file with the target name already exists, don't overwrite it: it is probably a duplicate, so stop and report it. If the rename fails (e.g. the file is open elsewhere or the folder is read-only), keep the old name and report it. Then recompute the index key (section 1 rule) from the **new** path and use it as the note's `pdf` field. When re-indexing a paper that already has a note, the `pdf` field must change to the new name too.
5. Read the topic page(s) the paper belongs to (`<library>/topics/`), so the note's Relevance section and your topic contribution can say how the paper fits what is already known.
6. Write the note at `<library>/paper_notes/_incoming/<firstauthor>-<year>-<short-title-slug>.md` (lowercase, hyphens; the main session moves it into `<library>/paper_notes/`, so write its links as if it were already there), starting with the frontmatter. Fill every field as SCHEMA.md describes, using its controlled vocabulary only; leave `cites` as `[]` (the main session fills it).
7. Write the results file (below), **last**: it is what marks the note as finished.

## Note template

```
---
(frontmatter: every field in SCHEMA.md, each value a JSON literal)
---
# <Title>
![[attachments/papers/<pdf field>]]   (PDF embed, directly under the title; see SCHEMA.md)
- **Authors / Source / DOI or arXiv / PDF (index key, page count) / Tags**
## Summary              (3–5 sentences, own words)
## Key findings         (bullets with numbers, each with page refs "(p. N)"; the most important first)
## Relevance to this project  (heading kept verbatim, tools match it: how the paper bears on the group's research threads and on the writer's research and projects as described in their own CLAUDE.md; link related notes)
## Setup / method       (geometry, conditions table, diagnostics, numerics, key parameters)
## Key equations        (LaTeX, with eq. numbers, page refs and notation)
## Data tables          (only quantitative tables worth reusing)
## Figures worth remembering  (fig number, page, what it shows)
## Notation
## Own analysis         (optional: the note writer's own derivations, worked examples, re-derived or recomputed values, readings beyond what the paper says)
```

**Front-loaded.** The first three sections (Summary, Key findings, Relevance) must stand on their own, in about 1,500–2,000 words: a reader who stops there has the paper's main results with their numbers and page refs, and knows how it bears on the user's work and on related notes. The sections after them are reference detail to look things up in. Older notes put Relevance last; section names, not order, are what tools and readers rely on, so either order is valid.

**Own analysis goes last.** Anything that is the note writer's reasoning rather than the paper's content (worked examples, recomputed or re-derived values, figure-slope readings turned into new quantities, "my reading of eq. N") goes in `## Own analysis`, each item labelled with what it rests on. Keep only a one-line pointer to it in Key findings or Relevance when it matters there. Short checks of the paper's own arithmetic, flagged misprints and figure readings of plotted values stay where they belong in the earlier sections.

**Length.** Aim for about 400–600 words per PDF page, up to about 8,000 words for the whole note, scaled to how much the paper contains (a dense theory paper sits at the top of the range, a short conference paper with few figures at the bottom). This is a soft target, not a cap: a note may go past it when the content needs it (a long review, a thesis chapter set, many tables worth reusing), and the results file then says why in one line. Never pad to reach it, and never cut a number, page reference or correction to meet it; trim repetition, restated background and `Own analysis` first.

## Results file

Write `<library>/paper_notes/_incoming/<note key>.return.md` (next to the note) containing the items below, then reply to the main session with only the two paths and the old → new PDF filename. The file, not the reply, is what the main session works from, so a cut-off main session loses nothing. It holds:
- the note path, and the old → new PDF filename (or why the rename was skipped)
- **topic contributions:** for each topic in the note's `topics`, 3–8 sentences saying how the paper fits that thread: what it adds, with page refs and key numbers; which existing notes it agrees with or contradicts (by key); and whether it changes the current understanding or an open question on the topic page
- **data rows:** CSV lines for any table in `<library>/data/README.md` whose kind of value the paper reports (e.g. screech frequencies, shock spacing, impinging tones, rocket-noise parameters), with the exact column order of that table and the `how` column filled. Say "none" if there are none
- vocabulary values you needed but SCHEMA.md lacks (with the stand-in you used)
- the parts to check against the PDF

## Rules

- Paraphrase; quote only short phrases. Every claim and number gets a page reference.
- PDF extraction often garbles equations and tables. Rebuild them where you can and check them (for example, by recomputing sums), then add a `> ` note saying what to verify against the PDF. Never present a guess as exact.
- **Cover every part of the analysis equally.** Capture modelling and simulation (stability analyses, reduced-order models, LES/DNS, theory) in the same depth as the experiments: governing equations, assumptions, base flow, numerics, resolution, boundary conditions, and how well the model matches the experiment. The Relevance section should say how both sides could inform the user's work.
- **Note how each method depends on the data.** For every analysis technique (statistics, POD, SPOD, BMD, DMD, wavenumber filtering, phase-averaging, etc.), record whether it needs time-resolved data, its key parameters (snapshots, block size and overlap, windowing, filters) and its preprocessing. In the Relevance section, say which methods suit time-resolved data and which suit non-time-resolved data like PIV, (time-resolved schlieren and acoustics suit SPOD and BMD; snapshot PIV suits POD and POD mode pairs). Highlight anything about intermittency, mode switching, or how frequency and amplitude change over time, along with methods that resolve this (Hilbert POD, Hilbert transforms, wavelets, SPOD-based reconstruction or filtering). These feed the group's SPOD → reconstruction → Hilbert POD pipeline.
- **Facility attribution:** if the experiments come from the Shock Lab group ("The Shock Lab" is the research group; its physical lab spaces are the Shock Lab, Combustion Lab and TABLE Lab), name the lab space (Shock Lab, Combustion Lab or TABLE Lab) only when the paper states it. Otherwise write "Shock Lab group facility".
- Cross-link related notes in `<library>/paper_notes/` (and list them in `related`), and point out where a paper agrees with or contradicts another.
- **Never name a PDF's folder or filename** in a note's text, for this paper or any other. `/add-paper` renames PDFs and moves them into topic folders, so names like `_Unprocessed/`, `div-class-title-…pdf` or `Alkislar-EtAl_2003_…` go stale. The only exception is the note's own `pdf` field and PDF line, which `library.py file` keeps up to date. To refer to another paper, use authors, year and venue. Then link its note if it has one. If its PDF is held but has no note, add "(PDF held, not yet indexed)". If it is listed in `Papers_to_get.md`, add "(in `Papers_to_get.md`)". To find out which applies, run `library.py find` and grep `<library>/attachments/papers/` and `<personal>/Misc/Papers_to_get.md`.
- **Citation details:** take DOI, volume, pages and year from the PDF. Anything you add from memory goes in `unverified`, so the BibTeX entry carries a warning.
- The `summary` field is one plain-text line of about 160 characters: it becomes the paper's line in `INDEX.md`.
