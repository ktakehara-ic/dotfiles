local function copilot_chat(query_textobject)
  local function selection()
    local shared = require("nvim-treesitter.textobjects.shared")
    local bufnr, textobject = shared.textobject_at_point(query_textobject, "textobjects")
    ---@diagnostic disable-next-line: param-type-mismatch
    local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(textobject)
    ---@diagnostic disable-next-line: param-type-mismatch
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col + 1, {})
    local text = table.concat(lines, "\n")

    if vim.trim(text) == "" then
      return nil
    end
    return {
      lines = text,
      start_row = start_row + 1,
      start_col = start_col + 1,
      end_row = end_row + 1,
      end_col = end_col + 1,
    }
  end

  local input = vim.fn.input("CopilotChat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, {
      selection = selection,
    })
  end
end

local mappings = {
  n = {
    ["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    ["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    ["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to up split" },
    ["<C-j>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to down split" },

    ["<tab>"] = { "<cmd>tabnext<cr>", desc = "Next tab" },
    ["<S-tab>"] = { "<cmd>tabprev<cr>", desc = "Prev tab" },

    -- dial.nvim
    ["<C-a>"] = { function() require("dial.map").manipulate("increment", "normal") end, desc = "Increment number under cursor" },
    ["<C-x>"] = { function() require("dial.map").manipulate("decrement", "normal") end, desc = "Decrement number under cursor" },
    ["g<C-a>"] = { function() require("dial.map").manipulate("increment", "gnormal") end, desc = "Increment number under cursor" },
    ["g<C-x>"] = { function() require("dial.map").manipulate("decrement", "gnormal") end, desc = "Decrement number under cursor" },

    -- window management
    ["<leader>wp"] = {
      function()
        local winnr = require('window-picker'):pick_window()
        if winnr then
          vim.api.nvim_set_current_win(winnr)
        end
      end,
      desc = "Pick any window"
    },
    ["<leader>wv"] = { "<C-w>v", desc = "Separate window vertical" },
    ["<leader>ws"] = { "<C-w>s", desc = "Separate window horizontal" },
    ["<leader>ww"] = { "<cmd>w<cr>", desc = "Save current window" },
    ["<leader>wW"] = { "<cmd>wa<cr>", desc = "Save all windows" },
    ["<leader>wq"] = { "<cmd>wq<cr>", desc = "Save and quit current window" },
    ["<leader>wQ"] = { "<cmd>wq<cr>", desc = "Save and quit all windows" },
    ["<leader>wz"] = { "<C-w>_<C-w>|", desc = "Zoom current window" },
    ["<leader>w="] = { "<C-w>=", desc = "Equaly height and width" },
    ["<leader>wo"] = { "<C-w>o", desc = "Close all other window" },

    ["<leader>qq"] = { "<cmd>q<cr>", desc = "Close current window" },
    ["<leader>qQ"] = { "<cmd>qa<cr>", desc = "Quit editor" },
    ["<leader>q<c-Q>"] = { "<cmd>q!<cr>", desc = "Force quit current window" },

    -- fuzzy finder
    ["<C-s>"] = { "<cmd>Telescope symbols<cr>", desc = "Find Symbols (Emoji, Kaomoji, etc...)" },

    ["<leader>fa"] = { "<cmd>Telescope autocommands<cr>", desc = "Find autocommands" },
    ["<leader>fb"] = { "<cmd>Telescope buffers<cr>", desc = "Find buffer" },
    ["<leader>fc"] = { "<cmd>Telescope commands<cr>", desc = "Find command" },
    ["<leader>fC"] = { "<cmd>Telescope command_history<cr>", desc = "Find command in history" },
    ["<leader>fd"] = { "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Find diagnostics current buffer" },
    ["<leader>fD"] = { "<cmd>Telescope diagnostics bufnr=<cr>", desc = "Find all diagnostics" },
    ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", desc = "Find file" },
    ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", desc = "Find help tags" },
    ["<leader>fk"] = { "<cmd>Telescope keymaps<cr>", desc = "Find keymaps" },
    ["<leader>fm"] = { "<cmd>Telescope marks<cr>", desc = "Find mark" },
    ["<leader>fn"] = { "<cmd>Telescope notify<cr>", desc = "Find notifications" },
    ["<leader>fr"] = { "<cmd>Telescope registers<cr>", desc = "Find register" },
    ["<leader>fs"] = { "<cmd>Telescope symbols<cr>", desc = "Find Symbols (Emoji, Kaomoji, etc...)" },
    ["<leader>ft"] = { function() require("telescope-tabs").list_tabs() end, desc = "Find tabs" },
    ["<leader>fw"] = { "<cmd>Telescope live_grep<cr>", desc = "Find word" },
    ["<leader>fW"] = { "<cmd>Telescope current_buffer_fuzzy_find skip_empty_lines=true<cr>", desc = "Find current buffer" },
    ["<leader>fz"] = { "<cmd>ObsidianSearch<cr>", desc = "Find Zettelkasten notes" },
    ["<leader>f/"] = { "<cmd>Telescope search_history<cr>", desc = "Find search word in history" },
    ["<leader>fli"] = { "<cmd>Telescope lsp_implementations<cr>", desc = "Find implementations" },
    ["<leader>flr"] = { "<cmd>Telescope lsp_references jump_type=vsplit<cr>", desc = "Find references" },

    ["<leader>e"] = { "<cmd>Neotree<cr>", desc = "Toggle NeoTree" },

    -- LSP
    ["<leader>lm"] = { "<cmd>Mason<cr>", desc = "Open LSP package manager" },
    ["<leader>li"] = { "<cmd>LspInfo<cr>", desc = "Open LSP information" },
    ["<leader>la"] = { function() require('actions-preview').code_actions() end, desc = "LSP code action" },
    ["<leader>lf"] = { function() vim.lsp.buf.format() end, desc = "LSP format buffer" },
    ["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "LSP rename current symbol" },
    ["<leader>lh"] = { function() vim.lsp.buf.signature_help() end, desc = "LSP show signature help" },
    -- NOTE: In help, you can jump to help definition using <C-]>.
    ["K"] = { function() vim.lsp.buf.hover() end, desc = "LSP Comment" },
    ["gd"] = { function() vim.lsp.buf.definition() end, desc = "LSP Jump to defition" },
    ["gy"] = { function() vim.lsp.buf.type_definition() end, desc = "LSP Jump to defition of current type" },
    ["[d"] = {
      function()
        ---@diagnostic disable-next-line: missing-fields
        vim.diagnostic.jump({ count = -1, float = { border = "rounded" } })
      end,
      desc = "LSP Previous diagnostic"
    },
    ["]d"] = {
      function()
        ---@diagnostic disable-next-line: missing-fields
        vim.diagnostic.jump({ count = 1, float = { border = "rounded" } })
      end,
      desc = "LSP Next diagnostic"
    },

    -- Package manager (Lazy)
    ["<leader>pm"] = { "<cmd>Lazy<cr>", desc = "Open Lazy" },
    ["<leader>pc"] = { "<cmd>LazyClose<cr>", desc = "Close Lazy" },

    -- Term
    ["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "Open floating terminal" },
    ["<leader>th"] = { "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Open horizontal terminal" },
    ["<leader>tv"] = { "<cmd>ToggleTerm direction=vertical<cr>", desc = "Open vertical terminal" },
    ["<leader>tt"] = { "<cmd>ToggleTerm direction=tab<cr>", desc = "Open vertical terminal" },

    -- Source
    ["<leader>ss"] = { "<cmd>source ~/.config/nvim/init.lua<cr>", desc = "Re-sourcing init.lua" },
    ["<leader>sp"] = { "<cmd>source %<cr>", desc = "Re-sourcing current file" },

    -- Git
    ["<leader>gg"] = { "<cmd>Neogit<cr>", desc = "Open Neogit" },
    ["<leader>gb"] = { function() require("gitsigns").toggle_current_line_blame() end, desc = "View git blame" },
    ["<leader>gd"] = { function() require("gitsigns").diffthis() end, desc = "View git diff" },
    ["<leader>g]"] = { function() require("gitsigns").nav_hunk("next", { preview = true }) end, desc = "Next git hunk" },
    ["<leader>g["] = { function() require("gitsigns").nav_hunk("prev", { preview = true }) end, desc = "Previous git hunk" },
    ["<leader>gK"] = { function() require("gitsigns").preview_hunk() end, desc = "Preview current line's git diff" },

    -- Hop
    ["<leader>h"] = { "<cmd>HopChar1<cr>", desc = "Hop to char 1" },

    -- Comment Out
    ["<leader>//"] = {
      function()
        return vim.v.count == 0
            and "<plug>(comment_toggle_linewise_current)"
            or "<plug>(comment_toggle_linewise_count)"
      end,
      desc = "Toggle comment linewise",
      expr = true,
    },
    ["<leader>/*"] = {
      function()
        return vim.v.count == 0
            and "<plug>(comment_toggle_blockwise_current)"
            or "<plug>(comment_toggle_blockwise_count)"
      end,
      desc = "Toggle comment blockwise",
      expr = true,
    },

    -- Zettelkasten
    ["<leader>zn"] = { "<cmd>ObsidianNew<cr>", desc = "New Note" },
    ["<leader>zf"] = { "<cmd>ObsidianNew<cr>fleeting/", desc = "New Fleeting Note" },
    ["<leader>zp"] = { "<cmd>ObsidianNew<cr>permanent/", desc = "New Permanent Note" },
    ["<leader>zl"] = { "<cmd>ObsidianNew<cr>literature/", desc = "New Permanent Note" },
    ["<leader>zt"] = { "<cmd>ObsidianTags<cr>", desc = "Search Tags" },
    ["<leader>zd"] = { "o<cr>---<cr><cr><esc>", desc = "Insert Divider" },

    -- fold
    ["zR"] = { function() require("ufo").openAllFolds() end, desc = "Open all folds" },
    ["zM"] = { function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
    ["zp"] = { function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    ["zw"] = { function() vim.wo.wrap = not vim.wo.wrap end, desc = "Toggle wrap" },

    -- Copilot Chat
    ["<leader>cc"] = { "<cmd>CopilotChat<cr>", desc = "Open CopilotChat" },
    ["<leader>ct"] = { "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat Window" },
    ["<leader>cB"] = {
      function()
        local input = vim.fn.input("CopilotChat: ")
        if input ~= "" then
          require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
        end
      end,
      desc = "CopilotChat - Chat with current buffer"
    },
    ["<leader>cif"] = { function() copilot_chat("@function.inner") end, desc = "CopilotChat - Chat about inner function" },
    ["<leader>caf"] = { function() copilot_chat("@function.outer") end, desc = "CopilotChat - Chat about outer function" },
    ["<leader>cib"] = { function() copilot_chat("@block.inner") end, desc = "CopilotChat - Chat about inner block" },
    ["<leader>cab"] = { function() copilot_chat("@block.outer") end, desc = "CopilotChat - Chat about outer block" },
    ["<leader>cil"] = { function() copilot_chat("@loop.inner") end, desc = "CopilotChat - Chat about inner loop" },
    ["<leader>cal"] = { function() copilot_chat("@loop.outer") end, desc = "CopilotChat - Chat about outer loop" },
    ["<leader>cr"] = { "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Reset chat history and clear buffer" },
    ["<leader>cfp"] = {
      function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end,
      desc = "CopilotChat - Prompt actions",
    },

    -- Neotest
    ["<leader>nr"] = { "<cmd>Neotest run<cr>", desc = "Run tests" },
    ["<leader>no"] = { "<cmd>Neotest output-panel<cr>", desc = "View tests outputs" },
    ["<leader>nt"] = { "<cmd>Neotest summary<cr>", desc = "View test tree" },

    -- Notify
    ["cn"] = { function() require('notify').dismiss() end, desc = "Close notifications" },

    -- Navbuddy
    ["<leader>o"] = { "<cmd>Navbuddy<cr>", desc = "Open outline navigation" },

    ["Z"] = { "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
  },
  x = {
    -- Comment out
    ["<leader>//"] = { "<plug>(comment_toggle_linewise_visual)", desc = "Toggle comment linewise" },
    ["<leader>/*"] = { "<plug>(comment_toggle_blockwise_visual)", desc = "Toggle comment blockwise" },
    -- move lines
    ["K"] = { ":move '<-2<CR>gv-gv", desc = "Move lines of code down" },
    ["J"] = { ":move '>+1<CR>gv-gv", desc = "Move lines of code up" },

    -- increment/decrement
    ["<C-a>"] = { function() require("dial.map").manipulate("increment", "visual") end, desc = "Increment number under cursor" },
    ["<C-x>"] = { function() require("dial.map").manipulate("decrement", "visual") end, desc = "Decrement number under cursor" },
    ["g<C-a>"] = { function() require("dial.map").manipulate("increment", "gvisual") end, desc = "Increment number under cursor" },
    ["g<C-x>"] = { function() require("dial.map").manipulate("decrement", "gvisual") end, desc = "Decrement number under cursor" },

    -- copilot chat
    ["<leader>c"] = { [[:CopilotChat]], desc = "CopilotChat - Chat about selected contents" },
  },
  t = {
    ["<C-h>"] = { [[<cmd>wincmd h<cr>]], desc = "Move to left split" },
    ["<C-l>"] = { [[<cmd>wincmd l<cr>]], desc = "Move to right split" },
    ["<C-k>"] = { [[<cmd>wincmd k<cr>]], desc = "Move to up split" },
    ["<C-j>"] = { [[<cmd>wincmd j<cr>]], desc = "Move to down split" },
    ["<C-\\><C-\\>"] = { [[<C-\><C-n>]], desc = "Escape" },
    ["<C-\\>q"] = { [[<C-\><C-n><C-w>q]], desc = "Escape and quite" },
  },
  i = {
    ["<C-s>"] = { "<cmd>Telescope symbols<cr>", desc = "Find Symbols (Emoji, Kaomoji, etc...)" },
  },
}


-- register sections
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
  local icons = require("icons")
  wk.add({
    { "<leader>c", group = "Copilot Chat", icon = icons.Copilot },
    { "<leader>f", group = "Fuzzy Finder" },
    { "<leader>fl", group = "LSP", icon = icons.Search },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Hop", icon = "󰑣" },
    { "<leader>l", group = "LSP", icon = icons.Search },
    { "<leader>n", group = "Neotest" },
    { "<leader>o", group = "Outline", icon = "" },
    { "<leader>p", group = "Package Manager", icon = icons.Package },
    { "<leader>q", group = "Quit", icon = icons.Window },
    { "<leader>s", group = "Resourcing configurations", icon = "󰑓" },
    { "<leader>t", group = "Terminal" },
    { "<leader>w", group = "Window" },
    { "<leader>z", group = "Zettelkasten", icon = "󰎚" },
    { "<leader>/", group = "Comment Out", icon = "" },
  })
end

for mode, mappings_in_mode in pairs(mappings) do
  for key, opts in pairs(mappings_in_mode) do
    local rhs = opts[1]
    opts[1] = nil
    vim.keymap.set(mode, key, rhs, opts)
  end
end
