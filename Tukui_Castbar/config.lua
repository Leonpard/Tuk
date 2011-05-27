local addon, ns = ...

ns.config={
    ["separateplayer"] = true, -- separate player castbar
    ["separatetarget"] = false, -- separate target castbar
    ["separatefocus"] = false, -- separate focus castbar
    ["separatefocustarget"]  = false, -- separate focustarget castbar
    player = {
--test
        ["width"] = 190, -- width of player castbar
        ["height"] = 22, -- height of player castbar
    },
    target = {
        ["width"] = 250, -- width of target castbar
        ["height"] = 21, -- height of target castbar
    },
    focus = {
        ["width"] = 350, -- width of focus castbar
        ["height"] = 26, -- height of focus castbar
    },
    focustarget = {
        ["width"] = 250, -- width of focus castbar
        ["height"] = 21, -- height of focus castbar
    }
}
