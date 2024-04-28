local imagebox = require("wibox.widget.imagebox")
local gtable  = require("gears.table")
local beautiful = require("beautiful")
local gsurface = require("gears.surface")
local dpi = require("beautiful.xresources").apply_dpi
local notifications = require 'modules.notifications'

local icon = {}

function icon:fit(_, width, height)
    -- Until someone complains, adding a "leave blank space" isn't supported
    if not self._private.image then return 0, 0 end

    local maximum  = math.min(width, height)
    local strategy = self._private.resize_strategy or "resize"
    local optimal  = math.min(
        (
            self._private.notification[1] and self._private.notification[1].icon_size
        ) or beautiful.notification_icon_size or dpi(48),
        maximum
    )

    local w = self._private.image:get_width()
    local h = self._private.image:get_height()

    if strategy == "resize" then
        return math.min(w, optimal, maximum), math.min(h, optimal, maximum)
    else
        return optimal, optimal
    end
end

function icon:draw(_, cr, width, height)
    if not self._private.image then return end
    if width == 0 or height == 0 then return end

    -- Let's scale the image so that it fits into (width, height)
    local strategy = self._private.resize_strategy or "resize"
    local w = self._private.image:get_width()
    local h = self._private.image:get_height()
    local aspect = width / w
    local aspect_h = height / h

    if aspect > aspect_h then aspect = aspect_h end

    if aspect < 1 or (strategy == "scale" and (w < width or h < height)) then
        cr:scale(aspect, aspect)
    end

    local x, y = 0, 0

    if (strategy == "center" and aspect < 1) or strategy == "resize" then
        x = math.floor((width  - w*aspect) / 2)
        y = math.floor((height - h*aspect) / 2)
    elseif strategy == "center" and aspect > 1 then
        x = math.floor((width  - w) / 2)
        y = math.floor((height - h) / 2)
    end

    cr:set_source_surface(self._private.image, x, y)
    cr:paint()
end

function icon:set_notification(notif)
    local old = (self._private.notification or {})[1]

    if old == notif then return end

    if old then
        old:disconnect_signal("destroyed",
            self._private.icon_changed_callback)
    end

    local icn = gsurface.load_silently(notif.icon)

    if icn then
        self:set_image(icn)
    end

    self._private.notification = setmetatable({notif}, {__mode="v"})

    notif:connect_signal("property::icon", self._private.icon_changed_callback)
    self:emit_signal("property::notification", notif)
end

local valid_strategies = {
    scale  = true,
    center = true,
    resize = true,
}

function icon:set_resize_strategy(strategy)
    assert(valid_strategies[strategy], "Invalid strategy")

    self._private.resize_strategy = strategy

    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::resize_strategy", strategy)
end


function icon:get_resize_strategy()
    return self._private.resize_strategy
        or beautiful.notification_icon_resize_strategy
        or "resize"
end

local function new(args)
    args = args or {}
    local tb = imagebox()

    gtable.crush(tb, icon, true)
    tb._private.notification = {}

    function tb._private.icon_changed_callback()
        local n = tb._private.notification[1]

        if not n then return end

        local icn = gsurface.load_silently(n.image)

        if icn then
            tb:set_image(icn)
        end
    end

    if args.notification then
        tb:set_notification(args.notification)
    end

    return tb
end

return setmetatable(icon, {__call = function(_, ...) return new(...) end})
