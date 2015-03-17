local T, C, L = unpack(Tukui);
--[[
	Borrowed some code from StaggerMeter by ElCodeMonkey @ curse
	the debuff
]]--

local _, class = UnitClass("player");
if (class ~= "MONK") then return end
if ((GetSpecialization()) and (GetSpecialization() > 1)) then return end

-- Define some local globals yobal
local amount, duration, percent, showBar = 0, 0, 0, false;
local LIGHT, MODERATE, HEAVY = 124275, 124274, 124273;
local playerName = UnitName("player");
local f = CreateFrame("Frame", "NuggsUI_StaggerMeter", UIParent);
local text = f:CreateFontString(f, "ARTWORK", "GameFontNormal");

local function clear_bar()
	text:SetText(nil);
	f:Hide();
	showBar = false;
end

local function update_meter()
	for i = 1,40 do
		duration, amount = 0, 0;
		local debuffID = select(11, UnitDebuff(playerName, i));
		if (debuffID == LIGHT or debuffID == MODERATE or debuffID == HEAVY) then
			local spellName = select(1, UnitDebuff(playerName, i));
			duration = select(6, UnitAura(playerName, spellName, "", "HARMFUL"));
			amount = select(15, UnitAura(playerName, spellName, "", "HARMFUL"));
			if (showBar == false) then showBar = true; end
			break;
		end
	end

	if (amount == 0 or duration == 0) then
		clear_bar();
		return;
	end

	if (showBar == true and not f:IsShown()) then
		f:Show();
	end

	local health, maxHealth = UnitHealth(playerName), UnitHealthMax(playerName);
	local updateBackDrop, r, g, b = false, 0, 0, 0;
	percent = math.min(amount / maxHealth * 100, 100);
	if (percent >= 6) then
		updateBackDrop = true;
		r,g,b = 1,0,0;
	elseif (percent >= 3 and percent < 6) then
		updateBackDrop = true;
		r,g,b = 1,1,0;
	elseif (percent < 3) then
		updateBackDrop = true;
		r,g,b = 0,.7,0;
	end
	if (updateBackDrop == true) then
		f:SetBackdropColor(r,g,b);
		updateBackDrop = false;
	end

	local pText = format(format("%.2f", percent));
	text:SetText(L.stagger_PERCENT .. ": " .. pText .. "% " .. L.stagger_DAMAGE .. ": " .. amount);
end

function f:PLAYER_DEAD()
	clear_bar();
end

function f:ACTIVE_TALENT_GROUP_CHANGED()
	if (GetSpecialization() == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("test");
		clear_bar();
	end
end

function f:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, _, _, _, _, _, destName, _, _, spellID)
	if (destName == playerName) then
		if (event == "SPELL_PERIODIC_DAMAGE" and spellId == STAGGER) then
			update_meter();
		elseif (event == "SWING_DAMAGE") then
			update_meter();
		elseif (event == "SPELL_AURA_APPLIED") then
			update_meter();
		elseif (event == "SPELL_AURA_REMOVED") then
			update_meter();
		end
	end
end

function f:ADDON_LOADED(name)
	if ((GetSpecialization()) and (GetSpecialization() > 1)) then return end

	f:SetTemplate("Default");
	f:Size(T.InfoLeftRightWidth, 20);
	text:SetAllPoints(f);
	text:SetFont("Fonts\\ARIALN.TTF", 14, "OUTLINE");
	text:SetTextColor(1,1,1);
	if (C.chat.background and TukuiChatBackgroundLeft) then
		f:Point("BOTTOMLEFT", TukuiChatBackgroundLeft, "TOPLEFT", 0, 6);
	else
		f:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 6);
	end
	f:Hide();
end

f:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end);
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("ADDON_LOADED");
f:RegisterEvent("PLAYER_DEAD");
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
