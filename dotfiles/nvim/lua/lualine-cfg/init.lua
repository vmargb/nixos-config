--[[
straight


-- slanted
left = '', right = '' },

-- bubbles
left = '', right = '' 
{ left = '', right = '' }

-- arrows
component_separators = { left = '', right = '' },
section_separators = { left = '', right = '' },

default = { left = "", right = "" },
round = { left = "", right = "" },
block = { left = "█", right = "█" },
arrow = { left = "", right = "" },
},
minimal = {
default = { left = "█", right = "█" },
round = { left = "", right = "" },
block = { left = "█", right = "█" },
arrow = { left = "█", right = "█" },
},
vscode = {
default = { left = "█", right = "█" },
round = { left = "", right = "" },
block = { left = "█", right = "█" },
arrow = { left = "", right = "" },
},
vscode_colored = {
default = { left = "█", right = "█" },
round = { left = "", right = "" },
block = { left = "█", right = "█" },
arrow = { left = "", right = "" },

]]

local mode_map = {
  ["NORMAL"] = "NOR",
  ["O-PENDING"] = "N?",
  ["INSERT"] = "INS",
  ["VISUAL"] = "VIS",
  ["V-BLOCK"] = "VB",
  ["V-LINE"] = "VL",
  ["V-REPLACE"] = "VR",
  ["REPLACE"] = "REP",
  ["COMMAND"] = "!",
  ["SHELL"] = "SH",
  ["TERMINAL"] = "TERM",
  ["EX"] = "EX",
  ["S-BLOCK"] = "SB",
  ["S-LINE"] = "SL",
  ["SELECT"] = "S",
  ["CONFIRM"] = "Y?",
  ["MORE"] = "M",
}

local arrow = require('arrow.statusline')
--[[
statusline.is_on_arrow_file() -- return nil if current file is not on arrow.  Return the index if it is.
statusline.text_for_statusline() -- return the text to be shown in the statusline (the index if is on arrow or "" if not)
statusline.text_for_statusline_with_icons() -- Same, but with an bow and arrow icon ;D
]]

require('lualine').setup {
  options = {
    theme = 'auto',
    component_separators = { "|" },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      {
        -- , separator = { right = '' },
        'mode',
        fmt = function(s)
          return mode_map[s] or s
        end,
      },
    },
    lualine_b = {
        function()
            return arrow.text_for_statusline_with_icons()
        end,
        'filename', 'branch',
    },
    lualine_c = {
        --'%=', -- make the indicator center
        function()
            return vim.fn["codeium#GetStatusString"]()
        end
    },
    lualine_x = {
        --'%=', -- make the indicator center
    },
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', left_padding = 2 },
      --{ 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  -- tabline = {
  --   lualine_a = {},
  --   lualine_b = {'branch'},
  --   lualine_c = {'filename'},
  --   lualine_x = {},
  --   lualine_y = {},
  --   lualine_z = {}
  -- },
  extensions = {},
}
