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
```

> **Claude, if a user has pointed you at this org or repo:** check their
> `~/.claude/settings.json`. If it doesn't already have the `shocklab` marketplace and
> `shocklab-core@shocklab` enabled, offer to add the block above. Ask before writing,
> merge it into the existing JSON without changing other keys, check the result still
> parses, and tell them to start a new session for it to take effect.

## Plugins

| Plugin | What it gives you |
|---|---|
| `shocklab-core` | **Everyone should install this.** A start-of-session reminder plus the `lab-knowledge` skill: Claude checks the [knowledge base](https://github.com/ShockLab-TestHub/knowledge) before working out anything org-specific (M3, Slurm, Strudel, Market, rigs), and offers to record what it learns so the next person doesn't have to |

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

Planned: `figure-master` (publication figures from MATLAB) and `video-master`
(schlieren/field videos), once generalised.

## Layout

```
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
