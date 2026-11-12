---
name: update-topics
description: Maintainers only. Work the contributions queued in the Shock Lab paper library's topic queues (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE; topics/_queue/<page>.md, from /add-paper, /paper-audit and /research-question) into their topic pages, every page with anything queued, major corrections first, then the largest queues; then apply the queued note updates (paper_notes/_queue/notes_to_update.md). One subagent per page, each page committed with its queue file as it finishes, so a cut-off loses at most one page. Token-heavy (a page revision costs about as much as a paper note). Use when the user runs /update-topics, or asks to "update/revise the topic pages" or "clear the topic queues".
argument-hint: "[<page> ... | N pages] [--no-notes | --notes-only] [--pr]"
effort: high
---

# Revise the topic pages from their queues

`/add-paper`, `/paper-audit` and `/research-question` don't rewrite topic pages for every paper: they queue each contribution in `<library>/topics/_queue/<page>.md`, and add-paper only revises a page once its queue reaches 10 items or 3 weeks. This skill clears the queues on demand, page by page, plus the queued note updates that members' runs leave behind. The revision procedure itself is the one in `/add-paper` (section 3 step 3, "To revise", and step 3a), not a copy of it here, so the two never drift apart.

## 0. Who may run it

**Maintainers only.** Revising a page rewrites synthesis that every member's queue entries feed into, and two branches revising the same page conflict badly, so the group keeps this to people with push access to the library. Check it: `gh api repos/MonashUniversity-ShockLab/Library_of_Shock_Lab --jq .permissions.push`. If that prints `true`, or the user's own `CLAUDE.md` says they are a library maintainer, go on. Otherwise say that topic pages are revised by maintainers, that their queued contributions are already read by `/lit` and `/research-question` alongside the page, and stop.

## 1. Setup

- **`<library>`** is the path in `SHOCKLAB_KNOWLEDGE` (the clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`): the folder with `SCHEMA.md`, `paper_notes/`, `topics/` and `tools/`. Resolve it once and use the absolute path. `library.py` means `python <library>/tools/library.py`.
- **`<add-paper>`** is the add-paper skill's `SKILL.md`: in the folder next to this skill's own (this skill's base directory, with `update-topics` replaced by `add-paper`). Give its absolute path in every subagent brief.
- **`<personal>`**: `SHOCKLAB_PERSONAL` if set, else `<library>/../My_Knowledgebase` if it exists, else `<library>` (as add-paper says). The progress file is `<personal>/Misc/update_topics.progress` (personal, never committed), lines `<page>\t<in-progress|done>\t<commit or ->`, one run at a time.
- **Say what it costs before starting** (skip this when the run is unattended and the user approved it when scheduling): each page revision costs about as much as writing a paper note. Show the plan (step 2's list, with queue sizes) and ask how many pages to do, defaulting to all.

**Pull first.** `git -C <library> pull --ff-only`. A maintainer may commit on `main` and push at the end. With `--pr`, or when the run is unattended (scheduled overnight), create a branch now, `update-topics/<github-login>-YYYY-MM-DD`, and put every commit on it; it ends in a pull request instead.

## 2. Resume, then choose the pages

1. **Resume a cut-off run.** Read the progress file. A page marked `in-progress` was cut off mid-revision by this user's own earlier run. Its uncommitted changes to the page and its queue file are that run's half-done revision: discard both (`git -C <library> restore -- topics/<page>.md topics/_queue/<page>.md`; the queue sections come back with it) and put the page first in this run's list. Only ever discard a page the progress file marks `in-progress`.
2. **Leave alone** any topic page or queue file with uncommitted changes the progress file doesn't explain (someone is editing it), and any page changed in an open pull request to the library (`gh pr list --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --state open --json number,files`): revising it now would conflict. Say which and why.
3. **The list.** If the user named pages, those (if they have anything queued; a page with an empty queue is skipped and said so). Otherwise every page with queued contributions (`library.py topics`, `queued` column, or the "Topic contributions queued" line of `library.py check`), in this order: pages with a major correction queued (`library.py check` lists them; a `**major.**` heading in the queue file), then the largest queue, then the oldest item. `N pages` caps the count. Never create a topic page or revive one listed under "Retired topic names" in `SCHEMA.md`; a queue file for a retired page is reported, not revised.

## 3. Revise, one page per subagent

At most 2 page subagents run at once, and never two on the same page. For each page:

1. Write `<page>\tin-progress\t-` to the progress file.
2. Launch one `general-purpose` subagent with `effort: "high"`. Its brief: "Revise the topic page `<library>/topics/<page>.md` from its queue file `<library>/topics/_queue/<page>.md`. Read `<add-paper>` section 3 step 3 ('To revise') and follow it exactly, and read `<library>/SCHEMA.md` (topic page template and the guidance on length) and the library's `CLAUDE.md`. Work only the queue sections that exist now, delete exactly those from the queue file (delete the file if it is then empty) and leave any others. Edit only that page and its queue file; read notes as needed but don't edit them. Don't commit, don't ask anything. If the page would grow well past about 5,000 words, keep the content and say which thread should become its own page. Reply in at most 12 lines: contributions worked in, claims corrected (was / now), contributions rejected and why, word count before → after, and any split suggestion."
3. When it returns, check the diff is limited to the page and its queue file (`git -C <library> diff --stat`). Then commit just those two paths by name: `Revise topic page: <page>` (never `git add -A` or `.`). Mark the page `done` in the progress file with the commit hash.
4. **Stop starting new pages** once any of these holds: the page cap is reached, the session has been compacted during this run, or you judge the context is past about 200k. Let a running subagent finish and commit its page. If the usage limit cuts the run off, the next run resumes from step 2.1.

After the pages, `library.py build` and `library.py check`; fix ERRORs and commit any rebuild (`INDEX.md`, `references.bib`).

## 4. Queued note updates

Unless `--no-notes`, apply every note queued in `<library>/paper_notes/_queue/notes_to_update.md`, following `<add-paper>` section 3 step 3a exactly (with `--notes-only`, do this and skip sections 2 and 3). Work in batches of about 6 notes, one `high` subagent per note that needs a PDF, at most 2 at once, never on a note another subagent is editing. After each batch: delete exactly the finished notes' sections from the queue file (keep sections added since, and items the agent left), `library.py build` and `check`, and commit those notes with the file by name: `Apply queued note updates: <n> notes`. Same stopping rules as section 3.

## 5. Land it and report

- **Push.** Show the user `git -C <library> log --stat origin/main..HEAD` and ask before pushing (an unattended run has that approval from scheduling). On `main`: `git -C <library> pull --rebase` and push. On a branch: `git -C <library> fetch origin` and `git -C <library> rebase origin/main`. On a conflict in `INDEX.md` or `references.bib`, take either side and run `library.py build`; in a queue file, keep the other side's new sections and drop only the ones this run worked in; on a topic page or note, abort the rebase, push the branch as it is and say so in the pull request (unattended) or show the user (attended). Then `library.py build` and `check`, commit any rebuild, push the branch and open a pull request to `MonashUniversity-ShockLab/Library_of_Shock_Lab` with the report as the body; the PR agent merges it.
- **Clear the progress file** of `done` lines once the commits are pushed.
- **Report:** pages revised (contributions worked in, main corrections, words before → after, split suggestions), pages skipped and why (uncommitted edits, open pull request, retired, cut off), queue sizes left (`library.py topics`), notes updated and items skipped, the `check` result, and the commits or pull request link.
