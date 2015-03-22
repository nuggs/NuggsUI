local TukuiUnitFrames = T["UnitFrames"]

hooksecurefunc(TukuiUnitFrames, "Party", function(Party)
	if (C.Party.Portrait) then
		Party.Portrait:ClearAllPoints()
		Party.Portrait:SetPoint("CENTER", Party.Health, "CENTER", 0, 0)
		Party.Portrait:Size(160, 18)
		Party.Portrait.Backdrop:SetBackdrop(nil)
		Party.Portrait:SetAlpha(.3)
		
		Party.Health:ClearAllPoints()
		Party.Health:SetPoint("TOPLEFT", 0, 0)
		Party.Health:SetPoint("TOPRIGHT")
	end
end)