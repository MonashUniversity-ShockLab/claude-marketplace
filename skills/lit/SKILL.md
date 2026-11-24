---
name: lit
description: Answer a research question from the Shock Lab paper library (the Library_of_Shock_Lab repo, found via $SHOCKLAB_KNOWLEDGE), e.g. what the literature says about a topic, which papers used a given method, data type or flow condition, how a result compares with published ones, what is still unresolved, or which papers to cite. Works from the topic pages, frontmatter search, data tables and notes, and cites note and page. Use when the user runs /lit, asks "what does the literature say about…", "which papers…", "has anyone measured…", "how does this compare with…", or needs citations or BibTeX for writing.
argument-hint: "<question>"
---

# Answer from the literature

## Where the library is

`<library>` in this skill is the root of the group's paper library: the folder that holds `SCHEMA.md`, `paper_notes/`, `topics/`, `data/` and `tools/` (normally your clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`). Resolve it once at the start and use the absolute path everywhere:

1. the path in the environment variable `SHOCKLAB_KNOWLEDGE`, if it is set;
2. otherwise `./Library_of_Shock_Lab` in the working directory, if it exists;
3. otherwise the working directory itself, if it contains `SCHEMA.md`.

If none of these exists, stop and tell the user to clone the library and set `SHOCKLAB_KNOWLEDGE` (see "Setting up a new lab member" in the `MonashUniversity-ShockLab/claude-marketplace` repo). `<library>/SCHEMA.md` and the library's own `CLAUDE.md` (if present) are the authority on layout, frontmatter and naming; follow them over anything here.

The helper scripts need only standard Python 3: run them as `python <library>/tools/library.py <command>`. If `python` is not on PATH, try `python3` or `py -3`, or the `python` of any conda env; ask the user once if none works.

The library is described in `<library>/SCHEMA.md`. In short: `topics/*.md` hold the cross-paper synthesis, `paper_notes/*.md` hold one paper each (frontmatter + body with page refs), `data/*.csv` hold numbers collected across papers, `references.bib` has BibTeX keyed by note slug, `INDEX.md` lists every paper and topic page, and `<library>/tools/library.py` searches the frontmatter. If the clone is a git repo, run `git -C <library> pull --ff-only` first (skip quietly if it fails, e.g. offline).

## 1. Work out what kind of question it is

| Question | Start here |
| --- | --- |
| A research thread ("what sets A1/A2 staging?", "is the guided jet mode needed for impingement tones?") | The topic page(s) in `<library>/topics/` (pick from the grouped list in `INDEX.md`), then the notes they cite |
| A filter ("TR schlieren of rectangular jets at NPR > 3", "papers using HPOD on PIV") | `library.py find`, e.g. `find --data schlieren-TR --flow rectangular-jet --param NPR --long`; `find --methods HPOD`; `find --topics screech-staging-and-mode-switching --since 2020` |
| Numbers ("published A2 St at M_j 1.15", "η for Falcon 9") | `<library>/data/*.csv` (columns in `data/README.md`), then the cited note and page |
| One paper | Its note (find the key with `find --author` / `--text`) |
| What cites what ("who built on Tam 1986?") | `grep -l '"tam-1986-bbsan-screech-relationship"' <library>/paper_notes/*.md` matches both `cites` and `related`; the note's own `cites` shows its in-library references. `cites` is matched automatically from reference lists, so treat it as a strong hint, not proof |
| Citations for writing | `references.bib` (key = note slug); warn about entries carrying `UNVERIFIED` |

If no topic page fits, say so and fall back to `find` plus Grep over `<library>/paper_notes/` (use `-n` and read only the matching sections).

## 2. Read only what you need

- Read the topic page first; it says which papers matter and where they disagree. Then always read its queue, `<library>/topics/_queue/<topic>.md`, if it exists: pages are revised only in batches, so the queue holds new papers not yet worked in (marked "(synthesis pending)" on the page) and corrections from note audits (`## audit: <key>` sections). Where a queued correction's `Current:` text matches what the page says, use its `Replace with:` version instead, and treat a page claim with a queued `major` correction as wrong. Cite the note, not the queue.
- For each paper, read the note's Summary and Key findings, and the sections the question needs (Setup / method for conditions, Key equations for models). Grep inside a note for specific terms rather than reading all of it.
- Notes indexed before the audits began are thinner and may hold errors until `/paper-audit` reaches them. An audited note has an `audited: "YYYY-MM-DD"` frontmatter field; `library.py find --unaudited` lists the rest. Say so when an answer rests on an un-audited note.
- If answering needs more than about six notes in depth, give the question and the list of note paths to a `general-purpose` subagent and ask it for a cited synthesis (claims with note key + page, agreements, contradictions), so the full notes don't fill this session.
- Open a PDF (path from the note's `pdf` field, under `<library>/attachments/papers/`; see SCHEMA for how keys map to files) only for exact wording, a figure, or a derivation the note doesn't have, using the page numbers in the note. PDFs are not in git; if one is missing, work from the note and tell the user it isn't in their copy of the Market `papers` folder.
- **Large documents** (manuals, handbooks, books) have a hub note plus part notes (`part_of` in their frontmatter) for only some chapters. Check the hub's Coverage table: for a chapter with no part note, find the pages with `library.py search <hub key> "<regex>"` (prints PDF pages and matching lines) and read just those pages from the hub's PDF, citing them as `p. N (PDF)`. If a chapter keeps coming up, suggest `/add-large-document <hub key> --chapter <N>`.

## 3. Answer

- Lead with the answer. Back each claim with a citation in the form [Author Year](<library>/paper_notes/<key>.md), p. N.
- Cover modelling and simulation (linear stability, resolvent, reduced-order models, LES/DNS) as fully as experiment. Keep the two apart where they disagree, and say how well the models match the data.
- State disagreements and open questions plainly, and say which view the stronger evidence supports.
- Say what the library does **not** cover. You may add papers you know of from outside it, but label them "not in the library" and, if they look worth having, suggest adding them with `/add-paper` (or list them in the user's own `<personal>/Misc/Papers_to_get.md`, a personal file that is not committed to the shared repo; `<personal>` is the folder in `SHOCKLAB_PERSONAL` if set, else `<library>/../My_Knowledgebase` if it exists, else `<library>`).
- Never present your own background knowledge as coming from a note. Flag details the notes mark as unverified or figure-read.
- For the user's own data or results, relate them to the published values (data tables, topic pages), and say what is new or at odds. Use the user's own `CLAUDE.md` for what their research and projects are.

## 4. Write back

The topic pages should improve with use. If the answer produced synthesis the topic page lacks, such as a new cross-paper comparison, a contradiction, a sharper statement of an open question, or a correction, finish by offering to add it to `<library>/topics/<topic>.md` in one line. If the user agrees, edit the page in its existing structure (SCHEMA.md "Topic pages"), update its "Last updated" line, and run `library.py check`. Fix outright errors on a topic page (wrong number, broken link) without asking, and mention it.

Only maintainers edit topic pages and notes. A maintainer is someone with push access to the shared library repo who says so, or whose own `CLAUDE.md` says so. For anyone else, don't edit them (this includes the error fixes above): give the suggested addition or correction in a few lines (page, section, supporting notes with page refs) for the user to pass to a maintainer or put in an issue. A maintainer commits the change on the current branch, shows the diff and asks before pushing (or opens a PR if they prefer).
