# A widget for the Awesome Window Manager to display power devices with UPower and DBus

This widget uses the
[`upower_dbus`](https://luarocks.org/modules/stefano-m/upower_dbus)
library.

# Requirements

In addition to the requirements listed in the `rockspec` file, you will need
the [Awesome Window Manager](https://awesomewm.org)
and UPower (for more information about this, see the
[`upower_dbus`](https://luarocks.org/modules/stefano-m/upower_dbus)
documentation).

# Installation

The easiest way to install this widget is to use `luarocks`:

    luarocks install power_widget

You can use the `--local` option if you don't want or can't install
it system-wide

This will ensure that all its dependencies are installed.

Note that if you install with `--local` you will have to make sure that the
`LUA_PATH` environment variable includes the local luarocks path. This can be
achieved by `eval`ing the command `luarocks path --bin` **before** Awesome is
started.

For example, if you start Awesome from the Linux console (e.g. `xinit
awesome`) and you use `zsh`, you can add the following lines to your
`~/.zprofile`:

``` shell
if (( $+commands[luarocks] )); then
    eval `luarocks path --bin`
fi
```

If you use `bash`, you can add the following lines to your `~/.bash_profile`:

``` shell
if [[ -n "`which luarocks 2>/dev/null`" ]]; then
    eval `luarocks path --bin`
fi
```

If you use
an [X Display Manager](https://en.wikipedia.org/wiki/Display_manager) you will
need to do what explained above in your `~/.xprofile` or `~/.xinitrc`. See the
documentation of your display manager of choice for more information.

# Configuration

The widget displays power icons that are searched in the folders defined
in the table `beautiful.upower_icon_theme_dirs` with extensions defined
in the table `beautiful.upower_icon_extensions`.
The default is to look into `"/usr/share/icons/Adwaita/scalable/devices/"`
and  `"/usr/share/icons/Adwaita/scalable/status/"`for
icons whose extension is `"svg"`. Note that the directory paths *must* end
with a slash and that the extensions *must not* contain a dot.
The icons are searched using Awesome's
[`awful.util.geticonpath` function](https://awesomewm.org/doc/api/modules/awful.util.html#geticonpath).

You can specify a GUI client to be launched when the widget is right-clicked.
This can be done by changing the `gui_client` field of the widget. The default
is to have no client. For example, you could use the [XFCE4 Power Manager](http://goodies.xfce.org/projects/applications/xfce4-power-manager)
or the [GNOME one](https://projects.gnome.org/gnome-power-manager/).

You can set the critical battery percentage at which a warning will be
displayed using the `critical_percentage` property (defaults to `5`).

# Mouse controls

When the widget is focused:

* Right button: launches GUI client (defined by the `gui_client` field; defaults to the empty string, so nothing will happen)

# Tooltip

A tooltip with the current device power status shown.

# Usage

Add the following to your `~/.config/awesome/rc.lua`:

Require the module:

```lua
-- require *after* `beautiful.init` or the theme will be inconsistent!
local power = require("power_widget")
-- override the GUI client.
power.gui_client = "xfce4-power-manager"
-- override the critical battery percentage
power.critical_percentage = 18
power:init()
```

Add the widget to your layout:

* Awesome 3.5.x `rc.lua`

```lua
right_layout:add(power)
```

* Awesome 4.x `rc.lua`

```lua
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- other widgets
            power,
        },
    }
```


# Contributing

This project is developed in the author's spare time. Contributions in the form
of issues, patches and pull requests are welcome.
