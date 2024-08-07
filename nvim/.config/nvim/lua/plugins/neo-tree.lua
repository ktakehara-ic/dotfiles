local icons = require("icons")

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    {
      's1n7ax/nvim-window-picker',
      name = 'window-picker',
      event = 'VeryLazy',
      version = '2.*',
      opts = {
        hint = 'floating-big-letter',
        filter_rules = {
          autoselect_one = false,
          include_current_win = false,
          bo = {
            filetype = { 'NvimTree', 'neo-tree', 'notify' },
            buftype = { 'terminal' },
          },
        },
        --- @param window_ids table<any, integer>
        filter_func = function(window_ids, filters)
          return vim.tbl_filter(function(win_id)
            local bufnr = vim.api.nvim_win_get_buf(win_id)
            if not filters.include_current_win and vim.api.nvim_get_current_win() == win_id then return false end
            -- filter windows by filetype
            if vim.tbl_contains(filters.bo.filetype, vim.bo[bufnr].filetype) then return false end
            -- filter windows by buftype
            if vim.tbl_contains(filters.bo.buftype, vim.bo[bufnr].buftype) then return false end
            -- other than 'nofile' buffer, return true
            if vim.bo[bufnr].buftype ~= 'nofile' then return true end

            return vim.tbl_contains({}, vim.bo[bufnr].filetype)
          end, window_ids)
        end,
      },
    },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      event_handlers = {
        {
          event = "neo_tree_popup_input_ready",
          handler = function(_) vim.cmd("stopinsert") end,
        },
      },
      sources = { "document_symbols", "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "trouble", "qf", "edgy" }, -- when opening files, do not use windows containing these filetypes or buftypes
      sort_case_insensitive = false,                                             -- used when sorting files and directories in the tree
      default_component_configs = {
        container = {
          enable_character_fade = true
        },
        diagnostics = {
          symbols = {
            error = icons.DiagnosticError .. " ",
            warn = icons.DiagnosticWarn .. " ",
            info = icons.DiagnosticInfo .. " ",
            hint = icons.DiagnosticHint .. " ",
          },
          highlights = {
            hint = "DiagnosticSignHint",
            info = "DiagnosticSignInfo",
            warn = "DiagnosticSignWarn",
            error = "DiagnosticSignError",
          },
        },
        indent = {
          indent_size = 2,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "╰",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = icons.FoldClosed,
          expander_expanded = icons.FoldOpened,
          expander_highlight = "NeoTreeExpander",
        },
        modified = {
          symbol = icons.FileModified,
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            -- Change type
            added     = icons.GitAdd,     -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified  = icons.GitChange,  -- or "", but this is redundant info if you use git_status_colors on the name
            deleted   = icons.GitDelete,  -- this can only be used in the git_status source
            renamed   = icons.GitRenamed, -- this can only be used in the git_status source
            -- Status type
            untracked = icons.GitUntracked,
            ignored   = icons.GitIgnored,
            unstaged  = icons.GitUnstaged,
            staged    = icons.GitStaged,
            conflict  = icons.GitConflict,
          }
        },
      },
      -- A list of functions, each representing a global custom command
      -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
      -- see `:h neo-tree-custom-commands-global`
      commands = {},
      window = {
        position = "float",
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["Y"] = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local m = vim.fn.fnamemodify
            local results = {
              filepath,          -- abs
              m(filepath, ':.'), -- rel to cwd
              m(filepath, ':~'), -- rel to home
              m(filepath, ':t'), -- filename only
              m(filepath, ':r'), -- filename without extension
              m(filepath, ':e'), -- extension only
            }
            vim.ui.select(results, { prompt = 'Choose to copy to clipboard' },
              function(selected)
                if not selected then return end
                vim.fn.setreg('"', selected)
                vim.fn.setreg('+', selected)
                vim.fn.setreg('*', selected)
                vim.notify('copied to clipboard: ' .. selected)
              end)
          end,
        },
      },
      filesystem = {
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_by_name = {
            --"node_modules"
            ".git",
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",
        --    netrw disabled, opening a directory opens within the
        --   window like netrw would, regardless of window.position
        -- "disabled",
        --    netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
        window = {},

        commands = {}, -- Add a custom command or override a global one using the same function name
      },
      buffers = {
        follow_current_file = {
          enabled = true,          -- This will find and focus the file in the active buffer every time
          --        -- the current file is changed while the tree is open.
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = true,   -- when true, empty folders will be grouped together
        show_unloaded = true,
        window = {},
      },
      git_status = {
        window = {
          position = "float",
        },
      },
      document_symbols = {
        window = {
          position = "left",
        },
      },
    })
  end
}
