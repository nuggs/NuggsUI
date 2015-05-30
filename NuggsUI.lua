local T, C, L = Tukui:unpack()

-- Move this stuff to proper files, Could probably go in a PvP module or something.
-- Maybe not.  shaman addon, you cannot outrun the wind, blablblblbl when windfury procs
--[[  ]]
--local n, _, _, _, _, _, _, m, hwl, cwa, u = GetCurrencyListInfo(390) print(n.." "..m.." "..cwa)
--/run local n, a, _, tw, w, t = GetCurrencyInfo(390) print(n.." "..a.." "..tw.." "..w.." "..t)
-- Some basic things I want from my UI.

local zoneName;
local NuggsUI_Worker = CreateFrame("Frame");

function NuggsUI_Worker:PLAYER_LOGIN()
    SetMapToCurrentZone();
    zoneName = GetZoneText();
	NuggsUI_Worker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	NuggsUI_Worker:UnregisterEvent("PLAYER_LOGIN");
    if (IsAddOnLoaded("Tukui_Datatext")) then
        local UnitFrames = T.UnitFrames
        local Pet = UnitFrames.Units.Pet
        Pet:SetPoint("BOTTOM", UnitFrames.Anchor, "TOP", 0, 83)
    end
end

-- Change some settings when entering BGs or arenas
function NuggsUI_Worker:PLAYER_ENTERING_WORLD(...)
    --[[if NuggsUI_IsPvP() then
        local mlook = CreateFrame("button","mlook")
        mlook:RegisterForClicks("AnyDown","AnyUp")
        mlook:SetScript("OnClick",function(s,b,d)
            if d then
                MouselookStart()
            else
                MouselookStop()
            end
        end)
        SecureStateDriverManager:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        local mov = CreateFrame("frame",nil,nil,"SecureHandlerStateTemplate")
        RegisterStateDriver(mov,"mov","[@mouseover,exists]1;0")
        mov:SetAttribute("_onstate-mov","if newstate==1 then self:SetBindingClick(1,'BUTTON2','mlook')else self:ClearBindings()end")
    else
        local mlook = CreateFrame("button", "mlook")
        mlook:RegisterForClicks("AnyDown", "AnyUp")
        mlook:SetScript("OnClick", function(s ,b, d)
            if d then
                MouselookStart()
            else
                MouselookStop()
            end
        end)
        SecureStateDriverManager:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        local mov = CreateFrame("frame", nil, nil, "SecureHandlerStateTemplate")
        RegisterStateDriver(mov, "mov", "[@mouseover,exists]1;1")
        mov:SetAttribute("type", "click")
    end]]

	if (NuggsUI_IsPvP() == 1) then
        if (ObjectiveTrackerFrame:IsVisible() or ObjectiveTrackerFrame:IsShown()) then
            ObjectiveTrackerFrame:Hide();
        end
        SetBinding("TAB","TARGETNEARESTENEMYPLAYER");
        SetBinding("SHIFT-TAB","TARGETNEARESTENEMY");
	else
        if (not ObjectiveTrackerFrame:IsVisible() or not ObjectiveTrackerFrame:IsShown()) then
            ObjectiveTrackerFrame:Show();
        end
		SetBinding("TAB","TARGETNEARESTENEMY");
		SetBinding("SHIFT-TAB","TARGETNEARESTENEMYPLAYER");
	end
end

function NuggsUI_Worker:COMBAT_LOG_EVENT_UNFILTERED(...)
	local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, sourceID, _, _, spellID, spellName, spellSchool = ...
	local isDestEnemy = (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE);

	if bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
		local enemy = UnitName(destGUID);

		if event == "SPELL_INTERRUPT" and UnitIsPlayer("target") and isDestEnemy then --UnitIsEnemy("player", destName) then--UnitIsPlayer(enemy) then
			SendChatMessage(">>>> Interrupt "..GetSpellLink(spellID).." ["..destName.."] <<<<", "SAY");
		end

		if event=="SPELL_AURA_APPLIED" then
			spellId, spellName, spellSchool = select(12,...);
			if spellId == 42292 or spellId == 59752 then
				SendChatMessage("<<<< TRINKET USED! >>>>", "SAY");
			end
		end
	end

	if event == "SPELL_AURA_APPLIED" and isDestEnemy and zoneName ~= "Ashran" then
		spellId, spellName, spellSchool = select(12,...);
		if spellId == 42292 or spellId == 59752 then --if sourceGUID ~= destGUID then
			SendChatMessage(">>>> TRINKET USED ".." ["..destName.."] <<<<", "SAY");
		end
	end
end

NuggsUI_Worker:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end);
NuggsUI_Worker:RegisterEvent("PLAYER_LOGIN");
NuggsUI_Worker:RegisterEvent("PLAYER_ENTERING_WORLD");


--[[ Implement later, mayhaps
local Tooltip = T["Tooltips"]
hooksecurefunc(Tooltip, "CreateAnchor", function()
	Tooltip.Anchor:ClearAllPoints()
	Tooltip.Anchor:SetPoint("BOTTOMRIGHT", RightChatBG, -5, 125)
end)
]]--
-- n,_,_,c,_,_,_,_,_,_,_,_,_,v1,v2,v3=UnitDebuff("Player", "Dampening");print(n..":".." "..c.." ".." "..v1.." "..v2.." "..v3)