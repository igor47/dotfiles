# auto_suspend

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
