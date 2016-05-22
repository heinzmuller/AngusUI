local _, angusui = ...

local frame=CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

SLASH_ANGUSUI1, SLASH_ANGUSUI2 = '/angusui', '/aui'; -- 3.
	function SlashCmdList.ANGUSUI(msg, editbox) -- 4.
end

function frame:ADDON_LOADED(self, addon)
	if (addon == "Blizzard_TimeManager") then

		for i, v in pairs({PlayerFrameTexture, TargetFrameTexture, TargetFrameTextureFrameTexture, PetFrameTexture, PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture, PartyMemberFrame4Texture,
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
		MainMenuBar:SetScale(.85);
		MultiBarBottomLeft:SetScale(.85);
		MultiBarBottomRight:SetScale(.85);
		CharacterMicroButton:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0);
		self:UnregisterEvent("ADDON_LOADED");
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if (event == "ADDON_LOADED") then
		self:ADDON_LOADED(self, ...)
	end
end)
