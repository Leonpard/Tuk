--------------------------------------------------------------------
-- data meter overlay
--------------------------------------------------------------------

if TukuiCF["datatext"].meter and TukuiCF["datatext"].meter > 0 then
	
	TukuiCF["meter"] = {}
	TukuiCF["meter"].desc = "Generic Meter"
	TukuiCF["meter"].toggle = nil
	TukuiCF["meter"].getRaidValuePerSecond = nil
	TukuiCF["meter"].getSumtable = nil
	TukuiCF["meter"].hooked = false
	
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	
	function checkHealer()
		TukuiDB.isHealer = false
		if ((TukuiDB.myclass == "PALADIN" and GetPrimaryTalentTree() == 1) or
		(TukuiDB.myclass == "SHAMAN" and GetPrimaryTalentTree() == 3) or 
		(TukuiDB.myclass == "DRUID" and GetPrimaryTalentTree() == 3) or 
		(TukuiDB.myclass == "PRIEST" and GetPrimaryTalentTree() ~= 3) ) then
			TukuiDB.isHealer =true
		end 		
	end
	
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	Stat:RegisterEvent("PLAYER_TALENT_UPDATE")
	Stat:RegisterEvent("CHARACTER_POINTS_CHANGED")
	Stat:RegisterEvent("UNIT_INVENTORY_CHANGED")
	Stat:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	Stat:SetScript("OnEvent", checkHealer)
	checkHealer()
	
	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	TukuiDB.PP(TukuiCF["datatext"].meter, Text)

	local reportMode = "Current"			-- default report its current
	---local reportMode = "Overall"			-- default report its overall
	
	local DataTextFormat = "raid"			-- Show raid dps/healing
	--local DataTextFormat = "personal"		-- Show my personal dps/healing
	--local DataTextFormat = "both"			-- Show my personal dps/healing and raid dps/healing
		
	
	Stat:SetScript("OnMouseDown", function(self, btn) 
		GameTooltip:Hide()
								
		if btn == "LeftButton" then		
		
			if TukuiCF["meter"].toggle ~= nil then
				TukuiCF["meter"].toggle()
			end	
			
		elseif btn == "MiddleButton" then			
			GameTooltip:Hide() 		
			if DataTextFormat == "raid" then
				DataTextFormat = "personal"
			elseif DataTextFormat == "personal" then
				DataTextFormat = "both"
			elseif DataTextFormat == "both" then
				DataTextFormat = "raid"
			end
		elseif btn == "RightButton" then
		
			if reportMode=="Current" then
				reportMode="Overall"
			else
				reportMode="Current"
			end
			OnEnter(self)			
		end
	end)
		
	local int = 1	
	local function Update(self, t)
	
		
		local dataMode = "DPS"
		if 	TukuiDB.isHealer then
			dataMode = "Heal"
		end
		
		int = int - t
		if int < 0 then
		
			local rps = 0
			local mydps = 0
			
			if TukuiCF["meter"].getRaidValuePerSecond ~= nil then
				if reportMode == "Overall" then			
					rps,mydps = TukuiCF["meter"].getRaidValuePerSecond("OverallData", dataMode)
				else
					if InCombatLockdown() then
						rps,mydps = TukuiCF["meter"].getRaidValuePerSecond("CurrentFightData", dataMode)				
					else
						rps,mydps = TukuiCF["meter"].getRaidValuePerSecond("LastFightData", dataMode)								
					end						
				end		
			end			
		
			if DataTextFormat == "raid" then
				Text:SetText(string.format("R:%.1fK",rps/1000))      
			elseif DataTextFormat == "personal" then
				Text:SetText(string.format("P:%.1fK",mydps/1000))      
			elseif DataTextFormat == "both" then
				Text:SetText(string.format("P:%.1fK R:%.1fK",mydps/1000,rps/1000))      
			end		
			
			
			self:SetAllPoints(Text)
			int = 1
		end
	end

	Stat:SetScript("OnUpdate", Update)
	
	local ConvertDataSet={}
	ConvertDataSet["OverallData"] = "Overall Data"
	ConvertDataSet["CurrentFightData"]= "Current Fight"
	ConvertDataSet["LastFightData"] = "Last Fight"
	
	local tthead = {r=0.4,g=0.78,b=1}
	local theal = {r=0,g=1,b=0}
	local tdamage = {r=1,g=0,b=0}
	local notgroup = {r = 0.35686274509804, g = 0.56470588235294, b = 0.031372549019608}
	local colortable = {}
	for class, color in pairs(_G["RAID_CLASS_COLORS"]) do
     colortable[class] = { r = color.r, g = color.g, b = color.b }
	end
	
	colortable["PET"] = {r = 0.09, g = 0.61, b = 0.55}
	colortable["UNKNOWN"] = {r = 0.49803921568627, g = 0.49803921568627, b = 0.49803921568627}
	colortable["MOB"] = {r = 0.58, g = 0.24, b = 0.63}
	colortable["UNGROUPED"] = {r = 0.63, g = 0.58, b = 0.24}
	colortable["HOSTILE"] = {r = 0.7, g = 0.1, b = 0.1}

	
	function DisplayTable(mode,repotType,amount)
	
		if TukuiCF["meter"].getSumtable ~= nil then
		
			StatsTable,totalsum, totalpersec = TukuiCF["meter"].getSumtable(mode, repotType)
		
			if repotType == "DPS" then
				GameTooltip:AddDoubleLine("Damage Done",ConvertDataSet[mode],tdamage.r,tdamage.g,tdamage.b,tthead.r,tthead.g,tthead.b)
			elseif repotType == "Heal" then			
				GameTooltip:AddDoubleLine("Healing Done",ConvertDataSet[mode],theal.r,theal.g,theal.b,tthead.r,tthead.g,tthead.b)
			end
					
			local numofcombatants = #StatsTable
			
			if numofcombatants == 0 then		
				GameTooltip:AddLine("No data to display")
			else		
				if numofcombatants > amount then
					numofcombatants = amount
				end
				GameTooltip:AddDoubleLine("Total",format("%d (%.1f) 100.0%%",totalsum,totalpersec))
				
				for i = 1, numofcombatants do			
				
					if StatsTable[i].enclass then
						classc = colortable[StatsTable[i].enclass]			
					else
						classc = notgroup
					end
					
					if repotType == "DPS" then		
						GameTooltip:AddDoubleLine(StatsTable[i].name,format("%d (%.1f) %.1f%%",StatsTable[i].damage,StatsTable[i].dps, math.floor(1000*StatsTable[i].damage/totalsum)/10),classc.r,classc.g,classc.b,classc.r,classc.g,classc.b)
					elseif repotType == "Heal" then									
						GameTooltip:AddDoubleLine(StatsTable[i].name,format("%d (%.1f) %.1f%%",StatsTable[i].healing,StatsTable[i].hps, math.floor(1000*StatsTable[i].healing/totalsum)/10),classc.r,classc.g,classc.b,classc.r,classc.g,classc.b)					
					end
				end
			end
		end
	end
	
	function CreateTooltipData(amount)
	
		GameTooltip:AddLine(TukuiCF["meter"].desc,tthead.r,tthead.g,tthead.b)
		
		if reportMode == "Overall" then
			DisplayTable("OverallData", "DPS",amount)
			
			GameTooltip:AddLine(" ")
			
			DisplayTable("OverallData", "Heal",amount)
		else
			if InCombatLockdown() then
				DisplayTable("CurrentFightData", "DPS",amount)
			else
				DisplayTable("LastFightData", "DPS",amount)
			end			
			
			GameTooltip:AddLine(" ")
			
			if InCombatLockdown() then
				DisplayTable("CurrentFightData", "Heal",amount)
			else
				DisplayTable("LastFightData", "Heal",amount)
			end			
		end				
		
	end	
	
	function OnEnter(self)

		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, TukuiDB.Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:ClearLines()					
		
		CreateTooltipData(10)
		
		GameTooltip:Show()	
		
	end

	
	Stat:SetScript("OnEnter", OnEnter)
	
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)	
	
	Update(Stat, 10)
end