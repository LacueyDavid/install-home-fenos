{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    performance = {
      byteCompileLua.enable = true;
      combinePlugins.enable = false;
    };

    extraPlugins = with pkgs.vimPlugins; [
      codecompanion-nvim
      nui-nvim
    ];

    extraConfigVim = ''
      set autowrite
      set nobackup
      set noswapfile
      set updatetime=500

      set scrolloff=10
      set showmode
      set showcmd
      set relativenumber
      set number
      set laststatus=3
      set wildmenu
      set wildmode=longest:full,list:full
      set visualbell
      set colorcolumn=+1
      set list
      set mouse=a
      set showmatch
      set wrap
      set textwidth=79
      set completeopt=longest,menuone,noselect
      set cursorline
      set splitright
      set splitbelow

      set ignorecase
      set smartcase
      set incsearch
      set hlsearch

      set tabstop=2
      set shiftwidth=2
      set shiftround
      set softtabstop=-1
      set expandtab
      set smarttab
      set autoindent

      set clipboard=unnamedplus
      set termguicolors
      set listchars=tab:>-,trail:.
      set cmdheight=0
      set signcolumn=yes
    '';

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
      };
    };

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      gitsigns.enable = true;
      comment.enable = true;
      nvim-surround.enable = true;
      fidget.enable = true;
      telescope.enable = true;
      fzf-lua.enable = true;
      oil.enable = true;
      flash.enable = true;
      noice.enable = true;
      diffview.enable = true;
      fugitive.enable = true;
      nvim-tree.enable = true;
      indent-blankline.enable = true;
      nvim-colorizer.enable = true;
      nvim-bqf.enable = true;
      auto-session = {
        enable = true;
        settings.auto_save = false;
      };
      render-markdown.enable = true;
      copilot-chat.enable = true;

      treesitter = {
        enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c
          cpp
          css
          dockerfile
          html
          javascript
          json
          lua
          markdown
          markdown_inline
          nix
          python
          query
          regex
          rust
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
        ];
        highlight.enable = true;
        indent.enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          clangd.enable = true;
          clojure_lsp.enable = true;
          cssls.enable = true;
          dockerls.enable = true;
          elixirls.enable = true;
          eslint.enable = true;
          html.enable = true;
          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
          nixd.enable = true;
          pyright.enable = true;
          ruff.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          ts_ls.enable = true;
          vimls.enable = true;
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            enable = false;
            timeout_ms = 500;
          };
          formatters_by_ft = {
            css = [ "prettier" ];
            django = [ "djlint" ];
            htmldjango = [ "djlint" ];
            html = [ "djlint" ];
            javascriptreact = [ "prettier" ];
            json = [ "prettier" ];
            lua = [ "stylua" ];
            markdown = [ "prettier" ];
            nix = [ "alejandra" ];
            javascript = [ "prettier" ];
            python = [ "black" "isort" ];
            sass = [ "prettier" ];
            scss = [ "prettier" ];
            sh = [ "shfmt" ];
            typescript = [ "prettier" ];
            typescriptreact = [ "prettier" ];
            yaml = [ "prettier" ];
            rust = [ "rustfmt" ];
          };
          formatters = {
            djlint = {
              command = "djlint";
              args = [ "--reformat" "-" "--indent" "2" ];
            };
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sorting = {
            comparators = [
              ''
                function(entry1, entry2)
                  local kind1 = entry1:get_kind()
                  local kind2 = entry2:get_kind()
                  local kinds = {
                    [12] = 1,
                    [3] = 2,
                    [6] = 3,
                  }
                  local priority1 = kinds[kind1] or 100
                  local priority2 = kinds[kind2] or 100
                  if priority1 ~= priority2 then
                    return priority1 < priority2
                  end
                end
              ''
              ''require("cmp.config.compare").offset''
              ''require("cmp.config.compare").exact''
              ''require("cmp.config.compare").score''
              ''require("cmp.config.compare").recently_used''
              ''require("cmp.config.compare").kind''
              ''require("cmp.config.compare").length''
              ''require("cmp.config.compare").order''
            ];
          };

          completion.completeopt = "menu,menuone,noinsert";
          completion.autocomplete = false;
          experimental.ghost_text = true;

          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 30;
          };

          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';

          formatting.fields = [ "abbr" "kind" "menu" ];

          mapping = {
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-e>" = "cmp.mapping.abort()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-j>" = ''
              cmp.mapping(function()
                if not cmp.visible() then
                  cmp.complete()
                else
                  cmp.select_next_item()
                end
              end, {'i', 's'})
            '';
          };

          sources = [
            {
              name = "nvim_lsp";
              entry_filter = ''
                function(entry, ctx)
                  return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
                end
              '';
            }
            { name = "emoji"; }
            {
              name = "buffer";
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              keywordLength = 3;
            }
            {
              name = "path";
              keywordLength = 3;
            }
            {
              name = "luasnip";
              keywordLength = 3;
            }
          ];

          window = {
            completion = {
              border = "solid";
              scrollbar = false;
            };
            documentation.border = "solid";
          };
        };
      };

      cmp-buffer.enable = true;
      cmp-cmdline.enable = true;
      cmp-emoji.enable = true;
      cmp-path.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lua.enable = true;
      cmp_luasnip.enable = true;
      luasnip.enable = true;
      friendly-snippets.enable = true;

      toggleterm = {
        enable = true;
        settings = {
          hide_numbers = false;
          autochdir = true;
          close_on_exit = true;
          direction = "float";
          shade_terminals = true;
        };
      };
    };

    extraConfigLua = ''
      vim.opt.fillchars = { vert = '│', diff = '/' }

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
      })

      local map = vim.keymap.set
      map("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab" })
      map("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
      map("n", "<leader><Tab>", "<cmd>tabnew<CR>", { desc = "New tab" })

      map("n", "<leader>ss", "<cmd>SessionSearch<CR>", { desc = "Session search" })
      map("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "Session delete" })

      map("n", "<leader>a", "<cmd>wa<CR>", { desc = "Write all" })
      map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write buffer" })
      map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit buffer" })
      map("n", "<A-e>", "<cmd>qa<CR>", { desc = "Quit all" })

      map("n", "<leader>pp", "<cmd>setlocal paste!<CR>", { desc = "Toggle paste" })
      map("n", "<leader>fr", "<cmd>lua require('conform').format({ async = true })<CR>", { desc = "Format" })

      map("n", "k", "v:count == 0 and 'gk' or 'k'", { expr = true, silent = true })
      map("n", "j", "v:count == 0 and 'gj' or 'j'", { expr = true, silent = true })
      map("n", "Y", "y$", { desc = "Yank to end" })

      map("n", "-", function() require("oil").open() end, { desc = "Open parent dir" })

      map("n", ";", ":", { desc = "Command mode" })
      map("n", "<leader>cw", "<cmd>botright cw<CR>", { desc = "Open quickfix" })

      map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Diagnostics float" })
      map("n", "<leader>dis", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
      map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
      map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

      map("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { desc = "Tree toggle" })

      map("n", "<leader><leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      map("n", "<leader><leader>g", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
      map("n", "<leader><leader>d", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
      map("n", "<leader><leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Buffer fuzzy" })
      map("n", "<leader><leader>o", "<cmd>Telescope oldfiles<CR>", { desc = "Old files" })
      map("n", "<leader><leader>b", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
      map("n", "<leader><leader>h", "<cmd>Telescope help_tags<CR>", { desc = "Help" })
      map("n", "<leader><leader>s", "<cmd>Telescope grep_string<CR>", { desc = "Grep string" })
      map("n", "<leader><leader>n", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Doc symbols" })

      map("n", "<leader>ct", "<cmd>CopilotChatToggle<CR>", { desc = "Copilot chat" })
      map("n", "<leader>cm", "<cmd>CopilotChatModels<CR>", { desc = "Copilot models" })
      map("n", "<leader>cs", "<cmd>CopilotChatStop<CR>", { desc = "Copilot stop" })

      map("n", "<leader>do", "<cmd>DiffviewOpen<CR>", { desc = "Diffview open" })
      map("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Diffview close" })
      map("n", "<leader>dh", "<cmd>DiffviewFileHistory<CR>", { desc = "Diffview history" })

      map("n", "<leader>tr", "<cmd>ToggleTerm<CR>", { desc = "Terminal" })

      -- ── CodeCompanion (Claude via Anthropic API) ──────────────────────
      require('codecompanion').setup({
        adapters = {
          anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
              schema = {
                model     = { default = 'claude-opus-4-5' },
                max_tokens = { default = 8096 },
              },
            })
          end,
        },
        strategies = {
          chat   = { adapter = 'anthropic' },
          inline = { adapter = 'anthropic' },
          agent  = { adapter = 'anthropic' },
        },
        display = {
          chat = {
            window = { layout = 'vertical', width = 0.55 },
            show_settings = true,
          },
          diff = { provider = 'default' },
        },
        -- Superpowers: 5-phase prompt available with :CodeCompanionActions
        prompt_library = {
          ['Superpowers: 5-Phase'] = {
            strategy = 'chat',
            description = 'Clarifier → Designer → Planifier → Coder → Verifier',
            opts = { index = 1, is_slash_cmd = false },
            prompts = {
              {
                role = 'system',
                content = [[
You are a senior software engineer. Apply the 5-phase Superpowers methodology:

PHASE 1 – CLARIFIER: Restate requirements in your own words. Ask targeted questions. Confirm acceptance criteria before anything else.
PHASE 2 – DESIGNER: Propose an architecture. Identify applicable patterns. Consider edge cases and failure modes.
PHASE 3 – PLANIFIER: Break the work into atomic, verifiable steps. Show the full plan and wait for approval before coding.
PHASE 4 – CODER: Write clean, tested, self-documenting code. Follow the existing conventions in the codebase. Handle errors explicitly.
PHASE 5 – VERIFIER: Review against original requirements. Check edge cases. Summarise what was done and what remains open.

Be concise and direct. Flag issues proactively. When uncertain, say so.]],
              },
            },
          },
        },
      })

      -- ── Claude Code CLI in a vertical split (via ToggleTerm) ─────────────
      local claude_term = nil
      local function toggle_claude_code()
        if vim.fn.executable('claude') == 0 then
          vim.notify('claude-code CLI not found in PATH. Run: home-manager switch', vim.log.levels.ERROR)
          return
        end
        local Terminal = require('toggleterm.terminal').Terminal
        if claude_term == nil then
          claude_term = Terminal:new({
            cmd = 'claude',
            direction = 'vertical',
            size = math.floor(vim.o.columns * 0.50),
            close_on_exit = false,
            on_open = function(t)
              vim.cmd('startinsert!')
              -- Pass current file as context when opening
              local file = vim.api.nvim_buf_get_name(0)
              if file ~= ''' then
                t:send('# Context: ' .. file, false)
              end
            end,
          })
        end
        claude_term:toggle()
      end

      -- ── Claude memory – persistent context file across sessions ──────────
      local mem_path = vim.fn.stdpath('data') .. '/claude-mem.md'
      local function ensure_mem()
        if vim.fn.filereadable(mem_path) == 0 then
          vim.fn.writefile({
            '# Claude Memory',
            ' ',
            '## Last Session Summary',
            ' ',
            '## Ongoing Context',
            ' ',
            '## Recurring Reminders',
            ' ',
          }, mem_path)
        end
      end

      -- ── CodeCompanion / Claude keymaps ────────────────────────────────────
      map({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<CR>', { desc = 'CC: chat' })
      map({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionChat Add<CR>',    { desc = 'CC: add to chat' })
      map({ 'n', 'v' }, '<leader>ci', '<cmd>CodeCompanion<CR>',            { desc = 'CC: inline' })
      map('n',          '<leader>cp', '<cmd>CodeCompanionActions<CR>',     { desc = 'CC: actions (Superpowers)' })
      map('n',          '<leader>cl', toggle_claude_code,                  { desc = 'Claude Code CLI' })
      map('n', '<leader>cme', function()
        ensure_mem()
        vim.cmd('vsplit ' .. mem_path)
      end, { desc = 'Claude memory: edit' })
      map('n', '<leader>cms', function()
        ensure_mem()
        local content = table.concat(vim.fn.readfile(mem_path), '\n')
        require('codecompanion').chat()
        vim.defer_fn(function()
          vim.api.nvim_paste('[SESSION MEMORY]\n' .. content .. '\n[/SESSION MEMORY]', true, -1)
        end, 400)
      end, { desc = 'Claude memory: inject into chat' })
    '';
  };
}
