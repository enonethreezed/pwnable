# Agent Instructions

## Scope

The user provides intent and decisions; the agent executes precisely. Do not add unrequested functionality or change the project direction.

Use English in responses. Be terse, direct, and information-dense. Do not propose unsolicited alternatives or next steps.

Never run `ludus` commands unless the user explicitly instructs it.

## Tracking

Beads (`bd`) and GitHub Issues are the only permitted task-tracking systems. Do not use Markdown TODO lists, GitHub-only work items, or any other issue tracker.

Every implementation, bug fix, documentation change, code review, and discovered follow-up is a task. Code reviews are performed as tracked tasks and must record their findings in the linked GitHub issue.

Create and link tasks in this order:

1. Create the Beads task with `bd create ... --json`.
2. Create the GitHub issue with `gh issue create`; its body must include `bd: <id>`.
3. Link the Beads task with `bd update <id> --external-ref "gh-<N>" --json`.
4. Claim the Beads task with `bd update <id> --claim --json`.

Use `bd onboard` to load the Beads workflow. Use `bd ready --json` before selecting unassigned work. Link discovered follow-up work with `--deps discovered-from:<parent-id>` and immediately create its matching GitHub issue.

## Task Completion

Except when the user explicitly says otherwise before completion, every completed task requires a commit and a successful push before it is closed.

Complete tasks in this order:

1. Implement the requested work and run appropriate validation.
2. Commit only the intended changes.
3. Run `git pull --rebase`, then `git push`, and verify `git status` is up to date with `origin`.
4. Close the linked Beads and GitHub issues.

If GitHub issue creation, validation, commit, rebase, or push fails, leave the task open and report the exact blocker. Do not claim completion.

Before committing, inspect `git status`, `git diff`, and `git log --oneline -10`. Never revert, discard, or modify unrelated user changes. Do not amend, force-push, or create empty commits unless explicitly requested.

## Shell Safety

Always use non-interactive flags for commands that may prompt:

```bash
cp -f source dest
mv -f source dest
rm -f file
rm -rf directory
cp -rf source dest
scp -o BatchMode=yes source dest
ssh -o BatchMode=yes host
apt-get -y install package
```
