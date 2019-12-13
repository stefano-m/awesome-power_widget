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

local math = math
local string = string

local function to_hour_min_str(seconds)
  local hours = math.floor(seconds/3600)
  local minutes = math.ceil( (seconds % 3600) / 60)
  return string.format("%02dh:%02dm", hours, minutes)
end

local icon_size = 64
local icon_flags = {IconLookupFlags.GENERIC_FALLBACK}
local notification = nil

local widget = wibox.widget {
  resize = true,
  widget = wibox.widget.imagebox
}

widget.critical_percentage = 5

local function _get_percentage(widget)
  local percentage = widget.device.Percentage

  if percentage then
    return math.floor(percentage)
  end

  return 0
end

function widget:_update_icon()
  local icon = icon_theme:lookup_icon(
    self.device.IconName,
    icon_size,
    icon_flags
  )

  if icon then
    self.image = icon:load_surface()
  end
end

function widget:_maybe_warn(warning_condition, notification_preset)
  local warning_level = self.device.warninglevel or "None"
  local percentage = _get_percentage(self)

  if warning_condition then
    local msg = (warning_level.name == "None" and "Low" or warning_level.name) .. " battery!"

    if notification then
      naughty.destroy(
        notification,
        naughty.notificationClosedReason.dismissedByCommand
      )
    end

    notification = naughty.notify({
        preset = notification_preset,
        title = msg,
        text = percentage .. "% remaining"})
  end
end

function widget:_update_tooltip()
  if self.device.IsPresent then
    local percentage = _get_percentage(self)
    local charge_status_msg = ""
    local what
    local when
    if self.device.type == power.enums.DeviceType.Battery then
      if self.device.TimeToEmpty > 0 then
        what = "Emtpy"
        when = self.device.TimeToEmpty
      elseif self.device.TimeToFull > 0 then
        what = "Full"
        when = self.device.TimeToFull
      end
      if when then
        charge_status_msg = string.format("\n%s in %s", what, to_hour_min_str(when))
      end
    end

    self.tooltip:set_text(
      string.format(
        "%d%% - %s%s",
        percentage,
        self.device.state.name,
        charge_status_msg
      )
    )
  else
    -- We don't know how we're powered, but we must be somehow!
    self.tooltip:set_text("Plugged In")
  end

end

local function _should_warn_critical(widget)
  if not widget.device.IsPresent then
    return false
  end

  local percentage = _get_percentage(widget)

  return (
    widget.device.state == power.enums.BatteryState.Discharging and
      (
        percentage <= widget.critical_percentage
          or widget.device.warninglevel == WarningLevel.Low
          or widget.device.warninglevel == WarningLevel.Critical
      )
  )
end

function widget:update()
  self.device:update_mappings()
  self:_update_icon()
  self:_update_tooltip()

  self:_maybe_warn(
    _should_warn_critical(self),
    naughty.config.presets.critical
  )
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
  self.gui_client = nil

  self:update()

  self:buttons(awful.util.table.join(
                 awful.button({ }, 3,
                   function ()
                     if self.gui_client then
                       spawn_with_shell(self.gui_client)
                     end
                   end
  )))
  return self
end

return widget:init()
