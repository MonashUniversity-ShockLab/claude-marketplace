---
name: schedule-library-processing
description: Schedule an unattended overnight run of a paper-library skill (add-paper, paper-audit or update-topics) for the Shock Lab paper library. Sets one Claude desktop-app task at 11pm tonight that runs the skill on a branch with its default choices, and a second at 4:05am that resumes the run if the usage limit cut it off, finishes only the work in flight and opens the pull request. A way to spend spare usage at the end of the week. Use when the user runs /schedule-library-processing <skill>, or asks to run add-paper, paper-audit or update-topics "tonight", "overnight" or "after hours".
argument-hint: "<add-paper | paper-audit | update-topics> [skill arguments]"
---

# Schedule an overnight library run

This skill only **schedules** work; it never runs the library skill itself. It creates two one-off tasks in the Claude desktop app:

| Task | When | What it does |
|---|---|---|
| Run | 23:00 tonight | Runs `<skill>` unattended on a new branch, taking the skill's defaults wherever it would ask, then opens a pull request |
| Finish | 04:05 the next morning | If the run was cut off (usage limit), resumes it so it finishes the work in flight, starts nothing new, and opens the pull request; otherwise does nothing |

The 11pm start means a run uses one 5-hour usage window, which resets at about 4am; the 4:05am task then spends a little of the next window to tidy up. Every run lands as a pull request, maintainers included: nothing is pushed to `main` unattended.

## 1. Check the request

1. **Skill.** The first word of `$ARGUMENTS` must be one of `add-paper`, `paper-audit` or `update-topics`. Anything else, or nothing: say which skills are allowed and stop. Any further words are passed to that skill unchanged (e.g. `paper-audit 4` or `add-paper <folder>`). The skill must be installed in this session (it is listed among your skills, possibly as `shocklab-library:<skill>`); if it isn't, say so and stop. Read that skill's `SKILL.md` description so you can tell the user, in one line, what it will do. Any lab member may book any of the three; each claims its papers, notes or topic pages on Market as it goes, so two runs never work on the same one.
2. **Library.** `<library>` is the path in the environment variable `SHOCKLAB_KNOWLEDGE`. It must be a git clone of `MonashUniversity-ShockLab/Library_of_Shock_Lab`; if the variable is unset or the folder isn't that clone, point the user to the marketplace README ("Setting up the paper library") and stop.
3. **Desktop app.** The scheduling tools (`mcp__scheduled-tasks__create_scheduled_task`, and `mcp__ccd_session_mgmt__get_session` / `send_message` for the finish task) come with the Claude desktop app's Code tab; load them with ToolSearch if they are deferred. If they aren't available (terminal-only Claude Code, the web), say that this skill needs the desktop app and stop. A cloud routine is no substitute: it can't see the PDFs in the clone or the Market drive.
4. **Times.** `<run date>` is today's date if it is before 22:45 now, else tomorrow's (say so). Run time is `<run date>`T23:00 and finish time the day after at 04:05, both as ISO 8601 with the computer's current UTC offset (check it with `date +%z`; it may differ between the two times across a daylight-saving change, so compute each separately, e.g. with `date -d`).
5. **One per night.** Task IDs are `library-processing-<run date>` and `library-processing-<run date>-finish`. If `mcp__scheduled-tasks__list_scheduled_tasks` already shows them, a run is already booked that night: say so and stop (the user can delete it in the app's Scheduled tasks list and run this again).

## 2. Confirm with the user

Tell the user, in a few lines, and ask for a yes before creating anything:
- what will run (skill, arguments, a one-line summary) and when (23:00 run, 04:05 finish);
- that it is token-heavy and is meant to use up to one full 5-hour usage window, plus a little of the next;
- that **the computer must be on, awake and on the network (Market drive and GitHub reachable), and the Claude desktop app open and signed in** at 23:00 and 04:05. A task due while the app is closed runs when it next opens, which defeats the point. Suggest they set the computer not to sleep tonight;
- that the run takes the skill's own defaults wherever it would normally ask (which papers, how many, effort), skips anything it would need a person to decide, and lists those in the pull request;
- that the run will not be watched, so it needs to work without permission prompts: if this session is in Auto or Bypass permission mode the tasks are saved in that mode; otherwise a prompt could stall the run until morning. Tell them which mode the tasks will get (the create result says).

## 3. Create the two tasks

Fill in the placeholders (`<skill>`, `<args>`, `<library>`, `<run date>`, `<state>`) before creating them; the prompts must be fully self-contained, because each task starts a fresh session that knows nothing of this one. `<state>` is `~/.claude/shocklab/library-processing/<run date>.state` written as an absolute path (create the folder now). Call `mcp__scheduled-tasks__create_scheduled_task` twice, with `fireAt` set, `notifyOnCompletion: true`, titles `Library run: <skill> (<run date>)` and `Library run finish (<run date>)`.

### Run task prompt (23:00)

> Unattended overnight run of the Shock Lab library skill `/<skill> <args>`, scheduled by the user on <today> with /schedule-library-processing. Nobody is watching: never wait for the user or ask them anything. The library clone is `<library>` (the environment variable `SHOCKLAB_KNOWLEDGE`). State file: `<state>`, lines `session=<id>`, `skill=<skill>`, `branch=<branch>`, `status=working|done|skipped`; keep it current.
>
> 1. **Gates.** Stop, with `status=skipped` and a one-line reason in the state file, if: the clone isn't on `main` (someone is working in it), or `git -C <library> pull --ff-only` fails. Files left in `paper_notes/_incoming/` or `paper_notes/_audit/` by an earlier cut-off run are not a reason to stop: the skill's own section 0 checks resume them or stop as it says. Otherwise get your own session id with `mcp__ccd_session_mgmt__get_session` ("self"; load it with ToolSearch) and write the state file with `status=working`.
> 2. **Run the skill.** Invoke `/<skill> <args>` (the Skill tool; the name may be `shocklab-library:<skill>`). If the skill can't be found, read and follow `~/.claude/plugins/marketplaces/shocklab/skills/<skill>/SKILL.md`. The user approved the cost when scheduling, so skip the cost question. Follow the skill exactly, with these overrides for an unattended run:
>    - **Always a pull request.** Work on a branch and end with a pull request, even if the user is a maintainer: create the branch the skill names for a pull request at the start (add-paper and paper-audit: the member branch; update-topics: its `--pr` branch), write its name into the state file, and never push to `main`. Everything else about who the user is (member or maintainer) follows the skill's own rules.
>    - **Never ask.** Wherever the skill would ask, take its stated default (e.g. all `free` and `mine` papers or notes, the default count and effort). Where it has no default, take the cautious option: skip that item (a `stale` or `taken` claim, a suspected duplicate or off-topic paper, a page with someone's uncommitted edits) and record it for the pull request. If Market is unreachable, nothing can be claimed: stop with `status=skipped` rather than risk processing papers someone else holds.
>    - **Cut-offs.** Commit after every wave as the skill says. If the usage limit stops you, stop; the 04:05 task will resume this session by message.
> 3. **Finish.** When the skill's work is done, do its push step without asking: rebase on `origin/main`, rebuild and check as it says, push the branch and open the pull request to `MonashUniversity-ShockLab/Library_of_Shock_Lab` with the skill's report as the body, plus a section "Overnight run: skipped or left for a person" listing everything skipped above. Leave merging to the PR agent. Release claims you didn't finish (the skill says how). Skip any step that needs the pull request merged first (add-paper's Market filing): put "after this merges, ask Claude to file the add-paper PDFs on Market" in the pull request. Put the clone back on `main` (`git -C <library> switch main`, `git -C <library> pull --ff-only`) so the next night's gate passes. Then set `status=done` and write `pr=<url>` to the state file. If `gh` fails, push the branch, write `pr=none: <error>` and still set `status=done`.

### Finish task prompt (04:05)

> 04:05 finish of last night's unattended Shock Lab library run (`/<skill> <args>`, scheduled with /schedule-library-processing). Nobody is watching: never wait for the user. Be cheap when there is nothing to do. State file: `<state>`; the library clone is `<library>`.
>
> 1. Read the state file. Missing, `status=done` or `status=skipped`: exit (nothing to finish).
> 2. `status=working`: load `mcp__ccd_session_mgmt__get_session` and `mcp__ccd_session_mgmt__send_message` with ToolSearch and look up the session it names. If it is still running, exit. Otherwise send it: "04:05 finish: the usage limit has reset. Don't start any new papers, notes or pages. Finish only the work in flight (the skill says how a cut-off run resumes from disk), commit it, release the claims of anything unstarted, then do step 3 of your instructions (push, pull request, state file)." If the result is "delivered" or "queued", exit.
> 3. If the message couldn't be delivered (session archived, not found, refused), finish the run yourself, in the same limits: check out the branch named in the state file in `<library>`, resume the skill's in-flight work as its cut-off rules say (invoke `/<skill>`, or read `~/.claude/plugins/marketplaces/shocklab/skills/<skill>/SKILL.md`), start nothing new, release unstarted claims, then rebase on `origin/main`, rebuild and check, push the branch and open the pull request as the skill says, with a section "Overnight run: skipped or left for a person", then switch the clone back to `main` and pull. Never ask the user anything and never push to `main`. Set `status=done` and `pr=<url>` in the state file.

## 4. Report

Tell the user both tasks are booked (titles and times), which permission mode they got, where the state file is, and that they'll find the pull request link in the state file and in this session's task notifications in the morning. They can cancel either task from the app's Scheduled tasks list before it fires.
