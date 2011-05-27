local T, C, L = unpack(Tukui)
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local pluginObjects = {}

local TukuiDataBroker = CreateFrame("Frame")

TukuiDataBroker:RegisterEvent("PLAYER_LOGIN")
TukuiDataBroker:SetScript("OnEvent", function(_, event, ...) TukuiDataBroker[event](TukuiDataBroker, ...) end)

-- Helper function to create a frame to display at a specific TukUI panel position
-- Based on code from "TukUI (Extra panel stats)" 
local function CreatePanelFrame(position)
	-- Create the frame and text objects
	local Frame = CreateFrame("Frame")
	Frame:EnableMouse(true)
	Frame:SetFrameStrata("BACKGROUND")
	Frame:SetFrameLevel(3)
	
	local Text = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C["media"].font, C["datatext"].fontsize)
	Text:SetHeight(TukuiInfoLeft:GetHeight())

	-- Make sure the frame has the same position as the text, so we can add support
	-- for mouse actions
	Frame:SetAllPoints(Text)

	-- Finally, set the text position on the info panel
	T.PP(position, Text)

	return Frame, Text
end
	
local function OnMouseDown(frame, btn)
	if frame.pluginObject.OnClick then
		frame.pluginObject.OnClick(frame, btn)
	end
end

local function OnTooltipEnter(frame)
	if not InCombatLockdown() then
		local obj = frame.pluginObject
		if not frame.isMoving and obj.OnTooltipShow then
			local anchor, yoff = T.DataTextTooltipAnchor(pluginObjects[frame.pluginName])
			GameTooltip:SetOwner(frame, anchor, 0, yoff);
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", frame, "TOP", 0, T.mult)
			GameTooltip:ClearLines()	
			obj.OnTooltipShow(GameTooltip, frame)
			GameTooltip:Show()
		elseif obj.OnEnter then
			obj.OnEnter(frame)
		end
	end
end

local function OnTooltipLeave(frame)
	GameTooltip:Hide()

	if frame.pluginObject.OnLeave then
		frame.pluginObject.OnLeave(frame)
	end
end

function TukuiDataBroker:New(_, name, obj)
	if C["broker_datatext"] ~= nil and C["broker_datatext"][name] ~= nil and C["broker_datatext"][name] > 0 and not pluginObjects[name] then
		local Frame, Text = CreatePanelFrame(C["broker_datatext"][name])

		-- Save info about the plugin into the Frame 
		Frame.pluginName = name
		Frame.pluginObject = obj
			
		-- Text is updated independently of the Frame so store it separately
		pluginObjects[name] = Text
			
		if obj.suffix then
			self:ValueUpdate(nil, name, nil, obj.value or name, obj)
			ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..name.."_value", "ValueUpdate")
		else
			self:TextUpdate(nil, name, nil, obj.text or obj.label or name)
			ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..name.."_text", "TextUpdate")
		end
			
		Frame:SetScript("OnEnter", OnTooltipEnter)
		Frame:SetScript("OnLeave", OnTooltipLeave)
		Frame:SetScript("OnMouseDown", OnMouseDown)

		if obj.OnCreate then obj.OnCreate(obj, Frame) end
	end
end

function TukuiDataBroker:TextUpdate(_, name, _, data)
	pluginObjects[name]:SetText(data)
end

function TukuiDataBroker:ValueUpdate(_, name, _, data, obj)
	pluginObjects[name]:SetFormattedText("%s %s", data, obj.suffix)
end

function TukuiDataBroker:PLAYER_LOGIN()
	TukuiDataBroker:SetScript("OnEvent", nil)
	self:UnregisterEvent("PLAYER_LOGIN")
	ldb.RegisterCallback(self, "LibDataBroker_DataObjectCreated", "New")
		
	for name, obj in ldb:DataObjectIterator() do
		if not pluginObjects[name] then
			self:New(nil, name, obj)
		end
	end
	self.PLAYER_LOGIN = nil
end

SLASH_TUKUIDATABROKER1 = '/showldb'
function SlashCmdList.TUKUIDATABROKER(msg, editbox)
	for name, obj in ldb:DataObjectIterator() do
        print(name)
    end
end
