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

### 5. Marketplace and plugins in user settings

Check `~/.claude/settings.json` (`C:\Users\<you>\.claude\settings.json` on Windows). If
`extraKnownMarketplaces.shocklab`, `enabledPlugins["shocklab-core@shocklab"]` or
`enabledPlugins["shocklab-library@shocklab"]` is missing, add:

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
    "shocklab-library@shocklab": true
  }
}
```

`shocklab-core` is for everyone. `shocklab-library` (the paper-library skills: `/lit` and
`/research-question` for everyone; `/add-paper`, `/paper-audit` and `/restructure-note`,
which change the notes, for maintainers only) is on by default, as in the library's
`onboarding/Getting started.md`; it needs the library clone and `SHOCKLAB_KNOWLEDGE` from
step 6. Leave it out only if they say they won't read papers.

- It's their personal config, so ask before writing.
- Merge into the existing JSON. Don't change or drop other keys. If `enabledPlugins` or
  `extraKnownMarketplaces` already exists, add to it. If the file doesn't exist, create
  it with just this block.
- Check that the file still parses afterwards.

Then offer the optional plugins listed in `README.md`, and add the ones they want to
`enabledPlugins`:

- `"shocklab-apps@shocklab": true`: `/queue` and `/enact-queue`, for people who build
  apps with a `FEATURE_QUEUE.md`.
- `"shocklab-figures@shocklab": true`: the `figure-master` agent, which needs MATLAB,
  plus `pdfimages` / `pdftoppm` for pulling figures out of papers. Its per-project setup is in the
README under "Setting up figure-master".

### 6. Local clone of the knowledge base and paper library

The knowledge base and the paper library are one repo,
`MonashUniversity-ShockLab/Library_of_Shock_Lab` (formerly `knowledge`; GitHub redirects
the old name). Ask where they keep code. Recommend a folder that is **not** synced by
OneDrive or Dropbox, because sync tools can corrupt `.git` (e.g. `C:\Users\<you>\code`
or `~/code`). Then:

```
git -c core.longpaths=true clone https://github.com/MonashUniversity-ShockLab/Library_of_Shock_Lab.git <parent>/Library_of_Shock_Lab
```

On Windows, also run `git -C <parent>/Library_of_Shock_Lab config core.longpaths true`.

Point Claude at the clone by adding this to the same `~/.claude/settings.json`, merged
in the same way:

```json
{ "env": { "SHOCKLAB_KNOWLEDGE": "<absolute path to the clone>" } }
```

On Windows, use forward slashes or escaped backslashes in the JSON string.

**Paper PDFs.** The group's PDFs are on the Market drive in `Z:\Library_of_Shock_Lab\papers`
(with `_Unprocessed`, `_Off_Topic`, `_Deferred` and the topic folders). Offer to copy the
whole folder's contents into `<parent>/Library_of_Shock_Lab/attachments/papers/`, which git
ignores (e.g. `robocopy "Z:\Library_of_Shock_Lab\papers" "<clone>\attachments\papers" /E /XC /XN /XO`
on Windows, or `rsync -a --ignore-existing "<market>/Library_of_Shock_Lab/papers/" "<clone>/attachments/papers/"`
on macOS/Linux; both copy only files they don't have yet and never overwrite one already in
the clone). Ask first; it is about 1 GB the first time. Tell them to re-run the same
command after every `git pull` to get PDFs for new notes. If
`Z:` isn't mapped, ask them where Market is mounted. Paper notes embed PDFs from there,
by the paths in the notes' `pdf:` fields. Papers they don't have show a "not found"
placeholder, which is expected.

`Misc/` is personal working space for the library skills, kept in the member's personal
folder (`SHOCKLAB_PERSONAL`, else `../My_Knowledgebase` next to the clone if it exists, else
the clone itself, where it is git-ignored): never committed to the shared repo. Offer to
create an empty `My_Knowledgebase` folder next to the clone (or to set `SHOCKLAB_PERSONAL`
in the same `env` block). Project-specific paper relevance also goes there, in
`Project_Paper_Relevance/`: since 2026-11-09 the notes' "Relevance to this project"
sections cover only the group's research threads. Research
questions are shared: `/research-question` saves them in the clone's `research_questions/`
with an `author:` field, and any member may add one on a branch with a PR (just the
question file and its README row; never someone else's question without asking them).

Optional: suggest opening the clone as an Obsidian vault with the Dataview plugin.

### 7. Finish

Tell them:

- Start a **new** Claude session. Plugins and settings load at session start, not in the
  current session. Accept the prompt to trust the `shocklab` marketplace if one appears.
- To check it worked: `shocklab-core` is listed under **+ → Plugins** (desktop app) or
  `/plugin` (terminal). Asking something like "write an sbatch script for a 16-core
  MATLAB job on M3" should make Claude consult the knowledge base and use
  `--ntasks=1 --cpus-per-task=16`.
- If they enabled `shocklab-library`: `/lit <question>` answers from the paper library
  with note and page citations. To get a paper added, put its PDF in Market
  `Z:\Library_of_Shock_Lab\papers\_Unprocessed\`; a maintainer processes it with
  `/add-paper` and pushes the note. Skills that change the library (`/add-paper`,
  `/paper-audit`, `/restructure-note`) are for maintainers only.
- Read `onboarding/Getting started.md` and `CLAUDE.md` in the library clone.

## Working on plugins here

- Generalise before committing: no personal paths, and no files that only one person has.
- On every change, bump `version` in both the plugin's `plugin.json` and its
  `marketplace.json` entry, so `autoUpdate` picks it up. `shocklab-library` and
  `shocklab-apps` have no `plugin.json`: their `marketplace.json` entries are the
  manifest and list their skills and agents from the top-level `skills/` and `agents/`
  folders (see README, "How the top-level `skills/` and `agents/` become plugins").
  Bump the entry's `version` when any skill or agent it lists changes.
- Keep each folder in `skills/` self-contained (its `SKILL.md` plus its own files), so it
  can be copied on its own into `~/.claude/skills/`. Library skills find the library
  through `SHOCKLAB_KNOWLEDGE`, never a personal path.
- Validate JSON before pushing, and run `claude plugin validate .` from the repo root if the CLI is available.
