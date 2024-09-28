{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.nvim;
in {
  options.tundra.programs.nvim = {
    enable = lib.mkEnableOption "Enable nvim module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      xdg.configFile.nvim = {
        source = ./nvim;
        recursive = true;
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        # Overrides init.lua, source from $XDG_CONFIG_HOME/nvim/source.lua
        extraLuaConfig = ''
          require('source')
        '';

        plugins = with pkgs.vimPlugins; [
          telescope-nvim
          nvim-treesitter.withAllGrammars
          harpoon
          playground
          undotree
          vim-fugitive
          direnv-vim
          copilot-vim

          # https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#you-might-not-need-lsp-zero
          lsp-zero-nvim
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-nvim-lsp-document-symbol
          luasnip

          # https://aaronbos.dev/posts/debugging-csharp-neovim-nvim-dap
          nvim-dap
          nvim-dap-ui

          nvim-tree-lua
          nvim-web-devicons

          rose-pine
          dracula-nvim

          vim-be-good
        ];

        extraPackages = with pkgs; [
          omnisharp-roslyn
          rust-analyzer
          clippy
          netcoredbg
          ripgrep
        ];
      };
    };
  };
}
