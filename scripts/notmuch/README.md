# notmuch

runs on purr (the mail server). every minute: index new mail, apply folder
tags, and have `mailograf` report counts to telegraf for the grafana panel.
`notmuch-new.sh` is linked into `~/bin`;
the `.timer` and `.service` files go into `~/.config/systemd/user`.
`mailograf` runs from a plain venv in its repo, created with
`python3.8 -m venv .venv && .venv/bin/pip install -e .` (python via mise).

to enable:

```
systemctl --user daemon-reload
systemctl --user enable notmuch.timer
systemctl --user start notmuch.timer
```

to check status:

```
systemctl --user list-timers
```
