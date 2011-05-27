local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- By Gorlasch at Tukui.org
-- Credits to: Foof, Hydra and HyPeRnIcS

if C.togglemenu.positionbelowMinimap == true then
    C.togglemenu.buttonwidth = TukuiMinimap:GetWidth() - 2 * C.togglemenu.buttonspacing
end

local function buttonwidth(num)
    return num * C.togglemenu.buttonwidth
end
local function buttonheight(num)
    return num * C.togglemenu.buttonheight
end
local function buttonspacing(num)
    return num * C.togglemenu.buttonspacing
end
local function borderwidth(num)
    return buttonwidth(num) + buttonspacing(num+1)
end
local function borderheight(num)
    return buttonheight(num) + buttonspacing(num+1)
end
local defaultframelevel = 0

function RunSlashCmd(cmd)
    local slash, rest = cmd:match("^(%S+)%s*(.-)$")
    for name, func in pairs(SlashCmdList) do
        local i, slashCmd = 1
        repeat
            slashCmd, i = _G["SLASH_"..name..i], i + 1
            if slashCmd == slash then
                return true, func(rest)
            end
        until not slashCmd
    end
end

local function updateTextures(button, checkable)
    button:StyleButton(checkable)
    if not C.togglemenu.useDefaultButtons then
        if checkable then
            button:GetCheckedTexture():SetTexture(1, 1, 1, .3)
        end
        button:GetHighlightTexture():SetTexture(0, 0, 0, 0)
        button:GetPushedTexture():SetTexture(0, 0, 0, 0)
        button:HookScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hovercolor)) end)
        button:HookScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
    end
end

local MenuBG = CreateFrame("Frame", "TTMenuBackground", UIParent)
local AddonBG = CreateFrame("Frame", "TTMenuAddOnBackground", UIParent)

if C.togglemenu.positionnexttoMinimap == true then
    if C.togglemenu.positionbelowMinimap == true then
        if C.togglemenu.positionInverted then
            menuAnchorPos = "TOPLEFT"
            bgAnchorPos = "BOTTOMLEFT"
            menuAnchor = TukuiMinimapStatsLeft
        else
            menuAnchorPos = "TOPRIGHT"
            bgAnchorPos = "BOTTOMRIGHT"        
            menuAnchor = TukuiMinimapStatsRight
        end
        if not TukuiMinimapStatsRight then
            menuAnchor = TukuiMinimap
        end
        MenuBG:CreatePanel("Default", borderwidth(1), borderheight(5), menuAnchorPos, menuAnchor, bgAnchorPos, 0, -1 * (buttonspacing(1) + C.togglemenu.positionOffset))
    else
        if C.togglemenu.positionInverted then
            menuAnchorPos = "TOPLEFT"
            bgAnchorPos = "TOPRIGHT"
            direction = 1
        else
            menuAnchorPos = "TOPRIGHT"
            bgAnchorPos = "TOPLEFT"        
            direction = -1
        end
        MenuBG:CreatePanel("Default", borderwidth(1), 1, menuAnchorPos, TukuiMinimap, bgAnchorPos, direction * (buttonspacing(1) + C.togglemenu.positionOffset), 0)    
    end
    AddonBG:CreatePanel("Default", borderwidth(1), 1, menuAnchorPos, MenuBG, menuAnchorPos, 0, 0)
else
    MenuBG:CreatePanel("Default", borderwidth(1), 1, "TOP", UIParent, "TOP", 0, buttonspacing(-5) - C.togglemenu.positionOffset)
    AddonBG:CreatePanel("Default", borderwidth(1), 1, "TOP", MenuBG, "TOP", 0, 0)
end
MenuBG:SetFrameLevel(defaultframelevel+0)
MenuBG:SetFrameStrata("HIGH")
if not C.togglemenu.showByDefault or C.togglemenu.mergeMenus then
    MenuBG:Hide()
end 
AddonBG:SetFrameLevel(defaultframelevel+0)
AddonBG:SetFrameStrata("HIGH")
if not C.togglemenu.showByDefault or not C.togglemenu.mergeMenus then
    AddonBG:Hide()
end 

function ToggleMenu_Toggle()
    if TTMenuAddOnBackground:IsShown() or TTMenuBackground:IsShown() then
        TTMenuAddOnBackground:Hide()
        TTMenuBackground:Hide()
    else
        if C.togglemenu.mergeMenus then
            TTMenuAddOnBackground:Show()
        else
            TTMenuBackground:Show()
        end
        if C.togglemenu.addOpenMenuButton then
            TTOpenMenuBackground:SetAlpha(0)
        end
    end
end

-- Add slash command
SLASH_TUKUITOGGLEMENU1 = "/ttm"
SlashCmdList.TUKUITOGGLEMENU = ToggleMenu_Toggle

-- Integrate the menu into TukuiRightCube
if TukuiCubeRight and C.togglemenu.useTukuiCubeRight == true then
    local ToggleCube = CreateFrame("Frame", "TukuiToggleCube", UIParent)
    ToggleCube:CreatePanel("Default", TukuiCubeRight:GetWidth(), TukuiCubeRight:GetHeight(), "CENTER", TukuiCubeRight, "CENTER", 0, 0)
    ToggleCube:SetFrameLevel(TukuiCubeRight:GetFrameLevel() + 1)
    ToggleCube:EnableMouse(true)
    ToggleCube:SetScript("OnMouseDown", function() ToggleMenu_Toggle() end)
end

-- Integrate the menu into the panel
if C.togglemenu.useDataText and C.togglemenu.useDataText > 0 then
    local DataText = CreateFrame("Frame")
    DataText:EnableMouse(true)
    DataText:SetFrameStrata("BACKGROUND")
    DataText:SetFrameLevel(3)
    local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
    Text:SetFont(C.media.font, C["datatext"].fontsize)
    T.PP(C.togglemenu.useDataText, Text)
    Text:SetText(C.togglemenu.DataTextTitle)
    DataText:SetAllPoints(Text)
    DataText:SetScript("OnMouseDown", function() ToggleMenu_Toggle() end)
end

-- color sh*t
if C.togglemenu.classcolor == true then
    local classcolor = RAID_CLASS_COLORS[T.myclass]
    hovercolor = {classcolor.r,classcolor.g,classcolor.b,1}
end

local mainmenusize
local lastMainMenuEntryID
local totalmainmenusize
local function addMainMenuButtons(menuItems, menuName, menuBackground)
    lastMainMenuEntryID = 0
    mainmenusize = 0

    local function InsertButton(items, i, hide)
        if hide then
            items[i]:Hide()
        else
            lastMainMenuEntryID = i
            mainmenusize = mainmenusize + 1
        end
    end

    for index, value in ipairs(C.togglemainmenu) do
        if value.text then
            menuItems[index] = CreateFrame("Button", menuName..index, menuBackground)
            menuItems[index]:CreatePanel("Default", buttonwidth(1), buttonheight(1), "TOP", menuBackground, "TOP", 0, buttonspacing(-1))
            menuItems[index]:SetFrameLevel(defaultframelevel+1)
            menuItems[index]:SetFrameStrata("HIGH")
            if mainmenusize == 0 then
                menuItems[index]:SetPoint("TOPLEFT", menuBackground, "TOPLEFT", buttonspacing(1), buttonspacing(-1))
            else
                menuItems[index]:SetPoint("TOP", menuItems[lastMainMenuEntryID], "BOTTOM", 0, buttonspacing(-1))
            end
            menuItems[index]:EnableMouse(true)
            menuItems[index]:RegisterForClicks("AnyUp")
            menuItems[index]:SetScript("OnClick", function() value["function"]() end)

            Text = menuItems[index]:CreateFontString(nil, "LOW")
            Text:SetFont(C.togglemenu.font, C.togglemenu.fontsize)
            Text:SetPoint("CENTER", menuItems[index], 0, 0) 
            Text:SetText(value.text)
        
            local hideItem = (C.togglemenu.mergeMenus and (value.text == "AddOns"))
            InsertButton(menuItems, index, hideItem)
            updateTextures(menuItems[index])
            totalmainmenusize = index            
        end
    end
end

local menu = {} -- Main buttons
addMainMenuButtons(menu, "Menu", MenuBG)
MenuBG:SetHeight(borderheight(mainmenusize))

local addonmenuitems = {};
if C.togglemenu.mergeMenus then
    addMainMenuButtons(addonmenuitems, "AddonMenu", AddonBG)
else
    mainmenusize = 1
    lastMainMenuEntryID = 1
    totalmainmenusize = 1
    addonmenuitems[1] = CreateFrame("Button", "AddonMenuReturnButton", AddonBG)
    addonmenuitems[1]:CreatePanel("Default", buttonwidth(1), buttonheight(1), "TOPLEFT", AddonBG, "TOPLEFT", buttonspacing(1), buttonspacing(-1))
    addonmenuitems[1]:EnableMouse(true)
    addonmenuitems[1]:RegisterForClicks("AnyUp")
    addonmenuitems[1]:SetFrameLevel(defaultframelevel+1)
    addonmenuitems[1]:SetFrameStrata("HIGH")
    addonmenuitems[1]:SetScript("OnMouseUp", function() ToggleFrame(TTMenuAddOnBackground); ToggleFrame(TTMenuBackground); end)
    updateTextures(addonmenuitems[1])
    Text = addonmenuitems[1]:CreateFontString(nil, "LOW")
    Text:SetFont(C.togglemenu.font, C.togglemenu.fontsize)
    Text:SetPoint("CENTER", addonmenuitems[1], 0, 0)
    Text:SetText("Return")
end

local OpenMenuBG = CreateFrame("Button", "TTOpenMenuBackground", UIParent)
OpenMenuBG:CreatePanel("Default", borderwidth(1), buttonheight(1)/2, "TOP", MenuBG, "TOP", 0, 0)
OpenMenuBG:SetFrameLevel(defaultframelevel+0)
OpenMenuBG:SetFrameStrata("HIGH")
OpenMenuBG:EnableMouse(true)
OpenMenuBG:RegisterForClicks("AnyUp")
OpenMenuBG:SetFrameLevel(defaultframelevel+0)
OpenMenuBG:SetFrameStrata("HIGH")
OpenMenuBG:SetScript("OnMouseUp", function() ToggleMenu_Toggle() end)
OpenMenuBG:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
OpenMenuBG:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
--updateTextures(OpenMenuBG)
Text = OpenMenuBG:CreateFontString(nil, "LOW")
Text:SetFont(C.togglemenu.font, C.togglemenu.fontsize)
Text:SetPoint("CENTER", OpenMenuBG, 0, 0)
Text:SetText("v")
if not C.togglemenu.addOpenMenuButton then
    TTOpenMenuBackground:Hide()
else
    TTOpenMenuBackground:SetAlpha(0)
end

local expandbutton = CreateFrame("Button", "AddonMenuExpandButton", AddonBG)
expandbutton:CreatePanel("Default", buttonwidth(1), buttonheight(1)/2, "BOTTOM", AddonBG, "BOTTOM", 0, buttonspacing(1))
expandbutton:EnableMouse(true)
expandbutton:RegisterForClicks("AnyUp")
expandbutton:SetFrameLevel(defaultframelevel+1)
expandbutton:SetFrameStrata("HIGH")
updateTextures(expandbutton)
Text = expandbutton:CreateFontString(nil, "LOW")
Text:SetFont(C.togglemenu.font, C.togglemenu.fontsize)
Text:SetPoint("CENTER", expandbutton, 0, 0)
Text:SetText("+")
expandbutton.txt = Text
if C.togglemenu.dontShowToggleOnlyMenu then
    expandbutton:Hide()
    C.togglemenu.defaultIsToggleOnly = false
end

local addonInfo
local lastMainAddon = "XYZNonExistantDummyAddon"
local menusize
local lastMainAddonID = 0
if not addonInfo then
    addonInfo = {{}}
    for i = 1,GetNumAddOns() do
        name,title,_, enabled, _, _, _ = GetAddOnInfo(i)
        if(name and enabled) then
            addonInfo[i] = {["enabled"] = true,  ["is_main"] = false, collapsed = true, ["parent"] = i}
        else
            addonInfo[i] = {["enabled"] = false, ["is_main"] = false, collapsed = true, ["parent"] = i}
        end
        -- check special addon list first
        local addonFound = false
        for key, value in pairs(C["toggleprefix"]) do
            if strsub(name, 0, strlen(key)) == key then
                addonFound = true
                if name == value then
                    lastMainAddon = name
                    lastMainAddonID = i
                    addonInfo[i].is_main = true
                else
                    addonInfo[i].parent = lastMainAddonID
                    for j = 1,GetNumAddOns() do
                        name_j, _, _, _, _, _, _ = GetAddOnInfo(j)
                        if name_j == value then
                            addonInfo[i].parent = j
                        end
                    end
                end
            end
        end
        -- collapse addons with common prefix
        if not addonFound then
            if strsub(name, 0, strlen(lastMainAddon)) == lastMainAddon then
                addonInfo[lastMainAddonID].is_main = true
                addonInfo[i].parent = lastMainAddonID
            else
                lastMainAddon = name
                lastMainAddonID = i
            end
        end
    end
end

local function addonEnableToggle(self, i)
    local was_enabled = addonInfo[i].enabled
    for j = 1,GetNumAddOns() do
        if ((addonInfo[j].parent == i and addonInfo[i].collapsed) or (i==j and not addonInfo[addonInfo[i].parent].collapsed)) then
            if was_enabled then
                DisableAddOn(j)
            else
                EnableAddOn(j)
            end
            addonInfo[j].enabled = not was_enabled
        end
    end
end

local function addonFrameToggle(self, i)
    local name, _,_, _, _, _, _ = GetAddOnInfo(i)
    if C.toggleaddons[name] then
        if IsAddOnLoaded(i) then
            C.toggleaddons[name]()
        end
    end
end

local addonToggleOnly = C.togglemenu.defaultIsToggleOnly

local function refreshAddOnMenu()
    menusize = mainmenusize
    for i = 1,GetNumAddOns() do
        local name, _, _, _, _, _, _ = GetAddOnInfo(i)
        if (addonInfo[i].is_main or (addonInfo[i].parent == i) or not addonInfo[addonInfo[i].parent].collapsed) then
            if (not addonToggleOnly or (C.toggleaddons[name] and IsAddOnLoaded(i))) then
                menusize = menusize + 1
            end
        end
    end
    if C.togglemenu.maxMenuEntries and C.togglemenu.maxMenuEntries > 0 then
        menuwidth  = ceil(menusize/C.togglemenu.maxMenuEntries)
    else
        menuwidth  = 1
    end
    menuheight = ceil(menusize/menuwidth)

    local lastMenuEntryID = lastMainMenuEntryID
    menusize = mainmenusize
    for i = 1,GetNumAddOns() do
        j=totalmainmenusize+i
        local name, _,_, _, _, _, _ = GetAddOnInfo(i)
        addonmenuitems[j]:Hide()        
        if (addonInfo[i].is_main or (addonInfo[i].parent == i) or not addonInfo[addonInfo[i].parent].collapsed) then
            if (not addonToggleOnly or (C.toggleaddons[name] and IsAddOnLoaded(i))) then
                addonmenuitems[j]:ClearAllPoints()
                if menusize % menuheight == 0 then
                    addonmenuitems[j]:SetPoint( "LEFT", addonmenuitems[lastMenuEntryID], "RIGHT", buttonspacing(1), borderheight(menuheight - 1) - buttonspacing(1))
                else
                    addonmenuitems[j]:SetPoint( "TOP", addonmenuitems[lastMenuEntryID], "BOTTOM", 0, buttonspacing(-1))
                end
                addonmenuitems[j]:Show()
                lastMenuEntryID = j
                menusize = menusize + 1
            end
        end
        if addonInfo[i].is_main then
            if addonToggleOnly then
                addonmenuitems[j].expandbtn:Hide()
            else
                addonmenuitems[j].expandbtn:Show()
            end
        end
    end
    if not C.togglemenu.dontShowToggleOnlyMenu then
        AddonBG:SetHeight(borderheight(menuheight+1) - buttonheight(1)/2)
    else
        AddonBG:SetHeight(borderheight(menuheight))
    end
    AddonBG:SetWidth(borderwidth(menuwidth))
    expandbutton:SetWidth(buttonwidth(menuwidth) + buttonspacing(menuwidth-1))
end

expandbutton:SetScript("OnMouseUp", function(self) 
    addonToggleOnly = not addonToggleOnly
    if addonToggleOnly then
        self.txt:SetText("+")
    else
        self.txt:SetText("-")
    end
    refreshAddOnMenu()
end)

for i = 1,GetNumAddOns() do
    j=totalmainmenusize+i
    local name, _,_, _, _, _, _ = GetAddOnInfo(i)
    addonmenuitems[j] = CreateFrame("CheckButton", "AddonMenu"..j, AddonBG)
    addonmenuitems[j]:CreatePanel("Default", buttonwidth(1), buttonheight(1), "TOP", AddonBG, "TOP", 0, buttonspacing(-1))
    addonmenuitems[j]:EnableMouse(true)
    addonmenuitems[j]:RegisterForClicks("AnyUp")
    addonmenuitems[j]:SetFrameLevel(defaultframelevel+1)
    addonmenuitems[j]:SetFrameStrata("HIGH")
    updateTextures(addonmenuitems[j], true)
    
    addonmenuitems[j]:SetChecked(not addonInfo[i].enabled)
    addonmenuitems[j]:SetScript("OnMouseUp", function(self, btn)
        if btn == "RightButton" then
            addonEnableToggle(self, i)
        else
            addonFrameToggle(self, i)
            self:SetChecked(not self:GetChecked()) -- prevent left clicks from changing state
        end                
    end)
    addonmenuitems[j]:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_NONE', 0, 0)
        GameTooltip:AddLine("Addon "..name)
        GameTooltip:AddLine("Rightclick to enable or disable (needs UI reload)")            
        if C.toggleaddons[name] then
            if IsAddOnLoaded(i) then
                GameTooltip:AddLine("Leftclick to toggle addon window")
            end
        end
        GameTooltip:Show()
    end)
    addonmenuitems[j]:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    Text = addonmenuitems[j]:CreateFontString(nil, "LOW")
    Text:SetFont(C.togglemenu.font, C.togglemenu.fontsize)
    Text:SetPoint("CENTER", addonmenuitems[j], 0, 0)
    Text:SetText(select(2,GetAddOnInfo(i)))
    if addonInfo[i].is_main then
        local expandAddonButton = CreateFrame("Button", "AddonMenuExpand"..j, addonmenuitems[j])
        expandAddonButton:CreatePanel("Default", buttonheight(1)-buttonspacing(2), buttonheight(1)-buttonspacing(2), "TOPLEFT", addonmenuitems[j], "TOPLEFT", buttonspacing(1), buttonspacing(-1))
        expandAddonButton:SetFrameLevel(defaultframelevel+2)
        expandAddonButton:SetFrameStrata("HIGH")
        expandAddonButton:EnableMouse(true)
        expandAddonButton:RegisterForClicks("AnyUp")
        updateTextures(expandAddonButton)
        
        expandAddonButton:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_NONE', 0, 0)
            if addonInfo[i].collapsed then
                GameTooltip:AddLine("Expand "..name.." addons")
            else
                GameTooltip:AddLine("Collapse "..name.." addons")
            end
            GameTooltip:Show()
        end)
        expandAddonButton:HookScript("OnLeave", function(self)
            GameTooltip:Hide()
            end)

        Text = expandAddonButton:CreateFontString(nil, "LOW")
        Text:SetFont(C.togglemenu.font, C.togglemenu.fontsize)
        Text:SetPoint("CENTER", expandAddonButton, 0, 0)
        Text:SetText("+")
        expandAddonButton.txt = Text
        expandAddonButton:SetScript("OnMouseUp", function(self)
            addonInfo[i].collapsed = not addonInfo[i].collapsed
            if addonInfo[i].collapsed then
                self.txt:SetText("+")
            else
                self.txt:SetText("-")
            end
            refreshAddOnMenu()
        end)
        addonmenuitems[j].expandbtn = expandAddonButton
    end
    addonmenuitems[j]:Hide()
end

refreshAddOnMenu()
