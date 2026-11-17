---
name: restructure-note
description: Reshape already-audited reference notes in the Shock Lab paper library (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE) to the add-paper Note template's structure and length rules (Summary, Key findings and Relevance first; own analysis in a late section; about 400–600 words per PDF page up to about 8,000), without reopening the PDF and without losing any number, page reference or link. Progress is kept in the user's personal Misc/restructure_ledger.tsv so runs resume; maintainers only; changes are pushed to the shared repo. Use only when the user runs /restructure-note or asks to restructure, reshape or shorten the audited notes.
argument-hint: "[N notes | <note key> ... | status | next]"
effort: high
---

# Restructure audited notes

**Maintainers only.** This skill changes paper notes, which only maintainers edit. A maintainer is someone with push access to the shared library repo who says so, or whose own `CLAUDE.md` says so. If the user is not a maintainer, don't run it: tell them to report a wrong note to a maintainer or in an issue (naming the note and the page of the paper), and stop. If it isn't clear, ask once.

`/paper-audit` checked these notes line by line against their PDFs, so their content is trusted. What changed afterwards is the shape a note should have (the paragraphs after the Note template in the `add-paper` skill's `SKILL.md`, in the `add-paper/` folder next to this skill's own folder): Summary, Key findings and Relevance first and readable on their own in about 1,500–2,000 words; the writer's own derivations and worked examples in `## Own analysis` near the end; and about 400–600 words per PDF page, up to about 8,000. This skill reshapes a note to those rules **as an editing job only**: no PDF, nothing added, nothing corrected, nothing correct lost.

## Where the library is

`<library>` in this skill is the root of the group's paper library: the folder that holds `SCHEMA.md`, `paper_notes/`, `topics/`, `data/` and `tools/` (normally your clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`). Resolve it once at the start and use the absolute path everywhere:

1. the path in the environment variable `SHOCKLAB_KNOWLEDGE`, if it is set;
2. otherwise `./Library_of_Shock_Lab` in the working directory, if it exists;
3. otherwise the working directory itself, if it contains `SCHEMA.md`.

If none of these exists, stop and tell the user to clone the library and set `SHOCKLAB_KNOWLEDGE` (see "Setting up a new lab member" in the `MonashUniversity-ShockLab/claude-marketplace` repo). `<library>/SCHEMA.md` and the library's own `CLAUDE.md` (if present) are the authority on layout, frontmatter and naming; follow them over anything here.

The helper scripts need only standard Python 3: run them as `python <library>/tools/library.py <command>`. If `python` is not on PATH, try `python3` or `py -3`, or the `python` of any conda env; ask the user once if none works.

`library.py` and `restructure_check.py` mean `python <library>/tools/<script>`.

**Pull first.** `git -C <library> switch main` and `git -C <library> pull --ff-only` (if the switch is refused because of uncommitted changes, show them and ask; an earlier run may have left the clone on its pull-request branch), and commit on the current branch (normally `main`); the run ends with a push (section 3). If the maintainer prefers a pull request, create a branch now (e.g. `restructure/YYYY-MM-DD`) for every commit below. A maintainer working in their own repo for the weekly sync skips the switch and just commits there.

**Personal files.** `<personal>` is the user's personal folder for these files, outside the shared repo: the path in the environment variable `SHOCKLAB_PERSONAL` if it is set, else `My_Knowledgebase/` next to the library (`<library>/../My_Knowledgebase`) if it exists, else `<library>` itself (the old layout, where `Misc/` is git-ignored). Research questions are not personal: they are shared in `<library>/research_questions/`, each with its `author`. The library tools find it the same way (`library.personal_dir()` in `<library>/tools/library.py`). The ledger `<personal>/Misc/restructure_ledger.tsv`, the flags file `<personal>/Misc/restructure_flags.md`, and the audit ledger and `notes_to_update.md` it reads, are the user's own working files: not part of the shared repo and never committed to it. Create the ledger and flags file when missing (headers below).

**Project relevance.** A restructure changes no content, so it neither adds project text nor moves existing project text out of a note (that would fail `restructure_check.py compare`). Project-specific Relevance text stays where it is; the next `/paper-audit` of the note moves it to the user's `<personal>/Project_Paper_Relevance/` files (see "Project relevance is personal" in the add-paper skill). A restructure adds no link to or mention of anything outside the library either (SCHEMA "Nothing outside the library").

## Settings

| Setting | Value | Why |
| --- | --- | --- |
| Policy | **Reorder only by default.** Over-target notes are also just reordered (`reorder --write <keys>`; ledger `still_over` yes) and left long. A full subagent restructure runs only for notes the user names | A full restructure of a long note costs a lot of tokens and typically trims only a few per cent of its length; the reorder gives most of the gain for free |
| Order | `restructure_check.py candidates`: audited notes not yet restructured and more than 10% over their word target, most over first | Only length needs a subagent; the longest notes cost every reader the most |
| Order-only notes | `restructure_check.py reorder --write` moves Relevance up in every in-target note with Relevance last, changing nothing else, and logs them in the ledger; commit them by name. A long front (over about 2,000 words) is left for the note's next audit. `reorder --unaudited --write` does the same for notes not yet audited, with no ledger rows | A section move needs no subagent tokens |
| Notes per run | 10 by default (`N` overrides, at most 30) | Keeps this session's context and the usage window small |
| Wave size | 3 restructurers in parallel; check, move and commit each wave before the next | A long note costs about the same with a larger or smaller model (the cost is mostly reading and rewriting the note), so batches are worth running when usage is otherwise idle |
| Restructurer | `note-restructurer` subagent (shipped with this skill's plugin as `shocklab-library:note-restructurer`; Sonnet, only Read/Write/Edit/Bash, the template inline), `effort: "medium"` | It edits text it is given; the hard reading was done by the audit, and `compare` guards against losses |
| Drafts | `<library>/paper_notes/_restructure/<key>.md` (git-ignored) | The live note is untouched until the check passes |
| Ledger | `<personal>/Misc/restructure_ledger.tsv` (personal, not committed) | Lets runs resume and report progress |
| Flags | `<personal>/Misc/restructure_flags.md` (personal, not committed) | Possible errors seen while editing, for the next audit or the user; never fixed here |

## 0. Mode

From `$ARGUMENTS`:
- **`status`:** restructured / audited notes (ledger against `paper_audit.tsv`), how many audited notes are still over target (`restructure_check.py candidates | tail -1`) and how many need only the reorder (`restructure_check.py reorder | tail -1`), and the next 5. No other work.
- **`next`:** the batch the next run would take, with words, pages and issues. Stop.
- **`<note key> …`:** restructure those notes, even if in the ledger or not audited (say so if a note was never audited: its content hasn't been checked against the PDF, so the restructure only reshapes it).
- **A number `N`**, or **empty:** under the reorder-only policy, run `reorder` mode on the next N (default 10) candidates by key (`reorder --write <keys>`), not subagents. Say that full restructures need the notes named.
- **`reorder`:** run `restructure_check.py reorder --write`, then `library.py check`, and commit the moved notes by name, on the current branch ("Restructure reference notes: Relevance moved up in <n> notes (script, no other change)"); the ledger is personal and stays uncommitted. Then push as in section 3. No subagents.

## 1. Gates

1. **Leftover drafts.** For each `_restructure/<key>.md` from a cut-off run: if its `<key>.result.md` exists, check and fold it (section 3); otherwise delete the draft and put the note first in this run's batch (a restructure is cheap to redo, unlike an audit).
2. **Skip** any note that is in `paper_notes/_audit/` or `paper_notes/_incoming/` (an audit or add-paper run is working on it), has uncommitted changes (`git status --short -- <note>`), or is named in `<library>/paper_notes/_queue/notes_to_update.md` with items still open (the restructure would compete with that edit; let `/paper-audit`'s section 4 apply them first). Say which were skipped.
3. Never touch PDFs, topic pages, data tables, `notes_to_update.md`, `notes_to_check.md` or the audit ledger. This lets this skill run beside `/paper-audit` and `/add-paper` without their files colliding.

## 2. Launch restructurers

For each note in the wave, write down the live note's `git hash-object` (to detect a change while the wave runs), then launch one `note-restructurer` subagent (`subagent_type: "shocklab-library:note-restructurer"`, or `"note-restructurer"` for an agent file copied into `~/.claude/agents/`; `effort: "medium"`), 3 in one message. The agent definition holds the rules and the template; its prompt is just:

> Library: `<absolute path of the library root>`. Note: `<library>/paper_notes/<key>.md` (<pages> PDF pages; word target <lo>–<hi>; now <words> words; issues: <issues>).

If `note-restructurer` isn't available (agent definitions load at session start), use a `general-purpose` subagent with `model: "sonnet"`, `effort: "medium"`, and a prompt telling it to read the `note-restructurer.md` agent file (`${CLAUDE_PLUGIN_ROOT}/agents/note-restructurer.md` when installed as a plugin, or wherever the user copied it) and follow it for that note.

## 3. Check, fold and commit a wave

For each note:
1. Read its `<key>.result.md` (not the note). Run `restructure_check.py compare <key>` yourself; it must print "OK: nothing lost" and no frontmatter change. If not, send the restructurer back (SendMessage) once; if it still fails, delete the draft, log the note under "Rejected" in the report, and move on.
2. The page-ref occurrence count may fall only where repetition was cut. If it fell by more than about a third, or the note shrank by more than 45%, read `git diff --no-index --word-diff=color` around a few cuts before accepting.
3. If the live note's `git hash-object` changed since launch, discard the draft and leave the note for the next run.
4. `mv -f <library>/paper_notes/_restructure/<key>.md <library>/paper_notes/<key>.md`.
5. Append the result file's possible errors to `<personal>/Misc/restructure_flags.md` under `## <key> (YYYY-MM-DD)` (skip if that heading exists). Create the file with a one-line header if missing: "Possible errors noticed while restructuring notes (not checked against the PDF). Fold into `<library>/paper_notes/_queue/notes_to_check.md` or the next audit."
6. Append a ledger row to `<personal>/Misc/restructure_ledger.tsv`, creating it with this header if missing: `key	restructured	words_before	words_after	pages	target	still_over	moved_to_own_analysis	note` (tab-separated; `still_over` yes/no; `note` one short line, e.g. the reason it is over target).
7. Delete `<key>.result.md`.

Then `library.py check` (it must show no new ERROR or WARN for these notes), and commit the wave's notes by name, on the current branch (the ledger and flags file are personal and stay uncommitted): `git commit -m "Restructure reference notes: <n> notes (structure and length rules, no content change)" -- <paths>`. The notes' frontmatter is unchanged, so `INDEX.md` and `references.bib` need no rebuild.

After the last wave, show the user `git -C <library> log --stat @{u}..HEAD` and ask before pushing; then `git -C <library> pull --rebase` and push. If the maintainer chose a branch, push it and open a PR to `MonashUniversity-ShockLab/Library_of_Shock_Lab` instead (`gh pr create`, with the report as the body). Then put the clone back on `main` (`git -C <library> switch main` and `git -C <library> pull --ff-only`), so the next run, an overnight run and `/lit` start from merged work; the branch's changes leave the working tree until the pull request merges (git-ignored files such as the PDFs in `attachments/papers/` stay). For the weekly sync, stop at the commit.

Context budget: as `/paper-audit` (stop starting waves once compacted or past about 200k).

## 4. Report

Short, in chat: per note, words before → after, what moved to Own analysis, and whether it is still over target and why; notes rejected or skipped and why; new items in `restructure_flags.md`; progress (restructured / audited, candidates left) and the next notes; the commits and whether they were pushed (or the PR link).
