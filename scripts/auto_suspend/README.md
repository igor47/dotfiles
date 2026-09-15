# auto_suspend

the `.timer` and `.service` files go into `~/.config/systemd/user`.
to enable:

```
systemctl --user daemon-reload
systemctl --user enable auto_suspend.timer
systemctl --user start auto_suspend.timer
```

to check status:

```
systemctl --user list-timers
```
