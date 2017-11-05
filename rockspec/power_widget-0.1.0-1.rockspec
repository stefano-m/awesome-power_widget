package = "power_widget"
version = "0.1.0-1"
source = {
  url = "git://github.com/stefano-m/awesome-power_widget",
  tag = "v0.1.0"
}
description = {
  summary = "A Power widget for the Awesome Window Manager",
  detailed = [[
    Monitor your power devices in Awesome with UPower and DBus.
    ]],
  homepage = "https://github.com/stefano-m/awesome-power_widget",
  license = "GPL v3"
}
dependencies = {
  "lua >= 5.1",
  "upower_dbus >= 0.1.0, < 0.2",
}
supported_platforms = { "linux" }
build = {
  type = "builtin",
  modules = { power_widget = "power_widget.lua" },
}
