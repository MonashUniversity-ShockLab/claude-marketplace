---
name: paper-audit
description: Audit existing reference notes in the Shock Lab paper library (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE), oldest-indexed first, against their PDFs and everything the library has learned since; deepen and correct each note to today's /add-paper standard and repair what its earlier, thinner reading caused elsewhere (topic pages, other notes, data tables). Progress is kept in the user's personal Misc/paper_audit.tsv so runs resume; maintainers only; changes are pushed to the shared repo. Use only when the user runs /paper-audit or asks to audit or re-check the early paper notes.
argument-hint: "[N papers | <note key> ... | status | next] [--until YYYY-MM-DD] [--light] [--no-topics]"
effort: high
---

# Audit the early paper notes

**Maintainers only.** This skill changes paper notes and topic pages, which only maintainers edit. A maintainer is someone with push access to the shared library repo who says so, or whose own `CLAUDE.md` says so. If the user is not a maintainer, don't run it: tell them to report a wrong note to a maintainer or in an issue (naming the note and the page of the paper), and stop. If it isn't clear, ask once.

The first `/add-paper` waves (15 and 19 October 2026, 109 notes) were written before the library had topic pages, before much of the vocabulary existed, in waves of 16–36 papers, and with less depth than later waves (about 3,800 words a note against about 6,000). Their gaps may have spread: topic pages and later notes were built on them. This skill re-reads each paper and fixes both the note and what it misled. It works oldest-indexed first and keeps a ledger, so it can run a few papers at a time over many sessions.

## Where the library is

`<library>` in this skill is the root of the group's paper library: the folder that holds `SCHEMA.md`, `paper_notes/`, `topics/`, `data/` and `tools/` (normally your clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`). Resolve it once at the start and use the absolute path everywhere:

1. the path in the environment variable `SHOCKLAB_KNOWLEDGE`, if it is set;
2. otherwise `./Library_of_Shock_Lab` in the working directory, if it exists;
3. otherwise the working directory itself, if it contains `SCHEMA.md`.

If none of these exists, stop and tell the user to clone the library and set `SHOCKLAB_KNOWLEDGE` (see "Setting up a new lab member" in the `MonashUniversity-ShockLab/claude-marketplace` repo). `<library>/SCHEMA.md` and the library's own `CLAUDE.md` (if present) are the authority on layout, frontmatter and naming; follow them over anything here.

The helper scripts need only standard Python 3: run them as `python <library>/tools/library.py <command>`. If `python` is not on PATH, try `python3` or `py -3`, or the `python` of any conda env; ask the user once if none works.

Library layout and vocabulary: `<library>/SCHEMA.md`. `library.py` means `python <library>/tools/library.py`. This skill reuses `/add-paper`'s procedures (the `add-paper` skill's `SKILL.md`, in the `add-paper/` folder next to this skill's own folder), referred to below as "add-paper §n".

**Pull first.** Pull (`git -C <library> pull --ff-only`) and commit on the current branch (normally `main`); the run ends with a push (section 4). If the maintainer prefers a pull request, create a branch now (e.g. `paper-audit/YYYY-MM-DD`) for every commit below. A maintainer working in their own repo for the weekly sync just commits there.

**Personal files.** `<personal>` is the user's personal folder for these files, outside the shared repo: the path in the environment variable `SHOCKLAB_PERSONAL` if it is set, else `My_Knowledgebase/` next to the library (`<library>/../My_Knowledgebase`) if it exists, else `<library>` itself (the old layout, where `Misc/` is git-ignored). Research questions are not personal: they are shared in `<library>/research_questions/`, each with its `author`. The library tools find it the same way (`library.personal_dir()` in `<library>/tools/library.py`). The ledger `<personal>/Misc/paper_audit.tsv`, and `<personal>/Misc/notes_to_update.md` and `notes_to_check.md`, are the user's own working files: not part of the shared repo and never committed to it. Create any that is missing (the ledger with a tab-separated header row of the columns `key`, `first_indexed`, `audited`, `mode`, `effort`, `words_before`, `words_after`, `outcome`, `changes`). Because the ledger is personal, two members can audit the same note; before a run, check open PRs to the shared repo (`gh pr list --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --search "Audit"`) and skip notes already being audited there.

**Project relevance is personal.** Follow the paragraph of that name in the add-paper skill's `SKILL.md`: text about the user's own projects goes to `<projects>` = `<personal>/Project_Paper_Relevance/` (one file per project, entries appended at the end), not into the shared note. An audit also **moves** project-specific text already in the old note's Relevance section out to `<projects>`, leaving the general point in the note. Decide `<projects>` once, at gate 5, and pass it to every auditor and to the fold.

## Settings

| Setting | Value | Why |
| --- | --- | --- |
| Order | `library.py added --pending`: oldest first-indexed day first; within a day, the notes most linked from other notes, topic pages and research questions first; large documents (PDF ≥ 80 pages, marked "large: last") after everything else | The oldest notes are the thinnest, and the most-linked ones have spread the most. Large documents need one auditor per chapter range, several usage windows each, so they wait for a dedicated run (`/paper-audit <key>`) rather than blocking the queue |
| Papers per run | 12 by default (`N` overrides, at most 20) | Keeps this session under its context budget |
| Wave size | 2 auditors in parallel; fold and commit each wave before the next | A full audit uses a large share of a usage window, so wider waves rarely finish inside one |
| Auditor effort | `medium` for normal papers; `high` for complex ones (those in add-paper §2's `high` list: theory- or modelling-heavy, exact-method, reviews and theses including each chapter auditor, papers central to the group's threads or the user's own projects, garbled or scanned PDFs) and for any paper the user names for it; never `xhigh` | `xhigh` costs far more for little gain, and `high` for every paper is costly too; the PDF still gets a full re-read either way |
| Mode | `full` (re-read the whole PDF); `light` with `--light` or when the PDF is missing | `light` fixes tags, links and relevance only |
| Long documents (about 80+ pages) | one auditor per chapter range, as add-paper §2 | Theses won't fit one auditor's context |
| Topic pages | revised when a queue reaches 10 or its oldest item is over 3 weeks old (add-paper §3 step 3), and once at the end of the run for a queued major correction; unless `--no-topics` | A revision costs about as much as an audit, however small the change, and one wave can make several pages due |
| Ledger | `<personal>/Misc/paper_audit.tsv` (personal, not committed) | Lets runs resume and report progress |
| Scope | everything, oldest first; `--until YYYY-MM-DD` limits it to notes first indexed by then (e.g. `--until 2026-10-19` for the two early waves) | |

### Context budget: 250k tokens

The main session must stay under **250,000 tokens** of context. A skill cannot set the context window itself, so the budget is kept by design:
- **Auditors** run as the `paper-auditor` subagent (shipped with this skill's plugin, where its `subagent_type` is `shocklab-library:paper-auditor`; `paper-auditor` if the agent file was copied into `~/.claude/agents/`), which sets `autoCompactWindow: 250000` for each auditor. All the heavy reading (PDF, old note, topic pages, later notes) happens there.
- **The main session never reads PDFs, whole notes or whole topic pages.** It works from the auditors' results files, tool output and `git diff --stat`. The exception is merging a long document's chapter drafts.
- **The fold runs in a subagent** (section 3), so a wave costs only a few thousand tokens here. Folding in the main session costs tens of thousands of tokens a wave.
- **Per-run cap:** with the fold delegated, a dozen or more waves plus the topic-page revisions should fit (in practice the usage limit stops a run first). Stop starting new waves once any of these holds: the run's paper count is reached; the session has been compacted during this run; or you judge the context is past about 200k. Finish and commit the wave in flight, then report. The next run resumes from the ledger.
- The session's own auto-compact window comes from the user's settings. For a hard 250k limit on the main session too, the user can start the audit session with `/autocompact 250k`. Mention this once in the first report if the run stopped on the budget.

## 0. Mode

From `$ARGUMENTS`:
- **`status`:** print progress and stop: notes audited / total, and for the two early waves (`library.py added --until 2026-10-19` against the ledger; `library.py find --audited` counts notes with an `audited:` date); counts by outcome; the next 5 pending notes (`library.py added --pending --limit 5`). No other work.
- **`next`:** list the batch the next run would take (with effort and mode you would give each) and stop.
- **`<note key> …`:** audit those notes, even if already in the ledger (a re-audit adds a new ledger row).
- **A number `N`:** audit the next N pending notes (at most 20).
- **Empty:** the next 12 pending notes.
- Flags: `--until`, `--light`, `--no-topics` as in Settings.

## 1. Gates and resume

1. **Resume a cut-off audit.** In `<library>/paper_notes/_audit/` (git-ignored):
   - `<key>.audit.md` present: the audit finished but wasn't folded. Fold these first (section 3); the fold is safe to repeat.
   - `<key>.md` or `<key>.progress.md` without `<key>.audit.md`: unfinished (cut off, usually by the usage limit). Don't delete anything: put that paper first in this run's batch and launch its auditor in **resume** mode (section 2 step 3), which carries on from the draft and the progress log. Same for `<key>.parts/` drafts. If an auditor from this same session was cut off, send it a message (SendMessage) once the limit resets instead of launching a new one.
2. **Another session at work.** Stop and report, changing nothing, if `<library>/paper_notes/_incoming/` holds files (an `/add-paper` run is in flight or cut off; let it finish first), or the user says another audit session is running on this clone.
3. **Uncommitted changes** (`git status -- Library_of_Shock_Lab`): never stage or overwrite them. Leave out of this run's batch any note that has uncommitted changes, and say so. Don't revise a topic page that has uncommitted changes (add-paper §0). Other uncommitted files are left alone.
4. **Unindexed PDFs** waiting in `attachments/papers/_Unprocessed/` (`library.py unindexed`): mention the count; don't index them here.
5. **Project files.** If `<personal>/Project_Paper_Relevance/` exists (and `<personal>` is not the library), `<projects>` is that folder; list its project files. If not, ask the user once as the add-paper skill describes (create it, or keep project text in the notes for now). In an unattended run don't ask: `<projects>` is "none", and auditors keep project text in the note under bold project labels, as before.

## 2. Pick the batch and launch auditors

1. `library.py added --pending [--until …] --limit <N + a few>`, then drop notes excluded by gate 3. Without explicit keys, also drop notes marked "large: last" unless nothing else is pending; audit those only when named (`/paper-audit <key>`). For specific keys, take those.
2. For each note, find its PDF from the `pdf` field (`<library>/attachments/papers/<pdf>`, or the absolute path). No PDF → `light` mode, and say so. Run `pdfinfo` for the page count (long documents are split by chapter range). Effort is `medium`, or `high` for a complex paper (Settings); skim the abstract and headings to decide, and use `high` when unsure.
3. Launch one `paper-auditor` subagent per paper (`subagent_type: "shocklab-library:paper-auditor"`, or `"paper-auditor"` for a copied agent file; `effort` as set), 2 per wave in one message. The agent definition holds the whole audit procedure, so the prompt only needs: the absolute path of `<library>`, the absolute path of the add-paper skill's `SKILL.md`, the note key, its first-indexed date, the PDF path (or "no PDF"), the mode, the chapter range for a long document, `<projects>` (its path and project files, or "none"), and the path of a recent note to copy the style of (one first indexed on or after 2026-10-24, on a similar kind of paper). For a cut-off paper, add "Resume: a draft and progress log exist in `_audit/`".
4. Wait for the wave. Work from the results files, not the replies, and hand them to the fold subagent (section 3).

## 3. Fold a wave in and commit

Only the fold edits the live notes, topic pages, queues, data tables and personal `<personal>/Misc/` files, one wave at a time, never while auditors or a topic revision are writing. Every step must be safe to repeat after a cut-off: check before appending (queue headings, ledger rows, CSV rows).

**Delegate the fold.** Once a wave's results files are written, launch one `general-purpose` subagent (`effort: "high"`) to fold the whole wave, and wait for it. Its brief: the wave's note keys, today's date and `<projects>` (path or "none"); "Read section 3 of `<absolute path of this SKILL.md>`, `<library>/SCHEMA.md` and the library's `CLAUDE.md`; `<library>` is `<absolute path>`; fold these audits by steps 1–14, including the commit on the current branch, but don't push"; that it may not ask the user anything, discard uncommitted changes or edit outside `<library>`; and that it replies in at most 20 lines: per note, words before → after, outcome and the main corrections (was / now); topic pages made due or with a major correction queued; note updates queued; datacheck misses and how each was settled; anything rejected or left for the next run (step 1) and why; the `check` result; and the commit hash. The main session uses that reply for the report. If the fold subagent is cut off, resume it by message, or launch a new one with the same brief (the steps are safe to repeat). Run the fold in the main session only for a long document's chapter merge (step 2), or if subagents can't be launched.

Steps 6–8 are scripted in `<library>/tools/audit_fold.py` (both safe to repeat): `audit_fold.py queues <key> <date>` does steps 6 (except the Papers lines and unmarked corrections) and 7 (except removing resolved items), and `audit_fold.py rows <key> <csv>` replaces a note's rows in one table (step 8, before the datacheck).

1. **Check each revised note before replacing the live one.** `git diff --no-index --stat <library>/paper_notes/<key>.md <library>/paper_notes/_audit/<key>.md`, the word counts, and the `key:` line. If the revised note is more than 10% shorter, or the key changed, read the diff around the cuts; accept removals only when the results file justifies them (tightening to the add-paper length target counts, provided no correct number, page reference or claim is lost; so does project text moved to the results file's **Project relevance** items), otherwise send the auditor back (SendMessage) or leave the paper for the next run and say so. If it is longer than the add-paper length target (about 400–600 words per PDF page, up to about 8,000) and the results file gives no reason, say so in the fold reply; don't reject it for that alone.
2. **Long documents:** merge the chapter drafts in `_audit/<key>.parts/` into one revised note, collect their `## Audit findings` into `<key>.audit.md`, and delete the `.parts/` folder.
3. **Replace the notes:** `mv -f <library>/paper_notes/_audit/<key>.md <library>/paper_notes/<key>.md`. Then `library.py audited <keys…>`, which sets each note's `audited:` frontmatter field to today's date (on the line after `unverified`; a re-audit replaces the old date). That field is the shared record of audit status that every clone sees; the ledger (step 12) stays the maintainers' detailed record.
4. **Vocabulary:** add or substitute proposed values as add-paper §3 step 1.
5. **Citations:** `library.py cites --write <keys…>`.
6. **Topic contributions:** append each to `<library>/topics/_queue/<topic>.md` as `## audit: <key> (queued YYYY-MM-DD)`. These count towards the page's revision threshold. Copy the contribution's **Corrections** (exact Current / Replace with / Why items) and **Additions** as given, with links rewritten relative to the queue file (`../../paper_notes/…`). **Never edit a topic page during the fold**, not even to fix a wrong claim, a page reference or a Papers line: every change goes in the queue, so each page is revised once, in one pass, from all its queued items. The one exception: if the note gained a topic, add its line to that page's Papers list, ending "(synthesis pending)". Keep each correction's `major` / `minor` mark. A **major** correction (it reverses or overturns a claim on the page, wherever it sits) makes the page due once, at the end of this run (section 4), whatever its queue size; `library.py check` lists such pages under "Major corrections queued". Minor corrections (page references, hedges, numbers, wording) wait for the queue threshold. If an auditor left a correction unmarked, judge it yourself and add the mark. Note the pages made due for the report.
7. **Note updates for other notes:** append the items to the personal `<personal>/Misc/notes_to_update.md` under `## <other note key>` (create the section if missing). Remove items about the audited notes themselves that the audit resolved.
7a. **Project relevance** (only when `<projects>` is a folder): append each results file's **Project relevance** items to the end of the named `<projects>` files, as `### [<key>](../../Library_of_Shock_Lab/paper_notes/<key>.md) (note, <today>, /paper-audit)` with the paper title in italics and the bullets below it (create the file for a new project as the add-paper skill describes). Skip an item whose heading with today's date and `/paper-audit` is already there. Never write above a line starting `<!-- END OF EXTRACTED TEXT`. These files are personal: never stage them.
8. **Data rows:** for each CSV the results file names, replace all rows with that `note` key by the rows given. Check the header and column order. Then run `library.py datacheck --quiet --note <key>`, and look at the PDF page for each value reported as not found (fix `how` if the value was read from a figure).
9. **notes_to_check.md** (personal, in `<personal>/Misc/`; skip if absent): delete each resolved item from the paper's line, and the line once nothing is left.
10. **Mentions elsewhere:** if the PDF was renamed, update its old filename wherever it appears (add-paper §3 step 5a).
11. `library.py file`, then `library.py build`, then `library.py check`. Fix every ERROR and the WARNs about the audited notes.
12. **Ledger:** append one row per note to `<personal>/Misc/paper_audit.tsv` (tab-separated, columns as its header): `key`, `first_indexed`, `audited` (today), `mode`, `effort`, `words_before`, `words_after`, `outcome`, `changes` (one short line: the main corrections and additions).
13. **Commit** the audited notes and every file changed in steps 4–11, staged by name (never `git add -A` or `git add .`, and never anything under `Misc/`; research questions belong to their authors, so don't edit them: name any that need a change in the reply), on the current branch: `Audit reference notes: <n> papers` (or `Audit reference note: <short title>`).
14. After the commit succeeds, delete the wave's `.audit.md` files.

Then check the context budget before starting the next wave.

## 4. After the last wave

- Unless `--no-topics`: revise the topic pages `library.py check` lists as due (10+ contributions or oldest over 3 weeks) or under "Major corrections queued" (section 3 step 6), once each, one `high` subagent per page (add-paper §3 step 3; it treats `## audit:` sections like paper contributions, except that the Papers line already exists and only its role text may change). Commit each page with its queue file as it finishes.
- If `notes_to_update.md` lists 10 or more notes, apply them as add-paper §3 step 3a.
- **Push.** Show the user `git -C <library> log --stat @{u}..HEAD` and ask before pushing. Then `git -C <library> pull --rebase` and push. If the maintainer chose a branch, push it and open a PR to `MonashUniversity-ShockLab/Library_of_Shock_Lab` instead (`gh pr create`, with the report below as the body). For the weekly sync, stop at the commit.
- If an audit renamed a PDF, offer to copy the renamed file to the same relative path under the Market folder `Z:\Library_of_Shock_Lab\papers\` (`cp -n`; never overwrite or delete there), so other members' copies match the note's `pdf` field.

## 5. Report

In chat, keep it short:
- each audited note (link), its outcome, words before → after, and the main corrections ("was / now");
- errors that had spread: topic-page claims, other notes or data rows that were wrong because of the old note, and where the fix went (fixed in the note or data table, or queued for the topic page);
- topic contributions queued (queue sizes now) and pages revised;
- note updates queued for other notes;
- anything skipped and why (uncommitted, no PDF, auditor output rejected);
- progress: audited / total notes (and of the 109 early-wave notes), and the next notes in line;
- why the run stopped (count reached, budget, cut-off), the commits and whether they were pushed (or the PR link).
