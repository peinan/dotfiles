local U = require("alex.utils")

local M = {}

----------------------------------------------------------------------------------------------------
--- Utils.

-- Custom mode names.
-- I want all of them to be the same length so that lualine stays constant.
local function fmt_mode(s)
    local mode_map = {
        ["COMMAND"] = "COMMND",
        ["V-BLOCK"] = "V-BLCK",
        ["TERMINAL"] = "TERMNL",
        ["V-REPLACE"] = "V-RPLC",
        ["O-PENDING"] = "0PNDNG",
    }
    return mode_map[s] or s
end

-- Theme dependant custom colors.
local C
local red
local green
local icon_hl
local text_hl

if U.is_nordic() then
    C = require("nordic.colors")
    red = C.red.base or C.red
    green = C.green.base or C.green
    icon_hl = { fg = C.gray2 }
    text_hl = { fg = C.gray2 }
else
    -- default.nvim用
    C = require("default.palette")
    red = C.red
    green = C.green
    icon_hl = { fg = C.gray2 }
    text_hl = { fg = C.gray2 }
end

local function get_virtual_text_color()
    if require("alex.native.lsp").virtual_diagnostics then
        return { fg = green }
    end
    return icon_hl
end

local function get_format_enabled_color()
    if require("alex.native.lsp").format_enabled then
        return { fg = green }
    end
    return icon_hl
end

local function get_zen_mode_color()
    if require("alex.plugins.no-neck-pain").enabled then
        return { fg = green }
    end
    return icon_hl
end

local function get_recording_color()
    if U.is_recording() then
        return { fg = red }
    else
        return { fg = text_hl }
    end
end

local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
        }
    end
end

----------------------------------------------------------------------------------------------------
--- Defaults.

local default_z = {
    {
        "location",
        icon = { "", align = "left" },
        fmt = function(str)
            local fixed_width = 5
            return string.format("%" .. fixed_width .. "s", str)
        end,
    },
    {
        "progress",
        icon = { "", align = "left" },
        separator = { right = "", left = "" },
    },
}

local default_x = {
    {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = {
            error = U.diagnostic_signs.error,
            warn = U.diagnostic_signs.warn,
            info = U.diagnostic_signs.info,
            hint = U.diagnostic_signs.hint,
            other = U.diagnostic_signs.other,
        },
        colored = true,
        padding = 2,
    },
    {
        U.current_buffer_lsp,
        padding = 1,
        color = { bg = "NONE", fg = text_hl.fg },
        icon = { " ", color = icon_hl },
    },
    {
        function()
            return ""
        end,
        color = { bg = "NONE", fg = get_virtual_text_color().fg },
        separator = { " ", "" },
    },
    {
        function()
            return " "
        end,
        color = { bg = "NONE", fg = get_zen_mode_color().fg },
        padding = 0,
    },
    {
        function()
            return "󰉼  "
        end,
        color = { bg = "NONE", fg = get_format_enabled_color().fg },
        padding = 0,
    },
}

----------------------------------------------------------------------------------------------------
--- Custom.

local oil = {
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = fmt_mode,
                icon = { "" },
                separator = { right = " ", left = "" },
            },
        },
        lualine_b = {},
        lualine_c = {
            {
                U.get_short_cwd,
                padding = 0,
                icon = { "   ", color = icon_hl },
                color = { bg = "NONE", fg = text_hl.fg },
            },
        },
        lualine_x = default_x,
        lualine_y = {},
        lualine_z = default_z,
    },
    filetypes = { "oil" },
}

local telescope = {
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = fmt_mode,
                icon = { "" },
                separator = { right = " ", left = "" },
            },
        },
        lualine_b = {},
        lualine_c = {
            {
                function()
                    return "Telescope"
                end,
                color = { bg = "NONE", fg = text_hl.fg },
                icon = { "  ", color = icon_hl },
            },
        },
        lualine_x = default_x,
        lualine_y = {},
        lualine_z = default_z,
    },
    filetypes = { "TelescopePrompt" },
}

----------------------------------------------------------------------------------------------------
--- Custom theme with transparent background for lualine_c, y, and x.

local auto_theme = require("lualine.themes.auto")
local transparent_theme = {}

-- Copy auto theme and set background to NONE for sections 'c', 'y', and 'x'
for mode, mode_data in pairs(auto_theme) do
    transparent_theme[mode] = {}
    for section, section_data in pairs(mode_data) do
        if section == "c" or section == "y" or section == "x" then
            -- Sections 'c', 'y', and 'x' have transparent background
            transparent_theme[mode][section] = {
                bg = "NONE",
                fg = section_data.fg, -- Keep original foreground color
            }
        else
            -- Other sections (a, b, z) keep original theme
            transparent_theme[mode][section] = section_data
        end
    end
end

----------------------------------------------------------------------------------------------------
--- Setup.

require("lualine").setup({
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = fmt_mode,
                icon = { "" },
                separator = { right = " ", left = "" },
            },
        },
        lualine_b = {},
        lualine_c = {
            {
                "branch",
                color = text_hl,
                icon = { " ", color = icon_hl },
                padding = 2,
            },
            {
                "diff",
                color = text_hl,
                source = diff_source,
                symbols = {
                    added = " ",
                    modified = " ",
                    removed = " ",
                },
                diff_color = {
                    added = icon_hl,
                    modified = icon_hl,
                    removed = icon_hl,
                },
                padding = 1,
            },
            {
                U.get_recording_state_icon,
                color = get_recording_color,
                padding = 1,
            },
        },
        lualine_x = default_x,
        lualine_y = {},
        lualine_z = default_z,
    },
    options = {
        theme = transparent_theme,
        disabled_filetypes = { "dashboard" },
        globalstatus = true,
        section_separators = { left = " ", right = " " },
        component_separators = { left = "", right = "" },
    },
    extensions = {
        telescope,
        oil,
    },
})

-- Ensure correct backgrond for lualine.
local id
id = vim.api.nvim_create_autocmd({ "BufWinEnter", "TermEnter", "TermOpen" }, {
    callback = function(args)
        vim.defer_fn(function()
            if vim.bo[args.buf].buftype == "terminal" then
                require("lualine").setup({})
                if id then
                    pcall(vim.api.nvim_del_autocmd, id)
                    id = nil
                end
                return
            end

            local excludes = {
                "dashboard",
                "lazy",
                "noice",
                "nofile",
                "lazy_backdrop",
                "",
            }

            if not vim.tbl_contains(excludes, vim.bo[args.buf].filetype) then
                require("lualine").setup({})
                if id then
                    pcall(vim.api.nvim_del_autocmd, id)
                    id = nil
                end
            end
        end, 50)
    end,
})

function M.refresh_statusline()
    require("lualine").refresh({ statusline = true })
end

return M
