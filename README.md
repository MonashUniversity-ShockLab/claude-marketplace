# ShockLab Claude Code agents

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
for the lab: agents, skills and commands that know how we work.

## Install

You need read access to this private repo (be in the org's `members` team) and git
credentials for GitHub on your machine (`gh auth login` then `gh auth setup-git`).

In Claude Code:

```
/plugin marketplace add ShockLab-TestHub/claude-agents
/plugin install shocklab-core@shocklab
```

Update later with `/plugin marketplace update shocklab`.

## Plugins

| Plugin | What it gives you |
|---|---|
| `shocklab-core` | `lab-knowledge` skill: Claude finds, reads and correctly writes to the [knowledge base](https://github.com/ShockLab-TestHub/knowledge) |

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
