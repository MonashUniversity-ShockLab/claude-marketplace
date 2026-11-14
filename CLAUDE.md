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
  add their GitHub username (`gh api user --jq .login`) to the `shocklab` team (the org's members team).

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
`/research-question`, `/add-paper` and `/paper-audit` for everyone; `/restructure-note`,
which reshapes audited notes, for maintainers only) is on by default, as in the library's
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

**Then retire personal copies the plugins replace.** Members often have earlier copies of
these skills, passed around before the marketplace existed. A personal copy doesn't update,
and it shows up alongside the plugin's (e.g. `/add-paper` next to
`/shocklab-library:add-paper`), so Claude may run the stale one. Look, read-only, in
`~/.claude/skills/*/SKILL.md`, `~/.claude/agents/*.md` and `~/.claude/commands/*.md`, and in
the `.claude/` folder of the project they work in, for:

- the same name as a plugin skill or agent: `add-paper`, `lit`, `research-question`,
  `paper-audit`, `restructure-note`, `import-knowledge`, `lab-knowledge`, `queue`,
  `enact-queue`, `paper-auditor`, `note-restructurer`, `figure-master` (list the plugins' current
  ones with `gh api repos/MonashUniversity-ShockLab/claude-marketplace/contents/skills` and
  `.../contents/plugins/<plugin>/skills`, in case this list is out of date);
- a different name but the same job, judged from its description (e.g. a `paper-index` or
  `literature` skill that writes notes into the library);
- in `~/.claude/CLAUDE.md`, a block telling Claude to check the ShockLab knowledge base (the
  manual snippet from this repo's README): the `shocklab-core` plugin now does that.

Show what you found: each item, its path, which plugin skill replaces it, and whether it
differs from the plugin version (e.g. their own edits). Recommend retiring each one, and on
their yes **move** it (don't delete) to `~/.claude/_retired_shocklab/<YYYY-MM-DD>/`, keeping
its folder name, so it can be restored; for the `CLAUDE.md` block, show the lines and remove
only those. Leave anything they want to keep, and tell them two versions will then show
up. If their copy has improvements the plugin lacks, suggest offering them to the lab as a
pull request to this repo. Changes take effect in their next session.

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

**Paper PDFs.** The group's PDFs are on the Market drive in `Library_of_Shock_Lab\papers`
(with `_Unprocessed`, `_Off_Topic`, `_Deferred` and the topic folders). Market's drive
letter differs between PCs (`Z:` on some, `Y:` on others), so find it rather than assume
one: use `SHOCKLAB_MARKET_PAPERS` if set, else check every mounted drive for a
`Library_of_Shock_Lab\papers` folder (PowerShell:
`Get-PSDrive -PSProvider FileSystem | ForEach-Object { Join-Path $_.Root 'Library_of_Shock_Lab\papers' } | Where-Object { Test-Path $_ }`;
on macOS/Linux, the mount points under `/Volumes`, `/mnt` and `/media/$USER`). One match:
use it and tell them which drive it is. Several: ask which. **None: flag it.** Tell them
Market isn't mounted on this machine and ask them to connect it or say where it is; never
guess a path, and skip the copy if they can't. Once found, offer to add
`SHOCKLAB_MARKET_PAPERS` (that folder, forward slashes) to the same `env` block, so the
library skills don't have to search again. Offer to copy the
whole folder's contents into `<parent>/Library_of_Shock_Lab/attachments/papers/`, which git
ignores (e.g. `robocopy "<M>:\Library_of_Shock_Lab\papers" "<clone>\attachments\papers" /E /XC /XN /XO`
on Windows, with `<M>` the drive found, or `rsync -a --ignore-existing "<market>/Library_of_Shock_Lab/papers/" "<clone>/attachments/papers/"`
on macOS/Linux; both copy only files they don't have yet and never overwrite one already in
the clone). Ask first; it is about 1 GB the first time. Tell them to re-run the same
command after every `git pull` to get PDFs for new notes. Paper notes embed PDFs from there,
by the paths in the notes' `pdf:` fields. Papers they don't have show a "not found"
placeholder, which is expected.

`Misc/` is personal working space for the library skills. Don't create a separate folder
for it: by default the skills keep it inside the clone, where `Misc/` is git-ignored and
never committed (anyone who already has `SHOCKLAB_PERSONAL` set or a `My_Knowledgebase`
folder next to the clone keeps using that). Project-specific paper relevance also goes there, in
`Project_Paper_Relevance/`: since 2026-11-09 the notes' "Relevance to this project"
sections cover only the group's research threads. Research
questions are shared: `/research-question` saves them in the clone's `research_questions/`
with an `author:` field, and any member may add one on a branch with a PR (just the
question file and its README row; never someone else's question without asking them).

### 7. Obsidian, if they want it (optional)

The library is an Obsidian vault: notes link to each other, paper notes embed their PDFs,
and dashboards (`Home.md`, `Tasks.md`, the `_*.md` index pages) list notes, owners and open
tasks. Everything also works without Obsidian, as plain Markdown. Ask: **"Do you want to
browse the library in Obsidian?"** If not, skip, and mention in the summary that they can
ask any time ("set up Obsidian for the library").

On their yes:

1. **Obsidian installed?** Check first (Windows: `winget list --id Obsidian.Obsidian`, or
   `%LOCALAPPDATA%\Programs\Obsidian\Obsidian.exe`; macOS: `/Applications/Obsidian.app`).
   If it's missing, ask, then install: `winget install -e --id Obsidian.Obsidian` (Windows),
   `brew install --cask obsidian` (macOS), or the AppImage/Flatpak from obsidian.md
   (Linux). It's free; no account is needed.
2. **The lab's plugins.** The clone already carries the shared vault settings in
   `.obsidian/` (`community-plugins.json` lists the two plugins below; `app.json` keeps links
   updated when notes are renamed). The plugin code itself isn't in git, so download each
   plugin's latest release into the clone (ask first; both are open source, MIT-licensed):
   - **Dataview** (`dataview`): draws the tables on the dashboards and index pages. Without
     it they show as raw `dataview` code blocks.
     `gh release download -R blacksmithgu/obsidian-dataview -p main.js -p manifest.json -p styles.css -D "<clone>/.obsidian/plugins/dataview" --clobber`
   - **HTML Reader** (`obsidian-html-plugin`): opens the interactive `.html` guides next to
     their notes in `documentation/` and `generated/`.
     `gh release download -R nuthrash/obsidian-html-plugin -p main.js -p manifest.json -D "<clone>/.obsidian/plugins/obsidian-html-plugin" --clobber`

   `.obsidian/plugins/` is git-ignored, so these never get committed. Recommend just these
   two; others they like are their own business, but don't add them to the shared
   `community-plugins.json` without a PR.

   **HTML Reader needs Unrestricted Mode for the guides to work.** Its default *Balance
   Mode* strips every `<script>`, so the interactive guides show raw `$…$` TeX and empty demo
   boxes. Equations and demos only work in **Unrestricted Mode**. Explain the cost before
   asking, as the library's `documentation/Interactive HTML Guides.md` does: in that mode
   any script in any `.html` file in the vault runs inside Obsidian with no sandbox (it can
   read and write their files), and the vault is a shared repo everyone pushes to. So they
   should read the diff of any `.html` someone else commits before opening it. Ask:
   **"Turn on Unrestricted Mode so the interactive guides work in Obsidian?"** On yes, write
   `.obsidian/plugins/obsidian-html-plugin/data.json` with `"opMode": "UnestrictedMode"` (the
   plugin's own spelling; keep any other keys already there), or have them set *Settings →
   HTML Reader → Operating Mode → Unrestricted Mode*. On no, leave Balance Mode: the guides'
   text still reads, and they can open a guide in their web browser for the demos (*Settings
   → Files and links → Detect all file extensions* shows `.html` files in the file list).
3. **Open the vault (they do this).** In Obsidian: *Open folder as vault* → choose the clone
   folder **itself** (e.g. `C:\Users\<you>\ShockLab\Library_of_Shock_Lab`), not a folder
   above it: PDF embeds resolve from the vault root, so a bigger vault breaks them. When
   Obsidian asks whether to trust the vault's author and enable plugins, choose **Trust**
   (that turns on community plugins; Claude can't click it for them). If they already have
   their own Obsidian vault, keep the library as a separate vault; never put one inside the
   other.
4. **Check it worked:** open `Home.md`: its tables should fill in. If they show code
   instead, Dataview isn't on (*Settings → Community plugins*: turn off Restricted mode, then
   enable Dataview and HTML Reader). If they chose Unrestricted Mode, open
   `generated/The Welch Method for Spectral Estimation.html`: its equations should render
   and its demo should run. (Obsidian's "Restricted mode" for community plugins and HTML
   Reader's "Unrestricted Mode" are different switches; both are needed for the demos.)
5. **What not to commit:** Obsidian rewrites `.obsidian/workspace*.json` as they click
   around; it's git-ignored. Paper PDFs in `attachments/papers/` stay out of git too. If
   Obsidian ever shows other `.obsidian/` changes in `git status`, leave them uncommitted
   unless they mean to change the lab's shared settings (by PR).

### 8. M3, if they will use it

Ask whether they will run jobs on M3 (MASSIVE). If not, skip. If so, follow the library's
`documentation/M3 Guide.md` §0–§3 with them. Two things only they can do, so check first
and pause until they're done:

- **M3 account and password**: set at <https://password-hpc.erc.monash.edu> (Login with AAF,
  normal Monash login). Without an account, tell them to request one through the M3
  documentation's account page and come back.
- **M3 project**: their project leader adds them. Ask who that is if they don't know;
  check later with `user_info` or `groups` on M3.

Then, with their approval: make the SSH key on their machine (guide §1, no passphrase),
put the public key on M3 (§2; Route A asks for their M3 password once, which **they type**
in their own terminal, never in chat), add the `~/.ssh/config` entry (§3) and test with
`ssh <host> "hostname; whoami"`. Never copy a private key anywhere or print it.

### 9. Their own project folder in git

Most members never put their own work under version control because they don't know git,
and a deleted script or a broken edit is then gone for good. Offer to do it with them; you
drive it, they approve each step and don't need to know any git commands. If they say no,
skip it and mention in the summary that they can ask any time ("put my project folder in
git").

Ask: **"Where is the main folder for your own work?"** (the scripts, code and notes for their
PhD or project, e.g. `OneDrive\PhD\Projects`; one folder that holds their projects is fine).
Then check, read-only:

- already a git repo (`git -C <folder> rev-parse --show-toplevel`)? If so, check it has a
  GitHub remote (`git remote -v`), nothing large is committed, and recent work is pushed
  (`git status -sb`). Offer only what is missing, e.g. just the GitHub step below. If the
  folder sits *inside* a bigger repo, or holds several repos, say so and ask what they want.
- not a repo: explain in two or three plain sentences what they get: every saved version of
  every script (undo for code), a private backup on GitHub, and an easy way to get the same
  code onto M3 or another computer. Then, on their yes:

1. **Look before touching anything.** Summarise the folder: file count and total size by
   type, the largest files, and anything that must not go into git:
   - data and results (`.mat`, `.h5`, `.tdms`, `.mraw`, `.cine`, videos, raw images, big
     `.csv`), PDFs of papers, build and environment folders (`.venv/`, `node_modules/`,
     `__pycache__/`, `dist/`), editor and OS clutter (`*.asv`, `*.m~`, `.DS_Store`,
     `Thumbs.db`);
   - **secrets**: `.env` files, API keys, tokens, passwords, private SSH keys, anything named
     `*secret*`, `*token*`, `*credentials*`. Never print their contents; list the file names.
   - third-party code bundled in (e.g. `export_fig`, `ffmpeg`): fine to keep if small, but
     binaries over 50 MB must be ignored (GitHub refuses files over 100 MB).
2. **Write a `.gitignore`** at the folder's root from what you found, with a comment per
   group, and show it. Code, notes, small configs and their own `README`s go in; data,
   outputs, papers and secrets stay out (they stay on their disk, Market or M3, untouched).
3. **Show what would be committed**: count, total size and the 20 largest files after the
   `.gitignore` (`git init -b main` then `git status --porcelain --ignored`, or
   `git add --dry-run .`). Nothing over 50 MB, and keep the total well under 1 GB. Adjust the
   `.gitignore` until they're happy; nothing is committed yet.
4. **Identity**: if `git config --global user.name` or `user.email` is empty, ask what to use
   (their name, and their Monash email or their GitHub no-reply address) and set them.
5. **First commit**: `git add .` (safe now that the `.gitignore` is agreed, and checked again
   with `git status`), then `git commit -m "Initial commit of <folder name>"`.
6. **Private backup on GitHub**: create a **private** repo under their own GitHub account
   (not the org; their supervisor can be added as a collaborator if they want) and push:
   `gh repo create <name> --private --source <folder> --push`. Suggest a short name from the
   folder. Show them the link.
7. **How to use it from now on**, in three lines: they never need to type git commands;
   just ask Claude "commit my changes" at the end of a session, "what did I change this
   week?", or "get back yesterday's version of <file>". If they use M3, the library's
   `documentation/M3 Guide.md` §4 shows how to clone the repo there and `git pull` after
   each change (edit on the laptop, not on M3).

If the folder is in OneDrive, that's fine: git and OneDrive work together. Avoid committing
from two computers at once in the same synced folder; use GitHub to move work between
machines instead.

Offer, too, a short `CLAUDE.md` at the folder's root describing their projects (what each
folder is, how the data flows, where data lives), so Claude starts every session knowing
their work: draft it from what you saw in step 1 and let them edit it. It goes in the
first commit, or a second one.

### 10. Bring in what they already know

Ask: **"Where is your current knowledge stored?"** (note folders or vaults, project
`CLAUDE.md`s and READMEs, Claude memory, HPC notes, paper folders such as `Literature/`
or Zotero `storage/`). Explain what happens next: Claude pulls out what is useful to the
whole lab into the library by pull request, and copies their papers that the group doesn't
already have to Market `_Unprocessed`, renamed to the `Authors_Year_Title.pdf` convention,
ready for anyone to index with `/add-paper` (token-heavy; it offers this at the end). Their own files are only read, never moved or changed, and
nothing private is copied.

If they want to do it now, follow `plugins/shocklab-core/skills/import-knowledge/SKILL.md`
in this repo (read it with
`gh api repos/MonashUniversity-ShockLab/claude-marketplace/contents/plugins/shocklab-core/skills/import-knowledge/SKILL.md -H "Accept: application/vnd.github.raw"`;
the plugin's `/import-knowledge` only loads in a new session). It needs step 6 done, and
Market mounted for the papers part. If they'd rather wait, tell them to run
`/import-knowledge` in a new session whenever they like. Either way, don't skip asking.

### 11. Finish

Tell them:

- Start a **new** Claude session. Plugins and settings load at session start, not in the
  current session. Accept the prompt to trust the `shocklab` marketplace if one appears.
- To check it worked: `shocklab-core` is listed under **+ → Plugins** (desktop app) or
  `/plugin` (terminal). Asking something like "write an sbatch script for a 16-core
  MATLAB job on M3" should make Claude consult the knowledge base and use
  `--ntasks=1 --cpus-per-task=16`.
- If they enabled `shocklab-library`: `/lit <question>` answers from the paper library
  with note and page citations. To get a paper added, put its PDF in Market
  `Library_of_Shock_Lab\papers\_Unprocessed\`; anyone can then process it with
  `/add-paper`, which opens a pull request with the note (it reads each paper in full, so
  it is token-heavy). Anyone can also audit an older note with `/paper-audit` (also by pull
  request, after claiming the note). `/restructure-note` is for maintainers only.
- Read `onboarding/Getting started.md` and `CLAUDE.md` in the library clone (in Obsidian,
  start at `Home.md`).
- If they skipped step 10: `/import-knowledge` brings their existing notes and papers into
  the library whenever they're ready.

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
