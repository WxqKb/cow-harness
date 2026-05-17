#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

OH_MY_CODEX_PACKAGE="${OH_MY_CODEX_PACKAGE:-oh-my-codex}"

echo "==> Installing ${OH_MY_CODEX_PACKAGE} globally"
if ! npm install -g "$OH_MY_CODEX_PACKAGE"; then
  cat <<'MSG' >&2

Failed to install oh-my-codex.

Check npm registry access and permissions, then rerun:
  bash cow-harness/scripts/install-ai-skills.sh
MSG
  exit 1
fi

if ! command -v omx >/dev/null 2>&1; then
  cat <<'MSG' >&2

oh-my-codex installed, but `omx` is not on PATH.
Check your npm global bin directory, then rerun:
  omx setup
  omx doctor
MSG
  exit 1
fi

echo "==> Running omx setup"
if ! omx setup; then
  cat <<'MSG' >&2

`omx setup` failed. Fix the reported setup issue, then rerun:
  bash cow-harness/scripts/install-ai-skills.sh
MSG
  exit 1
fi

echo "==> Running omx doctor"
if ! omx doctor; then
  cat <<'MSG' >&2

`omx doctor` reported problems. Fix the reported issues, then rerun:
  bash cow-harness/scripts/install-ai-skills.sh
MSG
  exit 1
fi

echo "==> Checking optional local superpowers skills"
required_paths=(
  "$HOME/.codex/superpowers/skills/brainstorming/SKILL.md"
  "$HOME/.codex/superpowers/skills/writing-plans/SKILL.md"
  "$HOME/.codex/superpowers/skills/systematic-debugging/SKILL.md"
  "$HOME/.codex/superpowers/skills/test-driven-development/SKILL.md"
  "$HOME/.codex/superpowers/skills/verification-before-completion/SKILL.md"
)

missing=0
for skill_path in "${required_paths[@]}"; do
  if [[ -f "$skill_path" ]]; then
    echo "ok: $skill_path"
  else
    echo "missing: $skill_path"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  cat <<'MSG' >&2

Some optional superpowers skills are missing. oh-my-codex passed setup and doctor, and the
project can still use omx workflows. Install or sync the listed superpowers skills if you
want exact compatibility with the optional superpowers routes in AGENTS.md.
MSG
  if [[ "${STRICT_SUPERPOWERS:-0}" == "1" ]]; then
    exit 2
  fi
fi

echo "==> AI skills installation check complete"
