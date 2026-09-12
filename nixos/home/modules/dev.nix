# Cross-platform dev env (Home Manager module)
# Things like neovim can't be fully controlled by the nix language, but you can
# write the config inline here, so that whenever you run a new flake switch,
# that file is rewritten.
{ pkgs, lib, ... }:

{
  # Go toolchain via HM
  programs.go.enable = true;

  home.packages =
    with pkgs;
    [
      uv

      # general dev tools
      gnumake

      # K8s
      kubectl
      kind
      kubernetes-helm
      kubectx

      # VCS & editor deps
      git
      ripgrep
      fd
      tree-sitter
      lua-language-server
      nodejs
      # (optional) Go LSP for LazyVim extras.lang.go
      gopls

      # Rust: compiler, Cargo tools, and the language server used by LazyVim.
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy

      # Python: interpreter plus the language server and formatter/linter used
      # by LazyVim's Python extra.  Project-specific dependencies should still
      # live in a virtual environment (for example, managed with uv).
      python3
      pyright
      ruff

      # Markdown: language server and linting.
      marksman
      markdownlint-cli

      # Nix: language server and formatter.
      nixd
      nixfmt

      # ai things
      codex
      opencode
      antigravity-cli
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") [
      chatgpt
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # Darwin uses Apple's compiler toolchain.
      gcc
    ];

  # Neovim core
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = true;
    withPython3 = true;
    # No xdg.* here — keep this block strictly for neovim options.
  };

  # --- LazyVim bootstrap & config files ---
  # ~/.config/nvim/init.lua
  xdg.configFile."nvim/init.lua".text = ''
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- all LazyVim config lives under lua/config and lua/plugins
    require("config.lazy")
  '';

  # ~/.config/nvim/lua/config/lazy.lua
  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    require("lazy").setup({
      spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },

        -- Extras you want:
        { import = "lazyvim.plugins.extras.lang.go" },
        { import = "lazyvim.plugins.extras.lang.rust" },
        { import = "lazyvim.plugins.extras.lang.python" },
        { import = "lazyvim.plugins.extras.lang.markdown" },
        { import = "lazyvim.plugins.extras.lang.nix" },
        -- Enable if you use it; requires auth inside Neovim
        { import = "lazyvim.plugins.extras.ai.copilot" },

        -- Your own plugins folder:
        { import = "plugins" },
      },
      defaults = { lazy = false, version = false },
      install = { colorscheme = { "tokyonight", "habamax" } },
      checker = { enabled = false },
      performance = {
        rtp = {
          disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
        },
      },
    })
  '';

  # Example plugin spec: ~/.config/nvim/lua/plugins/init.lua
  xdg.configFile."nvim/lua/plugins/init.lua".text = ''
    return {
      { "nvim-lualine/lualine.nvim", opts = {} },
      { "folke/which-key.nvim", opts = {} },
      {
        "folke/snacks.nvim",
        opts = {
          picker = {
            sources = {
              grep = {
                exclude = { "**/vendor/**" },
              },
            },
          },
        },
      },
    }
  '';

  # Antigravity IDE Replication: Sidebar Terminal, Live Diffs & Context Sync
  xdg.configFile."nvim/lua/plugins/antigravity.lua".text = ''
    -- Auto-reload buffers when modified externally by agy
    vim.opt.autoread = true
    local autoread_group = vim.api.nvim_create_augroup("AntigravityAutoRead", { clear = true })
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave", "TermClose" }, {
      group = autoread_group,
      callback = function()
        if vim.fn.getcmdwintype() == "" and vim.api.nvim_get_mode().mode ~= "c" then
          vim.cmd("checktime")
        end
      end,
    })

    local term_keys = {
      term_normal = {
        "<esc>",
        "<cmd>stopinsert<cr>",
        mode = "t",
        desc = "Escape to normal mode",
      },
      nav_left = {
        "<C-h>",
        "<cmd>wincmd h<cr>",
        mode = "t",
        desc = "Jump to code editor (left window)",
      },
      nav_wincmd = {
        "<C-w>",
        "<C-\\><C-n><C-w>",
        mode = "t",
        desc = "Window command prefix",
      },
    }

    local function get_win_opts(custom_opts)
      return vim.tbl_deep_extend("force", {
        position = "right",
        width = 0.38,
        keys = term_keys,
      }, custom_opts or {})
    end

    local function toggle_agy(args, win_opts)
      local cmd = "agy"
      if args and #args > 0 then
        cmd = cmd .. " " .. table.concat(args, " ")
      end
      Snacks.terminal.toggle(cmd, {
        win = get_win_opts(win_opts),
        interactive = true,
      })
    end

    local function send_selection_to_agy()
      vim.cmd([[execute "normal! \<ESC>"]])
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local file = vim.fn.expand("%:p:.")
      local ref = string.format("@%s:L%d-L%d ", file, start_line, end_line)

      local term = Snacks.terminal.get("agy", {
        win = get_win_opts(),
      })
      if term then
        term:show():focus()
        vim.defer_fn(function()
          vim.api.nvim_paste(ref, true, -1)
        end, 100)
      end
    end

    local function send_file_to_agy()
      local file = vim.fn.expand("%:p:.")
      local ref = string.format("@%s ", file)
      local term = Snacks.terminal.get("agy", {
        win = get_win_opts(),
      })
      if term then
        term:show():focus()
        vim.defer_fn(function()
          vim.api.nvim_paste(ref, true, -1)
        end, 100)
      end
    end

    local function smart_toggle_focus_agy()
      local term = Snacks.terminal.get("agy", get_win_opts())
      local current_buf = vim.api.nvim_get_current_buf()
      local current_win = vim.api.nvim_get_current_win()

      local in_agy = term and term:buf_valid() and (current_buf == term.buf or current_win == term.win)

      if in_agy then
        -- Inside agy: jump to code window in Normal mode
        vim.cmd("stopinsert")
        vim.cmd("wincmd p")
        if vim.api.nvim_get_current_win() == (term.win or -1) then
          vim.cmd("wincmd h")
        end
      else
        -- Inside code: if agy is open, focus it and start insert
        if term and term:valid() then
          term:focus()
          vim.cmd("startinsert")
        else
          -- If agy is not open/visible, normal left window navigation
          vim.cmd("wincmd h")
        end
      end
    end

    -- Smart toggle <C-h> between code editor and agy panel
    vim.keymap.set({ "n", "t" }, "<C-h>", smart_toggle_focus_agy, { desc = "Smart Toggle Focus (Code <-> Antigravity)" })

    -- Fast toggle sidebar visibility using <A-a> from both normal and terminal mode
    vim.keymap.set({ "n", "t" }, "<A-a>", function()
      toggle_agy()
    end, { desc = "Toggle Antigravity Sidebar" })

    return {
      -- Which-key group registration
      {
        "folke/which-key.nvim",
        opts = {
          spec = {
            { "<leader>a", group = "antigravity / ai", icon = "󰚩 " },
          },
        },
      },

      -- Diffview for reviewing agent changes
      {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
        opts = {
          enhanced_diff_hl = true,
          view = {
            default = {
              layout = "diff2_horizontal",
            },
          },
        },
        keys = {
          { "<leader>ad", "<cmd>DiffviewOpen<cr>", desc = "Review Changes (Diffview)" },
          { "<leader>aD", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
          { "<leader>ah", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
        },
      },

      -- Keybindings for Antigravity CLI integration
      {
        "LazyVim/LazyVim",
        keys = {
          {
            "<leader>aa",
            function() toggle_agy({}, { position = "right", width = 0.38 }) end,
            desc = "Toggle Antigravity Sidebar",
          },
          {
            "<leader>ac",
            function() toggle_agy({ "--continue" }, { position = "right", width = 0.38 }) end,
            desc = "Antigravity Continue Session",
          },
          {
            "<leader>ap",
            function() toggle_agy({ "--mode", "plan" }, { position = "right", width = 0.38 }) end,
            desc = "Antigravity Plan Mode",
          },
          {
            "<leader>aA",
            function() toggle_agy({}, { position = "float", width = 0.85, height = 0.85 }) end,
            desc = "Toggle Antigravity Float",
          },
          {
            "<leader>as",
            send_selection_to_agy,
            mode = "v",
            desc = "Send Selection to Antigravity",
          },
          {
            "<leader>af",
            send_file_to_agy,
            desc = "Send File Reference to Antigravity",
          },
        },
      },
    }
  '';
  # --- END LazyVim bootstrap ---

  # OpenCode with the local Ollama server.
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    model = "ollama/qwen3-coder";
    provider.ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama (local)";
      options.baseURL = "http://127.0.0.1:11434/v1";
      models."qwen3-coder" = {
        name = "Qwen3 Coder";
      };
    };
  };

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
