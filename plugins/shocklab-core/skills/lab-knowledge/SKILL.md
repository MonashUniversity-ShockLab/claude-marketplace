---
name: lab-knowledge
description: Look things up in, or write to, the ShockLab knowledge base (methods such as schlieren, PIV and calibration; facility and camera specs; paper notes; M3/MASSIVE and MATLAB how-tos; SPOD). Use when a question depends on how the lab does something, what a rig or camera's settings are, what a paper in the lab's reading list says, or when asked to add a note, paper or method page to the lab knowledge base.
---

# ShockLab knowledge base

The lab's shared knowledge lives in the private repo `ShockLab-TestHub/knowledge`, an
Obsidian vault of Markdown notes. Its `CLAUDE.md` is the authority on layout, naming and
provenance rules — read it before writing anything, and follow it over anything here.

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

If you have a clone, `git pull` before reading anything time-sensitive.

## 2. Look things up

Use the "Where to look for what" table in the vault's `CLAUDE.md`. In short:
`methods/` how the lab does things, `facilities/` hardware, `papers/` literature (file
names start `Author Year - `), `topics/` concepts, `documentation/` computing how-tos.

When you answer from the vault, say which note the answer came from. Treat anything with
`type: generated` as unverified unless `verified:` is filled in, and say so.

## 3. Write to it

- Follow the vault's `CLAUDE.md` exactly: templates in `_templates/`, naming rules,
  frontmatter.
- Anything you author is Claude-authored: it goes in `generated/` or `documentation/`
  with the `> [!warning] Claude-authored` callout — **never** in `papers/`.
- Never fill in `verified:` or `verified_by:`.
- Don't reword notes other people own; add tasks or open questions instead.
- Never commit PDFs, `.mat`, video or raw data.
- Show the user the diff and ask before committing or pushing; commits go to a repo the
  whole lab shares.
