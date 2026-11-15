---
name: share-learnings
description: Sweep a lab member's recently changed working documents (project READMEs, test reports, HPC and solver set-up notes, code write-ups, CLAUDE.md files, Claude's project memory) for things the rest of the lab could use, compare them with the ShockLab library (Library_of_Shock_Lab) and report what the library lacks - additions to existing pages, new documents worth writing, items to hold for a decision, and library statements the member's notes show are out of date. Nothing is written until the member picks a batch, which then goes in by pull request. Token-heavy (one subagent per area), so say so before starting. Use when the user runs /share-learnings, or asks "is there anything in my recent notes the lab could use", "what have I learned lately that should go in the library", "check my project docs against the knowledge base", or wants a periodic sweep of their own work for shareable learnings. Not for a new member's first import of everything they have, papers included (import-knowledge), or for writing up one named file or folder (make-reference).
argument-hint: "[folder or repo ...] [since <date>]"
---

# Share what you've learned lately

Most of what a lab member works out ends up in documents written for themselves: a test
report, a set-up log, a project `CLAUDE.md`, Claude's memory for the project. This skill
reads what changed in those documents recently, compares it with the library, and reports
what another member could use that the library doesn't hold yet. The member then picks
what to write, and that batch goes in by pull request.

It sits between two other skills. `/import-knowledge` is the one-off import when someone
joins (everything they have, papers included). `/make-reference` writes up one file or
folder the member already knows is worth sharing. This one is the periodic sweep that
finds the candidates in the first place, so run it every few weeks or after a piece of
work finishes.

The library's `CLAUDE.md` (in `$SHOCKLAB_KNOWLEDGE`) is the authority on where things go,
naming and provenance. Read it first, and follow it over anything here.

**Ground rules**

- **Read-only on the member's files**, and read-only on the library until they approve a
  batch (step 6).
- **Only what is theirs to share.** Skip secrets, personal material, reviews of people and
  supervisor feedback. Three kinds of content are reported under "hold", never proposed
  for writing, until the member says otherwise:
  - *someone else's work*: a document written by another member, or material from another
    research group, is that person's call. Say whose.
  - *confidential or contract work*: only knowledge drawn from public sources can ever be
    proposed, and never the client, the scope or the deliverables.
  - *unpublished research results*: a finding about the physics is not a how-to. It may
    suit `research_questions/` later, if the member wants it shared.
- **The paper library changes only through its own skills.** A learning about a published
  paper, a topic page or a `data/` table becomes a suggestion (a line for
  `topics/_queue/<page>.md` or `paper_notes/_queue/notes_to_check.md` if the member runs
  the library skills, otherwise "Suggested library updates" in the PR), never a direct
  edit.
- **Ask before writing anywhere shared**: once on the batch, once on the diff.

## 0. Setup and scope

- `SHOCKLAB_KNOWLEDGE` points at a clone of `Library_of_Shock_Lab` (else offer the setup
  in `CLAUDE.md` of `MonashUniversity-ShockLab/claude-marketplace`). Run
  `git -C "$SHOCKLAB_KNOWLEDGE" pull --ff-only` before anything else: a clone that is a
  few days behind makes the comparison propose things that are already there. Note the
  commit you compared against.
- **`<personal>`**: `SHOCKLAB_PERSONAL` if set, else the library clone. The skill keeps
  its own records in `<personal>/Misc/` (personal, never committed):
  `share_learnings.tsv`, one line per run, and `share_learnings_<YYYY-MM-DD>.md`, the
  candidate list from that run with what happened to each.
- **Where to look**: the folders or repos in `$ARGUMENTS`; with none, the current
  project. Ask whether other places hold recent work (a second repo, a notes vault, a
  folder on OneDrive).
- **Since when**: the date in `$ARGUMENTS`; else the date of the last run in
  `share_learnings.tsv`; else three weeks ago. Say which you used. Read the last run's
  candidate file too: anything still marked `open` is carried into this run's report as it
  stands, not worked out again.
- **Ask what is off-limits** before reading: confidential or contract projects, folders
  holding other people's documents, results not ready to share.
- **Say what it costs.** Each area gets its own subagent that reads the member's documents
  and the matching library pages. In the run this skill was written from (about 110
  changed documents in five areas), the five agents used 140k to 270k tokens and 4 to 14
  minutes each, about 1.1 million tokens in all, before any writing. Offer to narrow it to
  one or two areas, or to run it when usage is spare.

## 1. List what changed

This step is cheap; do it in the main session. The aim is a list of documents with enough
context to group them, not to read them.

- **Git repos**: commits per document since the date, which shows where the work was:

  ```
  git log --since=<date> --name-only --pretty=format: -- '*.md' '*.txt' '*.rst' | grep -v '^$' | sort | uniq -c | sort -rn
  ```

  Add uncommitted and untracked documents (`git status --porcelain`, `git diff --stat`).
  Drop paths that no longer exist: write-ups get moved, and a brief that names a missing
  file sends an agent hunting.
- **Repos inside the folder** (an app or tool that is its own clone and ignored by the
  outer repo) have their own history: run the same commands there.
- **Folders without git**: documents by modified time
  (`find <folder> -name '*.md' -newermt <date>`).
- **Claude's records of the project**: the project's `CLAUDE.md` (`git log -p --since=<date>
  -- CLAUDE.md` shows what was added) and Claude's memory for it
  (`~/.claude/projects/<project slug>/memory/*.md`, by modified time). These are often the
  densest source, because they hold exactly the things that had to be corrected once.
- **Leave out**: the library clone itself and any link to it, generated indexes, ledgers,
  logs and progress files, feature queues, and data.

Group what is left into areas (step 3) and show the member the list with counts and
sizes. Let them strike documents or whole areas.

## 2. Map the library

Also cheap, also in the main session. Agents compare better when the brief names the
pages to compare against, and you need the map to judge their reports.

- `documentation/_Documentation.md` (its table says what each page is for) and the
  headings of `documentation/Org Gotchas.md`.
- A listing with sizes of `methods/`, `facilities/`, `onboarding/`, `applets/`,
  `codebase_notes/`, `research_questions/` and `generated/`. A page of a few hundred bytes
  is a stub: note it, because the member's material may be what fills it.
- Open pull requests (`gh pr list --repo MonashUniversity-ShockLab/Library_of_Shock_Lab`),
  so nothing already on its way in is proposed again.
- For areas that touch the literature: `data/README.md` and the names in `topics/_queue/`.

## 3. One read-only agent per area

Split the documents into three to five areas so that each document belongs to exactly one
agent. Areas that have worked: cluster and job running; solver or simulation set-up; test
reports and rig-side findings; analysis code and methods; working with Claude, tools and
apps; literature-facing project documents (data tables, model reviews). A small run
(under about ten documents or 100 KB) needs no agents: read it in the main session.

Launch the agents together. Each brief stands alone, because the agent sees none of this
conversation:

```
Read-only gap analysis. Do not edit, create or delete any file, and run no git command
that changes state.

## Context
<folder> is a lab member's own working folder. <library path> is the Shock Lab's shared
knowledge base; <one or two sentences on the sections that matter for this area>. Its
CLAUDE.md gives the conventions.

## Goal
Find learnings in the documents below (changed since <date>) that would help other lab
members and that the library does not hold yet. For each, say where it should go: an
addition to an existing library page (name the page and section), or a new document
(title and folder).

What counts: general, reusable knowledge. A gotcha, a working recipe, a rule of thumb with
the evidence behind it, a check others could repeat, a cost or timing figure others can
plan with, a rig or instrument fact.
What does not: project status, job ids, personal paths or rules, results that matter only
to this one study (a general lesson drawn from them does count).
Phrase every proposal generally: the library does not refer to members' own projects.
<What is off-limits here and why: documents that are someone else's, confidential work,
a retired method, findings that are research results and not how-tos.>

## Sources
<Each file or folder, with how to read the big ones: "280 KB: outline with grep -n '^##',
then git diff <commit before the date> -- <file> to see what was added". Mention
uncommitted edits. "Do not read <folder>; another agent covers it.">

## Library pages to compare against
<Named pages: which to read in full, which only for headings or Scope.>

## Output (under 1,100 words)
A numbered list of candidates, best first. For each:
- Learning: 1 to 3 sentences, with the key number if there is one.
- Source: file and line numbers.
- Library coverage: "not covered", "partly" or "already covered", with the library file
  and line.
- Destination: existing page and section, or new document (title, folder).
- Value to others: high / medium / low, and who benefits.
- Caveats: one run? unverified? someone else's call?
End with a one-line list of what you checked that the library already covers.
```

Why the brief asks for these: file and line let the writing step check each number at
its source; the coverage line lets you confirm the gap with one grep; the "already
covered" list stops the next run proposing the same things; the word limit keeps the
main session's context for the synthesis.

## 4. Check the reports before passing them on

An agent's report is a claim, and it reads as confidently when it is wrong.

- **Confirm the gaps.** For each candidate you will rank near the top, grep the library
  for its key terms. "Not covered" should mean no hits in the group sections.
- **Merge duplicates.** The same learning often comes back from two areas (a job-submission
  habit shows up in both the cluster notes and the solver notes). Keep one candidate with
  both sources.
- **Conflicts** between the member's notes and a library page are findings in their own
  right: keep both statements with their dates, and don't pick a winner.
- **Weigh the evidence.** One run on one mesh, or one test on one node, is worth sharing
  if it says so. Carry the caveat with the candidate.

## 5. Report

Open with one line on what was compared (how many documents, changed since when, in
which folders, against the library at which commit) and how many candidates came out.
Then, as tables where the content is tabular:

1. **Additions to existing pages**: learning, page and section, value, strength of
   evidence. These are usually the cheapest to write and the most used.
2. **New documents**: proposed title and folder (by the library's layout), what it would
   hold, why no existing page fits, and what is still missing to write it.
3. **Hold for a decision**: someone else's work (say whose call), a change to group code
   that its owner has not decided on, unpublished results, confidential work.
4. **Library statements these notes contradict or outdate**: the page and line, and what
   the member's notes say now.
5. One line listing what was checked and is already covered.

Save the full candidate list to `<personal>/Misc/share_learnings_<YYYY-MM-DD>.md` (each
candidate with its sources, destination and a state: `open`, `held`, later `written in
<PR>`), and add a line to `share_learnings.tsv`: date, since-date, folders, library
commit, candidates found. The comparison is the expensive part; with the list saved, a
later session can write another batch without repeating it.

Ask which batch to write first. Recommend the additions and their Org Gotchas lines
unless something else is clearly more valuable.

## 6. Write the chosen batch

Route by what the item is:

| Item | How it is written |
|---|---|
| Additions to existing pages, Org Gotchas lines | here, as below |
| A new reference document | as `/make-reference` does (its steps 2 to 4), pointed at the source documents |
| An app | `/publish-app` |
| Anything in the paper library | queue lines or "Suggested library updates" (see the ground rules) |

Work in a separate worktree so the member's uncommitted edits are never swept in
(maintainers may work in their clone, as the library's `CLAUDE.md` allows):

```
git -C "$SHOCKLAB_KNOWLEDGE" fetch origin
git -C "$SHOCKLAB_KNOWLEDGE" worktree add -b learnings/<github-login>-<YYYY-MM-DD> ../lib-learnings-<login> origin/main
```

- **One writer per file.** Extending two or more pages: one subagent per page, each told
  to edit exactly that file. Every page's facts also want a line in
  `documentation/Org Gotchas.md`, so have the agents return those lines as proposals and
  add them yourself. Two agents editing one file overwrite each other.
- **Check each fact at its source before writing it.** Numbers, flags and error messages
  come from the cited source lines, not from the step 5 report. Where the source differs
  from the report, follow the source and tell the member.
- **Phrase generally.** No personal paths, usernames, job ids, project or run names. Use
  the page's own placeholders. Say what was observed, when, and on what (software
  version, hardware, the size of the case), because clusters and codes change and a
  reader needs to scale the figure.
- **Stay inside the page's Scope section.** Material that falls outside it waits for its
  own document; say so in the report.
- **Match the page and leave its text alone.** Keep its numbering and bullet style. Add;
  don't reword or reorder. If the page has an `owner:` who is not the member, don't edit
  it: add an `## Open questions` entry or a task, or list the addition in the PR for the
  owner.
- **Provenance.** On a Claude-authored page, add a sentence to the opening callout saying
  additions were made on this date from a lab member's notes, and update its "derived vs
  asserted" section. Mark single observations as such. A conflict or an untested step
  gets a task under `## Actions` (`- [ ] ... #todo/check`). Never fill in `verified:` or
  `verified_by:`.
- **Org Gotchas lines** use that file's format, under the right heading, each linking to
  the page that now holds the detail:
  `- **What goes wrong** — what to do instead. (observed YYYY-MM-DD) → [[page]]`.
  Keep them to the facts most likely to cost someone a queued job or a day.

Then read the diff yourself (not only the agents' summaries), run
`python tools/library.py check` in the worktree and fix any `ERROR`, and show the member
the diff. On their yes: stage the files by name, commit, push, and open a PR titled
`Learnings: <n> additions from <name>'s notes`. The description lists each item with its
source (file name only, no private paths), anything held and why (kinds and counts), and
any `## Suggested library updates`. Leave merging to the PR agent. Remove the worktree
afterwards.

## 7. Finish

Update the saved candidate list (what was written, in which PR; what is held; what is
still open). Tell the member the PR link, what remains unwritten and roughly what each
remaining batch would cost, and that a later `/share-learnings` picks up from the saved
list. Don't record the member's private paths in the library or the PR.
