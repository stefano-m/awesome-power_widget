package = "power_widget"
version = "0.5.3-1"
source = {
   url = "git://github.com/stefano-m/awesome-power_widget",
   tag = "v0.5.3"
}
description = {
   summary = "A Power widget for the Awesome Window Manager",
   detailed = [[
    Monitor your power devices in Awesome with UPower and DBus.
    ]],
   homepage = "https://github.com/stefano-m/awesome-power_widget",
   license = "GPL v3"
}
supported_platforms = {
   "linux"
}
dependencies = {
   "lua >= 5.1",
   "upower_dbus"
}
build = {
   type = "builtin",
   modules = {
      power_widget = "power_widget.lua"
   }
}
