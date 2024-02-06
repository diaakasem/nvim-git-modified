-- By convention, nvim Lua plugins include a setup function that takes a table
-- so that users of the plugin can configure it using this pattern:
--
-- require'myluamodule'.setup({p1 = "value1"})

-- import telescope pickers
local pickers = require('telescope.pickers')

local function get_git_branch()
    -- current working directory of the opened buffer
    local cwd = vim.fn.expand('%:p:h')
    local branch_name = vim.fn.system('cd ' .. cwd .. ' && git rev-parse --abbrev-ref HEAD')
    if branch_name == '' then
        return nil
    end
    return branch_name
end

local function get_main_branch()
    local cwd = vim.fn.expand('%:p:h')
    -- print("cwd: " .. cwd)
    local local_main_branch = vim.fn.system('cd ' .. cwd .. ' && git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || git symbolic-ref --short HEAD')
    -- local main_branch_name = vim.fn.system('echo "' .. local_main_branch .. '" | cut -d/ -f2')
    -- in lua ( neovim ) - splitting string by / and getting the second element
    local main_branch_name = local_main_branch:match("([^/]+)$")
    -- print("main_branch_name: " .. main_branch_name)
    -- FIXME: A hackly way to get this to work, as the git symbolic-ref command is not working as expected ( for mer )
    if (main_branch_name ~= 'master' and main_branch_name ~= 'main') then
        main_branch_name = 'master'
    end
    return main_branch_name
end

local function get_common_hash(branch_name, main_branch_name)
    local cwd = vim.fn.expand('%:p:h')
    -- trim the names from spaces or new lines or tabs
    local branch_name = branch_name:gsub("^%s*(.-)%s*$", "%1")
    local main_branch_name = main_branch_name:gsub("^%s*(.-)%s*$", "%1")
    -- print("cwd: " .. cwd)
    -- print("branch_name: " .. branch_name)
    -- print("main_branch_name: " .. main_branch_name)
    local common_hash = vim.fn.system('cd ' .. cwd .. ' && git merge-base -a ' .. branch_name .. ' ' .. main_branch_name)
    -- print("common_hash: " .. common_hash)
    return common_hash
end

local function get_modified_files(common_hash, branch_name)
    local cwd = vim.fn.expand('%:p:h')
    -- print("cwd: " .. cwd)
    local modified_files = vim.fn.system('cd ' .. cwd .. ' && git diff --name-only ' .. common_hash .. ' ' .. branch_name)
    local files = {}
    -- split by newline
    for file in string.gmatch(modified_files, "[^\r\n]+") do
        table.insert(files, file)
    end
    return files
end

local function main()
    local branch_name = get_git_branch()
    if branch_name == nil then
        print("Not a git repository")
        return
    end

    local main_branch_name = get_main_branch()
    if branch_name == main_branch_name then
        print("No changes in the " .. main_branch_name .. " branch")
        return
    end

    local common_hash = get_common_hash(branch_name, main_branch_name)
    local modified_files = get_modified_files(common_hash, branch_name)
    local cwd = vim.fn.expand('%:p:h')
    -- pick from the files
    pickers.new({}, {
        prompt_title = 'Git Modified Files',
        finder = require('telescope.finders').new_table {
            results = modified_files,
        },
        sorter = require('telescope.config').values.file_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            local select_file = function()
                local entry = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                local git_root = vim.fn.system('cd ' .. cwd .. ' && git rev-parse --show-toplevel')
                -- print("Git root: " .. git_root)
                git_root = git_root:gsub("^%s*(.-)%s*$", "%1")
                local file = git_root .. "/" .. entry.value
                -- print("Opening file: " .. file)
                vim.cmd('e ' .. file)
            end
            map('i', '<CR>', select_file)
            map('n', '<CR>', select_file)
            return true
        end,
    }):find()
end

local function setup(parameters)
end

vim.api.nvim_create_user_command(
    'GitModified',
    function(input)
        main()
    end,
    {bang = true, desc = 'Git Modified Files'}
)

-- This is a duplicate of the keymap created in the VimL file, demonstrating how to create a
-- keymapping in Lua.
vim.keymap.set('n', '<leader>gm', main, {desc = 'Git Modified', remap = false})

return {
    setup = setup,
    main = main,
}
