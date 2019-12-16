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

## Luarocks

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

## NixOS

If you are on NixOS, you can install this package from
[nix-stefano-m-overlays](https://github.com/stefano-m/nix-stefano-m-nix-overlays).


# Configuration

The widget will display the battery icons defined in your GTK+ theme and it
will resize them to fit in the available space. This means that you can switch
your icon theme, for example using `lxappearance`, and update the widget by
restarting AwesomeWM.

## GUI client

You can specify a GUI client to be launched when the widget is right-clicked.
This can be done by changing the `gui_client` field of the widget. The default
is to have no client. For example, you could use the [XFCE4 Power
Manager](http://goodies.xfce.org/projects/applications/xfce4-power-manager) or
the [GNOME one](https://projects.gnome.org/gnome-power-manager/).

## Critical Battery Percentage
You can set the critical battery percentage at which a warning will be
displayed using the `critical_percentage` property (defaults to `5`).

## Additional Warning Notification

The `warning_config` property holds a table used to configure an additional
warning notification at a custom percentage. This is disabled by default.

It **must** contain the following properties:

- `percentage`: a numeric value used to trigger the notification
- `preset`: a [naughty preset
  table](https://awesomewm.org/doc/api/libraries/naughty.html#config.presets)

Optionally, it can also have the `message` property that should be a string
with a custom warning message.

For example, one could add a warning with a custom message, a black foreground
color and yellow background color once the battery discharges below 15% as
follows:

``` lua
widget.warning_config = {
  percentage = 15,
  preset = {
    bg = "#FFFF00",
    fg = "#000000",
  },
  message = "The battery is getting low",
}
```

You can change about anything on the notification (shape, position, opacity,
etc.). For more details a look at the [naughty.notify
documentation](https://awesomewm.org/doc/api/libraries/naughty.html#notify).

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
power.gui_client = "xfce4-power-manager-settings"
-- override the critical battery percentage
power.critical_percentage = 18
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

## Working Around `attempt to call field 'new' (a nil value)` error

This widget has a transitive dependency on
[lua-enum](https://github.com/stefano-m/lua-enum) that exposes a module called
`enum.lua`. Unfortunately, the lgi library has a module with the same name and
your AwesomeWM might have that module in the path *before* the one needed by
this widget.  In that case, loading the widget will result in a error saying
something like `attempt to call field 'new' (a nil value)`.

In that case, you can try to rewrite `package.path` in your `rc.lua` as
follows:

``` lua
local ok, power = pcall(require, "power_widget")
if not ok then
  local gears = require("gears")
  local table = table

  -- Reverse package.path so that our enum.lua is found before LGI's
  local paths = gears.string.split(package.path, ';')
  package.path = table.concat(gears.table.reverse(paths), ';')

  package.loaded.enum = nil     -- "Unload" LGI's enum

  power = require("power_widget") -- Try again

end
```

# Contributing

This project is developed in the author's spare time. Contributions in the form
of issues, patches and pull requests are welcome.
