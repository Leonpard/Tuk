local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

C["togglemenu"] = {
    -- style
    ["font"] = C.media.font,                    -- Font to be used for button text
    ["fontsize"] = 12,                          -- Size of font for button text
    ["buttonwidth"] = 190,                      -- Width of menu buttons
    ["buttonheight"] = 20,                      -- Height of menu buttons
    ["buttonspacing"] = 3,                      -- Spacing of menu buttons
    ["classcolor"] = true,                      -- Class color buttons
    ["hovercolor"] = {0,.8,1,1},                -- Color of buttons on mouse-over (if classcolor is false)
    ["useDefaultButtons"] = false,              -- Use TukUI actionbar highlighting scheme
    -- position
    ["positionnexttoMinimap"] = true,           -- Show the menu next to the minimap
    ["positionbelowMinimap"] = true,            -- Show the menu below minimap (false - left of minimap), sets buttonwidth to width of minimap
    ["positionOffset"] = 0,                     -- Increases distance between minimap and menu
    ["positionInverted"] = false,               -- Inverts anchor and column expansion (use ,e.g., if minimap is on left side)
    -- menus
    ["defaultIsToggleOnly"] = true,             -- Sets the default value for the addon menu (true - toggle-only, false - enhanced version)
    ["dontShowToggleOnlyMenu"] = false,         -- Always show enhanced addon menu
    ["mergeMenus"] = false,                     -- Merge main and addon menu
    ["maxMenuEntries"] = 30,                    -- Maximum number of menu entries per column (0 - unlimited number)
    -- access
    ["useTukuiCubeRight"] = true,               -- Toggle the menu if click on TukuiCubeRight
    ["useDataText"] = 0,                        -- Place the toggle menu on the panel (0 - turn off)
    ["DataTextTitle"] = 'Menu',                 -- Use this text on panel
    ["showByDefault"] = false,                  -- Show the menu by default
    ["addOpenMenuButton"] = true,               -- Creates a mouseover button to open the menu
}

-- override prefix method to collapse addons
C["toggleprefix"] = {
--  prefix            parent addon
    ["DBM"]         = "DBM-Core",
    ["Tukui"]       = "Tukui",
    ["Auc-"]        = "Auc-Advanced",
    ["!Swatter"]    = "Auc-Advanced",
    ["BeanCounter"] = "Auc-Advanced",
    ["Enchantrix"]  = "Auc-Advanced",
    ["Informant"]   = "Auc-Advanced",
    ["SlideBar"]    = "Auc-Advanced",
    ["Stubby"]      = "Auc-Advanced",
}

-- define buttons in main menu and corresponding functions
C["togglemainmenu"] = {
    {    ["text"] = "Close Menu",
        ["function"] = function()
            ToggleMenu_Toggle()
        end
    },
    {    ["text"] = "AddOns",
        ["function"] = function()
            ToggleFrame(TTMenuAddOnBackground)
            ToggleFrame(TTMenuBackground)
        end
    },
    {    ["text"] = "Calendar",
        ["function"] = function()
            ToggleCalendar()
        end
    },
    {    ["text"] = "Reload UI",
        ["function"] = function()
            ReloadUI()
        end
    },
    {    ["text"] = "KeyRing",
        ["function"] = function()
            ToggleKeyRing()
        end
    },
--    {    ["text"] = "Move UI",
--        ["function"] = function()
--            RunSlashCmd("/moveui")
--        end
--    },
}

-- definde toggle functions
C["toggleaddons"] = {
    ["Recount"] = function()
        ToggleFrame(Recount.MainWindow)
        Recount.RefreshMainWindow()
    end,
    
    ["Skada"] = function()
        Skada:ToggleWindow()
    end,
    
    ["GatherMate2"] = function()
        GatherMate2.db.profile["showMinimap"] = not GatherMate2.db.profile["showMinimap"]
        GatherMate2.db.profile["showWorldMap"] = not GatherMate2.db.profile["showWorldMap"]
        GatherMate2:GetModule("Config"):UpdateConfig()
    end,
    
    ["AtlasLoot"] = function()
        ToggleFrame(AtlasLootDefaultFrame)
    end,
    
    ["Omen"] = function()
        ToggleFrame(Omen.Anchor)
    end,
    
    ["DXE"] = function()
        _G.DXE:ToggleConfig()
    end,
    
    ["DBM-Core"] = function()
        DBM:LoadGUI()
    end,
    
    ["TinyDPS"] = function()
        ToggleFrame(tdpsFrame)
    end,
    
    ["Tukui_ConfigUI"] = function()
        SlashCmdList.CONFIG()
    end,

    ["Panda"] = function()
        ToggleFrame(PandaPanel)
    end,

    ["PallyPower"] = function()
        ToggleFrame(PallyPowerFrame)
    end,

    ["ACP"] = function()
        ToggleFrame(ACP_AddonList)
    end,

    ["ScrollMaster"] = function()
        LibStub("AceAddon-3.0"):GetAddon("ScrollMaster").GUI:OpenFrame(1)
    end,
    
    ["PugLax"] = function()
        RunSlashCmd("/puglax")
    end,
}
