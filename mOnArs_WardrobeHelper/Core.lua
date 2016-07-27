local o = mOnWardrobe

---------------------------------------------------------------
--  Default Settings (mOnWDSave)
---------------------------------------------------------------

o.defaultSettings = {}
o.defaultSettings.hideList = false
o.defaultSettings.disableProgress = false

---------------------------------------------------------------
--  Main Initialization
---------------------------------------------------------------

o.instances = {}
o.version = GetAddOnMetadata("mOnArs_WardrobeHelper", "Version");

local TYPES = {
	'Boss drop', 'Quests', 'Vendor', 'World/Instance Drop', 'Achievements', 'Professions'
}

TYPES[0] = 'Other'

o.TYPES = TYPES
o.SPECIAL = {}

for i = 0,#TYPES do
	o.SPECIAL[TYPES[i]] = true
end

o.menuItems = {}
o.saves = {}
o.loaded = false

---------------------------------------------------------------
--  Debug Methods
---------------------------------------------------------------

o.debug = {}
o.debug.printInstances = function()
	local text = ""
	for k, v in orderedPairs(o.instances) do
		text = text .. "~" .. k
	end
	print(text)
end

---------------------------------------------------------------
--  Methods
---------------------------------------------------------------

local function isCollected(sources)
	for i = 1,#sources do
		if sources[i].isCollected then
			return true
		end
	end
	return false
end

o.updateMissingVisuals = function()
	o.instances = {}
	o.loaded = true
	for i = 1,30 do
		local appearances = C_TransmogCollection.GetCategoryAppearances(i)
		if appearances then
			for j = 1,#appearances do
				local collected = appearances[j].isCollected == true
				if collected and mOnWDSave.disableProgress then
				else
					local sources = C_TransmogCollection.GetAppearanceSources(appearances[j].visualID)
					if sources then
						collected = collected or isCollected(sources) == true
						if collected and mOnWDSave.disableProgress then
						else
							for m = 1,#sources do
								local i1, i2, b1, i3, b2, itemString, visualString, sourceType = C_TransmogCollection.GetAppearanceSourceInfo(sources[m].sourceID)

								-- 1 = Boss Raid Drops
								if sourceType == 1 then
									local drops = C_TransmogCollection.GetAppearanceSourceDrops(sources[m].sourceID)
									for k=1,#drops do
										local inst = drops[k]
										if o.instances[inst.instance] == nil then
											o.instances[inst.instance] = {}
											o.instances[inst.instance]['#collected'] = 0
											o.instances[inst.instance]['#total'] = 0
										end
										if #inst.difficulties == 0 then
											inst.difficulties[1] = "Normal"
										end
										for l=1,#inst.difficulties do
											local dif = inst.difficulties[l]
											if o.instances[inst.instance][dif] == nil then
												o.instances[inst.instance][dif] = {}
											end
											if o.instances[inst.instance][dif][inst.encounter] == nil then
												o.instances[inst.instance][dif][inst.encounter] = {}
											end
											if collected then
												o.instances[inst.instance]['#collected'] = o.instances[inst.instance]['#collected'] + 1
											else
												local item = {}
												item.link = itemString
												item.id = string.match(itemString, 'item:([^:]*):')
												item.visualID = appearances[j].visualID
												item.sourceID = sources[m].sourceID
												table.insert(o.instances[inst.instance][dif][inst.encounter], item)
											end
											o.instances[inst.instance]['#total'] = o.instances[inst.instance]['#total'] + 1
										end
									end
								else
									local type = TYPES[sourceType]
									if o.instances[type] == nil then
										o.instances[type] = {}
										o.instances[type]['Normal'] = {}
										o.instances[type]['#collected'] = 0
										o.instances[type]['#total'] = 0
									end
									if o.instances[type]['Normal'][i] == nil then
										o.instances[type]['Normal'][i] = {}
									end
									if collected then
										o.instances[type]['#collected'] = o.instances[type]['#collected'] + 1
									else
										local item = {}
										item.link = itemString
										item.id = string.match(itemString, 'item:([^:]*):')
										item.visualID = appearances[j].visualID
										item.sourceID = sources[m].sourceID
										table.insert(o.instances[type]['Normal'][i], item)
									end
									o.instances[type]['#total'] = o.instances[type]['#total'] + 1
								end
							end
						end
					end
				end
			end
		end
	end

	o.createMenuItems()
	collectgarbage()
	o.GUImainPage(1)
end

o.refreshInstance = function(instance)
	if o.instances[instance] == nil then
		return
	end
	for difficulty, bosses in pairs(o.instances[instance]) do
		if string.sub(difficulty, 1, 1) ~= '#' then
			for boss, items in pairs(bosses) do
				for i=#items,1,-1 do
					local sources = C_TransmogCollection.GetAppearanceSources(items[i].visualID)
					if isCollected(sources) then
						table.remove(items, i)
						o.instances[instance]['#collected'] = o.instances[instance]['#collected'] + 1
					end
				end
			end
		end
	end
	o.createMenuItems()
	o.GUImainPage(o.CURRENT_PAGE)
end

o.GUIopen = function()
	o.GUImainPage(o.CURRENT_PAGE)
	mOnWD_MainFrame.hideList:SetChecked(mOnWDSave.hideList)
	mOnWD_MainFrame:Show()
	o.GUIcurrentInstance()
end

o.fixSettings = function()
	if mOnWDSave == nil then mOnWDSave = {} end
	for k, v in pairs(o.defaultSettings) do
		if mOnWDSave[k] == nil then mOnWDSave[k] = v end
	end
end

o.createInstanceNames = function(name)
	local namesToTry = {}
	namesToTry[#namesToTry + 1] = name

	if name == 'The Escape from Durnholde' then
		namesToTry[#namesToTry + 1] = 'Old Hillsbrad Foothills'
	elseif name == 'Old Hillsbrad Foothills' then
		namesToTry[#namesToTry + 1] = 'The Escape from Durnholde'
	elseif name == 'Opening of the Dark Portal' then
		namesToTry[#namesToTry + 1] = 'The Black Morass'
	elseif name == 'The Black Morass' then
		namesToTry[#namesToTry + 1] = 'Opening of the Dark Portal'
	elseif name == 'Tempest Keep' then
		namesToTry[#namesToTry + 1] = 'The Eye'
	elseif name == 'The Eye' then
		namesToTry[#namesToTry + 1] = 'Tempest Keep'
	elseif name == "Ahn'Qiraj Temple" then
		namesToTry[#namesToTry + 1] = "Temple of Ahn'Qiraj"
	elseif name == "Temple of Ahn'Qiraj" then
		namesToTry[#namesToTry + 1] = "Ahn'Qiraj Temple"
	elseif name == "Sunken Temple" then
			namesToTry[#namesToTry + 1] = "The Temple of Atal'hakkar"
	elseif name == "The Temple of Atal'hakkar" then
			namesToTry[#namesToTry + 1] = "Sunken Temple"
	end

	local tmp = string.explodePHP(name, ": ")
	if #tmp == 2 then
		namesToTry[#namesToTry + 1] = tmp[2]
		local tmp2 = string.explodePHP(tmp[1], " ")
		for i = 1,#tmp2 do
			namesToTry[#namesToTry + 1] = tmp2[i] .. " " .. tmp[2]
		end
	end

	tmp = string.gsub(name, "'s", "s'")
	namesToTry[#namesToTry + 1] = tmp

	tmp = string.gsub(name, "s'", "'s")
	namesToTry[#namesToTry + 1] = tmp
	return namesToTry
end

o.updateSavedInstances = function()
	o.saves = {}
	for i = 1,GetNumSavedInstances() do
		local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if locked then
			local names = o.createInstanceNames(name)
			for j = 1,#names do
				o.saves[names[j]] = true
			end
		end
	end
end

---------------------------------------------------------------
--  Slash Commands
---------------------------------------------------------------

SLASH_MONWARDROBE1 = '/mwd';

local function handler(msg, editbox)
	o.GUIopen()
end

SlashCmdList["MONWARDROBE"] = handler;

---------------------------------------------------------------
--  Events
---------------------------------------------------------------

o.eventFrame = CreateFrame("Frame")
local f = o.eventFrame
f:RegisterEvent("ADDON_LOADED")

function f:OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23)
	if (event == "ADDON_LOADED") and (arg1 == "mOnArs_WardrobeHelper") then
		o.fixSettings()
	end
end

function f:OnUpdate(arg1)
	if WardrobeCollectionFrame then
		if WardrobeCollectionFrame.NavigationFrame then
			if mOnWD_MainFrame_bShow == nil then
				local b = CreateFrame("BUTTON","mOnWD_MainFrame_bShow",WardrobeCollectionFrame.NavigationFrame,"UIPanelButtonTemplate");
				b:SetPoint("BOTTOMLEFT",25,25);
				b:SetText("Wardrobe Helper")
				b:SetHeight(25);
				b:SetWidth(120);
				b:SetScript("OnClick", function()
						o.GUIopen()
					end)
			end
		end
	end
end

f:SetScript("OnUpdate", f.OnUpdate)
f:SetScript("OnEvent", f.OnEvent)