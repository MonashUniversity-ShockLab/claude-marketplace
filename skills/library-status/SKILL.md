---
name: library-status
description: Snapshot of the Shock Lab paper library's pending work (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE). It first brings the clone up to date (git pull --ff-only on main) and files indexed papers' PDFs on Market (market_sync.py, after one confirmation), so the report is current; otherwise it changes nothing. It reports contributions queued for each topic page (topics/_queue/, with pages due for revision and major corrections), queued note updates (paper_notes/_queue/notes_to_update.md), open items in notes_to_check.md, the paper-audit queue (notes not yet audited, next in line, audits in progress), PDFs waiting in Market _Unprocessed/ (free, claimed or stale), indexed papers whose PDF isn't filed on Market yet, a library health line (library.py check), and open pull requests to the library. It is cheap: no subagents and no PDFs read. Use when the user runs /library-status, or asks "what's queued in the library", "how many papers are waiting", "which topic pages need revising" or "library status".
argument-hint: "[topics | notes | audits | papers] [--list]"
effort: low
---

# Library status

A quick report of what is waiting to be done in the shared paper library, and which skill clears each part. It makes exactly two changes, both so the report reflects the current state: it fast-forwards the clone to `origin/main` (section 1, "Freshness") and files indexed papers' PDFs on Market (section 1a). **Change nothing else:** don't commit, merge, rebase, switch branches, claim, release, edit a queue or start any processing. Apart from those two steps, run only the read-only commands below, then report.

`$ARGUMENTS` may name sections to show (`topics`, `notes`, `audits`, `papers`; default all). The setup checks and the health line are always shown. With `--list`, also list every free Market paper by name (otherwise only the count and the claimed ones).

## 1. Setup

- **`<library>`**: the path in `SHOCKLAB_KNOWLEDGE`; else `./Library_of_Shock_Lab` in the working directory if it exists; else the working directory if it has `SCHEMA.md`. If none, say the library isn't set up (see "Setting up the paper library" in the `MonashUniversity-ShockLab/claude-marketplace` README) and stop.
- **Python**: `python`, else `python3` or `py -3`, else any conda env's `python`. `library.py` means `python <library>/tools/library.py`, and `paper_claim.py` means `python <library>/tools/paper_claim.py`. Both need only the standard library.
- **Freshness.** Every count below comes from the local clone, so bring it up to date first. Run `git -C <library> branch --show-current`.
  - On `main`: run `git -C <library> pull --ff-only`. Report how many commits it brought in (or that it was already up to date). `--ff-only` never merges or rewrites anything; if it refuses (local commits not yet pushed, e.g. a maintainer's weekly sync, or uncommitted edits to files the pull would change), don't force it, stash or merge: report git's message, then run `git -C <library> rev-list --count HEAD..origin/main` and say the counts may be that many commits stale.
  - On any other branch (usually a run in progress, e.g. `add-paper/...`): don't pull or switch. Run `git -C <library> fetch --quiet origin` and `git -C <library> rev-list --count HEAD..origin/main`, and say the counts are from that branch and how many commits of `main` it lacks.
  - If the network is unreachable, say the counts are as of the last pull.

  Also note any uncommitted changes under `topics/_queue/` or `paper_notes/_queue/` (`git -C <library> status --short -- topics/_queue paper_notes/_queue`): queue items someone has added but not committed yet.
- **Health line.** Run `library.py check`. Its summary line reads `<n> notes, <e> errors, <w> warnings, <u> PDFs in attachments/papers without a note`. Report the note count, the error count and the warning count, and group the `ERROR` and `WARN` lines by kind (the text after the key, e.g. "PDF not found", "broken link"), giving a count for each kind. List every `ERROR` line, since errors mean the library is inconsistent and someone should fix them. A "PDF not found" warning usually only means this clone lacks that PDF (PDFs are git-ignored, and copies come from Market), so say that instead of calling it a library fault. Ignore the queue lines at the end of `check`: sections 2 and 3 cover them.

## 1a. File the add-paper PDFs on Market

This is the "file the add-paper PDFs on Market" step of `/add-paper`, run here so Market holds the PDF of every note already on `main` and the `_Unprocessed/` counts in section 4 are current. Do it before sections 2–4, since filing also clears `_Unprocessed/` originals and their claims. Do it even when `$ARGUMENTS` doesn't ask for the `papers` section.

- **Only from an up-to-date `main`,** so Market never gets ahead of the notes: the clone must be on `main` with `git -C <library> rev-list --count HEAD...origin/main` (three dots) giving `0` after the freshness step, i.e. neither behind nor holding unpushed commits. Otherwise skip this step, say why (on a branch, pull refused, or local commits not on `main` yet), and section 4 reports the dry run only.
- **Dry run:** `python <library>/tools/market_sync.py --clear-unprocessed` (no `--apply`). It finds Market itself; if it exits with a setup problem (Market not mounted), say filing was skipped and why, and go on. Keep its output: section 4 reports from it.
- If its plan has no `MOVE`, `COPY` or `CLEAR` lines, there is nothing to file: say so in one line and go on.
- Otherwise show the user the plan in brief (the `Plan:` summary line and the `MOVE`/`COPY`/`CLEAR` lines, or their counts if there are more than 15) and ask once whether to apply it. On yes, run the same command with `--apply` and keep its result line and any `FAILED` lines for the report. On no, leave it, and section 4 reports the dry run. The tool only touches PDFs inside Market, never overwrites, and removes nothing except `_Unprocessed/` originals byte-identical to a filed copy, and their claim files.
- Never work around `COLLIDE`, `MISSING` or `REFUSED` lines, and never write your own copy or move commands: section 4 reports those lines for a person to sort out.

## 2. Topic queues

Run `library.py topics`. Its columns are `page, papers, words, updated, queued, oldest, flags`, under `-- <group>` header lines. From the rows with `queued` > 0, report:

- the totals: queued contributions and the number of pages that have any;
- pages flagged `revision due` (10 or more queued, or the oldest more than 21 days old; a maintainer's next `/add-paper` or `/paper-audit` run revises these, and anyone can with `/update-topics`);
- pages with a **major correction** queued: queue files in `<library>/topics/_queue/` with a heading containing `**major.**` (search for it). List these first, since a major correction means the page currently says something wrong;
- a table of pages with queued items, largest queue first: page, queued, oldest. If there are more than 15, show the top 15 and give a count for the rest;
- any queue file whose page doesn't exist in `<library>/topics/` (for example a retired name in `SCHEMA.md` "Retired topic names"). Report it; never fix it here.

**Pages being revised:** run `paper_claim.py list --topic` (section 4 explains how `paper_claim.py` finds Market; if Market isn't reachable, say this part is unavailable). Report `mine`, `taken` (who, how long ago, branch) and `stale` claims: those pages are being revised by an `/update-topics` or maintainer run, so their queues will shrink once its pull request merges. Give only the count of `done` claims (finished revisions; their claims are kept on purpose, so don't suggest cleaning them up). If the tool says `--topic` is unknown, the clone predates topic claims: say so and skip this.

Pages flagged `over 5k words` are not part of the queue, but mention them in one line, because they are candidates for a split when they are next revised.

## 3. Note queues

Both files are in `<library>/paper_notes/_queue/`. Count from the file; don't summarise every item.

- **`notes_to_update.md`** (queued changes to existing notes): the number of notes (`## <note key>` sections) and of items (`- ` bullets under them), and how many items are marked `[PDF]` (they need the PDF to confirm). List the note keys if there are 10 or fewer. A maintainer's `/add-paper` run applies them in a batch once 10 or more notes are listed, and `/update-topics` (anyone) applies them on demand.
- **`notes_to_check.md`** (parts of notes still to verify against the PDFs): the number of open lines (`- ` bullets), split into per-paper lines and those under the `# Cross-note inconsistencies` heading. Then say how many of the per-paper lines say `audited` and how many don't. Lines with no audit are the ones `/paper-audit` will most likely resolve. `/paper-audit` deletes each item it resolves.
If a file is missing, say so (no queue yet). Don't create it.

## 3a. Audit queue

The queue `/paper-audit` works through is `library.py added --pending`: notes not yet audited, oldest first-indexed day first, the most-linked first within a day. Its last line is `(<n> notes)`. Documents of 80 pages or more end with `large: last` and come after everything else, because each needs a dedicated run (`/paper-audit <key>`).

- **Progress:** notes audited / total. The audited count is the `(<n> notes)` last line of `library.py find --audited`, and the total is the note count from the health line. Audited plus pending should equal the total.
- **Pending:** the `<n>` from the last line, and how many of those are `large: last`.
- **Next in line:** the first 5 pending notes that are not `large: last` (key, first-indexed date). Run `paper_claim.py list --audit --keys <those keys>` and give each one's claim state, so the user can see which ones someone else is already auditing.
- **Audits in progress:** run `paper_claim.py list --audit`. Report claims in the states `mine`, `taken` (who, how long ago, branch) and `stale` (claimed more than 14 days ago). `done` claims are finished audits whose claim is kept on purpose, as a second guard against re-auditing a note (they are cleared once every note is audited): give only their count, and don't suggest cleaning them up.

## 4. Papers waiting on Market

Run `paper_claim.py list`. It finds Market itself (`SHOCKLAB_MARKET_PAPERS`, else the one mounted drive with `Library_of_Shock_Lab/papers`), and gets the user's GitHub login from `gh`. If it can't find the login, rerun it with `--as <login>` if the user's login is known, else with `--as nobody` (then nothing shows as `mine`). Exit status 2 means a setup problem, usually Market not mounted. In that case, report the message, say the Market count is unavailable, and never guess a path. If Market's drive differs between PCs, the user can set `SHOCKLAB_MARKET_PAPERS`.

Its first line is `# <n> waiting: <free> free, <mine> mine, <taken> taken, <stale> stale`. Report:

- those counts;
- each `mine` paper (this user's own claim, maybe from a cut-off `/add-paper` run: resume it, or release it with `paper_claim.py release`);
- the `taken` papers grouped by who claimed them, with age and branch;
- `stale` papers (claimed more than 14 days ago: ask the claimant before taking one over);
- the free papers: their count, and their names with `--list` or when there are 15 or fewer. When the names show a clear cluster (for example many on one subject), say so in one line.

Local `attachments/papers/_Unprocessed/` is not reported: Market is where requests wait.

**Indexed but not filed on Market.** Report from the `market_sync.py` dry run in section 1a (if 1a was skipped before the dry run, e.g. on a branch, run `python <library>/tools/market_sync.py --clear-unprocessed` now, with **no `--apply`**: without it, it only prints a plan and nothing changes). Its `Plan:` line counts PDFs already there, to move, to copy, collisions, missing everywhere, refused, and to clear from `_Unprocessed`. Report:

- what section 1a filed: the `--apply` result line (moved, copied, cleared) and any `FAILED` lines. If filing was skipped or declined, give the PDFs it would have moved or copied, and why it didn't (filing them is then one step from an up-to-date `main`: ask Claude to "file the add-paper PDFs on Market");
- each `MISSING` line: a note whose PDF is neither on Market nor in this clone. Usually the paper was processed before `/add-paper` renamed Market originals too, so the renamed PDF exists only in the processor's clone and the original waits in `_Unprocessed/` under its old name. Find the note whose `pdf` field is that path (search `paper_notes/` for it), then find who added it (`git -C <library> log --diff-filter=A --format="%an %ad" --date=short -- paper_notes/<key>.md`). Group the lines by that person, who is the one to file them;
- each `COLLIDE` or `REFUSED` line, as it is: a person sorts those out by hand;
- the number of `_Unprocessed` originals cleared (or that would be, if filing was skipped).

If Market isn't reachable, skip this along with the rest of the section.

## 5. Open pull requests

If `gh` is available and signed in, run `gh pr list --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --state open --json number,title,author,headRefName,updatedAt`. List each PR on one line: number, title, author, last updated. Queue items and notes in an open PR are not on `main` yet, so they are missing from the counts above. A PR from an `add-paper/` branch usually explains `taken` Market claims. If `gh` is unavailable, skip this section and say so.

## 6. Report

Keep it short: a heading per section asked for, with counts first and then the lists. Use one table for the topic queues; everything else fits in bullets. Mention problems only when there are some. End with the next actions this state calls for, at most five lines, each naming the skill or person that clears it:

- errors in the health line → fix them (`library.py check` names each one);
- PDFs still not filed on Market → the person who added each `MISSING` note asks Claude to "file the add-paper PDFs on Market" from their own clone; if section 1a was skipped or declined, this user can file the rest from an up-to-date `main`;
- free Market papers → `/add-paper` (anyone; token-heavy, about 150k–200k tokens per paper);
- topic pages due for revision, or major corrections queued → `/update-topics` (anyone; it claims each page, 3 pages per member run by default);
- 10 or more notes in `notes_to_update.md` → `/update-topics --notes-only` (anyone), or let the next maintainer `/add-paper` run apply them;
- notes waiting in the audit queue, or open `notes_to_check.md` lines → `/paper-audit` (token-heavy, a large share of a usage window per note);
- the clone still behind `origin/main` (the pull was refused, or it is on a branch) → sort out what blocked it, then `git -C <library> pull --ff-only` on `main`.

Any of these can be run unattended overnight with `/schedule-library-processing`. Don't start any of them: apart from the pull and the Market filing, this skill only reports.
