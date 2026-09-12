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
