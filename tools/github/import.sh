#!/usr/bin/env bash
# Import Sewlio Studio labels + issues into a GitHub repo via `gh`.
# Idempotent-ish: labels use --force (upsert); issues are created (no dedupe — run once).
# Dry-run by default; pass --apply to actually create. Requires: gh (authed), jq, a remote.
set -euo pipefail
cd "$(dirname "$0")"

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

command -v gh >/dev/null || { echo "error: gh not installed"; exit 1; }
command -v jq >/dev/null || { echo "error: jq not installed"; exit 1; }

# Guard: a GitHub remote must exist and be resolvable by gh.
if ! gh repo view >/dev/null 2>&1; then
  echo "error: no GitHub repo resolved by gh (add a remote + push, then re-run)"; exit 1
fi
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "target repo: $REPO   mode: $([ $APPLY -eq 1 ] && echo APPLY || echo DRY-RUN)"

run() { # echo in dry-run, execute in apply
  if [ $APPLY -eq 1 ]; then "$@"; else printf '  [dry-run]'; printf ' %q' "$@"; printf '\n'; fi
}

echo "== labels =="
jq -c '.[]' labels.json | while read -r l; do
  name=$(jq -r .name <<<"$l"); color=$(jq -r .color <<<"$l"); desc=$(jq -r .description <<<"$l")
  run gh label create "$name" --color "$color" --description "$desc" --force
done

create_issues() { # $1 = jq path to array
  jq -c "$1[]" issues.json | while read -r i; do
    title=$(jq -r .title <<<"$i")
    body=$(jq -r .body <<<"$i")
    deps=$(jq -r '(.dependencies // []) | if length>0 then "\n\nDepends on: " + join(", ") else "" end' <<<"$i")
    ms=$(jq -r '.milestone // empty' <<<"$i")
    sprint=$(jq -r 'if .sprint then "\nSprint: " + .sprint else "" end' <<<"$i")
    labels=$(jq -r '.labels | join(",")' <<<"$i")
    args=(gh issue create --repo "$REPO" --title "$title" --body "${body}${deps}${sprint}" --label "$labels")
    [ -n "$ms" ] && args+=(--milestone "$ms")   # milestone must pre-exist in the repo
    run "${args[@]}"
  done
}

echo "== epic issues =="; create_issues '.epics'
echo "== task issues =="; create_issues '.tasks'

echo "done ($([ $APPLY -eq 1 ] && echo applied || echo dry-run)). Re-run with --apply to create for real."
echo "note: create milestones M1..M10 in the repo first if you want --milestone to attach."
