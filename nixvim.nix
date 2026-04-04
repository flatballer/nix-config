{ pkgs, ... }:
{
  # ── Options ──────────────────────────────────────────────────────────────
  opts = {
    number = true;
    relativenumber = true;
    mouse = "a";
    clipboard = "unnamedplus";
    tabstop = 4;
    shiftwidth = 4;
    expandtab = true;
    termguicolors = true;
    signcolumn = "yes";
    updatetime = 300;
    completeopt = [ "menu" "menuone" "noselect" ];
    ignorecase = true;
    smartcase = true;
    inccommand = "split";
  };

  globals = {
    mapleader = " ";
    # markdown-preview
    mkdp_auto_start = 0;
    mkdp_auto_close = 1;
    # dadbod-ui
    db_ui_use_nerd_fonts = 1;
  };

  # ── Keymaps ──────────────────────────────────────────────────────────────
  keymaps = [
    # Window navigation
    { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.silent = true; }
    { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.silent = true; }
    { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.silent = true; }
    { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.silent = true; }
    # Oil
    { mode = "n"; key = "-"; action = "<cmd>Oil<CR>"; options = { silent = true; desc = "Open Oil"; }; }
    { mode = "n"; key = "<leader>o"; action.__raw = ''function() require("oil").open_float(vim.loop.cwd()) end''; options.desc = "Oil at CWD (float)"; }
    # fzf-lua
    { mode = "n"; key = "<leader>ff"; action = "<cmd>FzfLua files<CR>"; options.desc = "Find files"; }
    { mode = "n"; key = "<leader>fg"; action = "<cmd>FzfLua live_grep<CR>"; options.desc = "Live grep"; }
    { mode = "n"; key = "<leader>fb"; action = "<cmd>FzfLua buffers<CR>"; options.desc = "Buffers"; }
    { mode = "n"; key = "<leader>fh"; action = "<cmd>FzfLua help_tags<CR>"; options.desc = "Help tags"; }
    { mode = "n"; key = "<leader>fr"; action = "<cmd>FzfLua oldfiles<CR>"; options.desc = "Recent files"; }
    { mode = "n"; key = "<leader>fw"; action = "<cmd>FzfLua grep_cword<CR>"; options.desc = "Grep word under cursor"; }
    { mode = "n"; key = "<leader>fd"; action = "<cmd>FzfLua lsp_definitions<CR>"; options.desc = "LSP definitions"; }
    { mode = "n"; key = "<leader>fi"; action = "<cmd>FzfLua lsp_implementations<CR>"; options.desc = "LSP implementations"; }
    { mode = "n"; key = "<leader>frf"; action = "<cmd>FzfLua lsp_references<CR>"; options.desc = "LSP references"; }
    # Copilot toggle
    {
      mode = "n";
      key = "<leader>at";
      action.__raw = ''
        function()
          local client = require("copilot.client")
          if client.is_disabled() then
            require("copilot.command").enable()
            vim.notify("Copilot enabled", vim.log.levels.INFO)
          else
            require("copilot.command").disable()
            vim.notify("Copilot disabled", vim.log.levels.INFO)
          end
        end
      '';
      options.desc = "Toggle Copilot";
    }
  ];

  # ── Colorscheme ──────────────────────────────────────────────────────────
  colorschemes.tokyonight = {
    enable = true;
    settings.style = "night";
  };

  # ── Plugins ──────────────────────────────────────────────────────────────
  plugins = {

    # Treesitter
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        ensure_installed = [
          "lua" "python" "bash"
          "markdown" "markdown_inline"
          "json" "yaml" "sql"
        ];
      };
    };

    # Statusline
    lualine = {
      enable = true;
      settings.options = {
        theme = "tokyonight";
        section_separators = "";
        component_separators = "";
      };
    };

    # Git signs
    gitsigns.enable = true;

    # Web devicons (dep for lualine, fzf-lua, oil)
    web-devicons.enable = true;

    # which-key (keymap discoverability)
    which-key.enable = true;

    # Snippet engine
    luasnip.enable = true;

    # Completion (blink.cmp)
    blink-cmp = {
      enable = true;
      settings = {
        snippets.preset = "luasnip";
        sources.default = [ "lsp" "path" "snippets" "buffer" ];
        keymap.preset = "default";
        completion.documentation.auto_show = true;
      };
    };

    # LSP
    lsp = {
      enable = true;
      servers = {
        nixd = {
          enable = true;
          settings = {
            nixd = {
              nixpkgs.expr = "import <nixpkgs> { }";
              formatting.command = [ "alejandra" ];
              options.nix-darwin.expr = ''(builtins.getFlake "~/nix-darwin-config").darwinConfigurations.TMA-M4.options'';
            };
          };
        };

        lua_ls = {
          enable = true;
          settings.Lua = {
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
          };
        };

        basedpyright = {
          enable = true;
          settings.python.analysis.typeCheckingMode = "standard";
        };

        ruff = {
          enable = true;
        };

        sqls.enable = true;
      };

      keymaps = {
        lspBuf = {
          gd = { action = "definition"; desc = "Goto Definition"; };
          K  = { action = "hover"; desc = "Hover"; };
          gr = { action = "references"; desc = "References"; };
          "<leader>rn" = { action = "rename"; desc = "Rename"; };
          "<leader>ca" = { action = "code_action"; desc = "Code action"; };
          "<leader>fo" = { action = "format"; desc = "Format buffer"; };
        };
        diagnostic = {
          "[d" = { action = "goto_prev"; desc = "Prev diagnostic"; };
          "]d" = { action = "goto_next"; desc = "Next diagnostic"; };
          "<leader>e"  = { action = "open_float"; desc = "Line diagnostics"; };
          "<leader>xx" = { action = "setloclist"; desc = "Diagnostics (loclist)"; };
        };
      };

      postConfig = ''
        -- ty LSP (not yet in nixvim's built-in server list)
        vim.lsp.config("ty", {
          cmd = { "ty", "server" },
          filetypes = { "python" },
          root_markers = { "pyproject.toml", "setup.py", "setup.cfg", ".git" },
        })
        vim.lsp.enable("ty")

        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })
      '';
    };

    # Formatting (replaces none-ls)
    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          python   = [ "ruff_format" ];
          lua      = [ "stylua" ];
          markdown = [ "markdownlint" ];
          sh       = [ "shfmt" ];
          bash     = [ "shfmt" ];
          nix      = [ "alejandra" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = true;
        };
      };
    };

    # fzf-lua
    fzf-lua = {
      enable = true;
      settings.winopts.border = "rounded";
      # register as ui-select backend
      luaConfig.post = ''
        require("fzf-lua").register_ui_select()
      '';
    };

    # Oil (file explorer)
    oil = {
      enable = true;
      settings = {
        default_file_explorer = true;
        view_options.show_hidden = true;
      };
    };

    # Copilot
    copilot-lua = {
      enable = true;
      settings = {
        panel.enabled = false;
        suggestion = {
          enabled = true;
          auto_trigger = true;
          debounce = 75;
          keymap = {
            accept  = "<C-l>";
            next    = "<M-]>";
            prev    = "<M-[>";
            dismiss = "<C-]>";
          };
        };
        filetypes = {
          markdown   = true;
          help       = false;
          gitcommit  = true;
          gitrebase  = true;
          "*"        = true;
        };
      };
    };

    # Markdown preview
    markdown-preview = {
      enable = true;
    };

    # Dadbod (SQL)
    vim-dadbod.enable = true;
    vim-dadbod-ui.enable = true;
    vim-dadbod-completion.enable = true;
  };

  # ── Extra plugins (not in nixvim's plugin list) ───────────────────────────
  extraPlugins = with pkgs.vimPlugins; [
    vim-python-pep8-indent
  ];

  # ── Extra packages (LSP servers & formatters via nix) ────────────────────
  extraPackages = with pkgs; [
    nixd
    alejandra
    # Python
    basedpyright
    ruff
    ty
    # Lua
    lua-language-server
    stylua
    # SQL
    sqls
    # Shell
    shfmt
    # Markdown
    nodePackages.markdownlint-cli
    # Node (required by copilot.lua)
    nodejs
  ];

  # ── uv venv helper (replicates config/uv.lua) ────────────────────────────
  extraFiles."lua/config/uv.lua".text = ''
    local M = {}

    local uv = vim.uv or vim.loop

    local ROOT_MARKERS = {
      "pyproject.toml",
      "uv.lock",
      ".git",
      ".venv",
    }

    local function is_fs_root(path)
      if vim.fn.has("win32") == 1 then
        return path:match("^%a:[/\\]$") ~= nil
      else
        return path == "/"
      end
    end

    local function path_join(...)
      return table.concat({ ... }, "/")
    end

    function M.find_project_root(start_dir)
      local dir = start_dir or vim.fn.expand("%:p:h")
      if dir == "" then dir = vim.loop.cwd() end
      dir = vim.fs.normalize(dir)
      while dir and not is_fs_root(dir) do
        for _, marker in ipairs(ROOT_MARKERS) do
          if uv.fs_stat(path_join(dir, marker)) then return dir end
        end
        dir = vim.fs.dirname(dir)
      end
      return nil
    end

    function M.get_venv_path(root)
      if not root or root == "" then return nil end
      local env = vim.env.UV_PROJECT_ENVIRONMENT
      if env and env ~= "" then
        if not env:match("^/") and not env:match("^%a:[/\\]") then
          env = path_join(root, env)
        end
        if uv.fs_stat(env) then return vim.fs.normalize(env) end
      end
      local default = path_join(root, ".venv")
      if uv.fs_stat(default) then return vim.fs.normalize(default) end
      return nil
    end

    function M.activate_venv(venv)
      if not venv or venv == "" then return end
      local bin_dir = vim.fn.has("win32") == 1
        and path_join(venv, "Scripts")
        or  path_join(venv, "bin")
      if not uv.fs_stat(bin_dir) then return end
      local sep = vim.fn.has("win32") == 1 and ";" or ":"
      vim.env.VIRTUAL_ENV = venv
      vim.env.PATH = bin_dir .. sep .. (vim.env.PATH or "")
    end

    function M.ensure_uv_venv(opts)
      opts = opts or {}
      local root = M.find_project_root(opts.start_dir)
      if not root then
        if not opts.quiet then
          vim.notify("[uv] No project root found for current buffer", vim.log.levels.DEBUG)
        end
        return nil
      end
      local venv = M.get_venv_path(root)
      if not venv then
        if not opts.quiet then
          vim.notify("[uv] No uv virtual environment in " .. root, vim.log.levels.DEBUG)
        end
        return nil
      end
      M.activate_venv(venv)
      if not opts.quiet then
        vim.notify("[uv] Activated venv: " .. venv, vim.log.levels.INFO)
      end
      return venv
    end

    function M.with_uv_venv(cb, opts)
      cb(M.ensure_uv_venv(opts))
    end

    return M
  '';

  # Activate uv venv on buffer open for Python files
  autoCmd = [
    {
      event = [ "BufEnter" ];
      pattern = [ "*.py" ];
      callback.__raw = ''
        function()
          pcall(function()
            local uv_env = require("config.uv")
            local root = uv_env.find_project_root()
            local venv = root and uv_env.get_venv_path(root)
            if venv then uv_env.activate_venv(venv) end
          end)
        end
      '';
    }
  ];
}
