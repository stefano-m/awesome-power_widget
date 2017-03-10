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

You will also need the DBus headers (`dbus.h`) installed.
For example, Debian and Ubuntu provide the DBus headers with the `libdbus-1-dev`
package, Fedora, RedHad and CentOS provide them with the `dbus-devel` package,
while Arch provides them (alongside the binaries) with the `libdbus` package.

# Installation

## Using Luarocks

Probably, the easiest way to install this widget is to use `luarocks`:

    luarocks install upower_widget

You can use the `--local` option if you don't want or can't install
it system-wide

This will ensure that all its dependencies are installed.

### A note about ldbus

This module depends on the [`ldbus`](https://github.com/daurnimator/ldbus)
module that provides the low-level DBus bindings

    luarocks install --server=http://luarocks.org/manifests/daurnimator \
        ldbus \
        DBUS_INCDIR=/usr/include/dbus-1.0/ \
        DBUS_ARCH_INCDIR=/usr/lib/dbus-1.0/include

As usual, you can use the `--local` option if you don't want or can't install
it system-wide.

## From source

Alternatively, you can copy the `upower_widget.lua` file in your
`~/.config/awesome` folder. You will have to install all the dependencies
manually though (see the `rockspec` file for more information).

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
power:init()
power.gui_client = "xfce4-power-manager"
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
