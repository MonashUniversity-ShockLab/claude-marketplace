# claude-marketplace

The ShockLab Claude Code plugin marketplace (`shocklab`). See `README.md` for layout and
how to add a plugin.

## Setting up a new lab member

Run this when a user asks to be set up for MonashUniversity-ShockLab, or when you notice their
setup is incomplete. Go in order. Each step checks first and skips if already done, so it
is safe to re-run. Ask before anything that writes to their machine or config. At the
end, summarise what you did and what they still need to do.

### 1. GitHub CLI installed

`gh --version`. If missing, offer to install it:

- Windows: `winget install --id GitHub.cli -e --source winget` (the `--source winget`
  avoids a failure when the msstore source is unreachable). A shell that was already
  open won't see it on PATH. Use `"C:\Program Files\GitHub CLI\gh.exe"` until a new
  shell starts.
- macOS: `brew install gh`. Linux: https://github.com/cli/cli#installation

### 2. Logged in to GitHub

`gh auth status`. If not logged in, **the user has to do this themselves**, because it's
a browser approval. Give them this command to run in a terminal, or open it in one for
them:

```
gh auth login --hostname github.com --git-protocol https --web
```

Wait for them to say it's done, then re-check `gh auth status`.

### 3. Git uses the GitHub login

`gh auth setup-git`. Without this, Claude Code can't fetch the private marketplace, and
it fails without a clear error.

### 4. Member of the org

`gh api user/memberships/orgs/MonashUniversity-ShockLab --jq .state`

- `active`: continue.
- `pending`: they haven't accepted the invite. Send them to
  https://github.com/orgs/MonashUniversity-ShockLab/invitation, then re-check.
- 404 or error: they haven't been invited. **Stop here.** Tell them to ask an org owner to
  add their GitHub username (`gh api user --jq .login`) to the `members` team.

Then confirm git can read the repos without prompting:
`GIT_TERMINAL_PROMPT=0 git ls-remote https://github.com/MonashUniversity-ShockLab/claude-marketplace.git HEAD`
(in PowerShell, set `$env:GIT_TERMINAL_PROMPT=0` first).

### 5. Marketplace and plugin in user settings

Check `~/.claude/settings.json` (`C:\Users\<you>\.claude\settings.json` on Windows). If
`extraKnownMarketplaces.shocklab` or `enabledPlugins["shocklab-core@shocklab"]` is
missing, add:

```json
{
  "extraKnownMarketplaces": {
    "shocklab": {
      "source": { "source": "github", "repo": "MonashUniversity-ShockLab/claude-marketplace" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "shocklab-core@shocklab": true
  }
}
```

- It's their personal config, so ask before writing.
- Merge into the existing JSON. Don't change or drop other keys. If `enabledPlugins` or
  `extraKnownMarketplaces` already exists, add to it. If the file doesn't exist, create
  it with just this block.
- Check that the file still parses afterwards.

Then offer the optional plugins listed in `README.md`. Today that is
`shocklab-figures` (the `figure-master` agent), which needs MATLAB, plus `pdfimages` /
`pdftoppm` for pulling figures out of papers. If they want it, add
`"shocklab-figures@shocklab": true` to `enabledPlugins`. Its per-project setup is in the
README under "Setting up figure-master".

### 6. Local clone of the knowledge base

Ask where they keep code. Recommend a folder that is **not** synced by OneDrive or
Dropbox, because sync tools can corrupt `.git` (e.g. `C:\Users\<you>\code` or `~/code`).
Then:

```
git -c core.longpaths=true clone https://github.com/MonashUniversity-ShockLab/knowledge.git <parent>/knowledge
```

On Windows, also run `git -C <parent>/knowledge config core.longpaths true`.

Point Claude at the clone by adding this to the same `~/.claude/settings.json`, merged
in the same way:

```json
{ "env": { "SHOCKLAB_KNOWLEDGE": "<absolute path to the clone>" } }
```

On Windows, use forward slashes or escaped backslashes in the JSON string.

Ask whether they already have paper PDFs (e.g. a personal Obsidian vault). If so, offer to
copy them into `<parent>/knowledge/attachments/papers/`, which git ignores. Paper notes
embed PDFs from there, and the files need the `author-year-shorttitle.pdf` names in the
notes' `pdf:` fields. Papers they don't have show a "not found" placeholder, which is
expected.

Optional: suggest opening the clone as an Obsidian vault with the Dataview plugin.

### 7. Finish

Tell them:

- Start a **new** Claude session. Plugins and settings load at session start, not in the
  current session. Accept the prompt to trust the `shocklab` marketplace if one appears.
- To check it worked: `shocklab-core` is listed under **+ → Plugins** (desktop app) or
  `/plugin` (terminal). Asking something like "write an sbatch script for a 16-core
  MATLAB job on M3" should make Claude consult the knowledge base and use
  `--ntasks=1 --cpus-per-task=16`.
- Read `onboarding/Getting started.md` and `CLAUDE.md` in the knowledge clone.

## Working on plugins here

- Generalise before committing: no personal paths, and no files that only one person has.
- On every change, bump `version` in both the plugin's `plugin.json` and its
  `marketplace.json` entry, so `autoUpdate` picks it up.
- Validate JSON before pushing.
