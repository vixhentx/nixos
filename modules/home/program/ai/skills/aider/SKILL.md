---
name: aider
description: Dispatch a coding task to Aider (a DeepSeek-backed pair-programmer) in the current repository. Use when the user wants to offload an implementation to aider, e.g. "让 aider 改", "用 aider 实现", or asks Claude to make a code change via aider.
argument-hint: <prompt> [files...]
allowed-tools: [Bash, Read, Glob]
---

# Aider Dispatch

Run aider in the current git repo to implement a change, then report the diff.

Aider is preconfigured via `~/.aider.conf.yml` (`yes-always: true`, `auto-commits: false`), and its model + API key come from the environment. Do **not** pass `--model`, `--api-key`, or provider flags.

## Procedure

1. Identify the files to edit: use paths from the request when given; otherwise infer them from the prompt via `git status` / `Glob`.
2. Write the prompt to a temp file so multi-line prompts are shell-safe:
   ```bash
   spec=$(mktemp /tmp/aider-spec-XXXX.md)
   printf '%s' "$PROMPT" > "$spec"
   ```
3. Run aider in the current directory, redirecting output to a log with an explicit timeout:
   ```bash
   timeout 300 aider --message-file "$spec" <files...> > /tmp/aider.log 2>&1
   ```
4. Read the tail of the log, then verify the change with `git diff` and `git status`.
5. Report success/failure, a one-line summary of what changed, and the diff. Leave the change uncommitted for review.
