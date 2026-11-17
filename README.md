# ShockLab Claude Code agents

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
for the lab: agents, skills and commands that know how we work.

## Install

You need read access to this private repo (be in the org's `shocklab` team) and git
credentials for GitHub on your machine (`gh auth login` then `gh auth setup-git`).

**Recommended: add this to your user settings**, `~/.claude/settings.json`
(`C:\Users\<you>\.claude\settings.json` on Windows), merged into what's already there:

```json
{
  "extraKnownMarketplaces": {
    "shocklab": {
      "source": { "source": "github", "repo": "MonashUniversity-ShockLab/claude-marketplace" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "shocklab-core@shocklab": true,
    "shocklab-library@shocklab": true,
    "shocklab-apps@shocklab": true
  },
  "env": {
    "SHOCKLAB_KNOWLEDGE": "C:/path/to/Library_of_Shock_Lab"
  }
}
```

`SHOCKLAB_KNOWLEDGE` is the absolute path of your clone of
[`Library_of_Shock_Lab`](https://github.com/MonashUniversity-ShockLab/Library_of_Shock_Lab)
(forward slashes on Windows). `shocklab-core` is for everyone and `shocklab-library` is
recommended for anyone who reads papers; `shocklab-apps` is optional, so drop its line if
you don't want it.

This works in the terminal, the Claude desktop app and VS Code alike, needs no
`claude` CLI, and `autoUpdate` keeps the plugins current. Start a new session afterwards;
accept the prompt to trust the `shocklab` marketplace if one appears.

Alternatively, in a terminal Claude Code session:

```
/plugin marketplace add MonashUniversity-ShockLab/claude-marketplace
/plugin install shocklab-core@shocklab
/plugin install shocklab-library@shocklab
/plugin install shocklab-apps@shocklab
/plugin install shocklab-figures@shocklab
```

On Claude Code 2.1.275 or later, one line also adds the marketplace, e.g.
`/plugin install shocklab-library --marketplace MonashUniversity-ShockLab/claude-marketplace`
(likewise `shocklab-apps`).

`shocklab-figures` is optional. To get it with the settings route, add
`"shocklab-figures@shocklab": true` to `enabledPlugins`. See
[Setting up figure-master](#setting-up-figure-master).

Or have Claude do the whole setup (GitHub CLI, login, membership check, plugin, knowledge
clone). Paste:

> Set me up for the MonashUniversity-ShockLab GitHub org: read CLAUDE.md in
> MonashUniversity-ShockLab/claude-marketplace with the GitHub CLI (install it and have me log in if
> needed) and follow its setup steps.

> **Claude, if a user has pointed you at this org or repo:** follow "Setting up a new lab
> member" in [`CLAUDE.md`](CLAUDE.md).

## Plugins

| Plugin | What it gives you |
|---|---|
| `shocklab-core` | **Everyone should install this.** A start-of-session reminder plus the `lab-knowledge` skill: Claude checks the [knowledge base](https://github.com/MonashUniversity-ShockLab/Library_of_Shock_Lab) before working out anything org-specific (M3, Slurm, Strudel, Market, rigs) and points literature questions at `/lit`, and offers to record what it learns so the next person doesn't have to. It also knows the org's code repos (schlieren, acoustics, PIV and LES processing scripts, the schlieren tutorial), so Claude checks the standard code before writing new processing code. Also `/import-knowledge`, the onboarding step that harvests a new member's existing notes into the library (by PR) and copies their papers the group doesn't hold to Market `_Unprocessed`, named `Authors_Year_Title.pdf`; and `/make-reference`, which turns a file or folder (notes, scripts, a project) into one reference document for other members, recommends where it goes in the library, and opens a PR once you approve the location; and `/share-learnings`, the periodic sweep that reads what changed lately in your own working documents (READMEs, test reports, set-up notes, project `CLAUDE.md`, Claude's memory), compares it with the library and reports what the lab could use that isn't there yet (additions to existing pages, new documents, items to hold, library statements your notes outdate), then writes the batch you pick by PR (token-heavy: one subagent per area); and `/publish-app`, which puts an app you built (e.g. one based on FieldsPlayer) in its own org repo with downloadable releases, the way FieldsPlayer is set up, and lists it in the library's `applets/` |
| `shocklab-library` | Skills for the shared paper library (`Library_of_Shock_Lab`, found through `SHOCKLAB_KNOWLEDGE`): for everyone, `/lit` (answer from the library, with note and page citations) and `/research-question` (in-depth reasoned answer, saved and shared in the library's `research_questions/` with you as `author`; open a PR to add it) and `/add-paper` (index new PDFs into notes, topic pages and data tables by pull request, then file them on Market; token-heavy, as it reads each paper in full) and `/paper-audit` (re-check an older note against its PDF and the library, by pull request; notes are claimed first so nobody audits the same one twice; token-heavy), plus the `paper-auditor` agent it launches, and `/update-topics` (work the queued contributions into the topic pages, major corrections and largest queues first, then apply the queued note updates; each page and note is claimed on Market first so two runs never revise the same one; a member's run does 3 pages by default and opens a PR; one commit per page, so a cut-off loses at most one page; token-heavy), and `/schedule-library-processing <skill>` (books an unattended run of `add-paper`, `paper-audit` or `update-topics` for 11pm tonight, with a 4:05am task that finishes any cut-off work and opens the pull request: a way to spend spare usage at the end of the week; needs the Claude desktop app open and the computer awake overnight), and `/library-status` (pulls the library clone and files indexed papers' PDFs on Market, after one confirmation, then gives a quick report of what is waiting: contributions queued per topic page and pages due for revision, queued note updates and notes still to check, the paper-audit queue and audits in progress, papers in Market `_Unprocessed` and who has claimed them, indexed papers whose PDF isn't filed on Market yet, a library health line from `library.py check`, and open library pull requests, each with the skill that clears it); for maintainers only, `/restructure-note` (reshape audited notes to the template) and its `note-restructurer` agent. Members' `/add-paper` and `/paper-audit` runs queue topic-page changes but never revise the pages; `/update-topics` or a maintainer's run does that. To get a paper in, put its PDF in Market `Library_of_Shock_Lab\papers\_Unprocessed\`; anyone can then process it with `/add-paper`. See [Setting up the paper library](#setting-up-the-paper-library) |
| `shocklab-apps` | `/queue` (add a request to an app's `FEATURE_QUEUE.md` for the next build) and `/enact-queue` (build every queued request with one version bump, using the build and test steps in the app's README). Works for any app folder in your repo that has, or gets, a `FEATURE_QUEUE.md` |
| `shocklab-figures` | The `figure-master` agent: makes plots from data in the lab's MATLAB house style (Times 16 pt, LaTeX labels, `pogmap`/`CMRmap`, no titles), restyles existing ones, copies journal figures only after checking their licence and recreates them from data otherwise, then hands back a LaTeX figure block. Ships the `pogmap` and `CMRmap` colormaps. See [Setting up figure-master](#setting-up-figure-master) |

### How `shocklab-core` avoids duplicated work

1. **Look first.** A `SessionStart` hook adds a short reminder
   (`plugins/shocklab-core/hooks/session-reminder.md`) to every session, so Claude reaches
   for the `lab-knowledge` skill before working out org-specific procedures, not only when
   the question happens to match the skill's description. The skill starts with
   `documentation/Org Gotchas.md` in the knowledge repo, then greps.
2. **Write back.** When Claude solves something non-obvious and org-specific, it offers,
   after your task, to add it to the knowledge base. You see the diff before anything
   is committed.

3. **Let the PR agent merge.** A `PreToolUse` hook (`plugins/shocklab-core/hooks/merge-guard.sh`)
   catches `gh pr merge` on a MonashUniversity-ShockLab repo and asks you first, showing the
   PR's title, branches and changed files: the PR agent normally merges, but you may still
   merge yourself. If only part should go in, decline and have Claude split those files into
   their own PR. It never blocks, and stays silent for other orgs. Merges in the GitHub web
   page aren't caught; the guideline still applies.

Change the reminder's wording in `session-reminder.md` and bump the version; everyone
gets it on their next `/plugin marketplace update shocklab`.

### Without the plugin

If you'd rather not install the hook, put this in your user-level `~/.claude/CLAUDE.md`
(`C:\Users\<you>\.claude\CLAUDE.md` on Windows):

```markdown
## ShockLab
Before working out anything specific to the lab, Monash or its infrastructure (M3/MASSIVE,
Slurm requests, Strudel, the Market drive, MATLAB on the cluster, lab rigs, cameras),
check the ShockLab knowledge base first: start at `documentation/Org Gotchas.md` in
MonashUniversity-ShockLab/Library_of_Shock_Lab (local clone, or `gh api`; for literature questions start at `INDEX.md` and `topics/`). After solving something
non-obvious and org-specific, offer to record it there once my task is done.
```

### Setting up the paper library

1. Clone the library (not in a OneDrive or Dropbox folder):
   `git -c core.longpaths=true clone https://github.com/MonashUniversity-ShockLab/Library_of_Shock_Lab.git`
2. Copy the PDFs: the contents of the Market folder `Library_of_Shock_Lab\papers`
   (including `_Unprocessed`, `_Off_Topic` and `_Deferred`) go into
   `attachments/papers/` in your clone. Git ignores that folder. Copy again after a
   `git pull` to get PDFs for new notes. Market's drive letter differs between PCs
   (`Z:` on some, `Y:` on others); to find yours, run this in PowerShell, which prints
   nothing if Market isn't mounted (connect it first):
   `Get-PSDrive -PSProvider FileSystem | ForEach-Object { Join-Path $_.Root 'Library_of_Shock_Lab\papers' } | Where-Object { Test-Path $_ }`.
   Then on Windows, with `<M>` that drive letter:
   `robocopy "<M>:\Library_of_Shock_Lab\papers" "<clone>\attachments\papers" /E /XC /XN /XO`;
   on macOS/Linux:
   `rsync -a --ignore-existing "<market>/Library_of_Shock_Lab/papers/" "<clone>/attachments/papers/"`.
   Both copy only files you don't have yet and never overwrite one in your clone.
3. Set `SHOCKLAB_KNOWLEDGE` to the clone's absolute path (the `env` block above).
4. Python 3 on PATH (standard library only) runs `tools/library.py`; `pdftotext` and
   `pdfinfo` (Poppler, MiKTeX or TeX Live) are needed by `/add-paper` and `/paper-audit`.

`Misc/` (ledgers such as `paper_audit.tsv`, `restructure_ledger.tsv`, `Papers_to_get.md`)
is personal and by default lives inside the clone, where it is git-ignored (or in the path
in `SHOCKLAB_PERSONAL`, or a `My_Knowledgebase/` folder next to the clone, for anyone who
already has one; no need to create either). Research questions are
shared, in the clone's `research_questions/`: any member may add one with
`/research-question` and a PR. The skills and
`tools/library.py` find it the same way and create what they need there; nothing in it is
committed to the shared repo.

### Keeping up to date weekly

`autoUpdate` refreshes the plugins, but your library clone only changes when you pull it.
To have Claude do both every week, paste this into a Claude desktop-app session (the task
runs only while the app is open and the computer is awake):

> Set up a **weekly scheduled task** in the Claude desktop app that keeps my ShockLab setup
> in line with GitHub. Before creating it, ask me which day and time to run it (suggest
> Monday morning) and show me the task's prompt to check.
>
> Each week the task should:
>
> 1. **Pull the library.** In my clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`
>    (path in the `SHOCKLAB_KNOWLEDGE` environment variable), run `git pull --ff-only`. If
>    the clone has uncommitted changes, is not on `main`, or can't fast-forward, don't
>    stash, reset, rebase or merge: leave it and report it. If Market is mounted, also copy
>    any new paper PDFs from Market `Library_of_Shock_Lab\papers` into the clone's
>    `attachments\papers\`, with commands that never overwrite (Windows:
>    `robocopy <src> <dst> /E /XC /XN /XO`); if it isn't mounted, skip this and say so.
> 2. **Check the plugins match GitHub.** Read `.claude-plugin/marketplace.json` from
>    `MonashUniversity-ShockLab/claude-marketplace` on `main` (with `gh api`) and compare
>    each `shocklab-*` plugin's version with what Claude Code has installed locally (under
>    `~/.claude/plugins/`). Refresh the `shocklab` marketplace and update any plugin that is
>    behind with the `claude plugin` CLI commands if available (check `claude plugin --help`);
>    otherwise tell me to run `/plugin marketplace update shocklab` in a new session. Check
>    that the `shocklab` marketplace has `autoUpdate` on in my user settings, and tell me if
>    not, but don't change my settings yourself.
> 3. **Report briefly:** library commits pulled (count and a one-line summary of what
>    changed, e.g. new paper notes or topic pages), PDFs copied, plugins updated (old → new
>    version), and anything that needs me (a dirty clone, a failed update). Remind me that
>    updated skills load only in a **new** session.
>
> Never commit, push, delete or change settings, either while setting this up or in the
> weekly runs.

Without the `claude` CLI on PATH, the task can only report which plugins are behind; update
them by hand as it says.

### Using a skill without the plugin

Every skill is one self-contained folder in [`skills/`](skills/) (`skills/<name>/SKILL.md`
plus any files beside it), so an agent or a person can fetch one straight from this repo.
To use one without installing a plugin, copy `skills/<name>/` into `~/.claude/skills/`
(`C:\Users\<you>\.claude\skills\` on Windows), and any agent it launches from
[`agents/`](agents/) into `~/.claude/agents/`. Copied this way they run as `/<name>` and
their agents as `paper-auditor` / `note-restructurer` (without the `shocklab-library:`
prefix). The library skills read each other's files from sibling folders, so copy
`add-paper` and `lit` along with the others.

### Setting up figure-master

You need MATLAB. To pull figures out of papers you also need `pdfimages` and `pdftoppm`
(from MiKTeX, TeX Live or Poppler). The agent reads your paths from a `## Figures` section
in your project's `CLAUDE.md`. If that section is missing, it asks you for the paths and
then gives you the section to paste in:

```markdown
## Figures
- Document: C:\path\to\Report\main.tex
- Figures folder: C:\path\to\Report\figures
- Scripts folder: C:\path\to\Report\figures\scripts
- Bibliography: C:\path\to\Report\reference.bib
- Paper PDFs: C:\path\to\papers            (optional)
- Git: Overleaf clone, never commit         (optional)
```

The first time it's used, it copies `pogmap` and `CMRmap` into `<scripts folder>/colormaps/`,
so your scripts still run for co-authors who don't have the plugin. To use it, just ask for
a figure ("make a figure of ... from ..."). Claude hands the job to `figure-master`, or you
can ask for it by name.

Planned: `video-master` (schlieren and field videos from FieldsPlayer), once FieldsPlayer
has a home in the org.

## PR agent

A Claude agent in the lab's Anthropic Console (a Managed Agent) looks after pull requests
across the whole org. Every hour, 8am to 8pm Melbourne time, Monday to Friday, it:

1. finds open, non-draft PRs it hasn't reviewed at their current commit;
2. reviews each one against that repo's `CLAUDE.md`;
3. commits fixes for mechanical problems (frontmatter, naming, version bumps) to the PR
   branch;
4. squash-merges it and labels it `claude-approved`, noting anything the author should follow
   up. The one exception is a large change to an existing note (deleting it, rewriting a big
   part of it, or changing its results). Those get `needs-human` and a comment saying who
   should look.

In the library it also runs `tools/library.py check` (0 errors is the bar), never edits
`INDEX.md` or `references.bib` (it asks for a rebuild instead), and removes PDFs, `Misc/`
and the skills' scratch folders from PR branches. It treats an `/add-paper` PR (many one-line
link edits across existing notes) and a topic-page revision that drains its queue as normal
merges. It holds a topic page rewritten without draining its queue, and audit or restructure
work from someone who isn't a maintainer. After merging new paper notes, it reminds the
author to file the PDFs on Market.

New repos are covered automatically (the app is installed on all of the org's
repositories). Nothing needs adding per repo. Its GitHub App has no Workflows permission,
so it can't change or merge `.github/workflows/`; those PRs get `needs-human`. Pushes
straight to `main` skip it.

Its definition lives in [`managed-agents/pr-agent/`](managed-agents/pr-agent/):

| File | What it is |
|---|---|
| `agent.md` | Model and instructions (the review, fix and merge rules) |
| `environment.yaml` | Sandbox; its network can only reach GitHub |
| `vault.yaml` | Holds the GitHub tokens `GH_TOKEN` and `GH_DISPATCH_TOKEN` (never committed) |
| `deployment-hourly.yaml` | The Console schedule (hourly, 8am-8pm Melbourne, Mon-Fri), plus a $10 cap per run |

`claude-lock.json` records the Console IDs. To change the agent, edit the file, then run
`ant apply managed-agents/pr-agent/<file>` from the repo root, signed in with
`ant auth login` to the ShockLab workspace. Each run shows up as a session in the
Console, with the full transcript.

- Run now: `ant beta:deployments run --deployment-id <depl_... from claude-lock.json>`, or
  from the Actions tab run **Refresh PR agent token** with "Start an agent run" ticked.
- Pause: `ant beta:deployments pause --deployment-id <same>` (`unpause` to resume).

The agent acts on GitHub as `shocklab-pr-agent[bot]`, an org-owned GitHub App with
Contents, Pull requests and Issues set to read/write (no Workflows). App tokens last one
hour, and the agent's sandbox never sees the app's private key, so it can't mint its own.
Instead, each run's first step starts the
[`refresh-pr-agent-token`](.github/workflows/refresh-pr-agent-token.yml) workflow, which
mints a token and writes it into the vault as `GH_TOKEN`; the running session picks up the
new value within a few minutes, and the sweep begins. To start the workflow, the agent uses
`GH_DISPATCH_TOKEN`, a fine-grained token that can only read and run Actions in this repo.
It has an expiry date: when it lapses, runs stop at the first step, so make a new one and
update the credential. The workflow has no schedule of its own (GitHub's scheduler skipped
almost every slot). It needs the variable `PR_AGENT_APP_ID` and the secrets
`PR_AGENT_APP_KEY` (the app's private key) and `ANTHROPIC_VAULT_KEY` (a Console API key in
the ShockLab workspace) in this repo's Actions settings.

## Layout

```
managed-agents/pr-agent/                 the org-wide PR agent (Console Managed Agent)
.claude-plugin/marketplace.json          the catalogue: one entry per plugin
skills/<skill>/SKILL.md                  shared skills, one self-contained folder each
agents/<agent>.md                        agents the shared skills launch
plugins/<plugin>/.claude-plugin/plugin.json
plugins/<plugin>/agents/<agent>.md       subagents
plugins/<plugin>/skills/<skill>/SKILL.md skills
plugins/<plugin>/commands/<cmd>.md       slash commands
```

### How the top-level `skills/` and `agents/` become plugins

`shocklab-library` and `shocklab-apps` have no folder under `plugins/`. Their
marketplace entries are the manifest (there is no `plugin.json` for them, and they set
`"strict": false`) and list exactly which skill folders and agent files they contain,
as the [plugin manifest reference](https://code.claude.com/docs/en/plugins-reference)
("Marketplace entries and the manifest") allows:

- `shocklab-library` has `"source": "./"` (the repo root). When a root-source entry lists
  `skills`, only those folders load; its `agents` list replaces the default `agents/` scan.
- `shocklab-apps` has `"source": "./skills"`, with `skills` paths relative to that folder.
  It can't use the repo root, because a root-source plugin with no agent files listed
  would also pick up everything in `agents/`.

Installed plugins are copied into the plugin cache, and a plugin can only reach files
inside its own source folder, so the skills must stay inside the folder each entry names
(no `..` paths). To add a skill to one of these plugins, put it in `skills/<name>/`, add
its path to the entry's `skills` list, and bump the entry's `version`.

## Adding a plugin

1. Copy `plugins/shocklab-core` to `plugins/<your-plugin>` and edit its `plugin.json`.
2. Add agents/skills. **Generalise before committing**: no personal paths
   (`C:\Users\...`, OneDrive), no file names only you have. Take paths as arguments,
   or read them from an environment variable or the project's `CLAUDE.md`.
3. Add an entry to `.claude-plugin/marketplace.json`.
4. Test locally: `/plugin marketplace add ./` from a clone, then install it.
5. Bump `version` in both files when you change a plugin, so others get the update
   (for `shocklab-library` and `shocklab-apps`, the marketplace entry is the only place).
6. Open a PR.
