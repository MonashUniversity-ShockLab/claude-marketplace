---
name: review-proposals
description: Review the documentation proposals waiting in the ShockLab library (Library_of_Shock_Lab, found via $SHOCKLAB_KNOWLEDGE; documentation/_proposals/), oldest first. Claims each one on main, then launches a fresh doc-reviewer agent per proposal that judges every point against its evidence, primary sources and the rest of the group pages, writes the response in documentation/_responses/ and applies the accepted points; puts any point rejected again after a rebuttal to the maintainer; and opens one review PR once the maintainer has read the diff. Maintainers only (admins of the library repo). Token-heavy (one agent per proposal), so say so before a large batch. Use when the user runs /review-proposals, or says "review the doc proposals", "check the pending proposals".
argument-hint: "[list | N | <thread or proposal file> ...] [allow-self]"
---

# Review documentation proposals

Every addition to, or change of, the group pages (`documentation/` including Org Gotchas,
`methods/`, `facilities/`, `codebase_notes/`) starts as a proposal in
`documentation/_proposals/`, written by `/propose-docs`. This skill is the review step: it
claims the proposals, has a fresh `doc-reviewer` agent judge each one adversarially, records
the maintainer's decisions, and opens one review PR with the responses and the accepted
edits.

The process is defined in `<library>/documentation/_proposals/_Proposals.md`, with the
templates `<library>/_templates/proposal.md` and `<library>/_templates/response.md`. Read
`_Proposals.md` in full at the start of every run, and follow it over anything here.

**Division of work.** The agent does all the reading and judging: the proposal, the pages,
the web sources, the org's repos. This session lists, claims, briefs, puts maintainer
decisions to the user, commits and opens the PR. It never reads the target pages in full or
the agent's web sources; it works from the agent's reply, `git diff --stat` and the few
lines it needs to check.

Whenever this skill asks with AskUserQuestion, end with a "Notes" question with exactly two
options, "No notes" and "Ask me after".

## Where the library is

`<library>` is the root of the maintainer's clone of
`MonashUniversity-ShockLab/Library_of_Shock_Lab` (the folder with `SCHEMA.md`,
`documentation/` and `tools/`). Resolve it once and use the absolute path everywhere:

1. the path in the environment variable `SHOCKLAB_KNOWLEDGE`, if set;
2. otherwise `./Library_of_Shock_Lab` in the working directory, if it exists;
3. otherwise the working directory itself, if it contains `SCHEMA.md`.

If none exists, stop and point to "Setting up a new lab member" in
`MonashUniversity-ShockLab/claude-marketplace`. `<repo>` below is
`MonashUniversity-ShockLab/Library_of_Shock_Lab`; `library.py` means
`python <library>/tools/library.py` (try `python3` or `py -3` if `python` isn't on PATH);
`<today>` is `date +%F`.

## 0. Who may run it

Maintainers only: an **admin** of `<repo>` on GitHub. Everyone else has write access, so
being able to push proves nothing.

1. `<login>` = `gh api user --jq .login`. If `gh` isn't logged in, stop: `gh auth login` is
   the user's to run.
2. `gh api repos/MonashUniversity-ShockLab/Library_of_Shock_Lab/collaborators/<login>/permission --jq .permission`
   must print `admin`. Anything else (or an error): stop politely, changing nothing. Say that
   proposals are reviewed by the library's maintainers, that their own proposals will be
   reviewed by one of them, and that `/propose-docs proposal_response` shows what has come
   back on them.

## 1. Arguments

- `list`: show the queue (step 3) and stop. Claim nothing.
- Empty: every proposal ready for review, oldest first.
- `N`: the N oldest ready proposals.
- Thread names (`2026-11-17_jdoe_m3-scratch-quota`) or proposal file names: those (for a
  thread, its latest round).
- `allow-self`: also review the user's own proposals. Their responses get
  `self_reviewed: true`, and the PR title and body say "self-reviewed".

## 2. Pull, and pick up a cut-off run

1. `git -C <library> switch main` and `git -C <library> pull --ff-only`. If the switch or
   pull is refused because of uncommitted changes, show them and ask; never stage, stash or
   discard them. If `git -C <library> status --porcelain -- documentation/_proposals` shows
   anything, stop and ask: the claim commit edits those files.
2. **An unfinished run of this user's.** Look for branches `review/<login>-*`, local
   (`git -C <library> branch --list "review/<login>-*"`) and on origin
   (`git -C <library> ls-remote --heads origin "refs/heads/review/<login>-*"`). For each,
   `gh pr list --repo <repo> --head <branch> --state all --json number,state,url`:
   - PR merged or closed: finished. Ignore it (offer to delete a local branch that merged).
     A closed, unmerged PR leaves its claims behind: offer to release them ("If the run
     stops early").
   - PR open: submitted and waiting for the PR agent. Don't add to it.
   - **No PR: a cut-off run.** This run continues on that branch instead of starting a new
     one; say so. Its worktree (`<wt>`) is in `git -C <library> worktree list`; if it is gone,
     re-add it (`git -C <library> worktree add <path> <branch>`). In that worktree:
     - a proposal whose response is committed on the branch is done;
     - an uncommitted response that still has the agent's progress marker
       (`<!-- doc-reviewer: in progress`) was cut off mid-review: it goes first, and its
       agent is launched with "Resume" (step 6);
     - an uncommitted response without the marker: the agent finished but this session
       stopped before the commit. Do step 6.3 to 6.5 for it;
     - the user's own claims on `main` (`status: under-review`, `reviewer: <login>`) with
       nothing on the branch are still to review: they go at the front of this run's batch,
       already claimed.

     Once nothing is left uncommitted, `git -C <wt> fetch origin` and
     `git -C <wt> rebase origin/main`, so the rest are judged against the current pages,
     first dropping the review of any proposal someone else changed on `main` (step 8.1, with
     `<run_base>` as step 5 gives it for a cut-off run). On a conflict in a page, stop and
     show the user.

## 3. List the proposals

Read only the frontmatter: Grep `^(type|thread|round|title|proposer|created|status|reviewer|review_started|targets):`
over `<library>/documentation/_proposals/*.md` (skip `_Proposals.md`; `targets:` may run
over several lines), and count each file's points with `^#### [NC][0-9]+\.`. Don't read the
bodies. Also list open PRs and the files they touch:
`gh pr list --repo <repo> --state open --json number,title,headRefName,files`.

Sort by `created`, then file name, and give each a state:

| State | When | What happens |
|---|---|---|
| ready | `status: open`, proposer is not the user | reviewed |
| own | `status: open`, `proposer: <login>` | skipped and listed as waiting for another maintainer, unless `allow-self` |
| mine | `under-review`, `reviewer: <login>` | a cut-off run's claim: reviewed first (step 2) |
| taken | `under-review` by someone else, `review_started` within 14 days | skipped; say who holds it and since when |
| stale | `under-review` by someone else, `review_started` over 14 days ago | offered: say who claimed it and when, suggest asking them first, and take it over only on the user's yes |
| busy | a target page is touched by another open PR (not a proposal PR) | skipped by default, naming the PR: the page is about to change under the review |

Skip and report any file that isn't a well-formed proposal (no `type: proposal`, a file name
that doesn't match its `thread` and `round`, no points, or a target outside the four
folders: `documentation/` except `_proposals/`, `_responses/` and the `/add-paper` log
`add_paper_token_costs.md`; `methods/`; `facilities/`; `codebase_notes/`). The process files
`documentation/_proposals/_Proposals.md`, `documentation/_responses/_Responses.md`,
`_templates/proposal.md` and `_templates/response.md` are valid targets too: they change by
proposal like any group page. The PR agent should have caught a malformed file, and its
proposer should fix it with `/propose-docs`.

Show a table: proposal, proposer, round, created, points, target pages, state. With `list`,
stop here.

## 4. Pick, cost, claim

1. **Pick.** Ask which to review (AskUserQuestion): "All <n> ready, oldest first" (the
   default) or "Only some (I'll name them)", plus any stale ones the user may take over.
2. **Cost.** There is no measured figure yet. Each agent reads the proposal and its earlier
   rounds, every target page in full and the related pages, and fetches the official docs a
   point cites, at high effort. Before a batch of more than 3 proposals or about 30 points
   in all, say that the cost per proposal is unknown and offer fewer. The report at the end
   gives each agent's usage, so a figure can be added here later.
3. **Claim** before any review starts, on `main` in the clone. For each picked proposal set
   exactly three frontmatter lines: `status: under-review`, `reviewer: <login>`,
   `review_started: <today>`. Stage those files by name, commit
   `Claim doc proposals for review: <threads>`, and `git -C <library> push origin main`
   (maintainers may push to main).
   - **Rejected because main moved:** undo only the claim commit
     (`git -C <library> reset --keep HEAD~1`, which keeps any uncommitted work and stops
     rather than overwrite it; step 2 made sure the proposal files had no other changes),
     `git -C <library> pull --ff-only`, re-read the frontmatter, drop every
     proposal that is no longer `open` (someone else claimed it, or it was withdrawn) and
     say which, and claim the rest again.
   - **Refused for another reason** (branch protection, no network): nothing is claimed.
     Say so, and go on unclaimed only if the user agrees, knowing another maintainer could
     review the same proposal.
   - **A stale claim taken over:** the same three lines; note "taken over from <login>,
     claimed <date>" for the PR body.

## 5. The review worktree

- `git -C <library> fetch origin`; `<run_base>` = `git -C <library> rev-parse origin/main`
  (it now includes the claims).
- Branch `review/<login>-<today>` (if that name exists from a finished run today, add `-2`).
  `<parent>` = the folder that holds the clone
  (`dirname "$(git -C <library> rev-parse --show-toplevel)"`).
  `git -C <library> worktree add -b <branch> <parent>/lib-review-<login> origin/main`;
  `<wt>` is its absolute path. A cut-off run reuses its branch and worktree, and its
  `<run_base>` is `git -C <wt> merge-base HEAD origin/main`.
- Every edit of the run goes in `<wt>`. The clone stays on `main`.

## 6. One proposal at a time, oldest first

One agent at a time, in the same worktree, so each proposal is judged against the pages as
the earlier ones in this run left them.

1. **Gather the brief** (cheap, here):
   - the proposal's path in `<wt>`, its `round`, `created` and `base_commit`. Check the
     commit exists (`git -C <wt> cat-file -e <sha>^{commit}`); if not, the brief says so;
   - from round 2, the paths of the thread's earlier rounds
     (`documentation/_proposals/<thread>_r*.md`) and responses
     (`documentation/_responses/<thread>_r*_response.md`);
   - what earlier proposals in this run changed on the same pages: for each target,
     `git -C <wt> log --format="%h %s" <run_base>..HEAD -- "<target>"`, and from those
     agents' replies one line per point that touched it (point, verdict, what was applied
     where);
   - `self_reviewed`: true only for the user's own proposal under `allow-self`.
2. **Launch** one `doc-reviewer` agent (`subagent_type: "shocklab-core:doc-reviewer"`, or
   `"doc-reviewer"` if the agent file was copied into `~/.claude/agents/`;
   `effort: "high"`) and wait for it. The agent definition holds the whole procedure, so the
   brief only gives the inputs:

   ```
   Review one documentation proposal.
   - Library clone (read only; edit nothing there, no git that changes state): <library>
   - Review worktree (all your edits go here; don't commit): <wt>, branch <branch>
   - Proposal: documentation/_proposals/<file>
   - Earlier rounds and responses of this thread: <paths> | none (round 1)
   - base_commit of this round: <sha> | not found (compare against the pages' history since <created>)
   - Review base, for the response's base_commit: <run_base>
   - Reviewer: <login>. Date: <today>. self_reviewed: <true|false>
   - Changed earlier in this run on the same pages: <commit and one line per point> | nothing
   - [Resume: your draft response, with its progress marker, is in the worktree. Carry on from it.]
   Follow your agent definition and reply with the summary it specifies.
   ```

3. **Check the files, not the reply.**
   - `git -C <wt> status --porcelain` lists only the proposal's targets, its response
     (`documentation/_responses/<thread>_r<N>_response.md`), the proposal itself and, for an
     accepted new page, its folder's index page (`documentation/_Documentation.md`,
     `methods/_Methods.md`, `facilities/_Facilities.md`). Undo anything else
     (`git -C <wt> restore <file>`, or delete an untracked file) and say so.
   - The response has no progress marker, and its `counts` match its verdict table.
   - The proposal's diff changes only its `status:` line.
   - The diff doesn't touch `verified:` or `verified_by:` anywhere.
   - For a sample of verdict 1 and 2 points, Grep the page for a line of the applied text;
     for each verdict 3 C-point, Grep for its `## Open questions` entry.

   If something is off, send the agent a message (SendMessage) saying what to fix; fix
   small things yourself and say so.
4. **Maintainer decisions.** For each point the agent returned as a maintainer decision (a
   point rejected again after a rebuttal with a new argument or new evidence, or verdict-2
   wording the reviewer keeps after the proposer rebutted it as changing the meaning), show
   both cases as it gave them: the proposer's case and round, the reviewer's case, the
   proposed text. Then ask with AskUserQuestion, one question per point (at most three per
   call, plus Notes): "Accept the proposer's text" or "Keep it rejected" (for a wording
   rebuttal, "Keep the applied wording"; add "Accept the reviewer's wording" if the agent
   offered a new one). Don't recommend unless asked. A decision is final: the point gets no
   further rounds. Then:
   - in the response's section for the point, replace the pending line with
     `**Decision:** accepted | rejected, by <login> on <today>: <reason>`, using the user's
     reason if they gave one (else "agrees with the proposer's case" or "agrees with the
     reviewer's case"), and update its row in the verdict table;
   - if accepted, apply the text to the page yourself, keeping the page's conventions as the
     agent did (`_Proposals.md`, "Branches and PRs", last paragraph), and remove any
     `## Open questions` entry for the point;
   - recount `maintainer_decision` in the response's `counts`, and set the proposal's
     `status:`: `closed` only if every point of this round is now a 1 or decided (dropped
     and not-reviewed rows don't count against it) **and** the round carries no "Test
     pending" point; else `responded`. Any 2, 3, 4 or 5 leaves it `responded`, so the
     proposer can check verdict-2 wording and verdict-5 reasons, rebut them, or close the
     round with a status-only PR.
5. **Commit** in `<wt>`, staging by name the response, the proposal and every changed page
   (never `git add -A` or `.`):
   `Review <thread> r<N>: <a> accepted, <b> with changes, <c> test, <d> rejected, <e> covered`
   (add `, <f> decided` and ` (self-reviewed)` when they apply).
6. Keep, for the report and the next briefs: the agent's reply lines, and the usage the Agent
   result reports (total tokens, duration).

**Context.** If this session has been compacted during the run, or is past about 150k
tokens, start no new proposal: finish the one in flight and go to step 7. The rest stay
claimed, and the next run continues the branch.

## 7. Check, and show the diff

- `python <wt>/tools/library.py check`. Fix every ERROR the run caused (a broken wikilink in
  a response, say); report others without fixing them.
- Show the user `git -C <wt> log --stat <run_base>..HEAD` and the page edits
  (`git -C <wt> diff <run_base>..HEAD -- <changed pages>`; leave out responses and
  proposals). If the diff is long, give the command and the worktree path so they can read
  it in their editor. Remind them that verdict-2 wording is the reviewer's own, which is why
  they read it before the PR opens.
- Ask: open the PR, change something first, or stop here (the branch stays and the next run
  continues it). For a change they ask for: edit the page and the response's "Applied text"
  together, so they stay identical, and commit it as `Review <thread> r<N>: maintainer's edits`.

## 8. Push and open the PR

1. `git -C <wt> fetch origin`. **First, proposals changed on `main` by someone else.** List
   the commits on `main` since `<run_base>` that touch this run's proposal files
   (`git -C <wt> log --format="%h %an %s" <run_base>..origin/main -- <proposal files>`),
   leaving out this user's own `Claim doc proposals for review: …` commits. Each proposal
   they touch (set to `withdrawn`, its claim released, or anything else) keeps `main`'s
   version, and its review leaves this PR: find its commits on the branch
   (`git -C <wt> log --format=%h --grep="^Review <thread> r<N>" <run_base>..HEAD`, the
   review and any maintainer's edits) and drop each one, newest first, with
   `git -C <wt> rebase --onto <sha>~1 <sha>`. Tell the maintainer which proposal, who changed
   it on `main` and how, and that its response and page edits are no longer in the PR (a
   later proposal in this run that built on its edits may now conflict: stop and show the
   user). Then `git -C <wt> rebase origin/main`. On a conflict in a page, stop and show the
   user. On a proposal's frontmatter, keep this branch's `status:`.
2. `library.py check` again in `<wt>`, then `git -C <wt> push -u origin <branch>`.
3. `gh pr create --repo <repo> --base main --head <branch> --title "Doc proposals reviewed: <n> proposals"`,
   adding ` (<m> self-reviewed)` to the title when any is. Body:
   - one line: reviewer, date, `<run_base>`, and that the reviewer read the diff before
     opening the PR;
   - a table: Proposal | Round | Proposer | 1 | 2 | 3 | 4 | 5 | Decided | Status | Pages changed | Response;
   - self-reviewed proposals by name; stale claims taken over (from whom, claimed when);
     maintainer decisions (point, outcome);
   - the `authors:` of each human-written page changed, so they can see the change;
   - follow-ups for a maintainer: each response's "Existing text found doubtful", and any
     accepted C-point whose old statement is still on a page outside the proposal's targets.

   Leave merging to the org's PR agent (don't run `gh pr merge`). Don't leave a finished
   review unsubmitted for long: proposers can open their next round only once this PR has
   merged, since both change the round's status.
4. `git -C <library> worktree remove <wt>`, then make sure the clone is on `main` and up to
   date (`git -C <library> switch main`, `git -C <library> pull --ff-only`). The branch stays
   on origin until the PR merges; the claims on `main` give way to the PR's statuses then.

## If the run stops early

- **Claims stay** on `main`, so nobody else takes those proposals. The next run finds the
  branch without a PR and continues it (step 2): committed proposals are done, a draft
  response with the marker resumes its agent, the remaining own claims are reviewed first.
- **Dropping a claimed proposal** (the user won't finish it): release it on `main`: set
  `status: open` and empty `reviewer:` and `review_started:`, commit
  `Release doc proposal claim: <thread>`, push. The same for the claims of a review PR that
  was closed without merging.
- Never remove or overwrite another maintainer's claim except a stale one the user chose to
  take over.

## Report

Short, in chat:

- per proposal: the response (link), verdict counts, pages changed, status set;
- tests set (point: the test, and its pass criterion);
- rejections (point: why, in a line) and maintainer decisions (point: outcome);
- existing text found doubtful (page and heading: one line each);
- the PR link (or why there is none); proposals skipped (own and waiting for another
  maintainer, taken, busy, malformed); stale claims taken over; claims this user still
  holds and why;
- usage: tokens and minutes per agent and in all, or "not reported".
