local Window = require('mochi.ui.window')

-- Window.open({
--     name = 'test',
--     pos = 'cursor',
--     title = false,
--     border = true,
-- })
--
-- Window.open({
--     name = 'test2',
--     pos = 'center',
--     title = true,
--     border = false,
--     parent_win = 'test',
-- })

vim.keymap.set({ 'n', 'v' }, '<RightMouse>', function()
    vim.cmd.exec('"normal! \\<RightMouse>"')

    Window.open({
        name = 'mouse-test',
        pos = 'mouse',
        title = false,
        border = true,
    })
end)
