#!/usr/bin/env bash
# new-post.sh - start a new post. You just write; this does the boring setup.
#
#   ./new-post.sh beginner "How to pick your first model"
#
# makes  content/beginner/how-to-pick-your-first-model.md
# with the date filled in, tagged "organic", and marked draft. Open it, write,
# then delete the `draft = true` line when you want it live.

set -euo pipefail

section="${1:-}"
title="${2:-}"

if [ -z "$section" ] || [ -z "$title" ]; then
  echo 'Usage: ./new-post.sh <beginner|advanced|wellbeing> "Your title"'
  exit 1
fi

# turn the title into a filename: lower-case, spaces and punctuation -> dashes
slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')
file="content/${section}/${slug}.md"

if [ -e "$file" ]; then
  echo "Already exists: $file"
  exit 1
fi

cat > "$file" <<EOF
+++
title = "${title}"
date = $(date +%Y-%m-%d)
authorship = "organic"
draft = true
+++

Write your post here, in plain words.

When it's ready, delete the \`draft = true\` line above.
EOF

echo "Created $file"
echo "Open it, write, then remove the draft line to publish."
