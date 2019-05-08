--[[
  Copyright 2017-2019 Stefano Mazzucco <stefano AT curso DOT re>

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

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local lgi = require('lgi')
local icon_theme = lgi.Gtk.IconTheme.get_default()
local IconLookupFlags = lgi.Gtk.IconLookupFlags

local power = require("upower_dbus")
local WarningLevel = power.enums.BatteryWarningLevel

local spawn_with_shell = awful.spawn.with_shell or awful.util.spawn_with_shell

local icon_size = 64
local icon_flags = {IconLookupFlags.GENERIC_FALLBACK}

local widget = wibox.widget {
  resize = true,
  widget = wibox.widget.imagebox
}

widget.critical_percentage = 5

function widget:update()
  self.device:update_mappings()

  local icon = icon_theme:lookup_icon(
    self.device.IconName,
    icon_size,
    icon_flags
  )

  if icon then
    self.image = icon:load_surface()
  end

  if self.device.IsPresent then

    local percentage = math.floor(self.device.Percentage)
    local warning_level = self.device.warninglevel

    self.tooltip:set_text(
      percentage .. "%" .. " - " .. self.device.state.name)

    local should_warn = (
      self.device.state == power.enums.BatteryState.Discharging and
        (
          percentage <= self.critical_percentage
            or warning_level == WarningLevel.Low
            or warning_level == WarningLevel.Critical
        )
                        )

    if should_warn then
      local msg = (warning_level.name == "None" and "Low" or warning_level.name) .. " battery!"
      naughty.notify({
          preset = naughty.config.presets.critical,
          title = msg,
          text = percentage .. "% remaining"})
    end
  else
    -- We don't know how we're powered, but we must be somehow!
    self.tooltip:set_text("Plugged In")
  end
end

function widget:init()
  local manager = power.Manager
  self.manager = manager

  -- https://upower.freedesktop.org/docs/UPower.html#UPower.GetDisplayDevice
  self.device = power.create_device("/org/freedesktop/UPower/devices/DisplayDevice")

  self.device:on_properties_changed(
    function ()
      self:update()
    end
  )

  self.tooltip = awful.tooltip({ objects = { widget },})
  self.gui_client = ""

  self:update()

  self:buttons(awful.util.table.join(
                 awful.button({ }, 3,
                   function ()
                     spawn_with_shell(self.gui_client)
                   end
  )))
end

return widget
