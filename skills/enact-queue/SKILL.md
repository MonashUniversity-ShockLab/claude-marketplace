---
name: enact-queue
description: Implement every queued request in an app's FEATURE_QUEUE.md (written by /queue), then bump the version, build and verify once for the whole batch, using the build and test steps in that app's README. Use when the user runs /enact-queue, or says "do the queued changes", "build the queue", "time for a new <app> build".
argument-hint: "[app] [Q-ids to include, default all]"
---

# Build the queued requests

The queue is `<app folder>/FEATURE_QUEUE.md` (written by `/queue`). The point is one version bump, one build and one verification for the whole batch, so implement and test everything from source first and build only at the end.

## 1. Read the queue and settle questions up front

- Pick the app as `/queue` does (named, the only non-empty queue, or ask). Take every item under `## Queued`, or only the IDs the user named.
- Read the app's README and any entry for the app in the repo's `CLAUDE.md`. From them, note before starting:
  - the environment to build and test in (e.g. a conda env or virtualenv, and any PATH setup it needs);
  - where the version number lives (e.g. `__version__` in the package's `__init__.py`, `package.json`, a `VERSION` file) and the version history list in the README;
  - user-facing docs to update (e.g. a user guide);
  - the source-level tests, the build command, and how to verify a build (e.g. a `--selftest` option of the built executable, a smoke test).
  If the README doesn't say how to build or verify, ask the user once and offer to add the answer to the README.
- Re-check each item against the current source; anything already done goes straight to Done with a note.
- Collect every "Open:" question, plus any new ones from reading the code, and ask them **all in one AskUserQuestion call** (several questions are fine) before writing code. Note the answers in each entry's Notes.
- Order the items so that ones touching the same code go together. If two conflict, say so in the questions.

## 2. Implement, testing from source

Keep the task list to one step per item, then "Version, docs, build", "Verify build", "Commit".

For each item:
1. Implement it, following the app's existing code style.
2. Run the source-level tests that cover it (the app's `tests/` or whatever its README names, on synthetic data if the app provides a generator, or on test data the user points you to). Add or extend a test when the item adds behaviour that no test reaches. Test runs must not leave windows open on the user's screen; use the app's headless or off-screen mode.
3. Fix failures before moving on. If an item turns out much bigger than it looked, or needs a decision, ask then rather than guessing; if the user defers it, leave it under Queued with a note on what was learned.

Don't build between items.

## 3. Version, docs, build

Once all items pass from source:
- Bump the version once (minor bump for new features, patch bump for fixes only, unless the user says otherwise or the app's README sets another rule).
- Add one entry to the README version history covering every item in the batch (dated), and update the README developer notes and the user-facing docs for everything users see.
- Build once with the app's build command, from its environment. Run it in the background if it takes more than a minute or two.

## 4. Verify the build

Run the verification the README names (e.g. the built executable's self-test, a smoke test against the build), and look at any image or report it writes. If the build fails, fix it and rebuild the same version (delete the half-made output folder first).

## 5. Close out

- Move each built item from `## Queued` to `## Done` as `- Q-004 · Short title → 0.5 (YYYY-MM-DD)`, with a line on anything built differently from the request or dropped. Items not built stay under Queued.
- Commit source, docs, tests and the queue file together (`<App> 0.5: Q-004, Q-005, Q-007`, with a one-line summary per item in the body), following the repo's branch rules in its `CLAUDE.md`. Build outputs normally stay out of Git; follow the repo's `.gitignore`. Push only if that is the repo's habit or the user asks.
- Report per item: what changed, how it was tested, and anything left over; give the path of the new build.
