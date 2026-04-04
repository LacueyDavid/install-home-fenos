{ ... }:
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

    extraConfigVim = ''
      set number
      set relativenumber
      set mouse=a
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set splitbelow
      set splitright
      set termguicolors
      set updatetime=250
      set signcolumn=yes
      set ignorecase
      set smartcase
      set scrolloff=8
      set wrap
      set linebreak
      set clipboard=unnamedplus
      set completeopt=menu,menuone,noselect
      set cursorline
      set laststatus=3
    '';

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      gitsigns.enable = true;
      comment.enable = true;
      nvim-surround.enable = true;
      fidget.enable = true;
      telescope.enable = true;
      oil.enable = true;
      flash.enable = true;
      noice.enable = true;

      treesitter = {
        enable = true;
        settings = {
          auto_install = true;
          highlight.enable = true;
          indent.enable = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          clangd.enable = true;
          cssls.enable = true;
          dockerls.enable = true;
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
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            enable = true;
            timeout_ms = 800;
          };
          formatters_by_ft = {
            nix = [ "alejandra" ];
            lua = [ "stylua" ];
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];
            python = [ "ruff_format" ];
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            json = [ "prettier" ];
            yaml = [ "prettier" ];
            markdown = [ "prettier" ];
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          completion.completeopt = "menu,menuone,noinsert";
          experimental.ghost_text = true;
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          mapping = {
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-j>" = ''
              cmp.mapping(function()
                if not cmp.visible() then
                  cmp.complete()
                else
                  cmp.select_next_item()
                end
              end, {'i', 's'})
            '';
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "luasnip"; }
          ];
        };
      };

      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp_luasnip.enable = true;
      luasnip.enable = true;
      friendly-snippets.enable = true;

      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          shade_terminals = true;
        };
      };
    };

    extraConfigLua = ''
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
      })

      local map = vim.keymap.set
      map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write buffer" })
      map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit buffer" })
      map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
      map("n", "-", function() require("oil").open() end, { desc = "Open parent dir" })
      map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Terminal" })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
      map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
      map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    '';
  };
}
