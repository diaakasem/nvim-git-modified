if exists("g:loaded_git_branch_modified_files")
    finish
endif
let g:loaded_git_branch_modified_files = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_base_loc =  expand("<sfile>:h:r") . "/../lua/git-modified.lua"
exe "lua package.path = package.path .. ';" . s:lua_rocks_base_loc

lua GitModified = require("git-modified")
" lua GitModified.setup({ p1 = "value1" })
lua GitModified.main()

" lua require("myluamodule.definestuff").show_stuff()
