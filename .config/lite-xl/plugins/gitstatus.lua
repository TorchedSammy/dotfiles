-- mod-version:3
local core = require 'core'
local common = require 'core.common'
local config = require 'core.config'
local style = require 'core.style'
local DocView = require 'core.docview'
local StatusView = require 'core.statusview'
local TreeView = require 'plugins.treeview'
local gitdiff = require 'plugins.gitdiff_highlight.gitdiff'
config.plugins.gitstatus = common.merge({
  recurse_submodules = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Git Status",
    {
      label = "Recurse Submodules",
      description = "Also retrieve git stats from submodules.",
      path = "recurse_submodules",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.gitstatus)

local scan_rate = config.project_scan_rate or 5
local cached_color_for_item = {}

local git = {
  branch = nil,
  inserts = 0,
  deletes = 0,
  modifications = 0,
}
local av = nil

style.gitstatus_addition = style.gitstatus_addition or {common.color '#587c0c'}
style.gitstatus_modification = style.gitstatus_modification or {common.color '#0c7d9d'}
style.gitstatus_deletion = style.gitstatus_deletion or {common.color '#94151b'}

style.gitstatus_diff_normal = style.gitstatus_diff_normal or style.text
style.gitstatus_diff_addition = style.gitstatus_diff_addition or style.gitstatus_addition
style.gitstatus_diff_modification = style.gitstatus_diff_modification or style.gitstatus_modification
style.gitstatus_diff_deletion = style.gitstatus_diff_deletion or style.gitstatus_deletion

local function exec(cmd)
  local proc = process.start(cmd)
  while proc:running() do
    coroutine.yield(0.1)
  end
  return proc:read_stdout() or ''
end

local function update_diff(abs_path)
  local ins, dels, mods = 0, 0, 0
  local diff = exec {'git', 'diff', 'HEAD', '--word-diff', '--unified=1', '--no-color', abs_path}
  local parsed_diff = gitdiff.changed_lines(diff)
  for k, _ in pairs(parsed_diff) do
    local typ = parsed_diff[k]
    if typ == 'modification' then mods = mods + 1 end
    if typ == 'addition' then ins = ins + 1 end
    if typ == 'deletion' then dels = dels + 1 end
  end

  git.inserts = ins
  git.deletes = dels
  git.modifications = mods
end

core.add_thread(function()
  while true do
    if system.get_file_info('.git') then
      -- get branch name
      git.branch = exec({'git', 'rev-parse', '--abbrev-ref', 'HEAD'}):match('[^\n]*')

      -- get diff
      local diff = exec({'git', 'diff', '--numstat'})
      if config.plugins.gitstatus.recurse_submodules and system.get_file_info('.gitmodules') then
        local diff2 = exec({'git', 'submodule', 'foreach', 'git diff --numstat'})
        diff = diff .. diff2
      end

      -- forget the old state
      cached_color_for_item = {}

      local folder = core.project_dir
      for line in string.gmatch(diff, '[^\n]+') do
        local submodule = line:match('^Entering \'(.+)\'$')
        if submodule then
          folder = core.project_dir .. PATHSEP .. submodule
        else
          local _, _, path = line:match('(%d+)%s+(%d+)%s+(.+)')
          if path then
            local abs_path = folder .. PATHSEP .. path
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
    else
      git.branch = nil
    end

    if av then
      update_diff(av.doc.abs_filename)
    end

    coroutine.yield(scan_rate)
  end
end)

local old_set_active_view = core.set_active_view

function core.set_active_view(view)
  if getmetatable(view) == DocView and view ~= av then
    core.add_thread(function()
      av = view
      update_diff(view.doc.abs_filename)
    end)
  end
  old_set_active_view(view)
end

core.status_view:add_item {
  predicate = function()
    return core.active_view:is(DocView)
  end,
  name = 'gitstatus:status',
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    if not git.branch then return {} end

    return {
      style.text, git.branch,
      style.dim, '  ',
      git.modifications ~= 0 and style.gitstatus_diff_modification or style.gitstatus_diff_normal, '~', git.modifications,
      style.dim, '  /  ',
      git.inserts ~= 0 and style.gitstatus_diff_addition or style.gitstatus_diff_normal, '+', git.inserts,
      style.dim, '  /  ',
      git.deletes ~= 0 and style.gitstatus_diff_deletion or style.gitstatus_diff_normal, '-', git.deletes,
    }
  end,
  position = 1
}

function TreeView:draw_item_text(item, active, hovered, x, y, w, h)
  local item_text, item_font, item_color = self:get_item_text(item, active, hovered)
  item_color = cached_color_for_item[item.abs_filename] or item_color
  common.draw_text(item_font, item_color, item_text, nil, x, y, 0, h)
end
