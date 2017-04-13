local _, angusui = ...

local frame=CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_ACCEPTED")


-- SLASH_ANGUSUI1, SLASH_ANGUSUI2 = '/angusui', '/aui'; -- 3.
-- 	function SlashCmdList.ANGUSUI(msg, editbox) -- 4.
--
-- 	frame:followerUpgrades()
-- end

function slashCommand(arg)
	if (arg == "wodcrafts") then
		wodCrafts()
	elseif (arg == "garrison") then
		followerUpgrades()
	elseif (arg == "buildings") then
		garrisonBuildings()
	else
		print ("These are the commands you're looking for")
		print ("/angusui wodcrafts - List all WoD main crafting reagents")
		print ("/angusui garrison - Print Garry's Mod weapon/armor count")
		print ("/angusui buildings - Print Garry's Mod buildings")
	end
end

SlashCmdList.ANGUSUI = slashCommand
SLASH_ANGUSUI1, SLASH_ANGUSUI2 = "/angusui", "/aui"

function garrisonBuildings()
	--

	for k, building in pairs(C_Garrison.GetBuildings()) do
		for attr, val in pairs(building) do
			DEFAULT_CHAT_FRAME:AddMessage(attr .. ":" .. val);
		end
		--DEFAULT_CHAT_FRAME:AddMessage(building.buildingID);
	end
end

function wodCrafts()
	 DEFAULT_CHAT_FRAME:AddMessage("\124cff1eff00\124Hitem:110611:0:0:0:0:0:0:0:0:0:0\124h[Burnished Leather]\124h\124r")
	 DEFAULT_CHAT_FRAME:AddMessage("\124cff1eff00\124Hitem:111366:0:0:0:0:0:0:0:0:0:0\124h[Gearspring Parts]\124h\124r")
	 DEFAULT_CHAT_FRAME:AddMessage("\124cff1eff00\124Hitem:111556:0:0:0:0:0:0:0:0:0:0\124h[Hexweave Cloth]\124h\124r")
	 DEFAULT_CHAT_FRAME:AddMessage("\124cff1eff00\124Hitem:115524:0:0:0:0:0:0:0:0:0:0\124h[Taladite Crystal]\124h\124r")
	 DEFAULT_CHAT_FRAME:AddMessage("\124cff1eff00\124Hitem:108257:0:0:0:0:0:0:0:0:0:0\124h[Truesteel Ingot]\124h\124r")
	 DEFAULT_CHAT_FRAME:AddMessage("\124cff1eff00\124Hitem:112377:0:0:0:0:0:0:0:0:0:0\124h[War Paints]\124h\124r")
end

function followerUpgrades()
	local weapons = {};
	local armor = {};
	local upgrades = {};

	weapons[3] = 114128;
	weapons[6] = 114129;
	weapons[9] = 114131;
	armor[3] = 114745;
	armor[6] = 114808;
	armor[9] = 114822;

	upgrades["weapon"] = 0;
	upgrades["armor"] = 0;

	for value, itemID in pairs(weapons) do
	   local bag, bank = DataStore:GetContainerItemCount(DataStore:GetCharacter(), itemID);
	   upgrades["weapon"] = upgrades["weapon"] + (((bag or 0) + (bank or 0)) * value)
	end
	for value, itemID in pairs(armor) do
	   local bag, bank = DataStore:GetContainerItemCount(DataStore:GetCharacter(), itemID);
	   upgrades["armor"] = upgrades["armor"] + (((bag or 0) + (bank or 0)) * value)
	end

	if(upgrades["weapon"] < upgrades["armor"]) then
		print( "|cff00ff00Weapon: " .. upgrades["weapon"] .. "|r");
		print( "Armor: " .. upgrades["armor"] );
	else
		print( "Weapon: " .. upgrades["weapon"]);
		print( "|cff00ff00Armor: " .. upgrades["armor"] .. "|r");
	end
end

function unitFrameTextures()
	local texture = "Interface\\Addons\\AngusUI\\media\\bar"

	PlayerName:SetTextColor(1, 1, 1)

	TargetFrameNameBackground:SetTexture(texture)
	TargetFrameTextureFrameName:SetTextColor(1, 1, 1)

	FocusFrameNameBackground:SetTexture(texture)
	FocusFrameTextureFrameName:SetTextColor(1, 1, 1)
end

function frame:QUEST_ACCEPTED(self, position, id)
	if( id == 38188 or id == 38175) then
		followerUpgrades()
	end
end

function frame:ADDON_LOADED(self, addon)
	if (addon == "Blizzard_TimeManager") then

		for i, v in pairs({PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture, PartyMemberFrame4Texture,
			PartyMemberFrame1PetFrameTexture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame4PetFrameTexture, FocusFrameToTTextureFrameTexture, BonusActionBarFrameTexture0, BonusActionBarFrameTexture1, BonusActionBarFrameTexture2, BonusActionBarFrameTexture3,
			BonusActionBarFrameTexture4, MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3, MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2,
			MainMenuMaxLevelBar3, MinimapBorder, CastingBarFrameBorder, FocusFrameSpellBarBorder, TargetFrameSpellBarBorder, MiniMapTrackingButtonBorder, MiniMapLFGFrameBorder, MiniMapBattlefieldBorder,
			MiniMapMailBorder, MinimapBorderTop,
			select(1, TimeManagerClockButton:GetRegions())
		}) do
			v:SetVertexColor(.35, .35, .35)
		end

		for i,v in pairs({ select(2, TimeManagerClockButton:GetRegions()) }) do
				v:SetVertexColor(1, 1, 1)
		end

		MainMenuBarLeftEndCap:SetVertexColor(.35, .35, .35);
		MainMenuBarRightEndCap:SetVertexColor(.35, .35, .35);

		CharacterMicroButton:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0);

		unitFrameTextures()

		self:UnregisterEvent("ADDON_LOADED");
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if (event == "ADDON_LOADED") then
		self:ADDON_LOADED(self, ...)
	end
	if (event == "QUEST_ACCEPTED") then
		self:QUEST_ACCEPTED(self, ...)
	end
end)
