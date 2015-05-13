# Tmux fpp

Plugin wrapper around [Facebook PathPicker](http://facebook.github.io/PathPicker/).

Quickly open any path on your temrinal window in your `$EDITOR` of choice!

### Demo

[![Demo tmux-fpp](http://g.recordit.co/MhLPNgOKyN.gif)](http://recordit.co/MhLPNgOKyN)

### Dependencies

- `fpp` - Facebook PathPicker.

### Key bindings

In any tmux mode:

- `f` - "fpp" for a new window with a Facebook PathPicker selection of your tty.


### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @tpm_plugins "          \
      tmux-plugins/tpm             \
      jbnicolai/tmux-fpp           \
    "

Hit `prefix + I` to fetch the plugin and source it. You should now be able to
use the plugin.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/tmux-plugins/tmux-fpp ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/open.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

You should now be able to use the plugin.

### Configuration

> How can I change the default "f" key binding to something else? For example,
> key "x"?

Put `set -g @fpp-key 'x'` in `tmux.conf`.

### Other goodies

`tmux-fpp` works great with:

- [tmux-urlview](https://github.com/jbnicolai/tmux-urlview) - a plugin for
  quickly opening any url on your terminal window
- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - a plugin for
  regex searches in tmux and fast match selection
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank) - enables copying
  highlighted text to system clipboard

### License

[MIT](LICENSE.md)
