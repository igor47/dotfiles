# Scripts

a collection of my local scripts.

## aws_*

managing aws MFA key sessions locally.
see [the blog post](https://igor.moomers.org/aws-mfa-cli-direnv).

## fullcharge

reminder for how to make my laptop charge to 100% (which it doesn't usually do).

## auto_suspend

determines when to suspend my laptop depending on state of charge.
see the [relevant blog post](https://igor.moomers.org/arch-linux-config)

## notmuch

regularly re-run the notmuch index, including tagging spam messages

## claude-sudo

wrapper that launches `claude` with a sudo timestamp kept alive in the background,
so claude can run sudo non-interactively without storing a password on disk.

## rtssh

persistent ssh+tmux session (`rtssh <host> [session]`) that retries with backoff
on connection-level failures instead of hanging on a password prompt nobody's
there to answer. formerly a `.bashrc` function; moved here to add retry logic.
see [the blog post](https://pempek.net/articles/2013/04/24/vpn-less-persistent-ssh-sessions/).
