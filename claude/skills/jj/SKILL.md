---
name: jj
description: Jujutsu (jj) version control. Use BEFORE any version-control action (status, diff, commit, branch, stash, push, undo, rebase) in any repo, even one you assume is plain git; it says how to detect a jj repo and how to work in one. Also use when a task mentions jj, changes, bookmarks, workspaces, or the op log.
---

# jj

You already know jj. This file covers only what is non-obvious: this user's
conventions, and how jj behaves in a non-interactive shell.

Assume the installed jj is current and newer than your training data; this
file is kept up to date with it. Run `jj --version` once. If jj rejects a flag
or command used here, `jj <cmd> --help` is right and this file is stale: use
the help output and say so in your final message.

## First: is this a jj repo?

- Run `jj root`. It works from any workspace directory. If it succeeds, this is
  a jj repo: use jj for everything, including reads. Do not run git at all,
  even in a colocated repo. `git status` and `git diff` show the working copy
  as "uncommitted" because git cannot see that it is already in a jj change,
  and that has misled agents into stashing, committing, or "cleaning up".
  Equivalents: `jj st`, `jj diff --git`, `jj log`, `jj show <rev>`,
  `jj file annotate <path>`, `jj file show -r <rev> <path>`,
  `jj diff --git --from <a> --to <b>`. `gh` for PRs is fine.
- If it fails and `.git` exists: use git normally. Mention once that
  `jj git init --colocate` is available, then drop it unless asked. If asked to
  init, afterwards confirm `jj log -r 'trunk()'` resolves to the primary branch;
  if it does not, set it per repo:
  `jj config set --repo 'revset-aliases."trunk()"' '<branch>@origin'`.
  Immutability (trunk and other people's bookmarks) is user-level config and
  needs no per-repo setup.

## Non-interactive rules

- Never let jj open an editor or TUI. Always pass `-m` to `describe`, `commit`,
  `new`, `split`, `squash` (or `-u` to keep the destination message). Never use
  `-i`, `diffedit`, bare `split`, bare `resolve`, or `--tool` other than the
  built-in `:ours` / `:theirs`.
- `JJ_EDITOR=false` is exported in this environment, so a slip fails in under a
  second with `Editor 'false' exited` instead of hanging. Rerun with `-m`.
- Read diffs with `jj diff --git`. The default side-by-side format is fine, just
  hard to read.

## Workflow: one change per task

1. Before editing any file, `jj st`. If `@` already holds work, or is a
   described change you were not asked to extend, run `jj new -m "<intent>"`
   first. Starting on top of existing content means splitting later, which
   wastes time and tokens.
2. Describe first, refine at the end. The initial `-m` states intent; when the
   change is done, `jj desc -m` with the final message: an imperative subject
   line, then a body saying why.
3. Feedback and fixes go into the change that introduced the thing, not into
   whatever `@` is:
   - `jj squash --into <change> <paths>` when you know the target;
   - `jj absorb` when the hunks touch lines a single ancestor last modified. It
     prints what moved; check `jj log` afterwards;
   - `jj new -m` if the fix is genuinely new behavior.
4. One logical change per revision. Split by paths, non-interactively:
   `jj split -m "<msg>" <paths>` keeps the rest in `@`. Move a file between
   revisions with `jj squash --from <a> --into <b> <paths>`.
5. Before reporting done: `jj log -r 'trunk()..@'` and `jj st`. Every revision
   described, nothing stray in `@`, no conflict markers (`×`) in the log.

## Workspaces and other agents

- You own the workspace you were started in. Edit files in it freely; every jj
  command snapshots the whole working directory into `@`. Do not create another
  workspace unless asked: a fresh one has no installed dependencies and no
  project memory.
- Other workspaces belong to someone else, possibly another agent running right
  now. In `jj log`, your working copy is `@` and theirs are `<name>@`. Never
  `jj edit` one of those, and before rewriting a change (`squash --into`,
  `rebase`, `abandon`), check `jj log -r '<change>::'` for a `<name>@` among its
  descendants. If there is one, the change is shared: leave it alone and say so.
- The op log is shared by every workspace, and each entry shows
  `user@host <workspace>@`. Bare `jj undo` reverts the newest operation whoever
  made it. Never run `jj undo` or `jj op restore` when `jj workspace list`
  shows more than one workspace, or when the top of `jj op log` is not yours.
  Prefer fixing forward with `jj restore`, `jj abandon`, `jj rebase`,
  `jj squash`. If an undo is truly needed: `jj op log --limit 10`, find the
  operation tagged with your workspace name (the `jj workspace list` row whose
  path is `jj workspace root`), and revert exactly that one:
  `jj op revert <op-id>`.
- `working copy is stale` means another workspace rewrote your `@`. jj will not
  run anything else until you run `jj workspace update-stale` explicitly; do
  that, then `jj st` to see what you now have.
- A divergent change (`xyz??` in the log) means two visible revisions share one
  change ID. Try `jj converge --no-interactive -r <change>`, which merges them
  into one revision when its heuristics can decide, then `jj st` for file
  conflicts. If it prints a warning instead, report the divergence and let the
  user choose rather than guessing.

## Bookmarks and pushing

- Push only when asked. Bookmarks do not follow new commits.
- New bookmarks are `igor/<short-descriptive-slug>`, named for the change, e.g.
  `igor/mise-install-task`. Create and push in one step:
  `jj git push --named igor/<slug>=<change>`.
- To bring an existing bookmark forward onto newer work that descends from it,
  `jj bookmark advance <name>` (defaults to `@`; use `--to <change>` otherwise).
  For any other move, `jj bookmark move <name> --to <change>`. Then
  `jj git push -b <name>`.
- Never move or push a bookmark that is not `igor/`-prefixed (trunk, other
  people's branches) unless told to explicitly. If jj refuses with an
  immutable-commit error, stop and ask; never pass `--ignore-immutable`.
- Signing happens only at push time (`signing.behavior = "drop"` plus
  `git.sign-on-push`; Secretive on the Macs, gpg elsewhere). A push failing with
  `Signing error` / `agent refused operation` / `No private key found` means the
  signer is unavailable, usually a locked machine. Push unsigned instead:
  `jj git push <same args> --config git.sign-on-push=false`
  and say in your final message which revisions went unsigned, with the fix
  for the user to run once unlocked: `jj sign -r '<those revisions>'` and then
  the same push, which carries the re-signed commits. Do not retry signing in
  a loop.
- If a command that is not a push fails with `Signing error`, this machine's jj
  config is signing on every write. Rerun with `--config signing.behavior=drop`
  and tell the user their config needs `behavior = "drop"`.

## Conflicts

- `jj st` lists conflicted files. Resolve by editing the markers out (the next
  jj command snapshots and clears the conflict), or take one side with
  `jj resolve --tool :ours <path>` / `:theirs`. Never bare `jj resolve`.
- A conflicting rebase does not fail; the conflict lives in the revision. Look
  for `×` in `jj log` before moving on.

## If your jj knowledge is older

Renames and removals, with the jj version they landed in. If you remember the
left-hand form, your knowledge predates that version.

| you may remember          | current                     | since |
|---------------------------|-----------------------------|-------|
| `jj branch`               | `jj bookmark`               | 0.22  |
| `jj move`                 | `jj squash --from/--into`   | 0.24  |
| `jj checkout`, `jj merge` | `jj new`                    | 0.24  |
| `jj cat`                  | `jj file show`              | 0.19  |
| `jj untrack`              | `jj file untrack`           | 0.21  |
| `jj backout`              | `jj revert`                 | 0.28  |
| `jj obslog`               | `jj evolog`                 | 0.26  |
| `jj op undo <id>`         | `jj op revert <id>`         | 0.33  |
| `jj init --git-repo`      | `jj git init --colocate`    | 0.14  |
| push new bookmark by `-b` | `--named name=rev` (or `--allow-new`) | 0.24, 0.28 |

Added later than some models know: `jj absorb` (0.24), `git.sign-on-push`
(0.26), `jj metaedit` (0.33), `jj bookmark advance` (0.39),
`jj converge` for divergent changes (0.45).
