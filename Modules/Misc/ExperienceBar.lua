T, C, L = Tukui:unpack()

-- Hook in to the experience enable/disable functions to move the pet bar if we're using
-- the chat background.  Thanks Blazeflack.  :D
if not C.Chat.Background then return end

local TukuiActionBars = T["ActionBars"]
local Panels = T["Panels"]
local Miscellaneous = T["Miscellaneous"]

local PetPanel = Panels.PetActionBar
local Experience = Miscellaneous.Experience

local function OnEnable()
	PetPanel:ClearAllPoints()
	PetPanel:SetPoint("BOTTOM", Panels.RightChatBG, "TOP", 0, 14)
end

local function OnDisable()
	PetPanel:ClearAllPoints()
	PetPanel:SetPoint("BOTTOM", Panels.RightChatBG, "TOP", 0, 2)
end

hooksecurefunc(Experience, "Enable", OnEnable)
hooksecurefunc(Experience, "Disable", OnDisable)