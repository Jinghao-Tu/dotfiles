-- for both vscode and nvim
return {
    {
        "kylechui/nvim-surround",
        version = "*", -- Use "^3.0.0" for stability; omit to use `main` branch for the latest features
        event   = "VeryLazy",
        config  = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },
    {
        "sitiom/nvim-numbertoggle",
    },
}
