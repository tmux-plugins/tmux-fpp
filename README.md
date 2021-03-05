# Tmux fpp

Plugin wrapper around [Facebook PathPicker](http://facebook.github.io/PathPicker/).

Quickly open any path on your terminal window in your `$EDITOR` of choice!

### Demo

[![Demo tmux-fpp](http://g.recordit.co/MhLPNgOKyN.gif)](http://recordit.co/MhLPNgOKyN)

### Dependencies

- `fpp` - Facebook PathPicker.

### Key bindings

- `prefix + f` - open a new window with a fpp selection of your current tmux pane.

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'tmux-plugins/tmux-fpp'

Hit `prefix + I` to fetch the plugin and source it. You should now be able to
use the plugin.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/tmux-plugins/tmux-fpp ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/fpp.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

You should now be able to use the plugin.

### Configuration

> How can I change the default "f" key binding to something else? For example,
> key "x"?

Put `set -g @fpp-key 'x'` in `tmux.conf`.

> How can I paste the selected file paths into my original pane, instead of
> launching an editor?

Put `set -g @fpp-mode 'paste'` in `tmux.conf`.

Alternatively you can bind both behaviours to different keys manually:

```sh
# Disable default binding
set -g @fpp-bind off

# Bind 'f' to run FPP launching an editor
bind-key f run-shell '~/.tmux/plugins/tmux-fpp start edit'

# Bind 'x' to run FPP and paste the list of files in the initial pane
bind-key x run-shell '~/.tmux/plugins/tmux-fpp start paste'
```

> How can I specify custom path to fpp?

Put `set -g @fpp-path '~/my/path/fpp'` in `tmux.conf`.

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
