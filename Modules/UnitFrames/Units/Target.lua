local TukuiUnitFrames = T["UnitFrames"]

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