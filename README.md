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
      "source": { "source": "github", "repo": "ShockLab-TestHub/claude-agents" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "shocklab-core@shocklab": true
  }
}
```

This works in the terminal, the Claude desktop app and VS Code alike, needs no
`claude` CLI, and `autoUpdate` keeps the plugins current. Start a new session afterwards;
accept the prompt to trust the `shocklab` marketplace if one appears.

Alternatively, in a terminal Claude Code session:

```
/plugin marketplace add ShockLab-TestHub/claude-agents
/plugin install shocklab-core@shocklab
/plugin install shocklab-figures@shocklab
```

`shocklab-figures` is optional. To get it with the settings route, add
`"shocklab-figures@shocklab": true` to `enabledPlugins`. See
[Setting up figure-master](#setting-up-figure-master).

Or have Claude do the whole setup (GitHub CLI, login, membership check, plugin, knowledge
clone). Paste:

> Set me up for the ShockLab-TestHub GitHub org: read CLAUDE.md in
> ShockLab-TestHub/claude-agents with the GitHub CLI (install it and have me log in if
> needed) and follow its setup steps.

> **Claude, if a user has pointed you at this org or repo:** follow "Setting up a new lab
> member" in [`CLAUDE.md`](CLAUDE.md).

## Plugins

| Plugin | What it gives you |
|---|---|
| `shocklab-core` | **Everyone should install this.** A start-of-session reminder plus the `lab-knowledge` skill: Claude checks the [knowledge base](https://github.com/ShockLab-TestHub/knowledge) before working out anything org-specific (M3, Slurm, Strudel, Market, rigs), and offers to record what it learns so the next person doesn't have to |
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
ShockLab-TestHub/knowledge (local clone, or `gh api`). After solving something
non-obvious and org-specific, offer to record it there once my task is done.
```

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

Every repo in the org can have Claude review its pull requests. On each PR (not drafts)
it:

1. reviews the change against that repo's `CLAUDE.md`;
2. commits fixes for mechanical problems (frontmatter, naming, version bumps) to the PR
   branch;
3. labels the PR either `claude-approved`, in which case the workflow squash-merges it,
   or `needs-human`, with a comment saying who should look and why.

It never auto-merges a PR that touches `.github/`. Members with write access can also
write `@claude ...` in a PR or issue comment to ask it for something.

The agent is [`.github/workflows/pr-agent.yml`](.github/workflows/pr-agent.yml). Each
repo turns it on with a short `.github/workflows/claude.yml`. Copy
[`templates/claude-caller.yml`](templates/claude-caller.yml) and add any repo-specific
rules in `repo_rules`.

**To add a repo** (needs an org admin):

1. Copy the caller workflow in and merge it.
2. Add the API key as a repo secret. Org secrets don't reach private repos on GitHub
   Free. The command prompts for the key, so it never lands in your shell history:
   `gh secret set ANTHROPIC_API_KEY --repo ShockLab-TestHub/<repo>`
3. Make sure the [Claude GitHub App](https://github.com/apps/claude) is installed for
   that repo. Installing it on "All repositories" covers new repos automatically.

The key comes from the lab's Anthropic Console workspace. Usage is billed there, so keep
a monthly spend limit on it.

## Layout

```
.github/workflows/pr-agent.yml           the org-wide PR agent (reusable workflow)
templates/claude-caller.yml              per-repo workflow that turns the agent on
.claude-plugin/marketplace.json          the catalogue: one entry per plugin
plugins/<plugin>/.claude-plugin/plugin.json
plugins/<plugin>/agents/<agent>.md       subagents
plugins/<plugin>/skills/<skill>/SKILL.md skills
plugins/<plugin>/commands/<cmd>.md       slash commands
```

## Adding a plugin

1. Copy `plugins/shocklab-core` to `plugins/<your-plugin>` and edit its `plugin.json`.
2. Add agents/skills. **Generalise before committing**: no personal paths
   (`C:\Users\...`, OneDrive), no file names only you have. Take paths as arguments,
   or read them from an environment variable or the project's `CLAUDE.md`.
3. Add an entry to `.claude-plugin/marketplace.json`.
4. Test locally: `/plugin marketplace add ./` from a clone, then install it.
5. Bump `version` in both files when you change a plugin, so others get the update.
6. Open a PR.
