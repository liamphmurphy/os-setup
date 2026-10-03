# tmux: shared across all dev environments (prefix = Ctrl+a)
{ ... }:

{
  programs.tmux = {
    enable = true;
    # Home Manager also binds `C-a C-a` to send-prefix (beginning-of-line in shell)
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    # No lag on <Esc> in neovim
    escapeTime = 10;
    historyLimit = 50000;
    terminal = "tmux-256color";
    # Needed for neovim autoread (FocusGained autocmd in dev.nix)
    focusEvents = true;

    extraConfig = ''
      # True colour passthrough (Ghostty / Windows Terminal)
      set -as terminal-features ",*:RGB"

      # Splits: \ (or |) side-by-side, - stacked; open in current dir
      unbind '"'
      unbind %
      bind '\' split-window -h -c "#{pane_current_path}"
      bind |   split-window -h -c "#{pane_current_path}"
      bind -   split-window -v -c "#{pane_current_path}"
      bind c   new-window      -c "#{pane_current_path}"

      # Close: x = pane, w = window (tab), q = whole session (no confirmation)
      bind x kill-pane
      bind w kill-window
      bind q kill-session

      # Vim-style pane navigation / resizing (prefixed, so neovim's <C-h> is untouched)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Vi copy mode: v to select, y to yank
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      set -g renumber-windows on
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux config reloaded"
    '';
  };
}
