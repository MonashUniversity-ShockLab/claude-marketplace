---
name: library-status
description: Read-only snapshot of the Shock Lab paper library's pending work (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE). It reports contributions queued for each topic page (topics/_queue/, with pages due for revision and major corrections), queued note updates (paper_notes/_queue/notes_to_update.md), open items in notes_to_check.md, the paper-audit queue (notes not yet audited, next in line, audits in progress), PDFs waiting in Market _Unprocessed/ (free, claimed or stale), indexed papers whose PDF isn't filed on Market yet, a library health line (library.py check), and open pull requests to the library. It changes nothing and is cheap: no subagents and no PDFs read. Use when the user runs /library-status, or asks "what's queued in the library", "how many papers are waiting", "which topic pages need revising" or "library status".
argument-hint: "[topics | notes | audits | papers] [--list]"
effort: low
---

# Library status

A quick read-only report of what is waiting to be done in the shared paper library, and which skill clears each part. **Change nothing:** don't pull, commit, claim, release, edit a queue, run `market_sync.py --apply` or start any processing. Run only the read-only commands below, then report.

`$ARGUMENTS` may name sections to show (`topics`, `notes`, `audits`, `papers`; default all). The setup checks and the health line are always shown. With `--list`, also list every free Market paper by name (otherwise only the count and the claimed ones).

## 1. Setup

- **`<library>`**: the path in `SHOCKLAB_KNOWLEDGE`; else `./Library_of_Shock_Lab` in the working directory if it exists; else the working directory if it has `SCHEMA.md`. If none, say the library isn't set up (see "Setting up the paper library" in the `MonashUniversity-ShockLab/claude-marketplace` README) and stop.
- **Python**: `python`, else `python3` or `py -3`, else any conda env's `python`. `library.py` means `python <library>/tools/library.py`, and `paper_claim.py` means `python <library>/tools/paper_claim.py`. Both need only the standard library.
- **Freshness.** Run `git -C <library> fetch --quiet origin` (read-only, never `pull`), then `git -C <library> rev-list --count HEAD..origin/main`. Every count below comes from the local clone, so if it is behind, say by how many commits, that the counts may be stale, and that `git -C <library> pull` brings it up to date. If the fetch fails (offline), say the counts are as of the last pull. Also note any uncommitted changes under `topics/_queue/` or `paper_notes/_queue/` (`git -C <library> status --short -- topics/_queue paper_notes/_queue`): queue items someone has added but not committed yet.
- **Health line.** Run `library.py check`. Its summary line reads `<n> notes, <e> errors, <w> warnings, <u> PDFs in attachments/papers without a note`. Report the note count, the error count and the warning count, and group the `ERROR` and `WARN` lines by kind (the text after the key, e.g. "PDF not found", "broken link"), giving a count for each kind. List every `ERROR` line, since errors mean the library is inconsistent and someone should fix them. A "PDF not found" warning usually only means this clone lacks that PDF (PDFs are git-ignored, and copies come from Market), so say that instead of calling it a library fault. Ignore the queue lines at the end of `check`: sections 2 and 3 cover them.

## 2. Topic queues

Run `library.py topics`. Its columns are `page, papers, words, updated, queued, oldest, flags`, under `-- <group>` header lines. From the rows with `queued` > 0, report:

- the totals: queued contributions and the number of pages that have any;
- pages flagged `revision due` (10 or more queued, or the oldest more than 21 days old; `/add-paper` revises these on its next run);
- pages with a **major correction** queued: queue files in `<library>/topics/_queue/` with a heading containing `**major.**` (search for it). List these first, since a major correction means the page currently says something wrong;
- a table of pages with queued items, largest queue first: page, queued, oldest. If there are more than 15, show the top 15 and give a count for the rest;
- any queue file whose page doesn't exist in `<library>/topics/` (for example a retired name in `SCHEMA.md` "Retired topic names"). Report it; never fix it here.

Pages flagged `over 5k words` are not part of the queue, but mention them in one line, because they are candidates for a split when they are next revised.

## 3. Note queues

Both files are in `<library>/paper_notes/_queue/`. Count from the file; don't summarise every item.

- **`notes_to_update.md`** (queued changes to existing notes): the number of notes (`## <note key>` sections) and of items (`- ` bullets under them), and how many items are marked `[PDF]` (they need the PDF to confirm). List the note keys if there are 10 or fewer. `/add-paper` applies them in a batch once 10 or more notes are listed, and `/update-topics` (maintainers) applies them on demand.
- **`notes_to_check.md`** (parts of notes still to verify against the PDFs): the number of open lines (`- ` bullets), split into per-paper lines and those under the `# Cross-note inconsistencies` heading. Then say how many of the per-paper lines say `audited` and how many don't. Lines with no audit are the ones `/paper-audit` will most likely resolve. `/paper-audit` deletes each item it resolves.
If a file is missing, say so (no queue yet). Don't create it.

## 3a. Audit queue

The queue `/paper-audit` works through is `library.py added --pending`: notes not yet audited, oldest first-indexed day first, the most-linked first within a day. Its last line is `(<n> notes)`. Documents of 80 pages or more end with `large: last` and come after everything else, because each needs a dedicated run (`/paper-audit <key>`).

- **Progress:** notes audited / total. The audited count is the `(<n> notes)` last line of `library.py find --audited`, and the total is the note count from the health line. Audited plus pending should equal the total.
- **Pending:** the `<n>` from the last line, and how many of those are `large: last`.
- **Next in line:** the first 5 pending notes that are not `large: last` (key, first-indexed date). Run `paper_claim.py list --audit --keys <those keys>` and give each one's claim state, so the user can see which ones someone else is already auditing.
- **Audits in progress:** run `paper_claim.py list --audit`. Report claims in the states `mine`, `taken` (who, how long ago, branch) and `stale` (claimed more than 14 days ago). `done` claims are finished audits waiting to be cleaned up: give only their count.

## 4. Papers waiting on Market

Run `paper_claim.py list`. It finds Market itself (`SHOCKLAB_MARKET_PAPERS`, else the one mounted drive with `Library_of_Shock_Lab/papers`), and gets the user's GitHub login from `gh`. If it can't find the login, rerun it with `--as <login>` if the user's login is known, else with `--as nobody` (then nothing shows as `mine`). Exit status 2 means a setup problem, usually Market not mounted. In that case, report the message, say the Market count is unavailable, and never guess a path. If Market's drive differs between PCs, the user can set `SHOCKLAB_MARKET_PAPERS`.

Its first line is `# <n> waiting: <free> free, <mine> mine, <taken> taken, <stale> stale`. Report:

- those counts;
- each `mine` paper (this user's own claim, maybe from a cut-off `/add-paper` run: resume it, or release it with `paper_claim.py release`);
- the `taken` papers grouped by who claimed them, with age and branch;
- `stale` papers (claimed more than 14 days ago: ask the claimant before taking one over);
- the free papers: their count, and their names with `--list` or when there are 15 or fewer. When the names show a clear cluster (for example many on one subject), say so in one line.

Local `attachments/papers/_Unprocessed/` is not reported: Market is where requests wait.

**Indexed but not filed on Market.** Run `python <library>/tools/market_sync.py --clear-unprocessed` with **no `--apply`**. Without `--apply` it is a dry run that only prints a plan, and nothing changes. Its `Plan:` line counts PDFs already there, to move, to copy, collisions, missing everywhere, refused, and to clear from `_Unprocessed`. Report:

- the PDFs to move or copy: the clone has them, so filing them is one step (ask Claude to "file the add-paper PDFs on Market", which is the last step of `/add-paper`);
- each `MISSING` line: a note whose PDF is neither on Market nor in this clone. Usually the person who ran `/add-paper` hasn't done the Market step yet, and the renamed PDF exists only in their clone. Find the note whose `pdf` field is that path (search `paper_notes/` for it), then find who added it (`git -C <library> log --diff-filter=A --format="%an %ad" --date=short -- paper_notes/<key>.md`). Group the lines by that person, who is the one to file them;
- each `COLLIDE` or `REFUSED` line, as it is: a person sorts those out by hand;
- the number of `_Unprocessed` originals that would be cleared.

If Market isn't reachable, skip this along with the rest of the section.

## 5. Open pull requests

If `gh` is available and signed in, run `gh pr list --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --state open --json number,title,author,headRefName,updatedAt`. List each PR on one line: number, title, author, last updated. Queue items and notes in an open PR are not on `main` yet, so they are missing from the counts above. A PR from an `add-paper/` branch usually explains `taken` Market claims. If `gh` is unavailable, skip this section and say so.

## 6. Report

Keep it short: a heading per section asked for, with counts first and then the lists. Use one table for the topic queues; everything else fits in bullets. Mention problems only when there are some. End with the next actions this state calls for, at most five lines, each naming the skill or person that clears it:

- errors in the health line → fix them (`library.py check` names each one);
- PDFs not filed on Market → the person who added each note asks Claude to "file the add-paper PDFs on Market" from their own clone (or this user does, for the ones this clone can move or copy);
- free Market papers → `/add-paper` (anyone; token-heavy, about 150k–200k tokens per paper);
- topic pages due for revision, or major corrections queued → `/update-topics` (maintainers);
- 10 or more notes in `notes_to_update.md` → `/update-topics --notes-only` (maintainers), or let the next `/add-paper` run apply them;
- notes waiting in the audit queue, or open `notes_to_check.md` lines → `/paper-audit` (token-heavy, a large share of a usage window per note);
- the clone behind `origin/main` → `git -C <library> pull`.

Any of these can be run unattended overnight with `/schedule-library-processing`. Don't start any of them: this skill only reports.
