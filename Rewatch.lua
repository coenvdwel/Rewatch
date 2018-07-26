-- Rewatch originally by Dezine, Argent Dawn, Europe (Coen van der Wel, Almere, the Netherlands).

-- Special thanks to:
---- bobn64 (Tyrahis, Shu'halo)
---- bakkax (Baschtl, EU-Alexstrasza)

-- Please give full credit when you want to redistribute or modify this addon!


local rewatch_versioni = 60008;
--------------------------------------------------------------------------------------------------------------[ FUNCTIONS ]----------------------

-- create some more output to chatwindow
-- only for debugging purpose
local debug_enabled=false;


-- display a message to the user in the chat pane
-- msg: the message to pass onto the user
-- return: void
function rewatch_Message(msg)
	-- send the message to the chat pane
	DEFAULT_CHAT_FRAME:AddMessage(rewatch_loc["prefix"]..msg, 1, 1, 1);
end

-- display a debug message to the user in the chat pane
-- msg: the message to pass onto the user
-- return: void
function rewatch_Debug_Message(msg)
  -- send the message to the chat pane
  if (debug_enabled) then
    DEFAULT_CHAT_FRAME:AddMessage(rewatch_loc["prefix"]..msg, 1, 1, 1);
  end;
end

-- displays a message to the user in the raidwarning frame
-- msg: the message to pass onto the user
-- return: void
function rewatch_RaidMessage(msg)
	-- send the message to the raid warning frame
	RaidNotice_AddMessage(RaidWarningFrame, msg, { r = 1, g = 0.49, b = 0.04 });
end



-- loads the internal vars from the savedvariables
-- return: void
function rewatch_OnLoad()
	-- reset changed var (options window)
	rewatch_changedDimentions = false;
	-- has been loaded before, get vars
	if(rewatch_load) then
		-- support
		local supported, update = { "5.4", "5.4.1", 50402, 50403, 50404, 50405, 50406, 50407, 50408, 50409, 50500, 50501, 50502, 50503, 50504, 50505, 50506, 50507, 60000, 60001, 60002, 60003, 60004, 60005, 60006, 60007, 60008}, false;
		for _, version in ipairs(supported) do update = update or (version == rewatch_version) end;
		-- supported? then update
		if(update) then
			update = false;
			update = update or (rewatch_version == "5.4");
			update = update or (rewatch_version == "5.4.1");
			if(update) then
				rewatch_load["Font"] = "Interface\\AddOns\\Rewatch\\Fonts\\BigNoodleTitling.ttf";
				rewatch_load["Bar"] = "Interface\\AddOns\\Rewatch\\Textures\\Bar.tga";
				rewatch_load["SpellBarWidth"] = 25;
				rewatch_load["FontSize"] = 11;
				rewatch_load["HighlightSize"] = 11;
				rewatch_load["SpellBarHeight"] = 14;
				rewatch_load["HealthBarHeight"] = 110;
				rewatch_load["HealthDeficit"] = 0;
			end;
			if(rewatch_version < 50404) then
				rewatch_load["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["innervate"];
				rewatch_load["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
			end;
			if(rewatch_version < 50405) then
				rewatch_load["BarColor"..rewatch_loc["rejuvenation"]].a = 1;
				rewatch_load["BarColor"..rewatch_loc["regrowth"]].a = 1;
				rewatch_load["BarColor"..rewatch_loc["wildgrowth"]].a = 1;
				rewatch_load["Scaling"] = 100;
				rewatch_load["PBOAlpha"] = 0.2;
				rewatch_load["Layout"] = "horizontal";
			end;
			if(rewatch_version < 50407) then
				rewatch_load["SortByRole"] = 1;
				rewatch_load["ShowSelfFirst"] = 1;
			end;
			if(rewatch_version < 50507) then
				rewatch_load["ShowIncomingHeals"] = 1;
			end;
			if(rewatch_version < 60000) then
				rewatch_load["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
				rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=1; g=0.5; b=0, a=1};
				if(rewatch_load["Layout"] == "default") then rewatch_load["Layout"] = "horizontal"; end;
			end;
			if(rewatch_version < 60001) then
				rewatch_Message("The default layout preset has changed! Would you like to try? Type: /rew layout normal");
				rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = { r=0; g=0.7; b=0, a=1};
				rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=0.4; g=0.85; b=0.34, a=1};
			end;
			if(rewatch_version < 60002) then
				rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=0.4; g=0.85; b=0.34, a=1};
				rewatch_load["HealthColor"] = { r=0.07; g=0.07; b=0.07};
				rewatch_load["FrameColor"] = { r=0.07; g=0.07; b=0.07, a=1};
			end;
			if(rewatch_version < 60003) then
				rewatch_load["OORAlpha"] = 0.2;
			end;
			if(rewatch_version < 60005) then
				rewatch_load["ButtonSpells"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
				if(rewatch_load["Layout"] == "vertical") then rewatch_load["FrameColumns"] = 1; else rewatch_load["FrameColumns"] = 0; end;
			end;
			if(rewatch_version < 60008) then
			  rewatch_Message("New Version for BFA and shamis");
			  
			  rewatch_load["ButtonSpells11"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
        rewatch_load["ButtonSpells7"] = { rewatch_loc["purifyspirit"], rewatch_loc["healingsurge"], rewatch_loc["healingwave"], rewatch_loc["chainheal"] };
			  
			  rewatch_load["BarColor"..rewatch_loc["riptide"]] = { r=0; g=0.1; b=0,8, a=1};
			end;
			
			-- get spec properties
			rewatch_loadInt["InRestoSpec"] = false;
			if((GetSpecialization() == 4 and  select(3, UnitClass("player")) == 11) or (GetSpecialization() == 3 and  select(3, UnitClass("player")) == 7)) then
				rewatch_loadInt["InRestoSpec"] = true;
				rewatch_Message("In resto specc");  
			end;
			
			-- set internal vars from loaded vars
			rewatch_loadInt["Loaded"] = true;
			rewatch_loadInt["GcdAlpha"] = rewatch_load["GcdAlpha"];
			rewatch_loadInt["HideSolo"] = rewatch_load["HideSolo"];
			rewatch_loadInt["Hide"] = rewatch_load["Hide"];
			rewatch_loadInt["AutoGroup"] = rewatch_load["AutoGroup"];
			rewatch_loadInt["WildGrowth"] = rewatch_load["WildGrowth"];
			rewatch_loadInt["HealthColor"] = rewatch_load["HealthColor"];
			rewatch_loadInt["FrameColor"] = rewatch_load["FrameColor"];
			rewatch_loadInt["MarkFrameColor"] = rewatch_load["MarkFrameColor"];
			rewatch_loadInt["MaxPlayers"] = rewatch_load["MaxPlayers"];
			rewatch_loadInt["Highlighting"] = rewatch_load["Highlighting"];
			rewatch_loadInt["Highlighting2"] = rewatch_load["Highlighting2"];
			rewatch_loadInt["Highlighting3"] = rewatch_load["Highlighting3"];
			rewatch_loadInt["ShowButtons"] = rewatch_load["ShowButtons"];
			rewatch_loadInt["BarColor"..rewatch_loc["lifebloom"]] = rewatch_load["BarColor"..rewatch_loc["lifebloom"]];
			rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation"]] = rewatch_load["BarColor"..rewatch_loc["rejuvenation"]];
			rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]] = rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]];
			rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]] = rewatch_load["BarColor"..rewatch_loc["regrowth"]];
			rewatch_loadInt["BarColor"..rewatch_loc["wildgrowth"]] = rewatch_load["BarColor"..rewatch_loc["wildgrowth"]];
			rewatch_loadInt["BarColor"..rewatch_loc["riptide"]] = rewatch_load["BarColor"..rewatch_loc["riptide"]];
			rewatch_loadInt["Labels"] = rewatch_load["Labels"];
			rewatch_loadInt["ShowTooltips"] = rewatch_load["ShowTooltips"];
			rewatch_loadInt["NameCharLimit"] = rewatch_load["NameCharLimit"];
			rewatch_loadInt["Bar"] = rewatch_load["Bar"];
			rewatch_loadInt["Font"] = rewatch_load["Font"];
			rewatch_loadInt["FontSize"] = rewatch_load["FontSize"];
			rewatch_loadInt["HighlightSize"] = rewatch_load["HighlightSize"];
			rewatch_loadInt["OORAlpha"] = rewatch_load["OORAlpha"];
			rewatch_loadInt["PBOAlpha"] = rewatch_load["PBOAlpha"];
			rewatch_loadInt["HealthDeficit"] = rewatch_load["HealthDeficit"];
			rewatch_loadInt["DeficitThreshold"] = rewatch_load["DeficitThreshold"];
			rewatch_loadInt["SpellBarWidth"] = rewatch_load["SpellBarWidth"];
			rewatch_loadInt["SpellBarHeight"] = rewatch_load["SpellBarHeight"];
			rewatch_loadInt["HealthBarHeight"] = rewatch_load["HealthBarHeight"];
			rewatch_loadInt["Scaling"] = rewatch_load["Scaling"];
			rewatch_loadInt["NumFramesWide"] = rewatch_load["NumFramesWide"];
			rewatch_loadInt["AltMacro"] = rewatch_load["AltMacro"];
			rewatch_loadInt["CtrlMacro"] = rewatch_load["CtrlMacro"];
			rewatch_loadInt["ShiftMacro"] = rewatch_load["ShiftMacro"];
			rewatch_loadInt["Layout"] = rewatch_load["Layout"];
			rewatch_loadInt["SortByRole"] = rewatch_load["SortByRole"];
			rewatch_loadInt["ShowIncomingHeals"] = rewatch_load["ShowIncomingHeals"];
			rewatch_loadInt["ShowSelfFirst"] = rewatch_load["ShowSelfFirst"];
			rewatch_loadInt["ButtonSpells"] = rewatch_load["ButtonSpells"];
			-- -- special buttons  for current class: shaman (7) , druid (11)
			rewatch_loadInt["ButtonSpells"..select(3, UnitClass("player"))] = rewatch_load["ButtonSpells"..select(3, UnitClass("player"))];
			rewatch_loadInt["ButtonSpells7"] = rewatch_load["ButtonSpells7"];
			rewatch_loadInt["ButtonSpells11"] = rewatch_load["ButtonSpells11"];
			rewatch_loadInt["FrameColumns"] = rewatch_load["FrameColumns"];
			rewatch_loadInt["LockP"] = true;
			-- update later
			rewatch_changed = true;
			
			rewatch_Debug_Message("playerid: "..select(3, UnitClass("player")).." has following buttons: "..table.concat(rewatch_loadInt["ButtonSpells"..select(3, UnitClass("player"))])); --DEBUG REMOVE ME

			
			-- apply possible changes
			rewatch_DoUpdate();
			-- set current version
			rewatch_version = rewatch_versioni;
		-- reset it all when new or no longer supported
		else rewatch_load = nil; rewatch_version = nil; end;
	-- not loaded before, initialise and welcome new user
	else
		rewatch_load = {};
		rewatch_load["GcdAlpha"], rewatch_load["HideSolo"], rewatch_load["Hide"], rewatch_load["AutoGroup"] = 1, 0, 0, 1;
		rewatch_load["HealthColor"] = { r=0.07; g=0.07; b=0.07};
		rewatch_load["FrameColor"] = { r=0; g=0; b=0; a=0.3 };
		rewatch_load["MarkFrameColor"] = { r=0; g=1; b=0; a=1 };
		rewatch_load["BarColor"..rewatch_loc["lifebloom"]] = { r=0; g=0.7; b=0, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation"]] = { r=0.85; g=0.15; b=0.80, a=1};
		rewatch_load["BarColor"..rewatch_loc["rejuvenation (germination)"]] = { r=0.4; g=0.85; b=0.34, a=1};
		rewatch_load["BarColor"..rewatch_loc["regrowth"]] = { r=0.05; g=0.3; b=0.1, a=1};
		rewatch_load["BarColor"..rewatch_loc["wildgrowth"]] = { r=0.5; g=0.8; b=0.3, a=1};
		rewatch_load["BarColor"..rewatch_loc["riptide"]] = { r=0.0; g=0.1; b=0.8, a=1};
		rewatch_load["Labels"] = 0;
		rewatch_load["SpellBarWidth"] = 25; rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110; rewatch_load["Scaling"] = 100;
		rewatch_load["NumFramesWide"] = 1;
		rewatch_load["WildGrowth"] = 1;
		rewatch_load["Bar"] = "Interface\\AddOns\\Rewatch\\Textures\\Bar.tga";
		rewatch_load["Font"] = "Interface\\AddOns\\Rewatch\\Fonts\\BigNoodleTitling.ttf";
		rewatch_load["FontSize"] = 11; rewatch_load["HighlightSize"] = 11;
		rewatch_load["HealthDeficit"] = 0;
		rewatch_load["DeficitThreshold"] = 0;
		rewatch_load["OORAlpha"] = 0.2;
		rewatch_load["PBOAlpha"] = 0.2;
		rewatch_load["NameCharLimit"] = 0; rewatch_load["MaxPlayers"] = 0;
		rewatch_load["AltMacro"] = "/cast [@mouseover] "..rewatch_loc["naturescure"];
		rewatch_load["CtrlMacro"] = "/cast [@mouseover] "..rewatch_loc["innervate"];
		rewatch_load["ShiftMacro"] = "/stopmacro [@mouseover,nodead]\n/target [@mouseover]\n/run rewatch_rezzing = UnitName(\"target\");\n/cast [combat] "..rewatch_loc["rebirth"].."; "..rewatch_loc["revive"].."\n/targetlasttarget";
		rewatch_load["Layout"] = "vertical";
		rewatch_load["SortByRole"] = 1;
		rewatch_load["ShowSelfFirst"] = 1;
		rewatch_load["ShowIncomingHeals"] = 1;
		rewatch_load["Highlighting"] = {
			-- todo: wod defaults
		};
		rewatch_load["Highlighting2"] = {
			-- todo: wod defaults
		};
		rewatch_load["Highlighting3"] = {
			-- todo: wod defaults
		};
		rewatch_load["ShowButtons"] = 0;
		rewatch_load["ShowTooltips"] = 1;
		
		rewatch_load["ButtonSpells"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
		rewatch_load["ButtonSpells11"] = { rewatch_loc["swiftmend"], rewatch_loc["naturescure"], rewatch_loc["ironbark"], rewatch_loc["mushroom"] };
		rewatch_load["ButtonSpells7"] = { rewatch_loc["purifyspirit"], rewatch_loc["healingsurge"], rewatch_loc["healingwave"], rewatch_loc["chainheal"] };
		
		rewatch_load["FrameColumns"] = 1;
		rewatch_RaidMessage(rewatch_loc["welcome"]);
		rewatch_Message(rewatch_loc["welcome"]);
		rewatch_Message(rewatch_loc["info"]);
		-- set current version
		rewatch_version = rewatch_versioni;
	end;
end;

function rewatch_SetLayout(name)
	if(name == "normal") then
		rewatch_load["ShowButtons"] = 0;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["FrameColumns"] = 1;
		rewatch_load["SpellBarWidth"] = 25;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Layout"] = "vertical";
	elseif(name == "compact") then
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["FrameColumns"] = 1;
		rewatch_load["SpellBarWidth"] = 50;
		rewatch_load["SpellBarHeight"] = 14;
		rewatch_load["HealthBarHeight"] = 110;
		rewatch_load["Layout"] = "vertical";
	elseif(name == "classic") then
		rewatch_load["ShowButtons"] = 1;
		rewatch_load["NumFramesWide"] = 5;
		rewatch_load["FrameColumns"] = 0;
		rewatch_load["SpellBarWidth"] = 85;
		rewatch_load["SpellBarHeight"] = 10;
		rewatch_load["HealthBarHeight"] = 30;
		rewatch_load["Layout"] = "horizontal";
	else
		rewatch_Message("Unknown layout preset.");
	end;
	
	rewatch_loadInt["ShowButtons"] = rewatch_load["ShowButtons"];
	rewatch_loadInt["NumFramesWide"] = rewatch_load["NumFramesWide"];
	rewatch_loadInt["FrameColumns"] = rewatch_load["FrameColumns"];
	rewatch_loadInt["SpellBarWidth"] = rewatch_load["SpellBarWidth"];
	rewatch_loadInt["SpellBarHeight"] = rewatch_load["SpellBarHeight"];
	rewatch_loadInt["HealthBarHeight"] = rewatch_load["HealthBarHeight"];
	rewatch_loadInt["Layout"] = rewatch_load["Layout"];
	
	rewatch_changed = true;
	rewatch_DoUpdate();
end;

-- cut a name by the specified name character limit
-- name: the name to be cut
-- return: the cut name
function rewatch_CutName(name)
	-- strip realm name
	local s = name:find("-"); if(s ~= nil) then name = name:sub(1, s-1).."*"; end;
	-- fix length
	if((rewatch_loadInt["NameCharLimit"] == 0) or (name:len() < rewatch_loadInt["NameCharLimit"])) then return name;
	else return name:sub(1, rewatch_loadInt["NameCharLimit"]); end;
end;

-- update frame dimensions by changes in component sizes/margins
-- return: void
function rewatch_UpdateOffset()
	if(rewatch_loadInt["Layout"] == "horizontal") then
		rewatch_loadInt["FrameWidth"] = (rewatch_loadInt["SpellBarWidth"]) * (rewatch_loadInt["Scaling"]/100);
		rewatch_loadInt["ButtonSize"] = (rewatch_loadInt["SpellBarWidth"] / table.getn(rewatch_loadInt["ButtonSpells"..select(3, UnitClass("player"))])) * (rewatch_loadInt["Scaling"]/100);
		
		-- druid
		if( select(3, UnitClass("player")) == 11) then 
		  rewatch_loadInt["FrameHeight"] = ((rewatch_loadInt["SpellBarHeight"]*(3+rewatch_loadInt["WildGrowth"])) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100) + (rewatch_loadInt["ButtonSize"]*rewatch_loadInt["ShowButtons"]);
	  end;
	  --shaman
	  if( select(3, UnitClass("player")) == 7) then 
      rewatch_loadInt["FrameHeight"] = ((rewatch_loadInt["SpellBarHeight"]*(1)) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100) + (rewatch_loadInt["ButtonSize"]*rewatch_loadInt["ShowButtons"]);
    end;

	
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		
		-- druid
    if( select(3, UnitClass("player")) == 11) then 
		  rewatch_loadInt["FrameWidth"] = ((rewatch_loadInt["SpellBarHeight"]*(3+rewatch_loadInt["WildGrowth"])) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100);
		end;
		-- shaman
    if( select(3, UnitClass("player")) == 7) then 
      rewatch_loadInt["FrameWidth"] = ((rewatch_loadInt["SpellBarHeight"]*(1)) + rewatch_loadInt["HealthBarHeight"]) * (rewatch_loadInt["Scaling"]/100);
    end;
		
		rewatch_loadInt["ButtonSize"] = (rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100)) / table.getn(rewatch_loadInt["ButtonSpells"..select(3, UnitClass("player"))]);
		rewatch_loadInt["FrameHeight"] = (rewatch_loadInt["SpellBarWidth"]) * (rewatch_loadInt["Scaling"]/100);
	end;
	
	rewatch_loadInt["FrameWidth"] = rewatch_loadInt["FrameWidth"];
	rewatch_loadInt["FrameHeight"] = rewatch_loadInt["FrameHeight"];
end;

-- update everything
-- return: void
function rewatch_DoUpdate()
	rewatch_UpdateOffset();
	rewatch_CreateOptions();
	rewatch_gcd:SetAlpha(rewatch_loadInt["GcdAlpha"]);
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then val["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a); end; end;
	if(((rewatch_i == 2) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
	rewatch_OptionsFromData(true); rewatch_UpdateSwatch();
end;

-- pops up the tooltip bar
-- data: the data to put in the tooltip. either a spell name or player name.
-- return: void
function rewatch_SetTooltip(data)
	-- ignore if not wanted
	if(rewatch_loadInt["ShowTooltips"] ~= 1) then return; end;
	-- is it a spell?
	local md = rewatch_GetSpellId(data);
	if(md < 0) then
		-- if not, then is it a player?
		md = rewatch_GetPlayer(data);
		if(md >= 0) then
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
			GameTooltip:SetUnit(rewatch_bars[md]["Player"]);
		end; -- do nothing with the tooltip if not
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetSpellBookItem(md, BOOKTYPE_SPELL);
	end;
end;

-- gets the spell ID of the highest rank of the specified spell
-- spellName: the name of the spell to get the highest ranked spellId from
-- return: the corresponding spellId
function rewatch_GetSpellId(spellName)
	-- get spell info and highest rank, return if the user can't cast it (not learned, etc)
	local name, rank, icon = GetSpellInfo(spellName);
	if(name == nil) then return -1; end;
	-- loop through all book spells, return the number if it matches above data
	local i, ispell, irank = 1, GetSpellBookItemName(1, BOOKTYPE_SPELL);
	repeat
		if ((ispell == name) and ((rank == irank) or (not irank))) then return i; end;
		i, ispell, irank = i+1, GetSpellBookItemName(i+1, BOOKTYPE_SPELL);
	until (not ispell);
	
	-- return default -1
	return -1;
end;

-- gets the icon of the specified spell
-- spellName: the name of the spell to get the icon from
-- return: the corresponding icon path
function rewatch_GetSpellIcon(spellName)
	return select(3, GetSpellInfo(spellName));
end;

-- get the corresponding colour for the power type
-- powerType: the type of power used (MANA, RAGE, FOCUS, ENERGY, CHI, ...)
-- return: a rgb table representing the 'mana bar' colour
function rewatch_GetPowerBarColor(powerType)
	if(powerType == 0 or powerType == "MANA") then
		return { r = 0.24, g = 0.35, b = 0.49 };
	end;
	
	if(powerType == 1 or powerType == "RAGE") then
		return { r = 0.52, g = 0.17, b = 0.17 };
	end;
	
	if(powerType == 3 or powerType == "ENERGY") then
		return { r = 0.5, g = 0.48, b = 0.27 };
	end;
	
	return PowerBarColor[powerType];
end;

-- get the number of the supplied player's place in the player table, or -1
-- player: name of the player to search for
-- return: the supplied player's table index, or -1 if not found
function rewatch_GetPlayer(player)
	-- prevent nil entries
	if(not player) then return -2; end;
	-- for every seen player; return if the name matches the supplied name
	local guid = UnitGUID(player);
	-- ignore pet guid; this changes sometimes
	if(not UnitIsPlayer(player)) then guid = false; end;
	-- browse list and return corresponding id
	for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then
		if(not guid) then
			if(val["Player"] == player) then return i; end;
		elseif(val["UnitGUID"] == guid) then return i;
		-- recognise pets (Playername-pet != Petname)
		elseif(val["Pet"]) then if(UnitGUID(val["Player"]) == UnitGUID(player)) then return i; end;
		-- load bug, UnitGUID returns nil when not fully loaded, even on "player"
		elseif((player == UnitName("player")) and (not val["UnitGUID"])) then val["UnitGUID"] = guid; return i; end;
	end; end;
	
	-- return -1 if not found
	return -1;
end;

-- checks if the player or pet is in the group
-- player: name of the player or pet to check for
-- return: true, if the player is the user, or in the user's party or raid (or pet); false elsewise
function rewatch_InGroup(player)
	-- catch a self-check; return true if searching for the user itself
	if(UnitName("player") == player) then return true;
	else
		if((GetNumGroupMembers() > 0) and IsInRaid()) then
			if(UnitPlayerOrPetInRaid(player)) then
				return true;
			end;
		elseif(GetNumSubgroupMembers() > 0) then
			if(UnitPlayerOrPetInParty(player)) then
				return true;
			end;
		end;
	end;
	
	-- return
	return false;
end;

-- colors the frame corresponding to the player with playerid accordingly
-- playerId: the index number of the player in the player table
-- return: void
function rewatch_SetFrameBG(playerId)
	if(rewatch_bars[playerId]["Notify3"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(1.0, 0.0, 0.0, 1);
	elseif(rewatch_bars[playerId]["Corruption"]) then
		if(rewatch_bars[playerId]["CorruptionType"] == "Poison") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.0, 0.3, 0, 1);
		elseif(rewatch_bars[playerId]["CorruptionType"] == "Curse") then
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.5, 0.0, 0.5, 1);
		else
			rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.0, 0.0, 0.5, 1);
		end;
	elseif(rewatch_bars[playerId]["Notify2"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(1.0, 0.5, 0.1, 1);
	elseif(rewatch_bars[playerId]["Notify"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(0.9, 0.8, 0.2, 1);
	elseif(rewatch_bars[playerId]["Mark"]) then
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
	else
		rewatch_bars[playerId]["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
	end;
end;

-- trigger the cooldown overlays
-- return: void
function rewatch_TriggerCooldown()
	-- get global cooldown, and trigger it on all frames
	local non_cd_spell = rewatch_loc["regrowth"];
	if( select(3, UnitClass("player")) == 7) then -- for shaman us another non-cd spell
	  non_cd_spell = rewatch_loc["healingwave"];
	end; 
	
	
	local start, duration, enabled = GetSpellCooldown(rewatch_loc["regrowth"]); -- some non-cd spell
	CooldownFrame_Set(rewatch_gcd, start, duration, enabled);
end;

-- show the first rewatch frame, with the last 'flash' of the cooldown effect
-- return: void
function rewatch_ShowFrame()
	rewatch_f:Show();
	CooldownFrame_Set(rewatch_gcd, GetTime()-1, 1.25, 1);
end;

-- adjusts the parent frame container's height
-- return: void
function rewatch_AlterFrame()
	-- get current x and y
	local x, y = rewatch_f:GetLeft(), rewatch_f:GetTop();
	-- set height and width according to number of frames
	local num, height, width = rewatch_f:GetNumChildren()-1;
	if(rewatch_loadInt["FrameColumns"] == 1) then
		height = math.min(rewatch_loadInt["NumFramesWide"],  math.max(num, 1)) * rewatch_loadInt["FrameHeight"];
		width = math.ceil(num/rewatch_loadInt["NumFramesWide"]) * rewatch_loadInt["FrameWidth"];
	else
		height = math.ceil(num/rewatch_loadInt["NumFramesWide"]) * rewatch_loadInt["FrameHeight"];
		width = math.min(rewatch_loadInt["NumFramesWide"],  math.max(num, 1)) * rewatch_loadInt["FrameWidth"];
	end;
	-- apply
	rewatch_f:SetWidth(width); rewatch_f:SetHeight(height+20);
	rewatch_gcd:SetWidth(rewatch_f:GetWidth()); rewatch_gcd:SetHeight(rewatch_f:GetHeight());
	-- reposition to x and y
	if(x ~= nil and y ~= nil) then
		rewatch_f:ClearAllPoints();
		rewatch_f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y-UIParent:GetHeight());
	end;
	-- hide/show on solo
	if(((num == 1) and (rewatch_loadInt["HideSolo"] == 1)) or (rewatch_loadInt["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_f:Show(); end;
	-- make sure frames have a solid height and width (bugfix)
	for j=1,rewatch_i-1 do local val = rewatch_bars[j]; if(val) then
		if(not((val["Frame"]:GetWidth() == rewatch_loadInt["FrameWidth"]) and (val["Frame"]:GetHeight() == rewatch_loadInt["FrameHeight"]))) then
			val["Frame"]:SetWidth(rewatch_loadInt["FrameWidth"]); val["Frame"]:SetHeight(rewatch_loadInt["FrameHeight"]);
		end;
	end; end;
end;

-- snap the supplied frame to the grid when it's placed on a rewatch_f frame
-- frame: the frame to snap to a grid
-- return: void
function rewatch_SnapToGrid(frame)
	-- return if in combat
	if(rewatch_inCombat) then return -1; end;
	
	-- get parent frame
	local parent = frame:GetParent();
	if(parent ~= UIParent) then
		-- get frame's location relative to it's parent's
		local dx, dy = frame:GetLeft()-parent:GetLeft(), frame:GetTop()-parent:GetTop();
		-- make it snap (make dx a number closest to frame:GetWidth*n...)
		dx = math.floor((dx/rewatch_loadInt["FrameWidth"])+0.5) * rewatch_loadInt["FrameWidth"];
		dy = math.floor((dy/rewatch_loadInt["FrameHeight"])+0.5) * rewatch_loadInt["FrameHeight"];
		-- check if this is outside the frame, remove it
		if((dx < 0) or (dy > 0) or (dx+5 >= parent:GetWidth()) or ((dy*-1)+5 >= parent:GetHeight())) then
			-- remove it from it's parent
			frame:SetParent(UIParent); rewatch_AlterFrame();
			rewatch_Message(rewatch_loc["offFrame"]);
		-- if it's in the frame, move it
		else
			-- set id and get children
			frame:SetID(1337); local children = { parent:GetChildren() };
			-- move a frame to a new position if this frame covers it now
			for i, child in ipairs(children) do if(child:GetID() ~= 1337) then
				if((child:GetLeft() and (i>1))) then
					if((math.abs(dx - (child:GetLeft()-parent:GetLeft())) < 1) and (math.abs(dy - (child:GetTop()-parent:GetTop())) < 1)) then
						local x, y = rewatch_GetFramePos(parent); child:ClearAllPoints(); child:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
						child:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", x+rewatch_loadInt["FrameWidth"], y-rewatch_loadInt["FrameHeight"]); break;
					end;
				end;
			end; end;
			-- reset id and apply the snap location
			frame:SetID(0); frame:ClearAllPoints(); frame:SetPoint("TOPLEFT", parent, "TOPLEFT", dx, dy);
			frame:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", dx+rewatch_loadInt["FrameWidth"], dy-rewatch_loadInt["FrameHeight"]);
		end;
	else
		-- check if there's need to snap it back onto the frame
		local dx, dy = frame:GetLeft()-rewatch_f:GetLeft(), frame:GetTop()-rewatch_f:GetTop();
		if((dx > 0) and (dy < 0) and (dx < rewatch_f:GetWidth()) and (dy < rewatch_f:GetHeight())) then
			frame:SetParent(rewatch_f); rewatch_AlterFrame();
			rewatch_SnapToGrid(frame); rewatch_Message(rewatch_loc["backOnFrame"]);
		end;
	end;
end;

-- return the first available empty spot in the frame
-- frame: the outline (parent) frame in which the player frame should be positioned
-- return: position coordinates; { x, y }
function rewatch_GetFramePos(frame)
	
	local children = { frame:GetChildren() };
	local x, y, found = 0, 0, false;
	local mx, my;
	
	if(rewatch_loadInt["FrameColumns"] == 1) then
		mx = ceil(frame:GetNumChildren()/rewatch_loadInt["NumFramesWide"])-1;
		my = 1-rewatch_loadInt["NumFramesWide"];
	else
		mx = rewatch_loadInt["NumFramesWide"]-1;
		my = 1-ceil(frame:GetNumChildren()/rewatch_loadInt["NumFramesWide"]);
	end;
	
	-- walk through the available spots, left to right, top to bottom
	if (rewatch_loadInt["FrameWidth"] ~= nil and rewatch_loadInt["FrameHeight"] ~= nil) then
  	for dy=0, my, -1 do
  		for dx=0, mx, 1 do
  			found, x, y = false, rewatch_loadInt["FrameWidth"]*dx, rewatch_loadInt["FrameHeight"]*dy;
  			-- check if there's a frame here already
  			for i, child in ipairs(children) do
  				if((child:GetLeft() and (i>1))) then
  					if((math.abs(x - (child:GetLeft()-frame:GetLeft())) < 1) and (math.abs(y - (child:GetTop()-frame:GetTop())) < 1)) then
  						found = true; break; --[[ break for children loop ]] end;
  				end;
  			end;
  			-- if not, we found a spot and we should break!
  			if(not found) then break; --[[ break for dxloop ]] end;
  		end;
  		if(not found) then break; --[[ break for dy loop ]] end;
  	end;
  end;
	
	-- return either the found spot, or a formula based on array positioning (fallback)
	if(found) then
		if(rewatch_loadInt["FrameColumns"] == 1) then return frame:GetWidth()*math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]), ((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]) * frame:GetHeight() * -1;
		else return frame:GetWidth()*((rewatch_i-1)%rewatch_loadInt["NumFramesWide"]), math.floor((rewatch_i-1)/rewatch_loadInt["NumFramesWide"]) * frame:GetHeight() * -1; end;
	else return x, y; end;
	
end;

-- compares the current player table to the party/raid schedule
-- return: void
function rewatch_ProcessGroup()
	local name, i, n;
	local names = {};
	-- remove non-grouped players
	for i=1,rewatch_i-1 do if(rewatch_bars[i]) then
		if(not (rewatch_InGroup(rewatch_bars[i]["Player"]) or rewatch_bars[i]["Pet"])) then rewatch_HidePlayer(i); end;
	end; end;
	-- add self
	if((rewatch_i == 1) and (rewatch_loadInt["ShowSelfFirst"] == 1)) then
		rewatch_AddPlayer(UnitName("player"), nil);
	end;
	-- process raid group
	if(IsInRaid()) then
		n = GetNumGroupMembers();
		-- for each group member, if he's not in the list, add him
		for i=1, n do
			name = GetRaidRosterInfo(i);
			if((name) and (rewatch_GetPlayer(name) == -1)) then
				table.insert(names, name);
			end;
		end;
	-- process party group (only when not in a raid)
	else
		n = GetNumSubgroupMembers();
		-- for each group member, if he's not in the list, add him
		for i=1, n + 1 do
			if(i > n) then name = UnitName("player"); else name = UnitName("party"..i); end;
			if((name) and (rewatch_GetPlayer(name) == -1)) then
				table.insert(names, name);
			end;
		end;
	end;
	-- sort by role
	if(rewatch_loadInt["SortByRole"] == 1) then
		local healers, tanks, others = {}, {}, {};
		for i, name in pairs(names) do
			role = UnitGroupRolesAssigned(name);
			if(role == "TANK") then
				table.insert(tanks, name);
			elseif(role == "HEALER") then
				table.insert(healers, name);
			else table.insert(others, name); end;
		end;
		-- add players
		rewatch_AddPlayers(tanks);
		rewatch_AddPlayers(healers);
		rewatch_AddPlayers(others);
	-- or just by groups
	else
		rewatch_AddPlayers(names);
	end;
end;

-- shortcut to allow adding a list of players at once
-- for further reference, see rewatch_AddPlayer()
function rewatch_AddPlayers(names)
	for i, name in ipairs(names) do
		rewatch_AddPlayer(name, nil);
	end;
end;

-- create a spell button with icon and add it to the global player table
-- spellName: the name of the spell to create a bar for
-- playerId: the index number of the player in the player table
-- relative: the name of the rewatch_bars[n] key, referencing to the relative cast bar for layout
-- offset: the (1-index) position of this button
-- return: the created spell button reference
function rewatch_CreateButton(spellName, playerId, relative, offset)
	-- build button
	local button = CreateFrame("BUTTON", nil, rewatch_bars[playerId]["Frame"], "SecureActionButtonTemplate");
	button:SetWidth(rewatch_loadInt["ButtonSize"]); button:SetHeight(rewatch_loadInt["ButtonSize"]);
	button:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", rewatch_loadInt["ButtonSize"]*(offset-1), 0);
	
	-- arrange clicking
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	button:SetAttribute("unit", rewatch_bars[playerId]["Player"]); button:SetAttribute("type1", "spell"); button:SetAttribute("spell1", spellName);
	
	-- texture
	button:SetNormalTexture(rewatch_GetSpellIcon(spellName));
	button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9);
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp");
	
	-- transparency for highlighting icons
	if(spellName == rewatch_loc["removecorruption"]) then button:SetAlpha(0.2);
	elseif(spellName == rewatch_loc["naturescure"]) then button:SetAlpha(0.2);
	end;
	
	-- apply tooltip support
	button:SetScript("OnEnter", function() rewatch_SetTooltip(spellName); end);
	button:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	
	-- relate spell to button
	button.spellName = spellName;
	
	-- add cooldown overlay
	button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate");
	button.cooldown:SetPoint("CENTER", 0, -1);
	button.cooldown:SetWidth(button:GetWidth()); button.cooldown:SetHeight(button:GetHeight()); button.cooldown:Hide();
			
	-- return
	return button;
end;

-- create a spell bar with text and add it to the global player table
-- spellName: the name of the spell to create a bar for
-- playerId: the index number of the player in the player table
-- relative: the name of the rewatch_bars[n] key, referencing to the relative castbar for layout
-- return: the created spell bar reference
function rewatch_CreateBar(spellName, playerId, relative)
	-- create the bar
	local b = CreateFrame("STATUSBAR", spellName..playerId, rewatch_bars[playerId]["Frame"], "TextStatusBar");
	b:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	b:GetStatusBarTexture():SetHorizTile(false);
	b:GetStatusBarTexture():SetVertTile(false);
	
	-- arrange layout
	if(rewatch_loadInt["Layout"] == "horizontal") then
		b:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		b:SetHeight(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		b:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "BOTTOMLEFT", 0, 0);
		b:SetOrientation("horizontal");
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		b:SetHeight(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		b:SetWidth(rewatch_loadInt["SpellBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		b:SetPoint("TOPLEFT", rewatch_bars[playerId][relative], "TOPRIGHT", 0, 0);
		b:SetOrientation("vertical");
	end;
	
	-- bar color
	b:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
	
	-- set bar reach
	b:SetMinMaxValues(0, 10); b:SetValue(10);
	
	-- if this was reju, add a tiny germination sidebar to it
	local b2;
	if(spellName == rewatch_loc["rejuvenation"]) then
	
		-- create the tiny bar
		b2 = CreateFrame("STATUSBAR", spellName.." (germination)"..playerId, b, "TextStatusBar");
		b2:SetStatusBarTexture(rewatch_loadInt["Bar"]);
		b2:GetStatusBarTexture():SetHorizTile(false);
		b2:GetStatusBarTexture():SetVertTile(false);
		
		-- adjust to layout
		if(rewatch_loadInt["Layout"] == "horizontal") then
			b2:SetWidth(b:GetWidth());
			b2:SetHeight(b:GetHeight() * 0.33);
			b2:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, b:GetHeight() * 0.33);
			b2:SetOrientation("horizontal");
		elseif(rewatch_loadInt["Layout"] == "vertical") then
			b2:SetWidth(b:GetWidth() * 0.33);
			b2:SetHeight(b:GetHeight());
			b2:SetPoint("TOPLEFT", b, "TOPRIGHT", -(b:GetWidth() * 0.33), 0);
			b2:SetOrientation("vertical");
		end;
		
		-- bar color
		b2:SetStatusBarColor(rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]].r, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]].g, rewatch_loadInt["BarColor"..rewatch_loc["rejuvenation (germination)"]].b, rewatch_loadInt["PBOAlpha"]);
		
		-- bar reach
		b2:SetMinMaxValues(0, 10); b2:SetValue(0);
		
		-- put text in bar
		b2.text = b:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
		b2.text:SetPoint("RIGHT", b2); b2.text:SetAllPoints();
		b2.text:SetText("");
	end;
	
	-- overlay cast button
	local bc = CreateFrame("BUTTON", nil, b, "SecureActionButtonTemplate");
	bc:SetWidth(b:GetWidth());
	bc:SetHeight(b:GetHeight());
	bc:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0);
	bc:RegisterForClicks("LeftButtonDown", "RightButtonDown"); bc:SetAttribute("type1", "spell"); bc:SetAttribute("unit", rewatch_bars[playerId]["Player"]);
	bc:SetAttribute("spell1", spellName); bc:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp");
	
	-- put text in bar
	b.text = bc:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	b.text:SetPoint("RIGHT", bc); b.text:SetAllPoints(); b.text:SetAlpha(1);
	if(rewatch_loadInt["Labels"] == 1) then b.text:SetText(spellName); else b.text:SetText(""); end;
	
	-- apply tooltip support
	bc:SetScript("OnEnter", function() bc:SetAlpha(0.2); rewatch_SetTooltip(spellName); end);
	bc:SetScript("OnLeave", function() bc:SetAlpha(1); GameTooltip:Hide(); end);
	
	-- return bar reference(s)
	if(spellName == rewatch_loc["rejuvenation"]) then return b, b2;
	else return b; end;
end;

-- update a bar by resetting spell duration
-- spellName: the name of the spell to reset it's duration from
-- player: player name
-- stacks: if given, the amount of LB stacks
-- return: void
function rewatch_UpdateBar(spellName, player, stacks)
  rewatch_Debug_Message("Updating bar player: " .. player .. "spell: " .. spellName);

	-- this shouldn't happen, but just in case
	if(not spellName) then return; end;
	
	-- get player
	local playerId = rewatch_GetPlayer(player);
  rewatch_Debug_Message("Got player id " .. playerId);

	
	-- add if needed
    if(playerId < 0) then
        if((rewatch_loadInt["AutoGroup"] == 0) or (spellName == rewatch_loc["wildgrowth"])) then return; end;
        playerId = rewatch_AddPlayer(UnitName(player), nil);
		if(playerId < 0) then return; end;
    end;
	
	-- lag may cause this 'inconsistency', fixie here
	if(spellName == rewatch_loc["wildgrowth"]) then rewatch_bars[playerId]["RevertingWG"] = 0; end;
	
	-- if the spell exists
	if(rewatch_bars[playerId][spellName]) then

	  rewatch_Debug_Message("Trying update buff " .. player .. spellName);

		-- get buff duration
		local a = rewatch_GetBuffDuration(player, spellName, nil, "PLAYER")
		if(a == nil) then return; end;
		local b = a - GetTime();
	  rewatch_Debug_Message("Got resttime " .. b);

		-- update bar
		rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["BarColor"..spellName].a);
		
		-- set bar values
    rewatch_bars[playerId][spellName] = a;
		rewatch_bars[playerId][spellName.."Bar"]:SetMinMaxValues(0, b);
		rewatch_bars[playerId][spellName.."Bar"]:SetValue(b);
	end;
end;


-- get duration of buff 
-- 
-- 
function rewatch_GetBuffDuration(player, spellName, somevalue , filter)
  -- old select(7, UnitBuff(player, spellName, somevalue, playertype));

  rewatch_Debug_Message("Trying to get buff duration" .. player .. spellName .. filter);

  for counter = 1, 40 do
    local auraName = UnitBuff(player, counter, filter);
    if spellName == auraName then
      rewatch_Debug_Message("Got buff duration" .. select(6, UnitBuff(player, counter, filter)));

      return select(6, UnitBuff(player, counter, filter));
    end;
  end;

end;


-- check if debuff is decursible 
-- replaces 
-- _, _, _, _, debuffType = UnitDebuff(playerId, spell);
-- if((debuffType == "Curse") or (debuffType == "Poison") or (debuffType == "Magic" and rewatch_loadInt["InRestoSpec"])) then
-- 

--todo - make this work
function rewatch_Is_Decursible(player)

  rewatch_Debug_Message("Check if debuff is decursible");

  for i=1,40 do
  local debuffType = select (4, UnitDebuff(player,i))
   if((debuffType == "Curse") or (debuffType == "Poison") or (debuffType == "Magic" and rewatch_loadInt["InRestoSpec"])) then
     rewatch_Debug_Message("Got debuff " .. debuffType .. " (is decursible)");
     return true;
   end;
 end;
 return false;
  
end;


-- clear a bar back to 0 because it's been dispelled or removed
-- spellName: the name of the spell to reset it's duration from
-- playerId: the index number of the player in the player table
-- return: void
function rewatch_DowndateBar(spellName, playerId)
	-- if the spell exists for this player
	if(rewatch_bars[playerId][spellName] and rewatch_bars[playerId][spellName.."Bar"]) then
		-- ignore if it's WG and we have no WG bar
		if((spellName == rewatch_loc["wildgrowth"]) and (not rewatch_bars[playerId][spellName.."Bar"])) then return; end;
		
		-- reset bar values
		_, r = rewatch_bars[playerId][spellName.."Bar"]:GetMinMaxValues();
		rewatch_bars[playerId][spellName.."Bar"]:SetValue(r);
		rewatch_bars[playerId][spellName] = 0;
		if(rewatch_loadInt["Labels"] == 0) then rewatch_bars[playerId][spellName.."Bar"].text:SetText(""); end;
		
		-- hide germination bar by default
		if(spellName == rewatch_loc["rejuvenation (germination)"]) then
			rewatch_bars[playerId][spellName.."Bar"]:SetValue(0);
		end;
		
		-- check for wild growth overrides
		if(spellName == rewatch_loc["wildgrowth"] and GetSpellCooldown(rewatch_loc["wildgrowth"])) then
			if(rewatch_bars[playerId]["RevertingWG"] == 1) then
				rewatch_bars[playerId]["RevertingWG"] = 0;
				rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
			else
				rewatch_bars[playerId]["RevertingWG"] = 1;
				rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(0, 0, 0, 0.8);
				r, b = GetSpellCooldown(spellName)
				r = r + b; b = r - GetTime();
				rewatch_bars[playerId][spellName] = r;
				rewatch_bars[playerId][spellName.."Bar"]:SetMinMaxValues(0, b);
				rewatch_bars[playerId][spellName.."Bar"]:SetValue(b);
			end;
		end;
		
		rewatch_bars[playerId][spellName.."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..spellName].r, rewatch_loadInt["BarColor"..spellName].g, rewatch_loadInt["BarColor"..spellName].b, rewatch_loadInt["PBOAlpha"]);
	end;
end;

-- add a player to the players table and create his bars and button
-- player: the name of the player
-- pet: if it's the pet of the named player ("pet" if so, nil if not)
-- return: the index number the player has been assigned
function rewatch_AddPlayer(player, pet)
	-- return if in combat or if the max amount of players is passed
	if(rewatch_inCombat or ((rewatch_loadInt["MaxPlayers"] > 0) and (rewatch_loadInt["MaxPlayers"] < rewatch_f:GetNumChildren()))) then return -1; end;
	--bakka: why not rearrange in combat ?
	-- if(((rewatch_loadInt["MaxPlayers"] > 0) and (rewatch_loadInt["MaxPlayers"] < rewatch_f:GetNumChildren()))) then return -1; end;
	
	-- process pets
	if(pet) then
		player = player.."-pet"; pet = UnitName(player);
		if(pet) then player = pet; end; pet = true;
	else pet = false; end;
	
	-- prepare table
	rewatch_bars[rewatch_i] = {};
	
	-- build frame
	local x, y = rewatch_GetFramePos(rewatch_f);
	local frame = CreateFrame("FRAME", nil, rewatch_f);
	frame:SetWidth(rewatch_loadInt["FrameWidth"] * (rewatch_loadInt["Scaling"]/100));
	frame:SetHeight(rewatch_loadInt["FrameHeight"] * (rewatch_loadInt["Scaling"]/100));
	frame:SetPoint("TOPLEFT", rewatch_f, "TOPLEFT", x, y); frame:EnableMouse(true); frame:SetMovable(true);
	frame:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	frame:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
	frame:SetScript("OnMouseDown", function() if(not rewatch_loadInt["LockP"]) then frame:StartMoving(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end; end);
	frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); rewatch_SnapToGrid(frame); end);
	
	-- create player HP bar for estimated incoming health
	local statusbarinc = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	if(rewatch_loadInt["Layout"] == "horizontal") then
		statusbarinc:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		statusbarinc:SetHeight((rewatch_loadInt["HealthBarHeight"]*0.8) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		statusbarinc:SetHeight(((rewatch_loadInt["SpellBarWidth"]*0.8) * (rewatch_loadInt["Scaling"]/100)) -(rewatch_loadInt["ShowButtons"]*rewatch_loadInt["ButtonSize"]));
		statusbarinc:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
	end;
	statusbarinc:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	statusbarinc:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbarinc:GetStatusBarTexture():SetHorizTile(false);
	statusbarinc:GetStatusBarTexture():SetVertTile(false);
	statusbarinc:SetStatusBarColor(0.4, 1, 0.4, 1);
	statusbarinc:SetMinMaxValues(0, 1); statusbarinc:SetValue(0);
		
	-- create player HP bar
	local statusbar = CreateFrame("STATUSBAR", nil, statusbarinc, "TextStatusBar");
	statusbar:SetWidth(statusbarinc:GetWidth());
	statusbar:SetHeight(statusbarinc:GetHeight());
	statusbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	statusbar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	statusbar:GetStatusBarTexture():SetHorizTile(false);
	statusbar:GetStatusBarTexture():SetVertTile(false);
	statusbar:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 1);
	statusbar:SetMinMaxValues(0, 1); statusbar:SetValue(0);
	
	-- determine class
	local classID, class, classColors;
	-- if(UnitName("player") == player) then classID = 11; else classID = select(3, UnitClass(player)); end;
	-- player can bne shaman as well
  classID = select(3, UnitClass(player));
	if(classID ~= nil) then
		_, class = GetClassInfo(classID);
		classColors = RAID_CLASS_COLORS[class];
	else
		classColors = {r=0,g=0,b=0}
	end;
	
	-- put text in HP bar
	statusbar.text = statusbar:CreateFontString("$parentText", "ARTWORK");
	statusbar.text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"], "OUTLINE");
	statusbar.text:SetAllPoints(); statusbar.text:SetText(rewatch_CutName(player));
	
	-- class-color it
	statusbar.text:SetTextColor(classColors.r, classColors.g, classColors.b, 1);
	
	-- role icon
	local roleIcon = statusbar:CreateTexture(nil, "OVERLAY");
	local role = UnitGroupRolesAssigned(player);
	roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES");
	roleIcon:SetSize(16, 16);
	roleIcon:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 2, -2);
	
	if(role == "TANK") then
		roleIcon:SetTexCoord(0, 19/64, 22/64, 41/64);
		roleIcon:Show();
	elseif(role == "HEALER") then
		roleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		roleIcon:Show();
	else
		roleIcon:Hide();
	end;
	
	-- energy/mana/rage bar
	local manabar = CreateFrame("STATUSBAR", nil, frame, "TextStatusBar");
	if(rewatch_loadInt["Layout"] == "horizontal") then
		manabar:SetWidth(rewatch_loadInt["SpellBarWidth"] * (rewatch_loadInt["Scaling"]/100));
		manabar:SetHeight((rewatch_loadInt["HealthBarHeight"]*0.2) * (rewatch_loadInt["Scaling"]/100));
	elseif(rewatch_loadInt["Layout"] == "vertical") then
		manabar:SetWidth(rewatch_loadInt["HealthBarHeight"] * (rewatch_loadInt["Scaling"]/100));
		manabar:SetHeight((rewatch_loadInt["SpellBarWidth"]*0.2) * (rewatch_loadInt["Scaling"]/100));
	end;
	
	manabar:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, 0);
	manabar:SetStatusBarTexture(rewatch_loadInt["Bar"]);
	manabar:GetStatusBarTexture():SetHorizTile(false);
	manabar:GetStatusBarTexture():SetVertTile(false);
	manabar:SetMinMaxValues(0, 1); manabar:SetValue(0);
	
	-- color it correctly
	local pt = rewatch_GetPowerBarColor(UnitPowerType(player));
	manabar:SetStatusBarColor(pt.r, pt.g, pt.b);
	
	-- overlay target/remove button
	local tgb = CreateFrame("BUTTON", nil, statusbar, "SecureActionButtonTemplate");
	tgb:SetWidth(statusbar:GetWidth()); tgb:SetHeight(statusbar:GetHeight()); tgb:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 0, 0);
	tgb:SetHighlightTexture("Interface\\Buttons\\WHITE8x8.blp"); tgb:SetAlpha(0.2);
	
	-- add mouse interaction
	tgb:SetAttribute("type1", "target");
	tgb:SetAttribute("unit", player);
	tgb:SetAttribute("alt-type1", "macro");
	tgb:SetAttribute("alt-macrotext1", rewatch_loadInt["AltMacro"]);
	tgb:SetAttribute("ctrl-type1", "macro");
	tgb:SetAttribute("ctrl-macrotext1", rewatch_loadInt["CtrlMacro"]);
	tgb:SetAttribute("shift-type1", "macro");
	tgb:SetAttribute("shift-macrotext1", rewatch_loadInt["ShiftMacro"]);
	tgb:SetScript("OnMouseDown", function(_, button)
		if(button == "RightButton") then
			rewatch_dropDown.relativeTo = frame; rewatch_rightClickMenuTable[1] = player;
			ToggleDropDownMenu(1, nil, rewatch_dropDown, "rewatch_dropDown", -10, -10);
		elseif(not rewatch_loadInt["LockP"]) then frame:StartMoving(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end;
	end);
	tgb:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); rewatch_SnapToGrid(frame); end);
	tgb:SetScript("OnEnter", function() rewatch_SetTooltip(player); rewatch_bars[rewatch_GetPlayer(player)]["Hover"] = 1; end);
	tgb:SetScript("OnLeave", function() GameTooltip:Hide(); rewatch_bars[rewatch_GetPlayer(player)]["Hover"] = 2; end);
	
	-- build border frame
	local border = CreateFrame("FRAME", nil, statusbar);
	border:SetBackdrop({bgFile = nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = 1, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	border:SetBackdropBorderColor(0, 0, 0, 1);
	border:SetWidth((rewatch_loadInt["FrameWidth"] * (rewatch_loadInt["Scaling"]/100))+1);
	border:SetHeight((rewatch_loadInt["FrameHeight"] * (rewatch_loadInt["Scaling"]/100))+1);
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -0, 0);
	
	-- save player data
	rewatch_bars[rewatch_i]["UnitGUID"] = nil; if(UnitExists(player)) then rewatch_bars[rewatch_i]["UnitGUID"] = UnitGUID(player); end;
	rewatch_bars[rewatch_i]["Frame"] = frame; rewatch_bars[rewatch_i]["Player"] = player;
	rewatch_bars[rewatch_i]["PlayerBarInc"] = statusbarinc;
	rewatch_bars[rewatch_i]["Border"] = border;
	rewatch_bars[rewatch_i]["PlayerBar"] = statusbar;
	rewatch_bars[rewatch_i]["ManaBar"] = manabar;
	rewatch_bars[rewatch_i]["Mark"] = false; rewatch_bars[rewatch_i]["Pet"] = pet;
	rewatch_bars[rewatch_i][rewatch_loc["lifebloom"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation (germination)"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["regrowth"]] = 0;
	rewatch_bars[rewatch_i][rewatch_loc["wildgrowth"]] = 0;
	--shaman
	rewatch_bars[rewatch_i][rewatch_loc["riptide"]] = 0;
	
	
	-- bars for druid
	if( select(3, UnitClass("player")) == 11) then 
  	if(rewatch_loadInt["Layout"] == "horizontal") then
  		rewatch_bars[rewatch_i][rewatch_loc["lifebloom"].."Bar"] = rewatch_CreateBar(rewatch_loc["lifebloom"], rewatch_i, "ManaBar");
  	elseif(rewatch_loadInt["Layout"] == "vertical") then
  		rewatch_bars[rewatch_i][rewatch_loc["lifebloom"].."Bar"] = rewatch_CreateBar(rewatch_loc["lifebloom"], rewatch_i, "PlayerBar");
  	end;
  	rewatch_bars[rewatch_i][rewatch_loc["rejuvenation"].."Bar"], rewatch_bars[rewatch_i][rewatch_loc["rejuvenation (germination)"].."Bar"] = rewatch_CreateBar(rewatch_loc["rejuvenation"], rewatch_i, rewatch_loc["lifebloom"].."Bar");
  	rewatch_bars[rewatch_i][rewatch_loc["regrowth"].."Bar"] = rewatch_CreateBar(rewatch_loc["regrowth"], rewatch_i, rewatch_loc["rejuvenation"].."Bar");
  	pt = rewatch_loc["regrowth"].."Bar";
  	if(rewatch_loadInt["WildGrowth"] == 1) then
  		pt = rewatch_loc["wildgrowth"].."Bar";
  		rewatch_bars[rewatch_i][rewatch_loc["wildgrowth"].."Bar"] = rewatch_CreateBar(rewatch_loc["wildgrowth"], rewatch_i, rewatch_loc["regrowth"].."Bar");
  	end;
	end;
	-- bars for shaman
	if( select(3, UnitClass("player")) == 7) then 
  	if(rewatch_loadInt["Layout"] == "horizontal") then
      rewatch_bars[rewatch_i][rewatch_loc["riptide"].."Bar"] = rewatch_CreateBar(rewatch_loc["riptide"], rewatch_i, "ManaBar");
    elseif(rewatch_loadInt["Layout"] == "vertical") then
      rewatch_bars[rewatch_i][rewatch_loc["riptide"].."Bar"] = rewatch_CreateBar(rewatch_loc["riptide"], rewatch_i, "PlayerBar");
    end;
    pt = rewatch_loc["riptide"].."Bar";
	end;
	
	
	-- buttons
	rewatch_bars[rewatch_i].Buttons = {};
	if(rewatch_loadInt["ShowButtons"] == 1) then
		-- determine anchor
		if(rewatch_loadInt["Layout"] == "vertical") then pt = "ManaBar"; end;
		-- create buttons
		for buttonSpellId,buttonSpellName in pairs(rewatch_loadInt["ButtonSpells"..select(3, UnitClass("player"))]) do
			if(not rewatch_loadInt["InRestoSpec"]) then
				if(buttonSpellName == rewatch_loc["naturescure"]) then buttonSpellName = rewatch_loc["removecorruption"];
				elseif(buttonSpellName == rewatch_loc["ironbark"]) then buttonSpellName = rewatch_loc["barkskin"];
				end;
			end;
			if(rewatch_GetSpellIcon(buttonSpellName)) then
				rewatch_bars[rewatch_i].Buttons[buttonSpellName] = rewatch_CreateButton(buttonSpellName, rewatch_i, pt, buttonSpellId);
			end;
		end;
	end;
	
	rewatch_bars[rewatch_i]["Notify"] = nil; rewatch_bars[rewatch_i]["Notify2"] = nil; rewatch_bars[rewatch_i]["Notify3"] = nil;
	rewatch_bars[rewatch_i]["Corruption"] = nil; rewatch_bars[rewatch_i]["Class"] = class; rewatch_bars[rewatch_i]["Hover"] = 0;
	rewatch_bars[rewatch_i]["RevertingWG"] = 0;
	
	-- increment the global index
	rewatch_i = rewatch_i+1; rewatch_AlterFrame(); rewatch_SnapToGrid(frame);
	
	-- return the inserted player's player table index
	return rewatch_GetPlayer(player);
end;

-- hide all bars and buttons from - and the player himself, by name
-- player: the name of the player to hide
-- return: void
-- PRE: Called by specific user request
function rewatch_HidePlayerByName(player)
	if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
	else
		-- get the index of this player
		local playerId = rewatch_GetPlayer(player);
		-- if this player exists, hide all bars and buttons from - and the player himself
		if(playerId > 0) then
			-- check for others
			local others = false;
			for i=1,rewatch_i-1 do local val = rewatch_bars[i]; if(val) then
				if(i ~= playerId) then others = true; break; end;
			end; end;
			-- if there are other people in the frame
			if(others) then
				-- hide the player
				rewatch_HidePlayer(playerId);
				-- prevent auto-adding grouped players automatically
				if((rewatch_loadInt["AutoGroup"] == 1) and (rewatch_InGroup(player)) and UnitIsPlayer(player) and UnitIsConnected(player)) then
					rewatch_load["AutoGroup"], rewatch_loadInt["AutoGroup"] = 0, 0;
					rewatch_OptionsFromData(true);
					rewatch_Message(rewatch_loc["setautogroupauto0"]);
				end;
			else rewatch_Message(rewatch_loc["removefailed"]); end;
		end;
	end;
end;

-- hide all bars and buttons from - and the player himself
-- playerId: the table index of the player to hide
-- return: void
function rewatch_HidePlayer(playerId)
	-- return if in combat
	if(rewatch_inCombat) then return; end;
	
	-- remove the bar
	local parent = rewatch_bars[playerId]["Frame"]:GetParent();
	rewatch_bars[playerId]["PlayerBar"]:Hide();
	rewatch_bars[playerId]["PlayerBarInc"]:Hide();
	
	-- druid
	if( select(3, UnitClass("player")) == 11) then 
  	rewatch_bars[playerId][rewatch_loc["lifebloom"].."Bar"]:Hide();
  	rewatch_bars[playerId][rewatch_loc["rejuvenation"].."Bar"]:Hide();
  	rewatch_bars[playerId][rewatch_loc["rejuvenation (germination)"].."Bar"]:Hide();
  	if(rewatch_bars[playerId][rewatch_loc["wildgrowth"].."Bar"]) then
  		rewatch_bars[playerId][rewatch_loc["wildgrowth"].."Bar"]:Hide();
  	end;
  	rewatch_bars[playerId][rewatch_loc["regrowth"].."Bar"]:Hide();
	end;
	
	-- shaman
	if( select(3, UnitClass("player")) == 7) then 
	 rewatch_bars[playerId][rewatch_loc["riptide"].."Bar"]:Hide();
	end;
	
	for _, b in pairs(rewatch_bars[playerId].Buttons) do b:Hide(); end;
	
	rewatch_bars[playerId]["Frame"]:Hide();
	rewatch_bars[playerId]["Frame"]:SetParent(nil);
	rewatch_bars[playerId] = nil;
	
	-- update the frame width/height
	if(parent ~= UIParent) then rewatch_AlterFrame(); end;
end;

-- process highlighting
-- spell: name of the debuff caught
-- player: name of the player it was caught on
-- highlighting: list to check: Highlight, Highlight2 or Highlight3
-- notify: frame to affect: Notify, Notify2 or Notify3
-- return: true if a highlight was made, false if not
function rewatch_ProcessHighlight(spell, player, highlighting, notify)
	if(not rewatch_loadInt[highlighting]) then return false; end;
	for _, b in ipairs(rewatch_loadInt[highlighting]) do
		if(spell == b) then
			playerId = rewatch_GetPlayer(player);
			if(playerId > 0) then
				rewatch_bars[playerId][notify] = spell; rewatch_SetFrameBG(playerId);
				return true;
			end;
		end;
	end;
	return false;
end;

-- build a frame
-- return: void
function rewatch_BuildFrame()
	-- create it
	rewatch_f = CreateFrame("FRAME", "Rewatch_Frame", UIParent);
	-- set proper dimentions and location
	rewatch_f:SetWidth(100); rewatch_f:SetHeight(100); rewatch_f:SetPoint("CENTER", UIParent);
	rewatch_f:EnableMouse(true); rewatch_f:SetMovable(true);
	-- set looks
	rewatch_f:SetBackdrop({bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = nil, tile = 1, tileSize = 5, edgeSize = 5, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0);
	-- make it draggable
	rewatch_f:SetScript("OnMouseDown", function(_, button)
		if(button == "RightButton") then
			if(rewatch_loadInt["Lock"]) then
				rewatch_loadInt["Lock"] = false; rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["unlocked"]);
			else
				rewatch_loadInt["Lock"] = true; rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["locked"]);
			end;
		else if(not rewatch_loadInt["Lock"]) then rewatch_f:StartMoving(); end; end;
	end);
	rewatch_f:SetScript("OnMouseUp", function() rewatch_f:StopMovingOrSizing(); end);
	rewatch_f:SetScript("OnEnter", function () rewatch_f:SetBackdropColor(1, 0.49, 0.04, 1); end);
	rewatch_f:SetScript("OnLeave", function () rewatch_f:SetBackdropColor(1, 0.49, 0.04, 0); end);
	-- create cooldown overlay and add it to its own table
	rewatch_gcd = CreateFrame("Cooldown", "FrameCD", rewatch_f, "CooldownFrameTemplate"); rewatch_gcd:SetAlpha(1);
	rewatch_gcd:SetPoint("CENTER", 0, -1); rewatch_gcd:SetWidth(rewatch_f:GetWidth()); rewatch_gcd:SetHeight(rewatch_f:GetHeight()); rewatch_gcd:Hide();
end;

-- process the sent commands
-- cmd: the command that has to be executed
-- return: void
function rewatch_SlashCommandHandler(cmd)
	-- when there's a command typed
	if(cmd) then
		-- declaration and initialisation
		local pos, commands = 0, {};
		for st, sp in function() return string.find(cmd, " ", pos, true) end do
			table.insert(commands, string.sub(cmd, pos, st-1));
			pos = sp + 1;
		end; table.insert(commands, string.sub(cmd, pos));
		-- on a help request, reply with the localisation help table
		if(string.lower(commands[1]) == "help") then
			for _,val in ipairs(rewatch_loc["help"]) do
				rewatch_Message(val);
			end;
		-- if the user wants to add a player manually
		elseif(string.lower(commands[1]) == "add") then
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			elseif(commands[2]) then
				if(rewatch_GetPlayer(commands[2]) < 0) then
					if(rewatch_InGroup(commands[2])) then rewatch_AddPlayer(commands[2], nil);
					elseif(commands[3]) then
						if(string.lower(commands[3]) == "always") then rewatch_AddPlayer(commands[2], nil);
						else rewatch_Message(rewatch_loc["notingroup"]); end;
					else rewatch_Message(rewatch_loc["notingroup"]); end;
				end;
			elseif(UnitName("target")) then if(rewatch_GetPlayer(UnitName("target")) < 0) then rewatch_AddPlayer(UnitName("target"), nil); end;
			else rewatch_Message(rewatch_loc["noplayer"]); end;
		-- if the user wants to resort the list (clear and processgroup)
		elseif(string.lower(commands[1]) == "sort") then
			if(rewatch_loadInt["AutoGroup"] == 0) then
				rewatch_Message(rewatch_loc["nosort"]);
			else
				if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
				else
					rewatch_clear = true;
					rewatch_changed = true;
					rewatch_Message(rewatch_loc["sorted"]);
				end;
			end;
		-- if the user wants to change to a layout preset
		elseif(string.lower(commands[1]) == "layout") then
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_SetLayout(commands[2]);
			end;
		-- if the user wants to clear the player list
		elseif(string.lower(commands[1]) == "clear") then
			if(rewatch_inCombat) then rewatch_Message(rewatch_loc["combatfailed"]);
			else
				rewatch_clear = true;
				rewatch_Message(rewatch_loc["cleared"]);
			end;
		-- allow setting the max amount of players to be in the list
		elseif(string.lower(commands[1]) == "maxplayers") then
			if(tonumber(commands[2])) then
				rewatch_loadInt["MaxPlayers"] = tonumber(commands[2]); rewatch_load["MaxPlayers"] = rewatch_loadInt["MaxPlayers"];
				rewatch_Message("Set max players to "..rewatch_load["MaxPlayers"]..". Set to 0 to ignore the maximum."); rewatch_changed = true;
			end;
		-- if the user wants to set the gcd alpha
		elseif(string.lower(commands[1]) == "gcdalpha") then
			if(not tonumber(commands[2])) then rewatch_Message(rewatch_loc["nonumber"]);
			elseif((tonumber(commands[2]) < 0) or (tonumber(commands[2]) > 1)) then rewatch_Message(rewatch_loc["nonumber"]);
			else
				rewatch_load["GcdAlpha"] = tonumber(commands[2]); rewatch_loadInt["GcdAlpha"] = rewatch_load["GcdAlpha"];
				rewatch_gcd:SetAlpha(rewatch_loadInt["GcdAlpha"]);
				rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["setalpha"]..commands[2]);
			end;
		-- if the user wants to set the hide solo feature
		elseif(string.lower(commands[1]) == "hidesolo") then
			if(not((commands[2] == "0") or (commands[2] == "1"))) then rewatch_Message(rewatch_loc["nonumber"]);
			else
				rewatch_load["HideSolo"] = tonumber(commands[2]); rewatch_loadInt["HideSolo"] = rewatch_load["HideSolo"];
				if(((rewatch_i == 2) and (rewatch_load["HideSolo"] == 1)) or (rewatch_load["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
				rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["sethidesolo"..commands[2]]);
			end;
		-- if the user wants to set the hide feature
		elseif(string.lower(commands[1]) == "hide") then
			rewatch_load["Hide"] = 1; rewatch_loadInt["Hide"] = rewatch_load["Hide"];
			if(((rewatch_i == 2) and (rewatch_load["HideSolo"] == 1)) or (rewatch_load["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
			rewatch_OptionsFromData(true); rewatch_Message(rewatch_loc["sethide1"]);
		elseif(string.lower(commands[1]) == "show") then
			rewatch_load["Hide"] = 0; rewatch_loadInt["Hide"] = rewatch_load["Hide"];
			if(((rewatch_i == 2) and (rewatch_load["HideSolo"] == 1)) or (rewatch_load["Hide"] == 1)) then rewatch_f:Hide(); else rewatch_ShowFrame(); end;
			rewatch_OptionsFromData(true); rewatch_Message(rewatch_loc["sethide0"]);
		-- if the user wants to set the autoadjust list to group feature
		elseif(string.lower(commands[1]) == "autogroup") then
			if(not((commands[2] == "0") or (commands[2] == "1"))) then rewatch_Message(rewatch_loc["nonumber"]);
			else
				rewatch_load["AutoGroup"] = tonumber(commands[2]); rewatch_loadInt["AutoGroup"] = rewatch_load["AutoGroup"];
				rewatch_OptionsFromData(true);
				rewatch_Message(rewatch_loc["setautogroup"..commands[2]]);
				rewatch_changed = true;
			end;
		-- if the user wants to use the lock feature
		elseif(string.lower(commands[1]) == "lock") then
			rewatch_loadInt["Lock"] = true; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["locked"]);
		-- if the user wants to use the unlock feature
		elseif(string.lower(commands[1]) == "unlock") then
			rewatch_loadInt["Lock"] = false; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["unlocked"]);
		-- if the user wants to use the player lock feature
		elseif(string.lower(commands[1]) == "lockp") then
			rewatch_loadInt["LockP"] = true; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["lockedp"]);
		-- if the user wants to use the player unlock feature
		elseif(string.lower(commands[1]) == "unlockp") then
			rewatch_loadInt["LockP"] = false; rewatch_OptionsFromData(true);
			rewatch_Message(rewatch_loc["unlockedp"]);
		-- if the user wants to check his version
		elseif(string.lower(commands[1]) == "version") then
			rewatch_Message("Rewatch v"..rewatch_versioni);
		-- if the user wants to toggle the settings GUI
		elseif(string.lower(commands[1]) == "options") then
			rewatch_changedDimentions = false;
			InterfaceOptionsFrame_OpenToCategory("Rewatch");
		-- if the user wants something else (unsupported)
		elseif(string.len(commands[1]) > 0) then rewatch_Message(rewatch_loc["invalid_command"]);
		else rewatch_Message(rewatch_loc["credits"]); end;
	-- if there's no command typed
	else rewatch_Message(rewatch_loc["credits"]); end;
end;

--------------------------------------------------------------------------------------------------------------[ SCRIPT ]-------------------------

-- make the addon stop here if the user isn't a druid (classID 11) or a shaman (classid = 7)
if( (select(3, UnitClass("player"))) ~= 11 and (select(3, UnitClass("player"))) ~= 7)
then 
	return;
end;

-- build event logger
rewatch_events = CreateFrame("FRAME", nil, UIParent); rewatch_events:SetWidth(0); rewatch_events:SetHeight(0);
-- rewatch_events:RegisterEvent("UNIT_AURA");
rewatch_events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
 rewatch_events:RegisterEvent("GROUP_ROSTER_UPDATE");
rewatch_events:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE"); 
rewatch_events:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
rewatch_events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED"); 
rewatch_events:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
rewatch_events:RegisterEvent("UNIT_HEAL_PREDICTION"); 
rewatch_events:RegisterEvent("PLAYER_ROLES_ASSIGNED");
rewatch_events:RegisterEvent("PLAYER_REGEN_DISABLED"); 
rewatch_events:RegisterEvent("PLAYER_REGEN_ENABLED");

-- initialise all vars
rewatch_changedDimentions = false;
rewatch_f = nil;
rewatch_gcd = nil;
rewatch_bars = {};
rewatch_rightClickMenuTable = {};
rewatch_loadInt = {};
rewatch_i = 1;
rewatch_dropDown = nil;
rewatch_changed = false;
rewatch_inCombat = false;
rewatch_clear = false;
rewatch_options = nil;
rewatch_rezzing = "";

-- add the slash command handler
SLASH_REWATCH1 = "/rewatch";
SLASH_REWATCH2 = "/rew";
SlashCmdList["REWATCH"] = function(cmd)
	rewatch_SlashCommandHandler(cmd);
end;

-- create the outline frame
rewatch_BuildFrame();

-- create the rightclick menu frame
rewatch_rightClickMenuTable = { "", "Remove player", "Add his/her pet", "Mark this player", "Clear all highlighting", "Lock playerframes", "Close menu" };
rewatch_dropDown = CreateFrame("FRAME", "rewatch_dropDownFrame", nil, "UIDropDownMenuTemplate");
rewatch_dropDown.point = "TOPLEFT";
rewatch_dropDown.relativePoint = "TOPRIGHT";
rewatch_dropDown.displayMode = "MENU";
rewatch_dropDown.relativeTo = rewatch_f;
local playerId;
UIDropDownMenu_Initialize(rewatch_dropDownFrame, function(self)
	for i, title in ipairs(rewatch_rightClickMenuTable) do
		local info = UIDropDownMenu_CreateInfo();
		info.isTitle = (i == 1); info.notCheckable = ((i < 2) or (i > 6));
		info.text = title; info.value = i; info.owner = rewatch_dropDown;
		if(i == 4) then
			playerId = rewatch_GetPlayer(rewatch_rightClickMenuTable[1]);
			if(playerId >= 0) then info.checked = rewatch_bars[playerId]["Mark"]; end;
		end;
		if(i == 6) then info.checked = rewatch_loadInt["LockP"]; end;
		info.func = function(self)
			if(self.value == 2) then rewatch_HidePlayerByName(rewatch_rightClickMenuTable[1]);
			elseif(self.value == 3) then
				rewatch_AddPlayer(rewatch_rightClickMenuTable[1], "pet");
			elseif(self.value == 4) then
				playerId = rewatch_GetPlayer(rewatch_rightClickMenuTable[1]);
				if(playerId) then
					rewatch_bars[playerId]["Mark"] = not rewatch_bars[playerId]["Mark"];
					rewatch_SetFrameBG(playerId);
				end;
			elseif(self.value == 5) then
				playerId = rewatch_GetPlayer(rewatch_rightClickMenuTable[1]);
				if(playerId) then
					rewatch_bars[playerId]["Mark"] = false;
					rewatch_bars[playerId]["Notify"] = nil; rewatch_bars[playerId]["Notify2"] = nil;
					rewatch_bars[playerId]["Notify3"] = nil; rewatch_bars[playerId]["Corruption"] = nil;
					if(rewatch_bars[playerId].Buttons[rewatch_loc["removecorruption"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["removecorruption"]]:SetAlpha(0.2); end;
					if(rewatch_bars[playerId].Buttons[rewatch_loc["naturescure"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["naturescure"]]:SetAlpha(0.2); end;
					rewatch_SetFrameBG(playerId);
				end;
			elseif(self.value == 6) then
				rewatch_loadInt["LockP"] = (not self.checked); if(rewatch_loadInt["LockP"]) then rewatch_Message(rewatch_loc["lockedp"]); else rewatch_Message(rewatch_loc["unlockedp"]); end;
				rewatch_OptionsFromData(true);
			end; 
		end;
		UIDropDownMenu_AddButton(info);
	end;
end, "MENU");
UIDropDownMenu_SetWidth(rewatch_dropDown, 90);

-- make sure we catch events and process them
local r, g, b, a, val, n, debuffType, role;
-- rewatch_events:SetScript("OnEvent", function(timestamp, event, unitGUID, effect, _, meGUID, _, _, _, _, targetName, _, _, _, spell, _, school, stacks)
rewatch_events:SetScript("OnEvent", function(timestamp, event, unitGUID, effect, _, meGUID, _, _, _, _, targetName, _, spell, _, _, _, school, stacks)

  rewatch_Debug_Message("Got event: " .. event);
	
	-- eventArgs = {CombatLogGetCurrentEventInfo()}
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
	 	rewatch_Debug_Message("Got event" .. CombatLogGetCurrentEventInfo());

  	spell = select (13,CombatLogGetCurrentEventInfo());
  	effect = select (2,CombatLogGetCurrentEventInfo());
  	school = select (15,CombatLogGetCurrentEventInfo());
  	meGUID = select (4,CombatLogGetCurrentEventInfo());
  	targetName = select (9,CombatLogGetCurrentEventInfo());
  	
	end; 
	-- let's catch incombat here
	if(event == "PLAYER_REGEN_ENABLED") then rewatch_inCombat = false;
	elseif(event == "PLAYER_REGEN_DISABLED") then  rewatch_inCombat = true; end;
	-- only process if properly loaded
	if(not rewatch_loadInt["Loaded"]) then return;
	-- switched talent/dual spec
	elseif((event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "ACTIVE_TALENT_GROUP_CHANGED")) then
		if((GetSpecialization() == 4 and  select(3, UnitClass("player")) == 11) or (GetSpecialization() == 3 and  select(3, UnitClass("player")) == 7)) then
      rewatch_loadInt["InRestoSpec"] = true;
		else rewatch_loadInt["InRestoSpec"] = false; end;
		rewatch_clear = true;
		rewatch_changed = true;
	-- party changed
	elseif(event == "GROUP_ROSTER_UPDATE") then
		rewatch_changed = true;
	-- update threat
	elseif(event == "UNIT_THREAT_SITUATION_UPDATE") then
		if(unitGUID) then
			playerId = rewatch_GetPlayer(UnitName(unitGUID));
			if(playerId < 0) then return; end;
			if(playerId == nil) then return; end;
			val = rewatch_bars[playerId];
			if(val["UnitGUID"]) then
				a = UnitThreatSituation(val["Player"]);
				if(a == nil or a == 0) then
					val["Border"]:SetBackdropBorderColor(0, 0, 0, 1);
					val["Border"]:SetFrameStrata("MEDIUM");
				else r, g, b = GetThreatStatusColor(a);
					val["Border"]:SetBackdropBorderColor(r, g, b, 1);
					val["Border"]:SetFrameStrata("HIGH");
				end;
			end;
		end;
	-- changed role
	elseif(event == "PLAYER_ROLES_ASSIGNED") then
		if(unitGUID) then
			playerId = rewatch_GetPlayer(UnitName(unitGUID));
			if(playerId < 0) then return; end;
			val = rewatch_bars[playerId];
			if(val["UnitGUID"]) then
				role = UnitGroupRolesAssigned(UnitName(unitGUID));
				if(role == "TANK") then roleIcon:SetTexture("Interface\\AddOns\\Rewatch\\Textures\\tank.tga"); roleIcon:Show();
				elseif(role == "HEALER") then roleIcon:SetTexture("Interface\\AddOns\\Rewatch\\Textures\\healer.tga"); roleIcon:Show();
				else roleIcon:Hide(); end;
			end;
		end;
		
	-- buff applied/refreshed
	elseif((effect == "SPELL_AURA_APPLIED_DOSE") or (effect == "SPELL_AURA_APPLIED") or (effect == "SPELL_AURA_REFRESH")) then


	  rewatch_Debug_Message("Got buff applied / refreshed"..effect .. " with spell: " ..spell);

		-- quick bug-fix for 4.0 REFRESH retriggering for every WG tick
		if((effect == "SPELL_AURA_REFRESH") and (spell == rewatch_loc["wildgrowth"])) then return;
		--  ignore heals on non-party-/raidmembers
		elseif(not rewatch_InGroup(targetName)) then return;
		-- if it was a HoT being applied
		elseif((meGUID == UnitGUID("player")) and (((spell == rewatch_loc["wildgrowth"]) and (rewatch_loadInt["WildGrowth"] == 1)) or (spell == rewatch_loc["regrowth"]) or (spell == rewatch_loc["rejuvenation"]) or (spell == rewatch_loc["rejuvenation (germination)"]) or (spell == rewatch_loc["lifebloom"]) or (spell == rewatch_loc["riptide"]) )) then
			-- update the spellbar
			rewatch_UpdateBar(spell, targetName, stacks);
		-- if it's innervate that we cast, report
		elseif((meGUID == UnitGUID("player")) and (spell == rewatch_loc["innervate"]) and (targetName ~= UnitName("player"))) then
			SendChatMessage("Innervating "..targetName.."!", "SAY");
		-- if it's a spell that needs custom highlighting, notify by highlighting player frame	
		elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting", "Notify")) then
		elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting2", "Notify2")) then
		elseif(rewatch_ProcessHighlight(spell, targetName, "Highlighting3", "Notify3")) then
			-- ignore further, already processed it		
		-- else, if it was a debuff applied
		elseif(school == "DEBUFF") then
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			-- get the debuff type
			--_, _, _, _, debuffType = UnitDebuff(playerId, spell);
			
		
			-- process it
			--if((debuffType == "Curse") or (debuffType == "Poison") or (debuffType == "Magic" and rewatch_loadInt["InRestoSpec"])) then
			if(rewatch_Is_Decursible(targetName)) then
				rewatch_bars[playerId]["Corruption"] = spell; rewatch_bars[playerId]["CorruptionType"] = debuffType;
				if(rewatch_bars[playerId].Buttons[rewatch_loc["removecorruption"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["removecorruption"]]:SetAlpha(1); end;
				if(rewatch_bars[playerId].Buttons[rewatch_loc["naturescure"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["naturescure"]]:SetAlpha(1); end;
				if(rewatch_bars[playerId].Buttons[rewatch_loc["purifyspirit"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["purifyspirit"]]:SetAlpha(1); end;
				rewatch_SetFrameBG(playerId);
			end;
		-- else, if it was a bear/cat shapeshift
		elseif((spell == rewatch_loc["bearForm"]) or (spell == rewatch_loc["direBearForm"]) or (spell == rewatch_loc["catForm"])) then
			-- get the player position, or if -1, return
			playerId = rewatch_GetPlayer(targetName);
			if(playerId < 0) then return; end;
			-- if it was cat, make it yellow
			if(spell == rewatch_loc["catForm"]) then
				val = rewatch_GetPowerBarColor("ENERGY");
				rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(val.r, val.g, val.b, 1);
			-- else, it was bear form, make it red
			else
				val = rewatch_GetPowerBarColor("RAGE");
				rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(val.r, val.g, val.b, 1);
			end;
		-- else, if it was Clearcasting being applied to us
		elseif((spell == rewatch_loc["clearcasting"]) and (targetName == UnitName("player"))) then
			for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
				if(val[rewatch_loc["regrowth"]]) then
					val[rewatch_loc["regrowth"].."Bar"]:SetStatusBarColor(1, 1, 1, 1);
				end;
			end; end;
		end;
	-- if an aura faded
	elseif((effect == "SPELL_AURA_REMOVED") or (effect == "SPELL_AURA_DISPELLED") or (effect == "SPELL_AURA_REMOVED_DOSE")) then
		--  ignore non-party-/raidmembers
		if(not rewatch_InGroup(targetName)) then return; end;
		-- get the player position
		playerId = rewatch_GetPlayer(targetName);
		-- if it doesn't exists, stop
		if(playerId < 0) then -- nuffin!
		-- or, if a HoT runs out / has been dispelled, process it
		elseif((meGUID == UnitGUID("player")) and ((spell == rewatch_loc["regrowth"]) or (spell == rewatch_loc["rejuvenation"]) or (spell == rewatch_loc["rejuvenation (germination)"]) or (spell == rewatch_loc["lifebloom"]) or (spell == rewatch_loc["wildgrowth"]) or (spell == rewatch_loc["riptide"]))) then
			rewatch_DowndateBar(spell, playerId);
		-- else, if Clearcasting ends
		elseif((spell == rewatch_loc["clearcasting"]) and (targetName == UnitName("player"))) then
			for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
				if(val[rewatch_loc["regrowth"]]) then
					val[rewatch_loc["regrowth"].."Bar"]:SetStatusBarColor(rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].r, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].g, rewatch_loadInt["BarColor"..rewatch_loc["regrowth"]].b, rewatch_loadInt["PBOAlpha"]);
				end;
			end; end;
		-- or, process it if it is the applied corruption or something else to be notified about
		elseif(rewatch_bars[playerId]["Corruption"] == spell) then
			rewatch_bars[playerId]["Corruption"] = nil;
			if(rewatch_bars[playerId].Buttons[rewatch_loc["removecorruption"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["removecorruption"]]:SetAlpha(0.2); end;
			if(rewatch_bars[playerId].Buttons[rewatch_loc["naturescure"]]) then rewatch_bars[playerId].Buttons[rewatch_loc["naturescure"]]:SetAlpha(0.2); end;
			rewatch_SetFrameBG(playerId);
		elseif(rewatch_bars[playerId]["Notify"] == spell) then
			rewatch_bars[playerId]["Notify"] = nil; rewatch_SetFrameBG(playerId);
		elseif(rewatch_bars[playerId]["Notify2"] == spell) then
			rewatch_bars[playerId]["Notify2"] = nil; rewatch_SetFrameBG(playerId);
		elseif(rewatch_bars[playerId]["Notify3"] == spell) then
			rewatch_bars[playerId]["Notify3"] = nil; rewatch_SetFrameBG(playerId);
		-- else, if it was a bear/cat shapeshift
		elseif((spell == rewatch_loc["bearForm"]) or (spell == rewatch_loc["direBearForm"]) or (spell == rewatch_loc["catForm"])) then
			val = rewatch_GetPowerBarColor("MANA");
			rewatch_bars[playerId]["ManaBar"]:SetStatusBarColor(val.r, val.g, val.b, 1);
		end;
	-- if an other spell was cast successfull by the user or a heal has been received
	elseif((effect == "SPELL_CAST_SUCCESS") or (effect == "SPELL_HEAL")) then
		-- if it was your spell/heal
		if(meGUID == UnitGUID("player")) then
			rewatch_TriggerCooldown();
			-- update button cooldowns
			for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
				if(val.Buttons[spell]) then val.Buttons[spell].doUpdate = true; else break; end;
			end; end;
			-- if it is flourish
			if((spell == rewatch_loc["flourish"]) and (effect == "SPELL_CAST_SUCCESS")) then
				-- loop through all party members and update HoT bars
				for n=1,rewatch_i-1 do val = rewatch_bars[n]; if(val) then
					if(val[rewatch_loc["lifebloom"]]) then
						rewatch_UpdateBar(rewatch_loc["lifebloom"], val["Player"], nil);
					end;
					if(val[rewatch_loc["rejuvenation"]]) then
						rewatch_UpdateBar(rewatch_loc["rejuvenation"], val["Player"], nil);
					end;
					if(val[rewatch_loc["regrowth"]]) then
						rewatch_UpdateBar(rewatch_loc["regrowth"], val["Player"], nil);
					end;
					if(val[rewatch_loc["wildgrowth"]]) then
						rewatch_UpdateBar(rewatch_loc["wildgrowth"], val["Player"], nil);
					end;
					if(val[rewatch_loc["riptide"]]) then
            rewatch_UpdateBar(rewatch_loc["riptide"], val["Player"], nil);
          end;
				end; end;
			end;
		end;
	-- if we started casting Rebirth or Revive, check if we need to report
	elseif((effect == "SPELL_CAST_START") and ((spell == rewatch_loc["rebirth"]) or (spell == rewatch_loc["revive"])) and (meGUID == UnitGUID("player"))) then
		if(not rewatch_rezzing) then rewatch_rezzing = ""; end;
		if(UnitIsDeadOrGhost(rewatch_rezzing)) then
			SendChatMessage("Rezzing "..rewatch_rezzing.."!", "SAY");
			rewatch_rezzing = "";
		end;
	end;
end);

-- update everything
local d, x, y, v, left, i, currentTarget;
rewatch_events:SetScript("OnUpdate", function()
	-- load saved vars
	if(not rewatch_loadInt["Loaded"]) then
		rewatch_OnLoad();
		return;
	end;

	-- clearing and reprocessing the frames
	if(not rewatch_inCombat) then
		-- check if we have the extra need to clear
		if(rewatch_changed and rewatch_loadInt["AutoGroup"] == 1) then
			if((GetNumGroupMembers() == 0 and IsInRaid()) or (GetNumSubgroupMembers() == 0 and not IsInRaid())) then rewatch_clear = true; end;
		end;
		-- clear
		if(rewatch_clear) then
			for i=1,rewatch_i-1 do 
			 v = rewatch_bars[i]; 
			 if(v) then 
			   rewatch_HidePlayer(i); 
			 end; 
		  end;
			rewatch_bars = nil; rewatch_bars = {}; rewatch_i = 1;
			rewatch_clear = false;
		end;
		-- changed
		if(rewatch_changed) then
			if(rewatch_loadInt["AutoGroup"] == 1) then rewatch_ProcessGroup(); end;
			rewatch_changed = false;
		end;
	end;
	
	-- get current target
	currentTarget = UnitGUID("target");
	-- process updates
	for i=1,rewatch_i-1 do v = rewatch_bars[i];
		-- if this player exists
		if(v) then 
			-- make targetted unit have highlighted font
			x = UnitGUID(v["Player"]);
			if(currentTarget and (not v["Highlighted"]) and (x == currentTarget)) then
				v["Highlighted"] = true;
				v["PlayerBar"].text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["HighlightSize"], "THICKOUTLINE");
			elseif((v["Highlighted"]) and (x ~= currentTarget)) then
				v["Highlighted"] = false;
				v["PlayerBar"].text:SetFont(rewatch_loadInt["Font"], rewatch_loadInt["FontSize"], "OUTLINE");
			end;
			-- clear buffs if the player just died
			if(UnitIsDeadOrGhost(v["Player"])) then
				if(select(4, v["PlayerBar"]:GetStatusBarColor()) > 0.6) then
					v["PlayerBar"]:SetStatusBarColor(rewatch_loadInt["HealthColor"].r, rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 0.5);
					v["ManaBar"]:SetValue(0); v["PlayerBar"]:SetValue(0); v["PlayerBarInc"]:SetValue(0);
					if(v["Mark"]) then
						v["Frame"]:SetBackdropColor(rewatch_loadInt["MarkFrameColor"].r, rewatch_loadInt["MarkFrameColor"].g, rewatch_loadInt["MarkFrameColor"].b, rewatch_loadInt["MarkFrameColor"].a);
					else
						v["Frame"]:SetBackdropColor(rewatch_loadInt["FrameColor"].r, rewatch_loadInt["FrameColor"].g, rewatch_loadInt["FrameColor"].b, rewatch_loadInt["FrameColor"].a);
					end;
					v["PlayerBar"].text:SetText(rewatch_CutName(v["Player"]));
					rewatch_DowndateBar(rewatch_loc["lifebloom"], i);
					rewatch_DowndateBar(rewatch_loc["rejuvenation"], i);
					rewatch_DowndateBar(rewatch_loc["rejuvenation (germination)"], i);
					rewatch_DowndateBar(rewatch_loc["regrowth"], i);
					rewatch_DowndateBar(rewatch_loc["wildgrowth"], i);
					rewatch_DowndateBar(rewatch_loc["riptide"], i);
					v["Notify"] = nil; v["Notify2"] = nil; v["Notify3"] = nil;
					v["Corruption"] = nil; v["Frame"]:SetAlpha(0.2);
					if(v.Buttons[rewatch_loc["removecorruption"]]) then v.Buttons[rewatch_loc["removecorruption"]]:SetAlpha(0.2); end;
					if(v.Buttons[rewatch_loc["naturescure"]]) then v.Buttons[rewatch_loc["naturescure"]]:SetAlpha(0.2); end;
				end;
				-- else, unit's dead and processed, ignore him now
			else
				-- get and set health data
				x, y = UnitHealthMax(v["Player"]), UnitHealth(v["Player"]);
				v["PlayerBar"]:SetMinMaxValues(0, x); v["PlayerBar"]:SetValue(y);
				-- set predicted heals
				if(rewatch_loadInt["ShowIncomingHeals"] == 1) then
					d = UnitGetIncomingHeals(v["Player"]) or 0;
					v["PlayerBarInc"]:SetMinMaxValues(0, x);
					if(y+d>=x) then v["PlayerBarInc"]:SetValue(x);
					else v["PlayerBarInc"]:SetValue(y+d); end;
				end;
				-- set healthbar color accordingly
				d = y/x;
				if(d < 0.5) then
					d = d * 2;
					v["PlayerBar"]:SetStatusBarColor(0.50 + ((1-d) * (1.00 - 0.50)), rewatch_loadInt["HealthColor"].g, rewatch_loadInt["HealthColor"].b, 1);
				else
					d = (d * 2) - 1;
					v["PlayerBar"]:SetStatusBarColor(rewatch_loadInt["HealthColor"].r + ((1-d) * (0.50 - rewatch_loadInt["HealthColor"].r)), rewatch_loadInt["HealthColor"].g + ((1-d) * (0.50 - rewatch_loadInt["HealthColor"].g)), rewatch_loadInt["HealthColor"].b, 1);
				end;
				-- update text if needed
				if(rewatch_loadInt["HealthDeficit"] == 1) then
					d = rewatch_CutName(v["Player"]); if(v["Hover"] == 1) then d = string.format("%i/%i", y, x); elseif(v["Hover"] == 2) then v["Hover"] = 0; end;
					if((v["Hover"] == 0) and (y < (rewatch_loadInt["DeficitThreshold"]*1000))) then
						d = d.."\n"..string.format("%#.1f", y/1000).."k";
					end;
					v["PlayerBar"].text:SetText(d);
				else
					if(v["Hover"] == 1) then v["PlayerBar"].text:SetText(string.format("%i/%i", y, x));
					elseif(v["Hover"] == 2) then v["PlayerBar"].text:SetText(rewatch_CutName(v["Player"])); v["Hover"] = 0;
					end;
				end;
				-- get and set mana data
				x, y = UnitPowerMax(v["Player"]), UnitPower(v["Player"]);
				v["ManaBar"]:SetMinMaxValues(0, x); v["ManaBar"]:SetValue(y);
				-- fade when out of range
				if(IsSpellInRange(rewatch_loc["regrowth"], v["Player"]) == 1 or IsSpellInRange(rewatch_loc["healingwave"], v["Player"]) == 1) then
					v["Frame"]:SetAlpha(1);
				else
					v["Frame"]:SetAlpha(rewatch_loadInt["OORAlpha"]);
					v["PlayerBarInc"]:SetValue(0);
				end;
				-- update button cooldown layers
				for _, d in pairs(v.Buttons) do
					if(d.doUpdate == true) then
						CooldownFrame_Set(d.cooldown, GetSpellCooldown(d.spellName));
						d.doUpdate = false;
					end;
				end;
				-- current time
				x = GetTime();
				-- rejuvenation bar process
				if(rewatch_bars[i][rewatch_loc["rejuvenation"]] > 0) then
					left = v[rewatch_loc["rejuvenation"]]-x;
					if(left > 0) then
						v[rewatch_loc["rejuvenation"].."Bar"]:SetValue(left);
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["rejuvenation"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						if(math.abs(left-2)<0.1) then v[rewatch_loc["rejuvenation"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["rejuvenation"], i);
					end;
				end;
				-- rejuvenation (germination) bar process
				if(rewatch_bars[i][rewatch_loc["rejuvenation (germination)"]] > 0) then
					left = v[rewatch_loc["rejuvenation (germination)"]]-x;
					if(left > 0) then
						v[rewatch_loc["rejuvenation (germination)"].."Bar"]:SetValue(left);
						if(math.abs(left-2)<0.1) then v[rewatch_loc["rejuvenation (germination)"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["rejuvenation (germination)"], i);
					end;
				end;
				-- regrowth bar process
				if(rewatch_bars[i][rewatch_loc["regrowth"]] > 0) then
					left = rewatch_bars[i][rewatch_loc["regrowth"]]-x;
					if(left > 0) then
						v[rewatch_loc["regrowth"].."Bar"]:SetValue(left);
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["regrowth"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						if(math.abs(left-2)<0.1) then v[rewatch_loc["regrowth"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["regrowth"], i);
					end;
				end;
				-- lifebloom bar process
				if(rewatch_bars[i][rewatch_loc["lifebloom"]] > 0) then
					left = rewatch_bars[i][rewatch_loc["lifebloom"]]-x;
					if(left > 0) then
						v[rewatch_loc["lifebloom"].."Bar"]:SetValue(left);
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["lifebloom"].."Bar"].text:SetText(string.format("%.00f", left)); end;
						if(math.abs(left-2)<0.1) then v[rewatch_loc["lifebloom"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
					elseif(left < -1) then
						rewatch_DowndateBar(rewatch_loc["lifebloom"], i);
					end;
				end;
				
				-- wild growth bar process
				if((v[rewatch_loc["wildgrowth"].."Bar"]) and (rewatch_bars[i][rewatch_loc["wildgrowth"]] > 0)) then
					left = rewatch_bars[i][rewatch_loc["wildgrowth"]]-x;
					if(left > 0) then
						if(v["RevertingWG"] == 1) then
							_, y = v[rewatch_loc["wildgrowth"].."Bar"]:GetMinMaxValues();
							v[rewatch_loc["wildgrowth"].."Bar"]:SetValue(y - left);
						else
							v[rewatch_loc["wildgrowth"].."Bar"]:SetValue(left);
							if(math.abs(left-2)<0.1) then v[rewatch_loc["wildgrowth"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
						end;
						if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["wildgrowth"].."Bar"].text:SetText(string.format("%.00f", left)); end;
					elseif((left < -1) or (v["RevertingWG"] == 1)) then
						rewatch_DowndateBar(rewatch_loc["wildgrowth"], i);
					end;
				end;
				
				-- riptide bar process
        if(rewatch_bars[i][rewatch_loc["riptide"]] > 0) then
          left = rewatch_bars[i][rewatch_loc["riptide"]]-x;
          if(left > 0) then
            v[rewatch_loc["riptide"].."Bar"]:SetValue(left);
            if(rewatch_loadInt["Labels"] == 0) then v[rewatch_loc["riptide"].."Bar"].text:SetText(string.format("%.00f", left)); end;
            if(math.abs(left-2)<0.1) then v[rewatch_loc["riptide"].."Bar"]:SetStatusBarColor(0.6, 0.0, 0.0, 1); end;
          elseif(left < -1) then
            rewatch_DowndateBar(rewatch_loc["riptide"], i);
          end;
        end;
        
				
			end;
		end;
	end;
end);