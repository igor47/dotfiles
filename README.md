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
