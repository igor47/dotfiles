# notmuch

runs on purr (the mail server). every minute: index new mail, apply folder
tags, and have `mailograf` report counts to telegraf for the grafana panel.
`notmuch-new.sh` is linked into `~/bin`;
the `.timer` and `.service` files go into `~/.config/systemd/user`.
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
