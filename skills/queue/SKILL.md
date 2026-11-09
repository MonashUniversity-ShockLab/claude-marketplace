---
name: queue
description: Add a feature request or bug fix for one of the apps in the working repo to that app's FEATURE_QUEUE.md, without implementing or building it. Any app folder with a FEATURE_QUEUE.md (or one you create) counts. Use when the user runs /queue, or says "queue this", "add to the queue", "for the next build", "not now, but later the app should…". Also use /queue with no request to list what is queued.
argument-hint: "[app] <request>"
---

# Queue a request for the next build

Each app keeps its queue next to its source, as `<app folder>/FEATURE_QUEUE.md`. Queued items are built together later by `/enact-queue`, so one version bump and one build cover them all. **Do not change the app's code here, and do not build.**

## 1. Find the apps and pick one

- Find the queues in the working repo: `git ls-files '*FEATURE_QUEUE.md'` (or Glob `**/FEATURE_QUEUE.md` outside a git repo). Each file's folder is an app. The repo's `CLAUDE.md` or README may also say where its apps live.
- If the request names an app, use it. If it doesn't and only one app has a `FEATURE_QUEUE.md`, or the request is clearly about one app, use that one.
- Otherwise ask which app.
- If the app has no `FEATURE_QUEUE.md` yet, create one in the app's source folder (the folder with its README and build script) from the template below, with the app's name in the title.

```markdown
# <App> feature queue

Requests waiting for the next build. Add with `/queue <request>` (or by hand under *Queued*, in the same format); build them all at once with `/enact-queue`. Entries keep the request in the user's words; `Notes` are Claude's (likely files, open questions).

## Queued

<!-- Newest last. Format:
### Q-001 · Short title (added YYYY-MM-DD)
Request: what the user asked for, in their words.
Notes: where it probably lives; anything to settle before building ("Open: …").
-->

## Done

<!-- Moved here by /enact-queue: `- Q-001 · Short title → 0.5 (YYYY-MM-DD)`, plus a line if it was changed or dropped. -->
```

## 2. With no request: list the queue

If the user gave no request (`/queue`, `/queue <App>`, "what's queued?"), list the queued items of the app (or every app with a non-empty queue): ID, title and any open questions. Stop there.

## 3. Write the entry

Append under `## Queued` (newest last), with the next free ID: one more than the highest `Q-NNN` anywhere in that file, Done included. Use today's date.

```markdown
### Q-004 · Short title (added YYYY-MM-DD)
Request: the user's words, kept close to verbatim; tidy only obvious typos.
Notes: likely files/functions (a quick Grep is fine, at most a minute or two of looking); interactions with other queued items; "Open: …" for any decision the request leaves to the user.
```

- One entry per independent request. If the user lists several, split them.
- If the request duplicates or contradicts a queued item, say so and ask whether to merge it into that entry (edit the entry, keeping both sets of words) or keep both.
- If it is already done in the current source, say so instead of queuing it.
- Don't ask the open questions now unless the request can't be written down without the answer; `/enact-queue` asks them all in one go.

## 4. Commit

Commit only the queue file (`Queue <App> Q-004: short title`), following the repo's own branch rules in its `CLAUDE.md` (direct to the default branch, or a branch and PR). Push only if that is the repo's habit or the user asks. Then reply in a line or two: the ID, the title, any open question noted, and how many items are now queued for that app.
