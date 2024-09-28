require'nvim-treesitter.configs'.setup {
  -- Nix installs the plugins, so we don't need to do it here.
  auto_install = false; 
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require "nvim-treesitter.configs".setup {
  playground = {
      enable = true
  }
}
