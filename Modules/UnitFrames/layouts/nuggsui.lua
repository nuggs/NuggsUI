local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui)
-- ooc uf fade
--oUFs = { [1] = "oUF_Tukz_player", [2] = "oUF_Tukz_target", [3] = "oUF_Tukz_targettarget", [4] = "oUF_Tukz_pet", [5] = "oUF_Tukz_focus", [6] = "oUF_Tukz_focustarget" }

--local function uffade(self, event)
--	if event == "PLAYER_REGEN_DISABLED" then
--		for i = 1, 6 do
--			UIFrameFadeIn(_G[oUFs[i]], 0.075, _G[oUFs[i]]:GetAlpha(), 1) -- 0.075 is the fade time; _G[oUFs[i]]:GetAlpha(), 1 is starting alpha and end alpha
--		end
--	elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
--		for i = 1, 6 do
--			UIFrameFadeOut(_G[oUFs[i]], 0.5, _G[oUFs[i]]:GetAlpha(), 0.1) -- 0.5 is the fade time; _G[oUFs[i]]:GetAlpha(), 0.1 is starting alpha and end alpha
--		end
--	end
--end

--local oocfade = CreateFrame("Frame")
--oocfade:RegisterEvent("PLAYER_ENTERING_WORLD")
--oocfade:RegisterEvent("PLAYER_REGEN_ENABLED")
--oocfade:RegisterEvent("PLAYER_REGEN_DISABLED")
--oocfade:SetScript("OnEvent", uffade)