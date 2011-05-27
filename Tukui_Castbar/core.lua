-- Standalone Castbar for Tukui by Krevlorne @ EU-Ulduar
-- Credits to Tukz, Syne, Elv22, Sweeper and all other great people of the Tukui community.

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if ( C == nil or C["unitframes"] == nil or not C["unitframes"]["enable"] ) then return; end

if (C["unitframes"].unitcastbar ~= true) then return; end

local addon, ns=...
config = ns.config

local function placeCastbar(unit)
    local font1 = C["media"].uffont
    local castbar = nil
    local castbarpanel = nil
    
    if (unit == "player") then
        castbar = TukuiPlayerCastBar
    elseif (unit == "target") then
        castbar = TukuiTargetCastBar
    elseif (unit == "focus") then
        castbar = TukuiFocusCastBar
    elseif (unit == "focustarget") then
        castbar = TukuiFocusTargetCastBar
    else
        print("Tukui_Castbar: Cannot place castbar for unit: "..unit)
        return
    end

    local castbarpanel = CreateFrame("Frame", castbar:GetName().."_Panel", castbar)
    castbarpanel:CreateShadow("Default")
    local anchor = CreateFrame("Button", castbar:GetName().."_PanelAnchor", UIParent)
    anchor:SetTemplate("Default")
    anchor:SetBackdropBorderColor(1, 0, 0, 1)
    anchor:SetMovable(true)
    anchor.text = T.SetFontString(anchor, font1, 12)
    anchor.text:SetPoint("CENTER")
    anchor.text:SetText(castbar:GetName())
    anchor.text.Show = function() anchor:Show() end
    anchor.text.Hide = function() anchor:Hide() end
    anchor:Hide()
    
    if unit == "player" then
        anchor:SetSize(config["player"]["width"], config["player"]["height"])
        anchor:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
        castbarpanel:CreatePanel("Default", config["player"]["width"], config["player"]["height"], "CENTER", anchor, "CENTER", 0, 0)
    elseif (unit == "target") then
        anchor:SetSize(config["target"]["width"], config["target"]["height"])
        anchor:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
        castbarpanel:CreatePanel("Default", config["target"]["width"], config["target"]["height"], "CENTER", anchor, "CENTER", 0, 0)
    elseif (unit == "focus") then
        anchor:SetSize(config["focus"]["width"], config["focus"]["height"])
        anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
        castbarpanel:CreatePanel("Default", config["focus"]["width"], config["focus"]["height"], "CENTER", anchor, "CENTER", 0, 0)
    elseif (unit == "focustarget") then
        anchor:SetSize(config["focustarget"]["width"], config["focustarget"]["height"])
        anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 210)
        castbarpanel:CreatePanel("Default", config["focustarget"]["width"], config["focustarget"]["height"], "CENTER", anchor, "CENTER", 0, 0)
    end
    
    castbar:ClearAllPoints()        
    castbar:Point("TOPLEFT", castbarpanel, 2, -2)
    castbar:Point("BOTTOMRIGHT", castbarpanel, -2, 2)

    castbar.time = T.SetFontString(castbar, font1, 12)
    castbar.time:Point("RIGHT", castbarpanel, "RIGHT", -4, 0)
    castbar.time:SetTextColor(0.84, 0.75, 0.65)
    castbar.time:SetJustifyH("RIGHT")

    castbar.Text = T.SetFontString(castbar, font1, 12)
    castbar.Text:Point("LEFT", castbarpanel, "LEFT", 4, 0)
    castbar.Text:SetTextColor(0.84, 0.75, 0.65)

    if C["unitframes"].cbicons == true then
        if unit == "player" then
            castbar.button:ClearAllPoints()
            castbar.button:Point("RIGHT", castbar, "LEFT", -10, 0)
        elseif unit == "target" then
            castbar.button:ClearAllPoints()
            castbar.button:Point("LEFT", castbar, "RIGHT", 10, 0)
        elseif unit == "focus" then
            castbar.button:ClearAllPoints()
            castbar.button:Point("BOTTOM", castbar, "TOP", 0, 10)
            castbar.button:Size(50)
            castbar.button:CreateShadow("Default")
            
            castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
            castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
            castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
        elseif unit == "focustarget" then
            castbar.button:Size(26)
            castbar.button:CreateShadow("Default")
            castbar.button:Point("LEFT", castbar, "RIGHT", 10, 0)
        end
    end
    
    -- cast bar latency
    local normTex = C["media"].normTex;
    if C["unitframes"].cblatency == true and (unit == "player" or unit == "target") then
        castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
        castbar.safezone:SetTexture(normTex)
        castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
        castbar.SafeZone = castbar.safezone
    end
    
    castbar.Castbar = castbar    
    castbar.Castbar.Time = castbar.time
    castbar.Castbar.Icon = castbar.icon
end


if (config.separateplayer) then
    placeCastbar("player")
    table.insert(T.MoverFrames, TukuiPlayerCastBar_PanelAnchor)
end

if (config.separatetarget) then
    placeCastbar("target")
    table.insert(T.MoverFrames, TukuiTargetCastBar_PanelAnchor)
end

if (config.separatefocus) then
    placeCastbar("focus")
    table.insert(T.MoverFrames, TukuiFocusCastBar_PanelAnchor)
end

if (config.separatefocustarget and C["showfocustarget"]) then
    placeCastbar("focustarget")
    table.insert(T.MoverFrames, TukuiFocusTargetCastBar_PanelAnchor)
end
