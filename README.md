# ShockLab Claude Code agents

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
for the lab: agents, skills and commands that know how we work.

## Install

You need read access to this private repo (be in the org's `members` team) and git
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
(forward slashes on Windows). `shocklab-library` and `shocklab-apps` are optional; drop
their lines if you don't want them.

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
| `shocklab-core` | **Everyone should install this.** A start-of-session reminder plus the `lab-knowledge` skill: Claude checks the [knowledge base](https://github.com/MonashUniversity-ShockLab/Library_of_Shock_Lab) before working out anything org-specific (M3, Slurm, Strudel, Market, rigs) and points literature questions at `/lit`, and offers to record what it learns so the next person doesn't have to |
| `shocklab-library` | Skills for the shared paper library (`Library_of_Shock_Lab`, found through `SHOCKLAB_KNOWLEDGE`): for everyone, `/lit` (answer from the library, with note and page citations) and `/research-question` (in-depth reasoned answer, saved and shared in the library's `research_questions/` with you as `author`; open a PR to add it); for maintainers only, `/add-paper` (index new PDFs into notes, topic pages and data tables, then file them on Market), `/paper-audit` and `/restructure-note` (bring older notes up to standard), plus the `paper-auditor` and `note-restructurer` agents they launch. Students request a paper by putting its PDF in Market `Z:\Library_of_Shock_Lab\papers\_Unprocessed\`; maintainers process it and push. See [Setting up the paper library](#setting-up-the-paper-library) |
| `shocklab-apps` | `/queue` (add a request to an app's `FEATURE_QUEUE.md` for the next build) and `/enact-queue` (build every queued request with one version bump, using the build and test steps in the app's README). Works for any app folder in your repo that has, or gets, a `FEATURE_QUEUE.md` |
| `shocklab-figures` | The `figure-master` agent: makes plots from data in the lab's MATLAB house style (Times 16 pt, LaTeX labels, `pogmap`/`CMRmap`, no titles), restyles existing ones, copies journal figures only after checking their licence and recreates them from data otherwise, then hands back a LaTeX figure block. Ships the `pogmap` and `CMRmap` colormaps. See [Setting up figure-master](#setting-up-figure-master) |

### How `shocklab-core` avoids duplicated work

1. **Look first.** A `SessionStart` hook adds a three-line reminder
   (`plugins/shocklab-core/hooks/session-reminder.md`) to every session, so Claude reaches
   for the `lab-knowledge` skill before working out org-specific procedures, not only when
   the question happens to match the skill's description. The skill starts with
   `documentation/Org Gotchas.md` in the knowledge repo, then greps.
2. **Write back.** When Claude solves something non-obvious and org-specific, it offers,
   after your task, to add it to the knowledge base. You see the diff before anything
   is committed.

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
2. Copy the PDFs: the contents of the Market folder `Z:\Library_of_Shock_Lab\papers`
   (including `_Unprocessed`, `_Off_Topic` and `_Deferred`) go into
   `attachments/papers/` in your clone. Git ignores that folder. Copy again after a
   `git pull` to get PDFs for new notes.
3. Set `SHOCKLAB_KNOWLEDGE` to the clone's absolute path (the `env` block above).
4. Python 3 on PATH (standard library only) runs `tools/library.py`; `pdftotext` and
   `pdfinfo` (Poppler, MiKTeX or TeX Live) are needed by `/add-paper` and `/paper-audit` (maintainers).

`Misc/` (ledgers such as `paper_audit.tsv`, `restructure_ledger.tsv`, `Papers_to_get.md`)
is personal and lives in a folder outside the clone: the path in
`SHOCKLAB_PERSONAL` if set, else `My_Knowledgebase/` next to the clone (`../My_Knowledgebase`)
if it exists, else the clone itself (where it is git-ignored). Research questions are
shared, in the clone's `research_questions/`: any member may add one with
`/research-question` and a PR. The skills and
`tools/library.py` find it the same way and create what they need there; nothing in it is
committed to the shared repo.

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

New repos are covered automatically. Nothing needs adding per repo. Its GitHub token has
no Workflows permission, so it can't change `.github/workflows/`. Pushes straight to
`main` skip it.

Its definition lives in [`managed-agents/pr-agent/`](managed-agents/pr-agent/):

| File | What it is |
|---|---|
| `agent.md` | Model and instructions (the review, fix and merge rules) |
| `environment.yaml` | Sandbox; its network can only reach GitHub |
| `vault.yaml` | Holds the GitHub token as `GH_TOKEN` (the token itself is added separately and never committed) |
| `deployment-hourly.yaml` | The schedule, plus a $3 cap per run |

`claude-lock.json` records the Console IDs. To change the agent, edit the file, then run
`ant apply managed-agents/pr-agent/<file>` from the repo root, signed in with
`ant auth login` to the ShockLab workspace. Each run shows up as a session in the
Console, with the full transcript.

- Pause: `ant beta:deployments pause --deployment-id <depl_... from claude-lock.json>`
- Run now: `ant beta:deployments run --deployment-id <same>`

The GitHub token is a fine-grained token on the org with Contents, Pull requests and
Issues set to read/write, and it expires. To replace it, update the vault credential
with `ant beta:vaults:credentials update`.

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
