# c_formatter_42.vim

A simple Neovim plugin to format C files using [`c_formatter_42`](https://github.com/dawnbeen/c_formatter_42).

## 🔧 Requirements

- Install `c_formatter_42` with:

```bash
pip install c-formatter-42
```

lazy.nvim

```lua
{
  "Itsoon/c_formatter_42.vim",
  config = function()
    require("c_formatter_42").setup({
      auto_format = true, -- set to false if you don't want format-on-save
    })
  end,
}
```
