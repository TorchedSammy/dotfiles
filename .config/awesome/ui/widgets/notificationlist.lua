local wibox = require 'wibox'
local awcommon = require 'awful.widget.common'
local abutton = require 'awful.button'
local gtable = require 'gears.table'
local gtimer = require 'gears.timer'
local beautiful = require 'beautiful'
local naughty = require 'naughty.core'
local default_widget = require 'naughty.widget._default'
local notifications = require 'modules.notifications'

local module = {}

local default_buttons = gtable.join(
    abutton({ }, 1, function(n) n:destroy() end),
    abutton({ }, 3, function(n) n:destroy() end)
)

local props = {'shape_border_color', 'bg_image' , 'fg',
               'shape_border_width', 'shape'    , 'bg',
               'icon_size'}

-- Use a cached loop instead of an large function like the taglist and tasklist
local function update_style(self)
    self._private.style_cache = self._private.style_cache or {}

    for _, state in ipairs {'normal', 'selected'} do
        local s = {}

        for _, prop in ipairs(props) do
            if self._private.style[prop..'_'..state] ~= nil then
                s[prop] = self._private.style[prop..'_'..state]
            else
                s[prop] = beautiful['notification_'..prop..'_'..state]
            end
        end

        self._private.style_cache[state] = s
    end
end

local function wb_label(notification, self)
    -- Get the title
    local title = notification.title

    local style = self._private.style_cache[notification.selected and 'selected' or 'normal']

    if notification.fg or style.fg then
        title = '<span color="' .. (notification.fg or style.fg) .. '">' .. title .. '</span>'
    end

    return title, notification.bg or style.bg, style.bg_image, notification.icon, {
        shape              = notification.shape         or style.shape,
        shape_border_width =  notification.border_width or style.shape_border_width,
        shape_border_color =  notification.border_color or style.shape_border_color,
        icon_size          =  style.icon_size,
    }
end

-- Remove some callback boilerplate from the user provided templates.
local function create_callback(w, n)
    awcommon._set_common_property(w, 'notification', n)
end

local function update(self)
    -- Checking style_cache helps to avoid useless redraw during initialization
    if not self._private.base_layout or not self._private.style_cache then return end

    awcommon.list_update(
        self._private.base_layout,
        default_buttons,
        function(o) return wb_label(o, self) end,
        self._private.data,
        notifications.all,
        {
            create_callback = create_callback,
            widget_template = self._private.widget_template or default_widget
        }
    )
end

local notificationlist = {}

function notificationlist:set_widget_template(widget_template)
    self._private.widget_template = widget_template

    -- Remove the existing instances
    self._private.data = {}

    update(self)

    self:emit_signal('widget::layout_changed')
    self:emit_signal('widget::redraw_needed')
    self:emit_signal('property::widget_template', widget_template)
end

function notificationlist:set_style(style)
    self._private.style = style or {}

    update_style(self)
    update(self)

    self:emit_signal('widget::layout_changed')
    self:emit_signal('widget::redraw_needed')
    self:emit_signal('property::style', style)
end

function notificationlist:layout(_, width, height)
    if self._private.base_layout then
        return { wibox.widget.base.place_widget_at(self._private.base_layout, 0, 0, width, height) }
    end
end

function notificationlist:fit(context, width, height)
    if not self._private.base_layout then
        return 0, 0
    end

    return wibox.widget.base.fit_widget(self, context, self._private.base_layout, width, height)
end

for _, prop in ipairs { 'filter', 'base_layout' } do
    notificationlist['set_'..prop] = function(self, value)
        self._private[prop] = value

        update(self)

        self:emit_signal('widget::layout_changed')
        self:emit_signal('widget::redraw_needed')
        self:emit_signal('property::'..prop, value)
    end

    notificationlist['get_'..prop] = function(self)
        return self._private[prop]
    end
end

local function new(_, args)
    args = args or {}

    local wdg = wibox.widget.base.make_widget(nil, nil, {
        enable_properties = true,
    })

    gtable.crush(wdg, notificationlist, true)

    wdg._private.data = {}

    gtable.crush(wdg, args)

    wdg._private.style = wdg._private.style or {}

    -- Don't do this right away since the base_layout may not have been set yet.
    -- This also avoids `update()` being executed during initialization and
    -- causing an output that isn't reproducible.
    gtimer.delayed_call(function()
        update_style(wdg)

        if not wdg._private.base_layout then
            wdg._private.base_layout = wibox.layout.flex.horizontal()
            wdg._private.base_layout:set_spacing(beautiful.notification_spacing or 0)
            wdg:emit_signal('widget::layout_changed')
            wdg:emit_signal('widget::redraw_needed')
        end

        update(wdg)

        local is_scheduled = false

        -- Prevent multiple updates due to the many signals.
        local function f()
            if is_scheduled then return end

            is_scheduled = true

            gtimer.delayed_call(function() update(wdg); is_scheduled = false end)
        end

        -- Yes, this will cause 2 updates when a new notification arrives, but
        -- on the other hand, request::display is required to auto-disable the
        -- fallback legacy mode and property::active is needed to remove the
        -- destroyed notifications.
        naughty.connect_signal('property::active', f)
        naughty.connect_signal('request::display', f)
    end)

    return wdg
end

module.filter = {}

function module.filter.all(n) -- luacheck: no unused args
    return true
end

function module.filter.most_recent(n, count)
    for i=1, count or 1 do
        if n == naughty.active[i] then
            return true
        end
    end

    return false
end

return setmetatable(module, {__call = new})
