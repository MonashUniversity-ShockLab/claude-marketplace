---
name: lab-knowledge
description: Check the ShockLab knowledge base BEFORE working out anything specific to the lab, Monash or its infrastructure — M3/MASSIVE, Slurm/sbatch/srun requests, Strudel desktops, the Market drive, MATLAB on the cluster, licences, lab rigs, cameras, schlieren/PIV/calibration, SPOD processing, the lab's paper notes. Also use AFTER solving something non-obvious and org-specific, to offer to record it so nobody has to work it out again, and when asked to add a note, paper or method page.
---

# ShockLab knowledge base

The lab's shared knowledge lives in the private repo `ShockLab-TestHub/knowledge`, an
Obsidian vault of Markdown notes. Its `CLAUDE.md` is the authority on layout, naming and
provenance rules — read it before writing anything, and follow it over anything here.

The point of it: **nobody in the lab should have to work out the same org-specific thing
twice.** So look first, and write back what you learn.

## 1. Find the local clone

Check in this order and use the first that exists:

1. The path in the environment variable `SHOCKLAB_KNOWLEDGE`.
2. A sibling or parent folder named `knowledge` that contains a `CLAUDE.md` whose first line
   is `# knowledge: conventions`.
3. Otherwise, read without cloning:
   `gh api repos/ShockLab-TestHub/knowledge/contents/<path> -H "Accept: application/vnd.github.raw"`
   and search with `gh search code --repo ShockLab-TestHub/knowledge "<term>"`.
   If the user wants to write to it, offer to clone it
   (`gh repo clone ShockLab-TestHub/knowledge`) and suggest they set `SHOCKLAB_KNOWLEDGE`.

With a clone, run `git pull --ff-only` first (skip quietly if it fails, e.g. offline).

## 2. Look before working it out

Keep this quick — a few seconds, not a research project:

1. Read `documentation/Org Gotchas.md`: one line per hard-won fact, each linking to the
   full page. Most "why is the cluster doing X" questions are answered there.
2. If not, grep the clone for the key terms (`grep -ril "cpus-per-task" .` or similar)
   and read the hits. Use the "Where to look for what" table in the vault's `CLAUDE.md`
   to pick folders: `methods/`, `facilities/`, `documentation/`, `papers/`, `topics/`.
3. If you find it, use it and tell the user which note it came from. Treat anything with
   `type: generated` and an empty `verified:` as unverified, and say so.
4. If nothing covers it, say that briefly and carry on with the task.

## 3. Write back what you learn

When a task turns up something **non-obvious and specific to the org** — a Slurm flag M3
needs, a Strudel quirk, a mount trick, a licence or module version that works, a rig
setting — then, once the user's task is done, offer to record it. Don't interrupt the task
to do it.

- Short, single fact → a line in `documentation/Org Gotchas.md` under the right heading,
  with a link to where the detail lives.
- Needs explanation → add to the existing page that covers it, or a new
  `documentation/` page, and link it from `Org Gotchas.md`.
- Lab method or hardware → `methods/` or `facilities/`, owned by the user (human-written
  notes; you draft, they own).
- Record what was observed, when (`YYYY-MM-DD`), and on what (e.g. Slurm version,
  module), because cluster behaviour changes.

Not worth recording: things in the public docs that worked first time, personal
preferences, anything project-private.

## 4. Rules for any write

- Follow the vault's `CLAUDE.md`: templates in `_templates/`, naming rules, frontmatter.
- Anything you author is Claude-authored: `generated/` or `documentation/`, with the
  `> [!warning] Claude-authored` callout — **never** in `papers/`.
- Never fill in `verified:` or `verified_by:`.
- Don't reword notes other people own; add tasks or open questions instead.
- Never commit PDFs, `.mat`, video or raw data.
- Show the user the diff and ask before committing or pushing; it's a repo the whole lab
  shares. Pull, commit small, push.
