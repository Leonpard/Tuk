--------------------------------------------------------------------
-- recount data meter
--------------------------------------------------------------------

if TukuiCF["datatext"].meter and TukuiCF["datatext"].meter > 0 then
	if not IsAddOnLoaded("Recount") then return end
	if TukuiCF["meter"].hooked then return end
	
	local Recount = _G.Recount		
	
	function recountToggle()
	
		if Recount.MainWindow:IsShown() then 
			Recount.MainWindow:Hide() 
		else 
			Recount.MainWindow:Show();Recount:RefreshMainWindow() 
		end
	end

	-- match pets such as elementals with no proper owner, using their unique GUID
	function matchUnitGUID(unitname, guid)
		for _,data in pairs(Recount.db2.combatants) do
			if data.GuardianReverseGUIDs and data.GuardianReverseGUIDs[unitname] and data.GuardianReverseGUIDs[unitname].GUIDs then
				for k,v in pairs(data.GuardianReverseGUIDs[unitname].GUIDs) do
					if v == guid then return true end
				end
			end
		end
		return false
	end		
	
	function recountGetRaidValuePerSecond(tablename, mode)
		local mydps,dps, curdps, data = 0, 0, nil		
		for _,data in pairs(Recount.db2.combatants) do
			if data.Fights and data.Fights[tablename] and (data.type=="Self" or data.type=="Grouped" or data.type=="Pet" or data.type=="Ungrouped") then
				if mode == "DPS" then
					_,curdps = Recount:MergedPetDamageDPS(data,tablename)
				elseif mode == "Heal" then
					_,curdps = Recount:MergedPetHealingDPS(data,tablename)
				end
				if data.type ~= "Pet" or (not Recount.db.profile.MergePets and data.Owner and (Recount.db2.combatants[data.Owner].type=="Self" or Recount.db2.combatants[data.Owner].type=="Grouped" or Recount.db2.combatants[data.Owner].type=="Ungrouped")) or (not Recount.db.profile.MergePets and data.Name and data.GUID and self:matchUnitGUID(Recount,data.Name, data.GUID)) then
					dps = dps + 10 * curdps
					if(data.type=="Self") then
						mydps = curdps*10
					end
					
				end
			end
		end
		return math.floor(dps + 0.5)/10,math.floor(mydps + 0.5)/10
	end	
	
	function recountGetSumtable(tablename, mode)
		local data, fullname, totalsum, totalpersec, cursum, curpersec = nil, "", 0, 0, 0, 0
		local temptable = {}
		local sumtable = {}
		for _,data in pairs(Recount.db2.combatants) do
			if data.Fights and data.Fights[tablename] and (data.type=="Self" or data.type=="Grouped" or data.type=="Pet" or data.type=="Ungrouped") then
				if mode == "DPS" then
					cursum,curpersec = Recount:MergedPetDamageDPS(data,tablename)
				elseif mode == "Heal" then
					cursum,curpersec = Recount:MergedPetHealingDPS(data,tablename)
				end
				if data.type ~= "Pet" or (not Recount.db.profile.MergePets and data.Owner and (Recount.db2.combatants[data.Owner].type=="Self" or Recount.db2.combatants[data.Owner].type=="Grouped" or Recount.db2.combatants[data.Owner].type=="Ungrouped")) or (not Recount.db.profile.MergePets and data.Name and data.GUID and self:matchUnitGUID(Recount,data.Name, data.GUID)) then
					if cursum > 0 then
						totalsum = totalsum + cursum
						curpersec = math.floor(curpersec + 0.5)
						totalpersec = totalpersec + curpersec
						fullname = data.Name or _G["UNKNOWN"]
						if data.type == "Pet" then fullname = data.Name.." <"..data.Owner..">" end
						if mode == "DPS" then
							temptable = {name = fullname, damage = cursum, dps = curpersec, enclass = data.enClass}
						elseif mode == "Heal" then
							temptable = {name = fullname, healing = cursum, hps = curpersec, enclass = data.enClass}
						end
						tinsert(sumtable, temptable)
					end
				end
			end
		end
		if mode == "DPS" then
			table.sort(sumtable, function(a,b) return a.damage > b.damage end)
		elseif mode == "Heal" then
			table.sort(sumtable, function(a,b) return a.healing > b.healing end)
		end
		return sumtable, totalsum, totalpersec
	end	
	
	TukuiCF["meter"].desc = "Recount Meter"
	TukuiCF["meter"].toggle = recountToggle	
	TukuiCF["meter"].getRaidValuePerSecond = recountGetRaidValuePerSecond
	TukuiCF["meter"].getSumtable = recountGetSumtable
	TukuiCF["meter"].hooked = true
end