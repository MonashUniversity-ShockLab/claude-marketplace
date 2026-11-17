# Mode: `/propose-docs sweep [folders] [since <date>]` — what the lab could use from recent work

(Formerly `/share-learnings`.) Most of what a lab member works out ends up in documents
written for themselves: a test report, a set-up log, a project `CLAUDE.md`, Claude's memory
for the project. This mode reads what changed in those documents recently, compares it with
the library, and reports what another member could use that the library doesn't hold yet.
The member then picks what to write, and that batch goes in as proposals through the core
of SKILL.md (section 4), which a maintainer reviews before any page changes.

It sits between the other gathering modes: `import` is the one-off import when someone joins
(everything they have, papers included), and `<file or folder>` writes up one thing the
member already knows is worth sharing. The sweep is the periodic one that finds the
candidates in the first place, so run it every few weeks or after a piece of work finishes.

SKILL.md section 0 has run: `<library>` is the clone, freshly pulled on `main` (a clone a few
days behind makes the comparison propose things that are already there). Note the commit
you compare against (`git -C <library> rev-parse HEAD`). The library's `CLAUDE.md` is the
authority on where things go, naming and provenance; read it now.

**Ground rules for this mode**

- **Read-only on the member's files**, and on the library: once they approve a batch, the
  core writes the proposals (step 6).
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
  the library skills, otherwise "Suggested library updates" in the proposal PR), never a
  direct edit.
- **Ask before writing anywhere shared**: once on the batch, then on the core's approval
  table.

## 0. Scope

- **`<personal>`**: `SHOCKLAB_PERSONAL` if set, else the library clone. The mode keeps its
  own records in `<personal>/Misc/` (personal, never committed): `share_learnings.tsv`, one
  line per run, and `share_learnings_<YYYY-MM-DD>.md`, the candidate list from that run with
  what happened to each. These keep the names they had under `/share-learnings`, so earlier
  ledgers carry on working.
- **Where to look**: the folders or repos in `$ARGUMENTS` (after `sweep`); with none, the
  current project. Ask whether other places hold recent work (a second repo, a notes vault,
  a folder on OneDrive).
- **Since when**: the date in `$ARGUMENTS`; else the date of the last run in
  `share_learnings.tsv`; else three weeks ago. Say which you used. Read the last run's
  candidate file too: anything still marked `open` is carried into this run's report as it
  stands, not worked out again.
- **Ask what is off-limits** before reading: confidential or contract projects, folders
  holding other people's documents, results not ready to share.
- **Say what it costs.** Each area gets its own subagent that reads the member's documents
  and the matching library pages. In the run this mode was written from (about 110 changed
  documents in five areas), the five agents used 140k to 270k tokens and 4 to 14 minutes
  each, about 1.1 million tokens in all, before any writing. Offer to narrow it to one or
  two areas, or to run it when usage is spare.

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

Group what is left into areas (step 3) and show the member the list with counts and sizes.
Let them strike documents or whole areas.

## 2. Map the library

Also cheap, also in the main session. Agents compare better when the brief names the pages
to compare against, and you need the map to judge their reports.

- `documentation/_Documentation.md` (its table says what each page is for) and the headings
  of `documentation/Org Gotchas.md`.
- A listing with sizes of `methods/`, `facilities/`, `onboarding/`, `applets/`,
  `codebase_notes/`, `research_questions/` and `generated/`. A page of a few hundred bytes is
  a stub: note it, because the member's material may be what fills it.
- Open pull requests and open proposals (as SKILL.md 1.3 lists them), so nothing already on
  its way in is proposed again.
- For areas that touch the literature: `data/README.md` and the names in `topics/_queue/`.

## 3. One read-only agent per area

Split the documents into three to five areas so that each document belongs to exactly one
agent. Areas that have worked: cluster and job running; solver or simulation set-up; test
reports and rig-side findings; analysis code and methods; working with Claude, tools and
apps; literature-facing project documents (data tables, model reviews). A small run (under
about ten documents or 100 KB) needs no agents: read it in the main session.

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
- Evidence: derived (run or measured: date, machine, job, command), asserted (a source)
  or inferred (unchecked reading).
- Caveats: one run? unverified? someone else's call?
End with a one-line list of what you checked that the library already covers.
```

Why the brief asks for these: file and line let the writing step check each number at its
source; the coverage line lets you confirm the gap with one grep; the "already covered" list
stops the next run proposing the same things; the word limit keeps the main session's
context for the synthesis.

## 4. Check the reports before passing them on

An agent's report is a claim, and it reads as confidently when it is wrong.

- **Confirm the gaps.** For each candidate you will rank near the top, grep the library for
  its key terms. "Not covered" should mean no hits in the group sections.
- **Merge duplicates.** The same learning often comes back from two areas (a job-submission
  habit shows up in both the cluster notes and the solver notes). Keep one candidate with
  both sources.
- **Conflicts** between the member's notes and a library page are findings in their own
  right, and become C-points: quote the library text exactly (page, heading, date) next to
  what the notes say and the evidence for it. Don't pick a winner; the reviewer weighs both.
- **Weigh the evidence.** One run on one mesh, or one test on one node, is worth sharing if
  it says so. Carry the caveat and the evidence label (derived, asserted, inferred) with the
  candidate.

## 5. Report

Open with one line on what was compared (how many documents, changed since when, in which
folders, against the library at which commit) and how many candidates came out. Then, as
tables where the content is tabular:

1. **Additions to existing pages**: learning, page and section, value, strength of
   evidence. These are usually the cheapest to write and the most used.
2. **New documents**: proposed title and folder (by the library's layout), what it would
   hold, why no existing page fits, and what is still missing to write it.
3. **Hold for a decision**: someone else's work (say whose call), a change to group code
   that its owner has not decided on, unpublished results, confidential work.
4. **Library statements these notes contradict or outdate**: the page and line, what the
   member's notes say now, and the evidence. These go in as C-points.
5. One line listing what was checked and is already covered.

Save the full candidate list to `<personal>/Misc/share_learnings_<YYYY-MM-DD>.md` (each
candidate with its sources, destination and a state: `open`, `held`, later `proposed in
<thread>#<point>` with the proposal PR, and then the review's verdict), and add a line to
`share_learnings.tsv`: date, since-date, folders, library commit, candidates found. The
comparison is the expensive part; with the list saved, a later session can write another
batch without repeating it.

Ask which batch to propose first. Recommend the additions and their Org Gotchas lines unless
something else is clearly more valuable.

## 6. Draft the chosen batch

Route by what the item is:

| Item | How it goes in |
|---|---|
| Additions to existing pages, Org Gotchas lines | N-points, drafted as below, then the core (SKILL.md section 4) |
| Library statements the notes contradict or outdate (report category 4) | C-points: the existing text quoted exactly, the notes' evidence beside it, then the core |
| A new reference document | as the reference mode does (`modes/reference.md` steps 2 to 4), pointed at the source documents; it ends as a `(new page)` target of a proposal |
| An app | `/publish-app` |
| Anything in the paper library | queue lines or "Suggested library updates" (see the ground rules) |

Draft each point's exact text first; nothing is written to the library in this step.

- **Drafting several pages:** one subagent per page may draft that page's points and return
  them, with the Org Gotchas lines they imply, as text; you assemble them. No agent edits a
  library file.
- **Check each fact at its source before drafting it.** Numbers, flags and error messages
  come from the cited source lines, not from the step 5 report. Where the source differs
  from the report, follow the source and tell the member.
- **Phrase generally.** No personal paths, usernames, job ids, project or run names. Use the
  page's own placeholders. Say what was observed, when, and on what (software version,
  hardware, the size of the case), because clusters and codes change and a reader needs to
  scale the figure.
- **Stay inside the page's Scope section.** Material that falls outside it waits for its own
  document; say so in the report.
- **Match the page.** Keep its numbering and bullet style, and say where each point goes
  (page and heading). Add; don't reword or reorder. Any change to existing text, on a page
  the member wrote or anyone else's, is a C-point quoting that text, never a silent rewrite.
- **Evidence and provenance.** Give each point its evidence label (derived, asserted,
  inferred) with the specifics, and mark single observations as such. On a Claude-authored
  page, the reviewer updates the callout and "derived vs asserted" section when applying it.
  Never fill in `verified:` or `verified_by:`.
- **Org Gotchas lines** use that file's format, under the right heading, each linking to the
  page that holds the detail:
  `- **What goes wrong** — what to do instead. (observed YYYY-MM-DD) → [[page]]`.
  Keep them to the facts most likely to cost someone a queued job or a day.

Then read every drafted point yourself (not only the agents' summaries) and hand the batch
to the core (SKILL.md section 4): each point with its target page, where, the exact text,
N or C, the existing text (for C), the evidence label and specifics, and the source (file
name only, no private paths). For the batch, say the items come from a sweep of the
member's recent working documents, suggest a split of a large batch by topic into proposals
of up to about 15 points each, and pass on any `## Suggested library updates` and what was
held (kinds and counts) for the proposal PR's description.

## 7. Finish

With what the core gives back, update the saved candidate list (what was proposed, in which
thread, point and PR; what is held; what is still open). Tell the member the proposal PR
links, what remains unproposed and roughly what each remaining batch would cost, and that a
later `/propose-docs sweep` picks up from the saved list. Don't record the member's private
paths in the library, the proposals or the PRs.
