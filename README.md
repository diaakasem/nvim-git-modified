# Git Modified

This is a simple Neovim plugin to list / pick the modified files in the current branch in comparison to the main branch, using telescope for editing.

## Installation

### Lazy

An example of how to load this plugin in Lazy:

```lua
{
    "diaakasem/git-modified",
    dependencies = {
        {
            -- Depends on telescope pickers
            "telescope.nvim",
        }
    },
    config = function()
        require("git-modified").setup()
    end,
    keys = {
        "<leader>gm",
        function() require("git-modified").main() end,
        desc = "Git Modified"
    }
}
```

