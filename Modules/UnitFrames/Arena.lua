local C, T, L = Tukui:unpack()

NuggsUI_Arena = CreateFrame("Frame", nil, UIParent)

function NuggsUI_Arena:UNIT_SPELLCAST_SUCCEEDED(unitID, spell)

end

function NuggsUI_Arena:PLAYER_ENTERING_WORLD()

end

NuggsUI_Arena:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
NuggsUI_Arena:RegisterEvent("PLAYER_ENTERING_WORLD")