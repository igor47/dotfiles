dotfiles
========

assorted dotfiles. symlink each into place — prefer the **XDG** location
(`~/.config/...`) wherever the tool supports it; only a few tools that predate
XDG are read from `$HOME`.

machine-specific settings go in a local override that the shared config sources,
so the tracked files stay portable:

- **git:** `~/.config/git/config.local` (e.g. per-machine `user.email`, signing key)
- **shell:** `~/.bash_profile`

## install locations

| file                     | symlink to                        | notes |
|--------------------------|-----------------------------------|-------|
| `gitconfig`              | `~/.config/git/config`            | XDG   |
| `gitignore_global`       | `~/.config/git/ignore`            | git's default global excludes (no `core.excludesfile` needed) |
| `tmux.conf`              | `~/.config/tmux/tmux.conf`        | XDG; TPM auto-installs to `~/.config/tmux/plugins/` |
| `jjconfig.toml`          | `~/.config/jj/config.toml`        | XDG   |
| `alacritty.yml`          | `~/.config/alacritty/alacritty.yml` | XDG |
| `kitty.conf`             | `~/.config/kitty/kitty.conf`      | XDG   |
| `config-direnv-direnvrc` | `~/.config/direnv/direnvrc`       | XDG   |
| `bashrc`                 | `~/.bashrc`                       | bash: `$HOME` only |
| `ssh_config`             | `~/.ssh/config`                   | ssh: `$HOME` only; base config, add hosts below `moomers` |
| `screenrc`               | `~/.screenrc`                     | screen: `$HOME` only |
| `asdfrc`                 | `~/.asdfrc`                       | asdf: `$HOME` only |

quick-link the XDG ones:

```sh
cd ~/repos/dotfiles
while read -r src dst; do
  mkdir -p ~/.config/"$(dirname "$dst")"
  ln -sfn "$PWD/$src" ~/.config/"$dst"
done <<'EOF'
gitconfig              git/config
gitignore_global       git/ignore
tmux.conf              tmux/tmux.conf
jjconfig.toml          jj/config.toml
alacritty.yml          alacritty/alacritty.yml
kitty.conf             kitty/kitty.conf
config-direnv-direnvrc direnv/direnvrc
EOF
```

## tmux on osx (arm)

i needed help from [here](https://github.com/tmux/tmux/issues/1257#issuecomment-581378716) to get termtype info correct.
my sequence was:

```
/opt/homebrew/Cellar/ncurses/6.2/bin/infocmp tmux-256color > ~/.tmux/tmux-256color.info
tic -xe tmux-256color ~/.tmux/tmux-256color.info
```

## Very Important ##

<img src="https://raw.github.com/igor47/dotfiles/master/rickroll.gif"/>
