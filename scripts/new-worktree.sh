#!/usr/bin/env bash
#
# Create an isolated worktree for one session's work.
#
#   ./scripts/new-worktree.sh fix/my-thing
#   ./scripts/new-worktree.sh fix/my-thing --from origin/some-branch
#
# Why bother: several Claude Code and Cursor sessions share this checkout, and
# the main tree has one HEAD. When any session runs `git checkout`, every other
# session's next commit lands on that branch instead of its own. A worktree has
# its own HEAD, so a checkout elsewhere cannot reach it.
#
# A fresh worktree holds tracked files only. This fills in what is gitignored
# but needed to work, and skips whatever this repo does not have:
#
#   .env*          symlinked, so there is one copy of each secret. `.env.example`
#                  is tracked and arrives with the checkout.
#   node_modules   hardlinked with `cp -al`, not symlinked: Turbopack refuses a
#                  symlink pointing outside the project root and `next dev`
#                  panics on boot. One real directory sharing the original's
#                  disk blocks, so it costs almost no disk.
#   .terraform/    hardlinked per root module, so `terraform plan` works without
#                  re-running `init` and re-downloading providers.
#
# Re-run after changing dependencies: hardlinks share file contents, not the
# list of files, so a new package will not appear on its own.
#
# Same script as antwork.io's, generalised; keep them in step.

set -euo pipefail

branch=${1:-}
base=origin/main
if [ "${2:-}" = "--from" ] && [ -n "${3:-}" ]; then base=$3; fi

if [ -z "$branch" ]; then
  echo "usage: $0 <branch-name> [--from <base-ref>]" >&2
  echo "example: $0 fix/typo-in-readme" >&2
  exit 1
fi

# The main tree, even when run from inside another worktree: that is where the
# gitignored files to link live, and where .claude/worktrees/ belongs.
root=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
cd "$root"

# `.githooks/pre-commit` refuses commits on main. Wire it up here too, so a repo
# without a package.json `prepare` step still gets it. The setting is shared by
# every worktree of this repo, the main tree included.
if [ -d .githooks ] && [ "$(git config core.hooksPath || true)" != ".githooks" ]; then
  git config core.hooksPath .githooks
  echo "enabled .githooks (commit guard on main)"
fi

slug=$(printf '%s' "$branch" | tr '/' '-')
wt=".claude/worktrees/$slug"

if [ -e "$wt" ]; then
  echo "error: $wt already exists. Remove it first:" >&2
  echo "  git worktree remove $wt" >&2
  exit 1
fi

echo "fetching origin ..."
git fetch origin --quiet

echo "creating worktree $wt on $branch (from $base) ..."
git worktree add --no-track -b "$branch" "$wt" "$base"

# Relative symlink back to the main tree: one `../` per path segment between
# the link's directory and the repo root, so the link survives moving the repo.
ups() {
  local n
  n=$(( $(printf '%s' "$1" | tr -cd '/' | wc -c) + 1 ))
  printf '../%.0s' $(seq 1 "$n")
}

while IFS= read -r env; do
  env=${env#./}
  dir=$(dirname "$env")
  if [ "$dir" = "." ]; then linkdir=$wt; else linkdir=$wt/$dir; fi
  ln -s "$(ups "$linkdir")$env" "$wt/$env"
  echo "linked $env"
done < <(find . -name '.env*' -not -name '.env.example' -type f \
  -not -path './.git/*' -not -path './.claude/*' -not -path '*/node_modules/*' \
  -not -path '*/.next/*' -not -path '*/.terraform/*' \
  | while IFS= read -r f; do if git check-ignore -q "$f"; then echo "$f"; fi; done)

if [ -d node_modules ]; then
  echo "hardlinking node_modules (can take a minute, almost no disk) ..."
  cp -al node_modules "$wt/node_modules"
  echo "linked node_modules"
elif [ -f package.json ]; then
  echo "no node_modules to link — run 'npm install' inside the worktree" >&2
fi

while IFS= read -r tf; do
  tf=${tf#./}
  cp -al "$tf" "$wt/$tf"
  echo "linked $tf"
done < <(find . -type d -name .terraform -not -path './.claude/*' -prune)

cat <<EOF

  ready: $wt

    cd $wt
EOF

if [ -f package.json ]; then
  # Every worktree needs its own port, or the second dev server dies with
  # EADDRINUSE. Offset by however many worktrees already exist.
  port=$(( 3000 + $(git worktree list | wc -l | tr -d ' ') - 1 ))
  echo "    npm run dev -- -p $port"
fi

cat <<EOF

  when you are done:

EOF
[ -d node_modules ] && echo "    rm -rf $wt/node_modules   # first: 'worktree remove' is slow over it"
echo "    git worktree remove $wt"
echo
