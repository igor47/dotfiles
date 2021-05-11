dotfiles
========

other random assorted dotfiles.
these should be symlinked into your `$HOME` folder.
i recommend using `.bash_profile` for any system-specific settings for that particular machine.

## alacritty

this config file should be symlinked into a `.config`:

```
mkdir -p ~/.config/alacritty
ln -s ~/repos/dotfiles/alacritty.yml ~/.config/alacritty/
```

## tmux on osx (arm)

i needed help from [here](https://github.com/tmux/tmux/issues/1257#issuecomment-581378716) to get termtype info correct.
my sequence was:

```
/opt/homebrew/Cellar/ncurses/6.2/bin/infocmp tmux-256color > ~/.tmux/tmux-256color.info
tic -xe tmux-256color ~/.tmux/tmux-256color.info
```

## ssh config

this should probably just be the base config.
use like so:

```
cat ~/repos/dotfiles/ssh_config > ~/.ssh/config
```

and then add specific hosts beyond moomers there.

## Very Important ##

<img src="https://raw.github.com/igor47/dotfiles/master/rickroll.gif"/>
