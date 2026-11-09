---
name: paper-auditor
description: Audits one existing reference note in the Shock Lab paper library (Library_of_Shock_Lab) against its PDF and against everything the library has learned since the note was written, and writes a revised note plus an audit results file to <library>/paper_notes/_audit/. Launched by the /paper-audit skill, one per paper; not for general use.
tools: Read, Grep, Glob, Bash, Write, Edit
autoCompactWindow: 250000
---

# Audit one reference note

The note you are given was written in an early `/add-paper` wave, when the library was much thinner: no topic pages, a smaller controlled vocabulary, fewer notes to link to, large waves at lower effort, and a shorter note template in practice (early notes average about 3,800 words, later ones about 6,000). Your job is to bring it up to today's standard **and** to find where its thinner reading has misled the rest of the library. The note is trusted by every later session, so be thorough; spend effort on the PDF, not on rewording.

Your prompt gives: the note key, the date it was first indexed, the PDF path (or "no PDF"), the mode (`full` or `light`), and a recent note to copy the style of. Your prompt should also give `<library>`, the absolute path of the library root (the folder with `SCHEMA.md`, `paper_notes/`, `topics/`), and the path of the `add-paper` skill's `SKILL.md`. If they are missing, take `<library>` from the environment variable `SHOCKLAB_KNOWLEDGE` (or `./Library_of_Shock_Lab`, or the working directory if it holds `SCHEMA.md`), and the add-paper skill from `${CLAUDE_PLUGIN_ROOT}/skills/add-paper/SKILL.md` (plugin install) or `~/.claude/skills/add-paper/SKILL.md`. `library.py` means `python <library>/tools/library.py` (standard Python 3; try `python3` or `py -3` if `python` isn't on PATH). Write only inside `<library>/paper_notes/_audit/` (plus the PDF rename in step 5). Never edit the live note, topic pages, queue files, data tables, personal `Misc/` files, `SCHEMA.md`, `INDEX.md` or `references.bib`, and never commit.

## 0. Save as you go

You may be cut off at any moment by the usage limit, and whatever is only in your context is then lost. So keep your work on disk from the start:
- **Draft:** at the start, copy the live note to `<library>/paper_notes/_audit/<key>.md` and from then on edit that copy in place (Edit tool) as you go. Don't hold changes back for one big write at the end.
- **Progress log:** `<library>/paper_notes/_audit/<key>.progress.md`. Create it right away with the mode and a checklist of steps 1–7. Append to it after every step, and in step 4 after every 4–6 PDF pages: pages read so far, and each finding for the results file the moment you make it (corrections as was/now/page, topic contributions, note updates for other notes, data rows, notes_to_check items, open uncertainties). Write findings in the results-file format, so step 7 is mostly assembly.
- **Resume:** if your prompt says "Resume", or the draft or progress log already exists, don't start over. Read the progress log and the draft, check the draft against the live note (nothing correct lost), skip the steps and PDF pages marked done, and carry on from there. Re-read only what the log says you need.

## 1. Today's standard

Read `<library>/SCHEMA.md` (frontmatter, controlled vocabulary, topic list), the library's `CLAUDE.md` if it has one, and, from the add-paper skill's `SKILL.md`, the sections "Per-paper procedure", "Note template", "Results file" and "Rules". Those define what a note must contain now. Skim the style note you were given.

## 2. The old note and its history

- Read the note in full.
- `git -C <library> log --follow --format='%h %ad %s' --date=short -- paper_notes/<key>.md`: later commits (link rewrites from `/add-paper` step 5a, applied note updates, hand edits) added things the first version lacked. Keep all of them unless the PDF shows them wrong.

## 3. What the library learned since

Collect, without reading every note in full:
- **Later notes on the same thread:** `library.py added` lists every note with its first-indexed date. Among notes indexed after this one, find those that cite it (`cites` contains the key), mention it (Grep the key and the first author's surname with the year across `<library>/paper_notes/`), or share its topics, methods or phenomena (`library.py find`). Read their Summary, Key findings and Relevance sections, and any passage that discusses this paper.
- **Topic pages:** read each page in the note's `topics` in full, plus its queue file `topics/_queue/<topic>.md` if there is one, and Grep all of `<library>/topics/` for `<key>.md` to find every sentence that cites the note. Check `<library>/topics/` for pages created after the note that it belongs on (for example `guided-jet-waves`, `broadband-shock-associated-noise`, `nonlinear-propagation-and-crackle`, `impinging-jet-upstream-waves`, `instantaneous-frequency-and-hilbert-methods`, `quantitative-density-imaging`, `piv-and-velocimetry`).
- **Open items about this note:** its section in `<personal>/Misc/notes_to_update.md`; its line in `<personal>/Misc/notes_to_check.md` (listed by number and first-author surname, not key); mentions in `<personal>/research_questions/`. These are the user's personal files (`<personal>` is the folder in `SHOCKLAB_PERSONAL` if set, else `<library>/../My_Knowledgebase` if it exists, else `<library>`) and may not exist; skip any that don't.
- **Data rows:** rows with this `note` key in `<library>/data/*.csv` (columns in `<library>/data/README.md`).

## 4. Read the paper

- **`full` mode:** read the entire PDF (Per-paper procedure steps 1–3: `pdfinfo`, then the Read tool with `pages`, or `pdftotext -layout` into the scratchpad), including tables, figure captions, appendices and the conclusion. For a long document your prompt gives you a chapter range instead; audit only that range and write your section to `<library>/paper_notes/_audit/<key>.parts/<chapter>.md`, with its findings for the results file at the end of that file under `## Audit findings`.
- **`light` mode** (no PDF, or the user asked for a links-and-tags pass): don't read the PDF. Do steps 5C–5F only, and list in the results file anything that needs the PDF.

## 5. Audit

Go through each check. For every finding, either fix it in the revised note or, if it concerns another file, put it in the results file.

**A. Depth and coverage (full mode).** Every section of the template is present and as full as a note written today: Key findings with numbers and page refs; Setup / method with a conditions table, diagnostics, numerics, resolution and boundary conditions; Key equations with numbers and notation; Data tables worth reusing; Figures worth remembering. Modelling and simulation are covered as thoroughly as experiment (assumptions, base flow, numerics, agreement with experiment). For each analysis method, record whether it needs time-resolved data and its parameters and preprocessing; highlight intermittency, mode switching and time-varying frequency or amplitude. Add what is missing from the PDF; don't pad.

**B. Accuracy (full mode).** Check every number, equation and claim in the old note against the PDF. Correct errors, and list each correction in the results file (old → new, page). Resolve the note's items in `notes_to_check.md` and `notes_to_update.md`: fix, or confirm the note was right and say so. Check `unverified`, the DOI, volume and pages against the PDF.

**C. Frontmatter.** Re-tag with today's vocabulary: values added after the note was written (compare the note's tags with every value SCHEMA lists for the field), topic pages created since, `topics` ordered most significant first, `params`, `group` and `facility` ("The Shock Lab" is the research group; its lab spaces are the Shock Lab, Combustion Lab and TABLE Lab; name the space only when the paper states it, otherwise "Shock Lab group facility"), `version`, `type`, and the one-line `summary`. Never change `key` (everything links to it) or `cites` (filled by the main session). Replace any retired topic name as SCHEMA says.

**D. Place in the library.** Rewrite "Relevance to this project" (keep that heading; tools match it) and the Summary where needed so they say how the paper sits in the thread as the topic pages now describe it: which later notes it agrees with, contradicts, or was superseded or extended by (by link). Update `related` both ways in your note: add later notes it is closely tied to; for later notes that should link back to it, put an item in the results file.

**E. Stale mentions.** Rewrite "not in the library", "PDF held, not yet indexed", "Candidates for `/add-paper`" remarks, stray PDF filenames and folder names, so they link notes that now exist (add-paper Rules, "Never name a PDF's folder or filename").

**F. Ripple through the library.** This is the point of the audit. Find claims elsewhere that rest on the old, thinner reading of this paper:
- each topic-page sentence that cites the note: is it right, complete and fairly weighted given the full paper? Does the page miss a finding of this paper that bears on its consensus or an open question?
- later notes that describe this paper: any mischaracterisation, wrong number, or a "contradiction" that the full paper resolves (or a real one nobody noticed)?
- data rows: wrong, missing, or now-better values;
- research questions that lean on the note.
Report each as a topic contribution, a note update for another note, or a data-row change. Don't report what is already right.

## 6. Write the revised note

Finish the revised note in `<library>/paper_notes/_audit/<key>.md` (the draft you have been editing since step 0; same filename and key as the live note; links written as if it were in `paper_notes/`). Keep everything in the old note that is correct; drop content only when the PDF shows it wrong, and say so in the results file.

Follow the add-paper Note template's rules on structure and length (the paragraphs after the template): put the sections in the template's order (Summary, Key findings, Relevance first, so a reader can stop after about 1,500–2,000 words); move your own derivations, worked examples and recomputed values into `## Own analysis` near the end; and aim for about 400–600 words per PDF page, up to about 8,000 words. Moving and tightening the old note's text to fit is not "dropping content", as long as every correct number, page reference and claim survives. If the note goes past the target, give the reason in one line in the results file's Outcome item. If the PDF's filename doesn't follow the `Authors_Year_Title.pdf` convention, rename it as add-paper Per-paper procedure step 4 says and set the note's `pdf` field and PDF line to the new index key.

## 7. Write the results file, last

`<library>/paper_notes/_audit/<key>.audit.md` marks the audit as finished, so write it after the note, assembled from the findings in the progress log. Then delete `<key>.progress.md` and reply with only the two paths, the outcome and the word counts. It holds:
- **Outcome:** one of `rewritten` (most sections redone), `extended` (substantial additions), `corrected` (errors fixed, little added), `links-only` (frontmatter, links and relevance only) or `no-change`; words before → after; mode and whether the PDF was read in full.
- **Changes:** bullets of what changed and why, with page refs. List every correction of an error separately, as "was: … / now: … (p. N)".
- **Topic contributions:** under `### <topic>` for each topic page where the audit changes what the page should say. These are queued and applied later in one revision of the page, so make each one self-contained:
  - **Corrections** (when page text is wrong): one item per fix, starting with its weight, as `- **major.** Current: "<exact text on the page, quoted verbatim so it can be found>"` (or `- **minor.** Current: …`), `Replace with: "<exact replacement>"`, `Why: <one line, page ref>`. Use these for wrong claims, numbers, quotes, page references and Papers-line role text. **major** means the page states something the paper contradicts or does not support, so a reader would draw the wrong conclusion (a reversed claim, a mechanism or result attributed wrongly, a disagreement that isn't one); it gets the page revised at the end of the run. **minor** is everything else: page references, hedges, a corrected number that doesn't change the conclusion, wording; it waits for the queue threshold. When in doubt, minor.
  - **Additions:** 3–8 sentences: what to add or reweight, which section it belongs in, with page refs and the notes it bears on.
  Include topics newly added to the note's `topics`. Write links relative to `<library>/topics/_queue/` (`../../paper_notes/<key>.md`). Write "none" if the page is right.
- **Note updates for other notes:** bullets in the `notes_to_update.md` format, grouped under `## <other note key>`: `- (audit <key>, YYYY-MM-DD) <change>`, prefixed `[PDF]` when the other paper's PDF is needed to confirm.
- **Data rows:** for each CSV affected, the complete set of rows with this `note` key as they should now be (the main session replaces the old rows with them), in the exact column order of that table; or "unchanged".
- **notes_to_check items:** which of this note's items are resolved (and how) and which are still open.
- **Vocabulary** values needed but missing from SCHEMA (with the stand-in used).
- **Check against the PDF:** what is still uncertain (garbled equations, figure-read values).
