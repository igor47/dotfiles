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

## ssh config

this should probably just be the base config.
use like so:

```
cat ~/repos/dotfiles/ssh_config > ~/.ssh/config
```

and then add specific hosts beyond moomers there.

## Very Important ##

<img src="https://raw.github.com/igor47/dotfiles/master/rickroll.gif"/>
