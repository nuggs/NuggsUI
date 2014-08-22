--local T, C, L = unpack(Tukui)

--[[ TinyDPS editless skin, by Dajova
local TinyDPS = CreateFrame("Frame")
TinyDPS:RegisterEvent("ADDON_LOADED")
TinyDPS:SetScript("OnEvent", function(self, event, addon)
	if not addon == "TinyDPS" then return end

	if (tdps) then
		tdps.width = TukuiMinimap:GetWidth()
		tdps.barHeight = 16
	end
	tdpsFont.name = C["media"].uffont

	tdpsPosition = {x = 0, y = -6}

	tdpsFrame:SetHeight(tdps.barHeight + 4)
	tdpsFrame:SetTemplate("Default")
	tdpsFrame:CreateShadow("Default")

	tdpsAnchor:SetPoint('BOTTOMLEFT', TukuiMinimapStatsLeft or TukuiReputation or TukuiMinimap, 'BOTTOMLEFT', 0, -6)

	if tdpsStatusBar then
		tdpsStatusBar:SetBackdrop({bgFile = C["media"].normTex, edgeFile = C["media"].blank, tile = false, tileSize = 1, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0}})
		tdpsStatusBar:SetStatusBarTexture(C["media"].normTex)
	end

	self:UnregisterEvent("ADDON_LOADED")
end)]]--