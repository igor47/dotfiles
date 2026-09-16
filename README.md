dotfiles
========

assorted dotfiles, installed by symlinking each into place. XDG locations
(`~/.config/...`) are preferred wherever the tool supports them; a few tools
that predate XDG are read from `$HOME`.

## install

needs [mise](https://mise.jdx.dev). tasks are scripts in `tasks/`, wired up by
`mise.toml`; `mise tasks` lists them.

```sh
cd ~/repos/dotfiles
mise run install --dry-run   # show every link that would be made, and anything in the way
mise run install             # make them
```

the list of what goes where is the manifest at the top of `tasks/install`.
that file is the source of truth; add a row there when adding a config file.

- **link** rows become symlinks into this repo. the script repoints stale
  symlinks but never replaces a real file; those are reported as `SKIP`.
  `mise run install --force` moves such a file to `<file>.bak` and links over it.
- **each** rows point at a directory and link its children one at a time, so
  the directory in `$HOME` stays real and can hold machine-local entries
  beside the tracked ones. a link into the repo whose target has gone (a
  renamed or deleted entry) is pruned; anything else in there is left alone.
- **seed** rows (just `ssh_config`) are copied into place once if absent, and
  are then yours to edit locally. the copy is never touched again.

## claude code

`claude/skills/` is an **each** row: every `claude/skills/<name>/` is linked
individually into `~/.claude/skills/`, so a skill added here shows up on every
machine after a pull, and a machine can still keep its own unshared skills in
the same directory. skills are `claude/skills/<name>/SKILL.md`.

`claude/settings.json` holds portable preferences (editor mode, permission
mode, effort). it is *not* linked into `~/.claude`: claude code writes its own
`~/.claude/settings.json` (`/config`, `/model`, plugin installs), so linking
would churn the repo. instead the `claude` wrapper script in `~/bin` passes it
with `--settings`, which layers it above the local file for that session and
never writes back. keep machine-varying keys (model, theme, plugins) out of it.

everything else under `~/.claude` (sessions, history, caches, memory) is
machine state and stays out of the repo.

## scripts

`scripts/` is the former `igor47/scripts` repo, merged in with its history.
the ones meant to be on PATH are linked into `~/bin` by the manifest; see
[`scripts/README.md`](scripts/README.md) for what each does. `scripts/claude`
is the `claude` command everywhere.

## machine-local overrides

machine-specific settings go in a local file that the shared config sources,
so the tracked files stay portable:

- **git:** `~/.config/git/config.local` (per-machine `user.email`, signing key)
- **shell:** `~/.bash_profile`
- **ssh:** `~/.ssh/config` itself, since it is a seeded copy rather than a link

## Lock.app (macOS)

`lock-app/install` builds `~/Applications/Lock.app`, so cmd-space → "lock"
locks the screen. It's an AppleScript applet that sends cmd-ctrl-Q, with a
padlock icon so it's recognizable in Spotlight.

Needs one manual step afterward — macOS won't let a script grant it:
**System Settings → Privacy & Security → Accessibility → + →
`~/Applications/Lock.app`**. Without it the app fails with
`Lock is not allowed to send keystrokes (1002)`.

## tmux on osx (arm)

i needed help from [here](https://github.com/tmux/tmux/issues/1257#issuecomment-581378716) to get termtype info correct.
my sequence was:

```
/opt/homebrew/Cellar/ncurses/6.2/bin/infocmp tmux-256color > ~/.tmux/tmux-256color.info
tic -xe tmux-256color ~/.tmux/tmux-256color.info
```

## Very Important ##

<img src="https://raw.github.com/igor47/dotfiles/master/rickroll.gif"/>
