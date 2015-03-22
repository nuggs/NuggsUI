local TukuiUnitFrames = T["UnitFrames"]

hooksecurefunc(TukuiUnitFrames, "Player", function(Player)
	if C.UnitFrames.Portrait then
		Player.Portrait:ClearAllPoints()
		Player.Portrait:SetPoint("CENTER", Player.Health, "CENTER", 0, 0)
		Player.Portrait:Size(250, 25)
		Player.Portrait.Backdrop:SetBackdrop(nil)
		Player.Portrait:SetAlpha(.3)

		Player.Health:ClearAllPoints()
		Player.Health:SetPoint("TOPLEFT", 0, 0)
		Player.Health:SetPoint("TOPRIGHT")
	end
end)
