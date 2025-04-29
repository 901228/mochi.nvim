local Window = require('mochi.ui.window')

-- Window.open({
--     name = 'test0',
--     pos = 'mouse',
--     title = false,
--     border = 'double',
-- })

Window.open({
    name = 'test',
    pos = 'cursor',
    title = false,
    border = 'medium',
})

Window.open({
    name = 'test2',
    pos = 'center',
    title = true,
    border = 'black',
    parent_win = 'test',
})

vim.keymap.set({ 'n', 'v' }, '<RightMouse>', function()
    vim.cmd.exec('"normal! \\<RightMouse>"')

    Window.open({
        name = 'mouse-test',
        pos = 'mouse',
        title = false,
        border = 'none',
    })
end)

