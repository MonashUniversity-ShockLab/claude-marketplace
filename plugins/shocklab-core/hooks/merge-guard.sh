#!/usr/bin/env bash
# PreToolUse hook (shocklab-core): soft guard on merging pull requests in the
# MonashUniversity-ShockLab org. The lab's PR agent merges PRs; a person may still merge
# their own, but is first shown what the merge brings in and asked to confirm.
# Never blocks: it answers "ask" (the user decides) or stays silent. Any failure → silent.
ORG="MonashUniversity-ShockLab"
input=$(cat)

# Only `gh pr merge ...` commands (Bash or PowerShell tool).
case "$input" in *"gh pr merge"*) ;; *) exit 0 ;; esac

# The command text after "gh pr merge", cut at the end of the JSON string or a shell separator.
args=$(printf '%s' "$input" | grep -o 'gh pr merge[^"&;|]*' | head -n 1 | sed 's/^gh pr merge//')
target="" repo=""
set -f
set -- $args
while [ $# -gt 0 ]; do
  case "$1" in
    -R|--repo) repo="$2"; shift ;;
    --repo=*) repo="${1#--repo=}" ;;
    -t|--subject|-b|--body|-F|--body-file|-A|--author-email|--match-head-commit) shift ;;
    -*) ;;
    *) [ -z "$target" ] && target="$1" ;;
  esac
  shift
done
set +f

command -v gh >/dev/null 2>&1 || exit 0
view=(gh pr view)
[ -n "$target" ] && view+=("$target")
[ -n "$repo" ] && view+=(--repo "$repo")
info=$("${view[@]}" --json url,title,baseRefName,headRefName,additions,deletions,files --jq \
  '"\(.url)\n\(.title)\n\(.headRefName) -> \(.baseRefName)   (+\(.additions) -\(.deletions), \(.files|length) file(s))\n" + ([.files[:15][] | "  \(.path)  (+\(.additions) -\(.deletions))"] | join("\n")) + (if (.files|length) > 15 then "\n  ... and \((.files|length) - 15) more" else "" end)' 2>/dev/null) || exit 0

case "$info" in *"github.com/$ORG/"*) ;; *) exit 0 ;; esac   # other orgs: no opinion

msg="ShockLab guideline: the PR agent merges PRs (hourly, weekdays 8am-8pm), so you normally don't need to.
You are about to merge:
$info

Merge it yourself anyway? That's allowed. If only part of it should go in now (e.g. just one .md file), decline and ask Claude to move those files into their own PR."

esc() { local s=$1; s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\t'/\\t}; s=${s//$'\r'/}; s=${s//$'\n'/\\n}; printf '%s' "$s"; }
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$(esc "$msg")"
