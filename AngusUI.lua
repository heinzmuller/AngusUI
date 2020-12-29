local _, angusui = ...

local darkness = .5

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function slashCommand(arg)
	if (arg == "bar") then
		resetActionBar()
	else
		print("These are the commands you're looking for")
		print("/bar")
	end
end

function resetActionBar()
	-- Hide actionbar page stuff
	-- local hide = { MainMenuBarArtFrame.PageNumber, ActionBarUpButton, ActionBarDownButton }
	-- for i, v in pairs(hide) do
	-- 	v:SetShown(false)
	-- end

	-- Show MultiBarBottomRight :)
	local r = MultiBarBottomRight
	r:SetShown(true)

	-- Adjust anchors for button 7
	local b = MultiBarBottomRightButton7
	b:ClearAllPoints()
	b:SetPoint("LEFT", MultiBarBottomRightButton6, "RIGHT", 6, 0)
end

SlashCmdList.ANGUSUI = slashCommand
SLASH_ANGUSUI1, SLASH_ANGUSUI2 = "/angusui", "/aui"
function frame:ADDON_LOADED(self, addon)
	if (addon == "Blizzard_TimeManager") then
		for i, v in pairs(
			{
				PartyMemberFrame1Texture,
				PartyMemberFrame2Texture,
				PartyMemberFrame3Texture,
				PartyMemberFrame4Texture,
				PartyMemberFrame1PetFrameTexture,
				PartyMemberFrame2PetFrameTexture,
				PartyMemberFrame3PetFrameTexture,
				PartyMemberFrame4PetFrameTexture,
				FocusFrameToTTextureFrameTexture,
				BonusActionBarFrameTexture0,
				BonusActionBarFrameTexture1,
				BonusActionBarFrameTexture2,
				BonusActionBarFrameTexture3,
				BonusActionBarFrameTexture4,
				MainMenuBarTexture0,
				MainMenuBarTexture1,
				MainMenuBarTexture2,
				MainMenuBarTexture3,
				MainMenuMaxLevelBar0,
				MainMenuMaxLevelBar1,
				MainMenuMaxLevelBar2,
				MainMenuMaxLevelBar3,
				MinimapBorder,
				CastingBarFrameBorder,
				FocusFrameSpellBarBorder,
				TargetFrameSpellBarBorder,
				MiniMapTrackingButtonBorder,
				MiniMapLFGFrameBorder,
				MiniMapBattlefieldBorder,
				MiniMapMailBorder,
				MinimapBorderTop,
				MainMenuBarArtFrameBackground.BackgroundLarge,
				MainMenuBarArtFrameBackground.BackgroundSmall,
				StatusTrackingBarManager.SingleBarLarge,
				StatusTrackingBarManager.SingleBarSmall,
				PlayerFrameTexture,
				TargetFrameTextureFrameTexture,
				select(1, TimeManagerClockButton:GetRegions())
			}
		) do
			v:SetVertexColor(darkness, darkness, darkness)
		end

		for i, v in pairs({select(2, TimeManagerClockButton:GetRegions())}) do
			v:SetVertexColor(1, 1, 1)
		end

		MainMenuBarArtFrame.LeftEndCap:SetVertexColor(darkness, darkness, darkness)
		MainMenuBarArtFrame.RightEndCap:SetVertexColor(darkness, darkness, darkness)

		-- TODO: Mouseover alpha
		MicroButtonAndBagsBar:SetAlpha(0.2)

		UIParent:SetScale(.55)

		self:UnregisterEvent("ADDON_LOADED")
	end
end

frame:SetScript(
	"OnEvent",
	function(self, event, ...)
		hooksecurefunc(
			"InterfaceOptions_UpdateMultiActionBars",
			function()
				SHOW_MULTI_ACTIONBAR_2 = false

				UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = {
					baseY = 2,
					watchBar = 1,
					maxLevel = 1,
					anchorTo = "MultiBarBottomLeft",
					point = "TOPLEFT",
					rpoint = "TOPLEFT",
					xOffset = 0,
					yOffset = 55
				}
			end
		)

		hooksecurefunc(
			MainMenuBar,
			"ChangeMenuBarSizeAndPosition",
			function(var)
				resetActionBar()
			end
		)

		if (event == "ADDON_LOADED") then
			self:ADDON_LOADED(self, ...)
		end

		if (event == "PLAYER_ENTERING_WORLD") then
			MainMenuBar:SetScale(.8)
		end
	end
)
