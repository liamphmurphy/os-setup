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

      # Name tabs after the running program (nvim, claude, ...) rather than zsh
      setw -g automatic-rename on
      set -g automatic-rename-format '#{pane_current_command}'

      # Status bar: Tokyo Night colours (matches nvim) on a transparent
      # background (matches Ghostty). Plain padded blocks, no Nerd Font glyphs,
      # so it renders in any terminal (incl. Windows Terminal on WSL).
      set -g status-position bottom
      set -g status-interval 5
      set -g status-justify left
      set -g status-style "bg=default fg=#a9b1d6"

      # Session name; turns orange while the prefix is held
      set -g status-left-length 30
      set -g status-left "#{?client_prefix,#[fg=#1a1b26 bg=#ff9e64 bold],#[fg=#1a1b26 bg=#bb9af7 bold]} #S #[default] "

      # Current folder and time
      set -g status-right-length 60
      set -g status-right "#[fg=#7aa2f7]#{b:pane_current_path} #[fg=#565f89]│ #[fg=#c0caf5]%H:%M "

      # Tabs: current one is a blue block, others dimmed
      setw -g window-status-separator " "
      setw -g window-status-format "#[fg=#565f89] #I #W "
      setw -g window-status-current-format "#[fg=#1a1b26 bg=#7aa2f7 bold] #I #W "

      # Pane borders, messages and copy-mode selection
      set -g pane-border-style "fg=#292e42"
      set -g pane-active-border-style "fg=#7aa2f7"
      set -g message-style "bg=#292e42 fg=#c0caf5"
      set -g message-command-style "bg=#292e42 fg=#c0caf5"
      setw -g mode-style "bg=#2e3c64 fg=#c0caf5"
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux config reloaded"
    '';
  };
}
