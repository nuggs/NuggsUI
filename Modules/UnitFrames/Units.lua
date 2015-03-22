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

hooksecurefunc(TukuiUnitFrames, "Target", function(Target)
	if C.UnitFrames.Portrait then
		Target.Portrait:ClearAllPoints()
		Target.Portrait:SetPoint("CENTER", Target.Health, "CENTER", 0, 0)
		Target.Portrait:Size(250, 25)
		Target.Portrait.Backdrop:SetBackdrop(nil)
		Target.Portrait:SetAlpha(.3)
		
		Target.Health:ClearAllPoints()
		Target.Health:SetPoint("TOPLEFT", 0, 0)
		Target.Health:SetPoint("TOPRIGHT")
	end
end)