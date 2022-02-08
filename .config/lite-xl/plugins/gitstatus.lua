-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local DocView = require 'core.docview'
local StatusView = require "core.statusview"
local TreeView = require "plugins.treeview"

local scan_rate = config.project_scan_rate or 5
local cached_color_for_item = {}

function TreeView:draw_item_text(item, active, hovered, x, y, w, h)
  local item_text, item_font, item_color = self:get_item_text(item, active, hovered)
  item_color = cached_color_for_item[item.abs_filename] or item_color
  common.draw_text(item_font, item_color, item_text, nil, x, y, 0, h)
end



local git = {
  branch = nil,
  inserts = 0,
  deletes = 0,
}

config.gitstatus = {
  recurse_submodules = true
}
style.gitstatus_addition = style.gitstatus_addition or {common.color "#587c0c"}
style.gitstatus_modification = style.gitstatus_modification or {common.color "#0c7d9d"}
style.gitstatus_deletion = style.gitstatus_deletion or {common.color "#94151b"}

style.gitstatus_diff_normal = style.gitstatus_diff_normal or style.text
style.gitstatus_diff_addition = style.gitstatus_diff_addition or style.gitstatus_addition
style.gitstatus_diff_modification = style.gitstatus_diff_modification or style.gitstatus_modification
style.gitstatus_diff_deletion = style.gitstatus_diff_deletion or style.gitstatus_deletion

local function exec(cmd)
  local proc = process.start(cmd)
  while proc:running() do
    coroutine.yield(0.1)
  end
  return proc:read_stdout() or ""
end


core.add_thread(function()
  while true do
    if system.get_file_info(".git") then
      -- get branch name
      git.branch = exec({"git", "rev-parse", "--abbrev-ref", "HEAD"}):match("[^\n]*")

      local inserts = 0
      local deletes = 0

      -- get diff
      local diff = exec({"git", "diff", "--numstat"})
      if config.gitstatus.recurse_submodules and system.get_file_info(".gitmodules") then
        local diff2 = exec({"git", "submodule", "foreach", "git diff --numstat"})
        diff = diff .. diff2
      end

      -- forget the old state
      cached_color_for_item = {}

      local folder = core.project_dir
      for line in string.gmatch(diff, "[^\n]+") do
        local submodule = line:match("^Entering '(.+)'$")
        if submodule then
          folder = core.project_dir .. PATHSEP .. submodule
        else
          local ins, dels, path = line:match("(%d+)%s+(%d+)%s+(.+)")
          if path then
            local abs_path = folder .. PATHSEP .. path
            local av = core.active_view
            if getmetatable(av) == DocView and abs_path == av.doc.abs_filename then
              core.log_quiet('current')
              inserts = inserts + (tonumber(ins) or 0)
              deletes = deletes + (tonumber(dels) or 0)
            end
            -- Color this file, and each parent folder,
            -- so you can see at a glance which folders
            -- have modified files in them.
            while abs_path do
              cached_color_for_item[abs_path] = style.gitstatus_modification
              abs_path = common.dirname(abs_path)
            end
          end
        end
      end

      git.inserts = inserts
      git.deletes = deletes

    else
      git.branch = nil
    end

    coroutine.yield(scan_rate)
  end
end)


local get_items = StatusView.get_items

function StatusView:get_items()
  if not git.branch then
    return get_items(self)
  end
  local left, right = get_items(self)

  local t = {
    style.dim, self.separator2,
    style.text, git.branch,
    style.dim, "  ",
    git.inserts ~= 0 and style.gitstatus_diff_addition or style.gitstatus_diff_normal, "+", git.inserts,
    style.dim, " / ",
    git.deletes ~= 0 and style.gitstatus_diff_deletion or style.gitstatus_diff_normal, "-", git.deletes,
  }
  for _, item in ipairs(t) do
    table.insert(right, item)
  end

  return left, right
end

