local M = {}
local Layout = require('mochi.ui.layout')
local state = require('mochi.ui.state')

---@alias mochi.ui.window.opts.pos
---| 'mouse' # mouse position
---| 'cursor' # cursor position
---| 'win' # window position
---| 'center' # center of screen

---@alias mochi.ui.window.opts.border
---| 'single'
---| 'double'
---| 'rounded'
---| 'medium'
---| 'black'
---| 'none'

---@class mochi.ui.window.opts
---@field name string
---@field pos mochi.ui.window.opts.pos
---@field relative_win? integer
---@field title boolean
---@field border mochi.ui.window.opts.border
---@field parent_win? string

---@param opts vim.api.keyset.win_config
---@param size { width: integer, height: integer }
---@param pos mochi.ui.window.opts.pos
---@param win integer if pos is 'win', `win` is the window to use
local function calculate_win_pos(opts, size, pos, win)
    if pos == 'mouse' then
        opts.relative = 'mouse'
        opts.row = 1
        opts.col = 0
    elseif pos == 'cursor' then
        opts.relative = 'cursor'
        opts.row = 1
        opts.col = 0
    elseif pos == 'win' then
        opts.relative = 'win'
        opts.win = win
        opts.row = 1
        opts.col = 0
    elseif pos == 'center' then
        opts.relative = 'editor'
        opts.row = math.floor((vim.o.lines - size.height - 1) / 2)
        opts.col = math.floor((vim.o.columns - size.width) / 2)
    end
    return opts
end

---@param opts mochi.ui.window.opts
function M.open(opts)
    -- check if window already exists
    if state[opts.name] ~= nil then
        if vim.api.nvim_win_is_valid(state[opts.name].win) and vim.api.nvim_buf_is_valid(state[opts.name].buf) then
            vim.api.nvim_set_current_win(state[opts.name].win)
            return
        else
            state[opts.name] = nil
        end
    end

    -- create buffer
    state[opts.name] = {} ---@diagnostic disable-line: missing-fields
    state[opts.name].buf = vim.api.nvim_create_buf(false, true)

    -- TODO: add components

    -- layout
    local layout_opts = Layout.layout()
    state[opts.name].width = layout_opts.width
    state[opts.name].height = layout_opts.height

    -- setup window options
    ---@type vim.api.keyset.win_config
    local win_opts = {
        width = layout_opts.width,
        height = layout_opts.height,
        style = 'minimal',
        zindex = 99 + state[opts.name].buf,
    }
    win_opts = calculate_win_pos(win_opts, state[opts.name], opts.pos, opts.relative_win)
    if opts.title then
        win_opts.title = opts.name
        win_opts.title_pos = 'center'
    end

    local winhl = 'Normal:Normal,FloatBorder:LineNr'
    if opts.border == 'medium' then
        win_opts.border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' }
    elseif opts.border == 'black' then
        win_opts.border = { '▄', '▄', '▄', '█', '▀', '▀', '▀', '█' }
    elseif opts.border == 'single' then
        win_opts.border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' }
    elseif opts.border == 'double' then
        win_opts.border = { '╔', '═', '╗', '║', '╝', '═', '╚', '║' }
    elseif opts.border == 'rounded' then
        win_opts.border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
    elseif opts.border == 'none' then
        winhl = 'Normal:Normal'
    end

    -- create window
    state[opts.name].win = vim.api.nvim_open_win(state[opts.name].buf, true, win_opts)
    vim.wo[state[opts.name].win].winhl = winhl
    vim.bo[state[opts.name].buf].filetype = opts.name

    -- setup key mappings
    local close_func = function() M.close(opts.name) end
    vim.keymap.set('n', 'q', close_func, { buffer = state[opts.name].buf })
    vim.keymap.set('n', '<ESC>', close_func, { buffer = state[opts.name].buf })
end

---@param win_name string
function M.close(win_name)
    local win = state[win_name].win
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end

    local buf = state[win_name].buf
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end

    local parent_win = state[state[win_name].parent_win]
    if parent_win ~= nil and vim.api.nvim_win_is_valid(parent_win.win) then
        vim.api.nvim_set_current_win(parent_win.win)
    end

    state[win_name] = nil
end

return M
