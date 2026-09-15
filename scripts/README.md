# Scripts

a collection of my local scripts, part of the dotfiles repo. the ones meant
to be on PATH are linked into `~/bin` by `mise run install` (see the manifest
in `../tasks/install`).

## aws_*

managing aws MFA key sessions locally.
see [the blog post](https://igor.moomers.org/aws-mfa-cli-direnv).

## fullcharge

reminder for how to make my laptop charge to 100% (which it doesn't usually do).

## notmuch

regularly re-run the notmuch index, including tagging spam messages

## claude

the `claude` on PATH (via `~/bin`). runs the real binary from `~/.local/bin`
without needing that directory on PATH, layers the tracked settings from
`~/repos/dotfiles/claude/settings.json` on top with `--settings`, and pins the
tmux window name for the session. anything that shells out to `claude`,
including `claude-sudo`, goes through it.

## claude-sudo

wrapper that launches `claude` with a sudo timestamp kept alive in the background,
so claude can run sudo non-interactively without storing a password on disk.

## rtssh

persistent ssh+tmux session (`rtssh <host> [session]`) that retries with backoff
on connection-level failures instead of hanging on a password prompt nobody's
there to answer. formerly a `.bashrc` function; moved here to add retry logic.
see [the blog post](https://pempek.net/articles/2013/04/24/vpn-less-persistent-ssh-sessions/).
