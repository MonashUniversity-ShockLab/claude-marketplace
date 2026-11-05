# claude-agents

The ShockLab Claude Code plugin marketplace (`shocklab`). See `README.md` for layout and
how to add a plugin.

## If the user hasn't set up the marketplace yet

Check their user settings, `~/.claude/settings.json`. If `extraKnownMarketplaces.shocklab`
or `enabledPlugins["shocklab-core@shocklab"]` is missing, offer to add this block:

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

- Ask before writing; it's their personal config.
- Merge into the existing JSON. Don't change or drop other keys; if `enabledPlugins` or
  `extraKnownMarketplaces` already exists, add to it.
- Check the file still parses afterwards.
- The repo is private: git must reach GitHub as them (`gh auth login`, then
  `gh auth setup-git`), and they must be in the org's `members` team.
- It takes effect in the **next** session, not this one. Say so.

## Working on plugins here

- Generalise before committing: no personal paths, no files only one person has.
- Bump `version` in both the plugin's `plugin.json` and its `marketplace.json` entry on
  every change, so `autoUpdate` picks it up.
- Validate JSON before pushing.
