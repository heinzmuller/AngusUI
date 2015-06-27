local _, angusui = ...

local frame=CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_ACCEPTED")

SLASH_ANGUSUI1, SLASH_ANGUSUI2 = '/angusui', '/aui'; -- 3.
	function SlashCmdList.ANGUSUI(msg, editbox) -- 4.

	frame:followerUpgrades()
end

function frame:followerUpgrades()
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

function frame:QUEST_ACCEPTED(self, position, id)
	if( id == 38188 or id == 38175) then
		self:followerUpgrades()
	end
end

function frame:ADDON_LOADED(self, addon)
	if (addon == "Blizzard_TimeManager") then

		for i, v in pairs({PlayerFrameTexture, TargetFrameTextureFrameTexture, PetFrameTexture, PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture, PartyMemberFrame4Texture,
			PartyMemberFrame1PetFrameTexture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame4PetFrameTexture, FocusFrameTextureFrameTexture,
			TargetFrameToTTextureFrameTexture, FocusFrameToTTextureFrameTexture, BonusActionBarFrameTexture0, BonusActionBarFrameTexture1, BonusActionBarFrameTexture2, BonusActionBarFrameTexture3,
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
		MainMenuBar:SetScale(.75);
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
