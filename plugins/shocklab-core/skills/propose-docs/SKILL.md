---
name: propose-docs
description: Every addition to, or change of, the ShockLab library's group pages (documentation/ including Org Gotchas, methods/, facilities/ and codebase_notes/ in Library_of_Shock_Lab) goes in through this skill as a proposal, a pull request to documentation/_proposals/ that a maintainer reviews (/review-proposals); it never edits those pages itself. Modes are `/propose-docs [what]` for something from the current task or conversation (lab-knowledge's write-back), `/propose-docs <file or folder>` to write one file or folder up as a reference page for the lab with a recommended place in the library, `/propose-docs sweep` to check the member's recently changed working documents for what the lab could use (token-heavy), `/propose-docs import` for a new member's onboarding import of their notes plus copying their papers the group lacks to Market _Unprocessed, `proposal_response` to follow up a review (verdicts, test briefs, rebuttals, the next round) and `withdraw <thread>`; purely mechanical fixes (typos, broken links, formatting) go by a fast-lane PR. Every member uses it, maintainers included. Use when the user runs /propose-docs, or says "propose a change to the M3 guide", "add this to Org Gotchas", "update the docs", "this page in the library is wrong", "fix a typo in the docs", "write this up for the lab", "make a reference doc from this folder", "synthesise these notes for others", "is there anything in my recent notes the lab could use", "what have I learned lately that should go in the library", "check my project docs against the knowledge base", "add my notes/papers to the lab library", when onboarding (claude-marketplace setup) reaches the import step, "I got a response to my proposal" or "withdraw my proposal". Not for paper notes, topic pages or data tables (the library skills) or app cards (/publish-app).
argument-hint: "[what] | <file or folder> [who it's for] | sweep [folders] [since <date>] | import | proposal_response [thread] | withdraw <thread>"
---

# Propose a change to the library's group pages

Every addition to, or change of, a page in the library's `documentation/` (including
`Org Gotchas.md`), `methods/`, `facilities/` or `codebase_notes/` goes in as a **proposal**
first. A maintainer's `/review-proposals` then judges each point against its evidence and
the rest of the library, writes a **response**, and opens the PR that applies what it
accepts. This skill writes the proposals, takes the proposer through the response, and
writes the next round. The point of the process is that nothing replaces a working method
on those pages without someone having checked it.

**Modes.** Each mode finds the items its own way; the gathering modes then hand them to the
shared core (sections 1.3 to 1.8, through [section 4](#4-hand-off-from-a-gathering-mode)).
Read a mode file only when that mode runs.

| Mode | Finds the items from | Read |
|---|---|---|
| `/propose-docs [what]` (default) | the current task or conversation, or what the user names (lab-knowledge's write-back offers this) | section 1 |
| `/propose-docs <file or folder>` | one file or folder, written up as **one reference page** for other members, with a recommended place in the library | `modes/reference.md` |
| `/propose-docs sweep [folders] [since <date>]` | the member's recently changed working documents, compared with the library (periodic; **token-heavy**, so say so before starting) | `modes/sweep.md` |
| `/propose-docs import` | everything a new member already has (onboarding), plus copying their paper PDFs the group lacks to Market `_Unprocessed` | `modes/import.md` |
| `proposal_response [thread]` | a maintainer's response to the member's proposal | section 2 |
| `withdraw <thread>` | — | section 3 |

`modes/` is in this skill's base directory, next to this file.

The process page `documentation/_proposals/_Proposals.md` and the templates
`_templates/proposal.md` and `_templates/response.md`, in the member's library clone, are
the authority on file names, point IDs, verdicts, rounds, statuses and branches. Read them
at the start of every run and follow them over anything here; this skill only says how to
act on them. The library's `CLAUDE.md` is the authority on page conventions (naming,
provenance callouts, derived / asserted / inferred, `authors:`, the Org Gotchas line format).

**Ground rules**

- **Everyone proposes**, maintainers included; the member's role makes no difference here.
  A maintainer can't review their own proposal unless they pass `allow-self` to
  `/review-proposals` (and the response then says so): remind them.
- **Never edit an in-scope page.** Only the review PR applies accepted points. The one
  exception is the fast lane (step 1.2). Never fill in `verified:` or `verified_by:`.
- **In scope too:** the process files `documentation/_proposals/_Proposals.md`,
  `documentation/_responses/_Responses.md`, `_templates/proposal.md` and
  `_templates/response.md`, which change by proposal like any group page.
- **Out of scope:** `paper_notes/`, `topics/`, `data/` (the library skills: `/add-paper`,
  `/paper-audit`, `/update-topics`; or an issue), `applets/` (`/publish-app`),
  `generated/` and `onboarding/` (an ordinary branch and PR, as `modes/reference.md` sets out), and
  `documentation/add_paper_token_costs.md` (a log `/add-paper` runs append to, not a page).
  Say which route applies and leave those items out of the proposal.
- **The evidence is what gets a point accepted.** The reviewer starts from "not yet shown",
  and an asserted or inferred point that contradicts derived existing text gets a test or a
  rejection, never "accept". Help the member pin the evidence down before they submit.
- **Nothing private in the proposal.** It lands on `main` for the whole group to read: no
  personal paths (use the page's placeholders), secrets, reviews of people or confidential
  work. Sources by file name only. Something drawn from another member's document is their
  call to share; ask the member first.
- **Ask before writing anywhere shared**: once on the approval table, once on the finished
  file before the PR.

## 0. Setup (every mode)

1. **Library clone:** `$SHOCKLAB_KNOWLEDGE`; else `./Library_of_Shock_Lab` in the working
   directory; else the working directory if it holds `SCHEMA.md`. None: stop and offer the
   setup in `CLAUDE.md` of `MonashUniversity-ShockLab/claude-marketplace`. Below,
   `<library>` is its absolute path.
2. **Up to date, on `main`:** `git -C <library> switch main` (if refused because of
   uncommitted changes, show them and ask; never stash or discard them), then
   `git -C <library> pull --ff-only` and `git -C <library> fetch origin`.
3. **Read** `<library>/documentation/_proposals/_Proposals.md`, `<library>/_templates/proposal.md`
   and, for `proposal_response`, `<library>/_templates/response.md`. If the process page is
   missing after the pull, the library hasn't adopted proposals yet: stop and say so.
4. **Who:** `gh api user --jq .login` (the GitHub login, as given) and the member's name
   (`gh api user --jq .name`, else `git config user.name`, else ask). If `gh` isn't logged
   in, stop: `gh auth login` is the member's to run.
   Maintainer or not (only for the `allow-self` reminder):
   `gh api repos/MonashUniversity-ShockLab/Library_of_Shock_Lab --jq .permissions.admin`.
5. **Mode** from `$ARGUMENTS` (or the user's words, when the skill was triggered without
   the command): `proposal_response [thread]` → section 2; `withdraw <thread>` → section 3;
   `sweep ...` → `modes/sweep.md`; `import` → `modes/import.md`; a path to a file or
   folder outside the library clone, to be written up for others → `modes/reference.md`;
   anything else, including a page of the library itself, is what to propose → section 1.
   If it is unclear whether a path is something to write up or the source of one change,
   ask. Read the mode file now and follow it; it returns here at section 4.

Every write below happens in a worktree off `origin/main`, so the member's own uncommitted
edits are never swept in:

```
git -C <library> fetch origin
git -C <library> worktree add -b <branch> ../lib-<slug> origin/main
```

`../lib-<slug>` is a folder next to the clone (`docfix` as the slug for a fast-lane fix).
Before adding it, check the branch name is free, locally
(`git -C <library> branch --list <branch>`) and on origin
(`git -C <library> ls-remote --heads origin <branch>`); if it is taken (a second PR on the
same day), add `-2`, `-3`, … to the branch and to the folder until both are free. This holds
for every branch this skill creates (`proposal/…` and `docfix/…`).
Every write ends the same way: run `python tools/library.py check` in the worktree and fix any
`ERROR` in the files you wrote (a wikilink inside proposed text to a page the proposal
itself creates may show as broken; that is expected, say so in the PR body); show the member
the diff; on their yes stage the files by name (never `git add -A` or `.`), commit, push
(`git push -u origin <branch>`), open the PR with
`gh pr create --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --base main --head <branch>`,
remove the worktree (`git -C <library> worktree remove <path>`), and leave the clone on
`main`. Leave merging to the PR agent.

## 1. Write a proposal (default mode; 1.3 to 1.8 are the shared core)

### 1.1 Gather the items

From what the user points at (a file, a page, a failed job, something worked out in this
session) or from the conversation. For each item, note what it would add or change and the
page it is about. Read the source yourself; take numbers, flags and error messages from it,
not from memory or a summary.

### 1.2 Fast lane

If **every** change is mechanical (a typo, a broken link or wikilink, Markdown formatting, a
frontmatter fix) and no command, number, path, file or option name, version, partition or
QOS name, or meaning changes, offer the fast lane instead: the edits made directly in a
worktree on branch `docfix/<login>-<YYYY-MM-DD>` (section 0), PR titled `Docs fix: <what>`
with each fix listed. The PR agent checks it and sends anything more back here. Then stop. If in doubt, it is a proposal. A mixed batch: offer to send the
mechanical part by the fast lane and the rest as a proposal.

### 1.3 Check open proposals and PRs

- List the proposals in `documentation/_proposals/` (not `_Proposals.md`) whose latest round
  has `status:` `open`, `under-review` or `responded`, with their `targets` and point
  headings. Also open PRs not yet merged:
  `gh pr list --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --state open --json number,title,headRefName,files`
  (proposal PRs, review PRs, and any PR touching the target pages).
- An item that duplicates a pending point: don't propose it again. Tell the user which
  thread and point (`<thread>#<point>`) and whose. If they have evidence that thread lacks,
  suggest they tell its proposer. Their own open thread can't take new points either: new
  points start a new thread.
- An item that touches text a pending point is changing: say so, and record it under
  "Checked against" so the reviewer sees both.

### 1.4 Work out each item

- **Target page.** By what the content is:

  | Content | Target |
  |---|---|
  | A one-line org fact (what goes wrong, what to do instead) | a line in `documentation/Org Gotchas.md` under its heading, linked to the page with the detail (proposed as its own point, even when one line) |
  | A workflow, script or HPC how-to kept up to date | the `documentation/` page that covers it (thread subfolder if one fits), else a new one |
  | How the lab does a technique | `methods/` |
  | A rig, nozzle, camera or sensor | `facilities/` |
  | A summary of a group code repo | `codebase_notes/` |
  | How proposals and responses work | `documentation/_proposals/_Proposals.md`, `documentation/_responses/_Responses.md`, `_templates/proposal.md` or `_templates/response.md` |

  Prefer adding to an existing page over a near-duplicate page. A **new page** is a
  `## <folder>/<Title>.md (new page)` target: its first point gives the placement (path,
  named as the library's `CLAUDE.md` says; frontmatter and opening callout for its folder;
  the row for the folder's index page; the nearest existing page and why it doesn't fit),
  and each section of the page is one further point. `methods/` and `facilities/` pages are
  human-written (`type: note`, `owner: MonashUniversity-ShockLab`, `authors:` the member),
  so propose one there only if the member will stand behind it as its author; otherwise use
  the Claude-authored folder that fits.
- **Conflict search across all four folders**, not only the target page. Grep
  `documentation/`, `methods/`, `facilities/` and `codebase_notes/` for the item's key terms
  (commands, flags, option and partition names, numbers, rig and software names) and read
  each hit in context. Check `## Open questions` sections on the pages too. For a large
  batch (an import, a sweep), hand each target page's search to a read-only subagent that
  returns the hits as file, heading, line and the exact lines.
- **N or C.** Anything that changes, removes or disagrees with existing text, on the target
  page or any other in-scope page, is a C-point; a pure addition is an N-point. When unsure,
  make it C: the reviewer treats a conflicting N-point as a C-point anyway. For a C-point,
  quote the existing text **exactly** (copied from the file) with page and heading, and
  every other in-scope page that says the same or a related thing.
- **Evidence.** Label each point and pin down the specifics:
  - **derived:** the member ran or measured it: date, machine, job ID, command and the
    relevant output;
  - **asserted:** from a source: official docs (URL and the date read), a named colleague, a
    paper note;
  - **inferred:** the member's own reading, not checked.

  When the specifics are missing, ask "how do you know?" and record the answer. Check what
  you can yourself: fetch the official docs and note the URL and today's date, quote the
  output from the conversation or the file the user named, read the code at a named commit.
  If a source disagrees with the item, tell the user before going on. Never upgrade a label
  to make a point look stronger; if the member can't say how they know, it is inferred, and
  tell them how the reviewer will weigh that (an inferred C-point against derived text will
  get a test or a rejection).
- **Proposed text: the exact text** as it would appear on the page, never a description of
  it. Match the page: its bullet and numbering style, its placeholders, no personal paths,
  usernames or project names, and the date and versions the fact was observed on. Org
  Gotchas lines use that file's format,
  `- **What goes wrong** — what to do instead. (observed YYYY-MM-DD) → [[page]]`. On a
  human-written page, extend or correct rather than reword other people's text.

### 1.5 Split

One proposal covers one coherent topic and may touch several pages. If the points span
unrelated topics (M3 and a rig, say) or come to more than about 15, split them into several
proposals by topic, each its own thread and PR.

### 1.6 Approval table

Show the user, per proposal:

| Point | Target page | N/C | Evidence | In one line |
|---|---|---|---|---|

Below it, the items left out: already covered (where), already in a pending proposal (which
point), out of scope (which route), and anything held as someone else's call. Show the full
proposed text of any point on request, and of all points when there are only a few. Let the
user edit, re-label or drop points, and repeat until they approve.

### 1.7 Write the file

In a worktree on branch `proposal/<login>-<YYYY-MM-DD>-<slug>` (section 0):

- **Thread** `<YYYY-MM-DD>_<login>_<slug>`: today's date, the login, and a few lower-case
  words joined by `-`. File `documentation/_proposals/<thread>_r1.md`; check the name is
  free on `main` and in open PRs.
- Start from `_templates/proposal.md`. Frontmatter: `thread`, `round: 1`, `title`,
  `proposer` (login), `proposer_name`, `created` (today), `base_commit`
  (`git -C <library> rev-parse origin/main`, the commit the worktree was made from),
  `targets` (library-relative path of every page the proposal adds to, changes or creates),
  `status: open`; leave `reviewer`, `review_started` and `responds_to` empty.
- Body: fill the title and round; a Summary (what it adds or changes and where it came
  from, in general terms); one `## <page path>` section per target page with its
  `### New information` and `### Conflicting information` points. Number N-points and
  C-points through the whole proposal, not per page. Fill every field the template gives
  each point (`Where` and `Checked against` included, for C-points too). Delete the
  template's comment and every section that doesn't apply
  (Previous round, Rebuttals, Test results, the new-page section if there is none).
- **Images** the proposed text needs (small figures, PNG or SVG under about 1 MB, each with a
  source line; never data files): copy each into the worktree's `attachments/images/` under
  a name that is free on `main`, and embed it in the proposed text where the page would show
  it (`![[<name>.png]]`). They go in the same PR; the review keeps the embeds of the points
  it accepts.

### 1.8 Open the PR

The PR adds only the proposal file and the images it embeds (1.7); the PR agent won't merge
anything else in it. Commit and title `Proposal: <title> (round 1)`. Body: a
two- or three-line summary, the counts of N- and C-points and the pages they touch, the
sources (file names only), any `## Suggested library updates` for the paper library, and a
link to the process page
(`https://github.com/MonashUniversity-ShockLab/Library_of_Shock_Lab/blob/main/documentation/_proposals/_Proposals.md`).

Tell the user: the PR agent merges the proposal once its format checks out; a maintainer
reviews it later with `/review-proposals`; nothing on the pages changes until that review's
PR merges; and `/propose-docs proposal_response` takes them through the response when it
comes back. Maintainers: the `allow-self` reminder.

## 2. `proposal_response [thread]`

### 2.1 Find the response

The member's threads are the proposal files with their login in `proposer:`; group them by
`thread` and take the latest round of each. With a thread named, work on that one;
otherwise take, one at a time:

- latest round `responded`: the response is on `main` at
  `documentation/_responses/<thread>_r<N>_response.md`;
- latest round `under-review`: look for an open review PR (head branch `review/...`) whose
  files include the response
  (`gh pr view <n> --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --json files`),
  and read it from the PR head
  (`gh api "repos/MonashUniversity-ShockLab/Library_of_Shock_Lab/contents/<path>?ref=<branch>" -H "Accept: application/vnd.github.raw"`).
  Tell the user the accepted edits are still waiting to merge. Go through the verdicts and
  write test briefs now, but don't open the next round's PR until the review PR has merged
  (the process page: both change the last round's status). Keep the rebuttal notes beside
  the briefs (`<tests>/<thread>/rebuttals_draft.md`) for the next run. With no review PR
  either, the review is still in progress: say so and move on.

If the member has none of these, say so and stop.

Pending tests need no separate search: a round that carries one stays `responded` (the
review doesn't close it, and a round holding only pending tests isn't sent). A thread's
pending tests are the verdict-3 points in its latest response plus the "Test pending" rows
in its latest round's Previous round table. Check `<tests>/<thread>/` for
`<point>_result.md` files waiting for them (2.3).

### 2.2 Verdict table

Read the response and the proposal round it answers. Show:

| Point | Page | Verdict | In short | What happens next |
|---|---|---|---|---|

- **1 Accept, 2 Accept with changes:** applied in the review PR. A 1 needs nothing. For each
  verdict 2, show the proposer's text and the applied text side by side, with the response's
  reason, and ask whether the meaning was kept. If not, the point can be rebutted in the
  next round, with the applied text as its existing text (2.4 applies: a new argument or
  evidence). While the review PR is still open, a comment on it for the reviewing
  maintainer may be quicker (draft it; post it only on the user's yes).
- **3 Test:** section 2.3.
- **4 Reject:** section 2.4.
- **5 Already covered / not for the library:** show where the response says it already is
  (or why it doesn't belong), and check that page says it. Normally the point is dropped. If
  the cited text doesn't cover it, that is a rebuttal (quote the page). If the response
  says it is right but belongs on a page this proposal didn't target, it names the page:
  offer to propose it there in a new thread (section 1) and drop it here.
- **Maintainer decision:** final; show the decision and who made it. No further rounds.

The review closes a round only when every point is a 1 or a maintainer decision, so a
round with any 2 or 5 comes back `responded` even when nothing is rejected. When its points
are only 1, 2 and 5, show the 2s and 5s as above and ask, per point, whether the member
accepts it; if they accept them all, close the round with a status-only PR (2.5), and
otherwise the points they dispute are rebutted in the next round.

Mention "Existing text found doubtful" if it touches the member's area: they can start a new
thread on it. If `self_reviewed: true`, say the maintainer reviewed their own proposal.

### 2.3 Tests (verdict 3)

Ask which tests the member will run now (others become "Test pending", or "Dropped" if they
let the point go). For each one they will run, write a self-contained test brief that they
can hand to another agent or session.

**Where:** outside the library clone. If the working directory is neither the clone nor
inside it, use `<cwd>/Doc_Proposal_Tests/`; otherwise ask, suggesting
`$SHOCKLAB_PERSONAL/Doc_Proposal_Tests/` when that is set and outside the clone. That folder
is `<tests>`. Brief: `<tests>/<thread>/<point>.md`; result: `<tests>/<thread>/<point>_result.md`.
These are the member's working files; this skill never commits them.

The brief, filled in from the response and the proposal:

```
# Test brief: <thread>#<point>

You are running one test for a ShockLab documentation proposal. Run it as set; don't
change the test or the pass criterion. If it can't be run as set, stop and say why in the
result file.

## The claim
<the point's proposed text, quoted; for a C-point also the existing text it would replace,
with page and heading>

## The test as set
<quoted from the response: what to run, on what, how many times>

## Pass if
<quoted pass criterion>

## Bring back
<quoted from the response>

## Rules
- Read the library's documentation/M3 Guide.md, documentation/Org Gotchas.md and its HPC
  guidelines for Claude (library clone at $SHOCKLAB_KNOWLEDGE) before any cluster work, and
  follow them and the member's own HPC rules in their project's CLAUDE.md.
- Work and write only in the member's own folders; never touch other people's files,
  shared installs or the library.
- Smallest run that settles the criterion. Ask the member before any job that uses real
  allocation or queue time beyond a short test, and before anything irreversible.
- No secrets, passwords or tokens in the result file.

## When done
Write <point>_result.md next to this brief:
- Test as set: quoted, with the pass criterion
- What was run: date, machine, job IDs, commands
- Result: passed | failed | not run (why), with the output that shows it
- Proposed text: unchanged, or revised in light of the result (exact text)
- Anything that differed from the test as set
```

Tell the member where the briefs are and how to use one (a new session in the project:
"run the test brief at <path>"), and to run `/propose-docs proposal_response` again once the
results are in. Tests on a cluster cost allocation; they decide when.

**On a later run**, read each `_result.md` for the thread's pending tests. Check it against
the pass criterion and the evidence asked for, from the output it quotes, not its verdict
line. A failed test usually means dropping the point, or a revised proposed text that the
result supports. A missing or incomplete result stays "Test pending".

### 2.4 Rejections (verdict 4)

Go through each with the member: the response's **Why** (with its sources) and **What would
change this**. They either accept it (**Dropped**) or rebut it. A rebuttal needs a new
argument or new evidence that the last round didn't have. Help gather and check it: read
the reviewer's sources, look for better ones, and see whether the member's own results meet
"what would change this". If the rebuttal only restates the first case, say so plainly: it
won't be reviewed again, so recommend dropping it or getting the evidence first. A point
rejected again after a rebuttal goes to a maintainer's decision, so this is the member's
last full say on it.

### 2.5 The next round

Write round N+1 only when something is carried forward (a rebuttal or a test result), or
when every remaining point is Dropped and one of them left an `## Open questions` entry on
a page (a C-point given a 3 earlier: grep `documentation/`, `methods/`, `facilities/` and
`codebase_notes/` for `[[<thread>_r` and keep the hits under an `## Open questions`
heading), so that the review removes it. Open its PR only once the review PR for round N
has merged. Then:

- **New file** `documentation/_proposals/<thread>_r<N+1>.md` from the template: same `thread`
  and `title`, `round: N+1`, `created` today, a new `base_commit`, `targets` (the page of
  every point in its Previous round table, Dropped and Test pending included, so the review
  can remove a settled point's `## Open questions` entry), `status: open`, `responds_to` the
  response file name without `.md` (`<thread>_r<N>_response`).
- **No new points.** Anything new starts a new thread (section 1).
- **Summary**, then **Previous round**: a row for every point of round N that wasn't
  accepted (verdicts 3, 4 and 5), every verdict-2 point being rebutted, and every test still
  pending from an earlier round (listed again in each round until it has a result or is
  dropped), each marked Rebutted, Test result, Test pending or Dropped. Maintainer
  decisions are final and get no row.
- **Rebuttals** and **Test results** sections as the template sets them, linking the
  response that set the verdict (`[[<thread>_r<K>_response]]`). Every rebuttal fills
  **New argument or evidence**. A verdict-2 rebuttal quotes the applied text as the existing
  text. Where a rebuttal comes with revised wording, add the exact `**Proposed text:**`.
- **Close round N** in the same PR: its `status: responded` becomes `status: closed`.
- Branch `proposal/<login>-<YYYY-MM-DD>-<slug>` (today's date; section 0 adds `-2`, … if
  it is taken), title `Proposal: <title> (round N+1)`.

If only pending tests remain, apart from dropped points (nothing rebutted, no results yet),
send nothing: round N stays `responded`, so it still shows under "Waiting for the
proposer", and the dropped points go in the table when the next round is sent. If nothing
at all is carried (everything accepted, dropped or decided, no test pending) and no dropped
point left an `## Open questions` entry, open a status-only PR that just sets round N to
`closed`: same branch pattern, title `Proposal: <title> (round N closed)`.

## 3. `withdraw <thread>`

1. Find the thread (with none named, list the member's threads whose latest round is open,
   under review or responded, and ask). Only the proposer withdraws their own thread.
2. If the proposal PR itself hasn't merged yet, close that PR instead
   (`gh pr close <n> --repo MonashUniversity-ShockLab/Library_of_Shock_Lab --comment "Withdrawn by the proposer"`),
   on the user's yes, and stop.
3. Latest round `under-review`: don't withdraw. A maintainer has claimed it (`reviewer:`,
   `review_started:`) and is reviewing it: tell the user who and since when, and to wait for
   the response, then withdraw (or follow it up with `proposal_response`). `closed` or
   `withdrawn`: nothing to withdraw.
4. Latest round `open` or `responded`: look for `## Open questions` entries the thread left
   on the pages (grep the four folders for `[[<thread>_r`, as in 2.5).
   - **None:** a status-only PR: worktree on `proposal/<login>-<YYYY-MM-DD>-<slug>` (today's
     date; section 0), change only that round's status line to `withdrawn`, PR titled
     `Proposal: <title> (withdrawn)`.
   - **Some:** only a review removes them, so don't set `withdrawn` directly. Send a last
     round as in 2.5 with every remaining point Dropped (the unaccepted points of the latest
     response, and any test still pending) and a Summary saying the proposer withdraws the
     thread. In the same PR, a `responded` round N becomes `closed`; an `open` round N that
     was never reviewed becomes `withdrawn`, and the new round answers the latest response
     there is (`responds_to`). The review removes the entries and closes the thread.

## 4. Hand-off from a gathering mode

The reference, sweep and import modes (and lab-knowledge's write-back, through the default
mode) find their items and show the user their own findings first; then they come here
instead of editing the four folders or opening their own PR for those items.

**What the mode hands over**, one entry per item:

| Field | Content |
|---|---|
| Target | library-relative path of an existing page (`documentation/M3 Guide.md`), or a new page: `(new page) <folder>/<Title>.md` |
| Where | the heading it goes under, or "new section after ...". For a new page, the first item is the placement (path, frontmatter and callout, index row) and each section is one item |
| Proposed text | exactly as it would appear on the page |
| N or C | the mode's best guess |
| Existing text | C only: quoted exactly, with page and heading |
| Evidence | derived / asserted / inferred, with the specifics |
| Source | the file it came from, by file name only (no personal paths) |
| Images | any figures the proposed text embeds: the local file and its name for `attachments/images/` (they go in the proposal PR, 1.7) |

and, once for the batch: a line on where the items come from (for the Summary: "a new
member's notes", "a sweep of recent test reports"), any grouping into proposals the mode
suggests, and anything for the PR description (what a new page is for and who it is for,
what was left out and why by kind and count, `## Suggested library updates` for the paper
library). An item may arrive with a field missing; ask the user for it.

**Then run 1.3 to 1.8** (section 0 is already done): the check against pending proposals
and open PRs, the conflict search across all four folders (the mode's N or C is a guess;
decide it here and quote the existing text), the evidence check, the split, the approval
table (with each item's source), the proposal file(s) and their PR(s). Gathering (1.1) and
the fast-lane check (1.2) are skipped.

**What goes back to the mode**, for its report or ledger, per item: in proposal
`<thread>#<point>` with its PR link; dropped by the user; already covered (where); already in
a pending proposal (which point); or out of scope (and its route). Then finish the mode's
own last step, and the Finish below.

## Finish

Report in a few lines: the thread name(s) and PR link(s), N- and C-point counts per
proposal, what was left out and why; for `proposal_response`, the verdict counts, where the
test briefs are, what went into the next round (or that round N was closed, or left open
for pending tests). Make sure the worktrees are removed and the clone is back on `main`
(`git -C <library> switch main`, `git -C <library> pull --ff-only`).
