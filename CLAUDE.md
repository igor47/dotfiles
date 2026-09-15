# dotfiles

Personal config files, symlinked into `$HOME` by `mise run install`.

## Rules for editing this repo

- **Install through the mise task, never by hand.** Do not `ln -s` or `cp`
  files into `$HOME` directly. Run `mise run install --dry-run` first and read
  the output; then `mise run install`. Use `--force` only when the dry run shows
  a `SKIP` and the user has agreed to have that file moved to `.bak`.
- **The manifest in `tasks/install` is the single source of truth** for what
  goes where. Adding a config file means adding a row there. The README
  describes the mechanism but does not repeat the table.
- **New automation is a new script in `tasks/`**, executable, with `#MISE` and
  `#USAGE` headers so `mise tasks` documents it and flags land as `usage_<flag>`
  env vars. Do not add a Makefile or standalone shell scripts at the root.
- **`claude/skills/` is linked as a whole directory** into `~/.claude/skills`.
  Put new skills at `claude/skills/<name>/SKILL.md`.
- **`claude/settings.json` is loaded with `--settings`, never symlinked.** The
  `claude` wrapper in `~/bin` passes it on every launch. Only portable
  preferences belong in it; never `model`, `theme`, or `enabledPlugins`, since
  a value here overrides whatever `/model` or `/config` saved locally. Do not
  add anything else from `~/.claude` (sessions, history, caches, memory).
- **`scripts/` holds executables linked into `~/bin`.** A new script needs a
  `link scripts/<name> bin/<name>` manifest row and an entry in
  `scripts/README.md`. `scripts/claude` is the only `claude` on PATH; changes
  to how Claude Code is launched go there, not in `bashrc`.
- **`ssh_config` is a seed, not a link.** The installed `~/.ssh/config` has
  machine-local additions; edits to the shared base go in the repo file and
  are applied by hand on each machine.
- **Machine-specific values** belong in the local override files listed in
  the README, not in tracked files.
- The README is written in lowercase prose. Match it.
