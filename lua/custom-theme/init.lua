local M = {}
local api = vim.api
local hl = api.nvim_set_hl
local Path = require("plenary.path")
local async = require("plenary.async")
local path = vim.fn.stdpath('data') .. '/custom-theme.json'
local backUp_path = vim.fn.stdpath('data') .. '/custom-theme-backup.json'
local cmd = vim.api.nvim_create_autocmd

M.h_bufnr = nil
M.highlight_list = {}
M.backup = {}
M.theme_name = nil
function M.setup()
    --get the current theme
    M.theme = vim.g.colors_name
    M.get_theme_highlights()
    M.backup = vim.deepcopy(M.highlight_list)

    local c_hl = M.get(path)
    if c_hl then
        M.highlight_list = c_hl
        M.set_theme_highlights(path)
    else
        M.save(backUp_path, M.highlight_list)
        M.save(path, M.highlight_list)
    end

    api.nvim_create_user_command("CustomTheme", function()
        M.open_theme_color_selector()
    end, {})
    api.nvim_create_user_command("CustomThemeReset", function()
        M.reset()
    end, {})
end

function M.get(p)
    local theme = Path:new(p)
    if theme:exists() then
        return vim.fn.json_decode(theme:read())
    end
    return nil
end

function M.save(p, t)
    Path:new(p):write(vim.fn.json_encode(t), "w")
end

function M.set_theme_highlights(p)
    local hl_json = M.get(p)
    for name, colors in pairs(hl_json) do
        hl(0, name, {
            fg = colors.fg or "NONE",
            bg = colors.bg or "NONE",
        })
    end
end

function M.get_theme_highlights()
    local highlights = api.nvim_exec("highlight", true)
    local lines = vim.split(highlights, "\n")
    -- find highlight groups on current buffer
    for _, line in ipairs(lines) do
        local name = line:match("^(%w+)")
        local fg_color = line:match("guifg=(#[%x]+)")
        local bg_color = line:match("guibg=(#[%x]+)")
        if name then
            M.highlight_list[name] = {
                fg = fg_color or "NONE",
                bg = bg_color or "NONE",
            }
        end
    end
end

function M.open_theme_color_selector()
    M.current_buffer = api.nvim_get_current_buf()
    -- check current buffer highlights

    local buf = api.nvim_create_buf(false, false)
    M.h_bufnr = buf
    vim.cmd "vsplit"
    vim.cmd(string.format("buffer %d", buf))

    local file = vim.fn.json_decode(Path:new(path):read())

    local theme = file
    local lines = {}
    for name, colors in pairs(theme) do
        local fg = colors.fg or "NONE"
        local bg = colors.bg or "NONE"
        table.insert(lines, string.format("%s  fg=%s  bg=%s", name, fg, bg))
    end
    table.sort(lines, function(a, b) return a < b end)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)


    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_option(buf, "swapfile", false)
    api.nvim_buf_set_option(buf, "buflisted", false)
    api.nvim_buf_set_option(buf, "filetype", "custom_theme")
    M.set_keys()

    -- set cursor move event for highlight buffer
    local group = api.nvim_create_namespace("CustomTheme")
    vim.api.nvim_clear_autocmds { group = group, buffer = buf }

    cmd({ "CursorMoved" }, {
        buffer = buf,
        group = group,
        callback = function()
            M.set_theme_highlights(path)
            local line = api.nvim_win_get_cursor(0)[1]
            local name = api.nvim_buf_get_lines(buf, line - 1, line, false)[1]:match("^(%w+)")
            vim.cmd(string.format("hi %s guifg=#FFFFFF guibg=#ff5454", name))
        end,
    })

end

function M.set_keys()
    local keys = {
        ["<CR>"] = "set_hl",
        ["q"] = "close",
    }
    for key, cmdl in pairs(keys) do
        api.nvim_buf_set_keymap(M.h_bufnr, "n", key, string.format(":lua require('custom-theme').%s()<CR>", cmdl),
            {
                nowait = true,
                noremap = true,
                silent = true,
            })
        api.nvim_buf_set_keymap(M.h_bufnr, "i", key, string.format(":lua require('custom-theme').%s()<CR>", cmdl),
            {
                nowait = true,
                noremap = true,
                silent = true,
            })

    end
end

function M.set_hl()
    local lines = api.nvim_buf_get_lines(M.h_bufnr, 0, -1, false)
    for _, line in ipairs(lines) do
        local name = line:match("^(%w+)")
        local fg_color = line:match("fg=(#[%x]+)")
        local bg_color = line:match("bg=(#[%x]+)")
        if name then
            M.highlight_list[name] = {
                fg = fg_color or "NONE",
                bg = bg_color or "NONE",
            }
        end
    end
    M.save(path, M.highlight_list)
    M.set_theme_highlights(path)
    -- close the M.list_buffer
    local current_win = api.nvim_get_current_win()
    local current_buf = api.nvim_get_current_buf()
    api.nvim_win_close(current_win, false)
    api.nvim_buf_delete(current_buf, { force = true })
    vim.cmd("syntax sync fromstart")


end

function M.close()
    local current_win = api.nvim_get_current_win()
    local current_buf = api.nvim_get_current_buf()
    api.nvim_win_close(current_win, false)
    api.nvim_buf_delete(current_buf, { force = true })
end

function M.reset()
    local bacup = M.get(backUp_path)
    if bacup then
        M.highlight_list = bacup
        M.set_theme_highlights(backUp_path)
        M.save(path, M.highlight_list)
        vim.cmd("syntax sync fromstart")
    end
end

return M
