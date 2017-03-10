--[[
  Copyright 2017 Stefano Mazzucco <stefano AT curso DOT re>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local beautiful = require("beautiful")

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local power = require("upower_dbus")

-- Awesome DBus C API
local cdbus = dbus -- luacheck: ignore

local spawn_with_shell = awful.spawn.with_shell or awful.util.spawn_with_shell or awful.spawn.with_shell
local icon_theme_dirs = { -- The trailing slash is mandatory!
  "/usr/share/icons/Adwaita/scalable/status/",
  "/usr/share/icons/Adwaita/scalable/devices/"}
local icon_theme_extensions = {"svg"}
icon_theme_dirs = beautiful.upower_icon_theme_dirs or icon_theme_dirs
icon_theme_extensions = beautiful.upower_icon_theme_extension or icon_theme_extensions

local widget = wibox.widget.imagebox()

local function build_icon_path(device)
  if device.IconName then
    return awful.util.geticonpath(device.IconName, icon_theme_extensions, icon_theme_dirs)
  end
  return ""
end

function widget:update()
  self.device:update_mappings()
  self:set_image(build_icon_path(self.device))

  if self.device.IsPresent then
    local percentage = math.floor(self.device.Percentage)
    local warning_level = self.device.WarningLevel

    self.tooltip:set_text(
      percentage .. "%" .. " - " .. self.device.State)

    if warning_level == "Low" or warning_level == "Critical" then
      naughty.notify({
          preset = naughty.config.presets.critical,
          title = warning_level .. "  battery!",
          text = percentage .. "% remaining"})
    end
  else
    self.tooltip:set_text("Plugged In")
  end
end

local function setup_signals(wdg)
  if wdg.device then
    -- Recent versions of UPower do not implement signals any more
    -- Use the PropertiesChanged signal instead.
    cdbus.add_match(
      "system",
      "type=signal" ..
        ",interface=org.freedesktop.DBus.Properties" ..
        ",member=PropertiesChanged" ..
        ",path=" ..
        wdg.device.dbus.path
    )

    cdbus.connect_signal("org.freedesktop.DBus.Properties",
                         -- PropertiesChanged (STRING interface_name,
                         --                    DICT<STRING,VARIANT> changed_properties,
                         --                    ARRAY<STRING> invalidated_properties);
                         function (info, interface, changed, _)
                           if info.member == "PropertiesChanged"
                             and interface == wdg.device.dbus.interface
                             and info.path == wdg.device.dbus.path
                           then
                             for k, v in pairs(changed) do
                               if wdg.device[k] then
                                 wdg.device[k] = v
                               end
                             end
                             wdg:update()
                           end
    end)
  end
end

function widget:init()
  local manager = power.Manager
  manager:init()
  self.manager = manager

  local devices = {}
  for _, d in ipairs(self.manager.devices) do
    devices[d.Type] = d
  end
  self.device = devices["Battery"] or devices["Line Power"]

  self.tooltip = awful.tooltip({ objects = { widget },})
  self.gui_client = ""

  setup_signals(self)

  self:update()

  self:buttons(awful.util.table.join(
                 awful.button({ }, 3,
                   function ()
                     spawn_with_shell(self.gui_client)
                   end
  )))
end

return widget
