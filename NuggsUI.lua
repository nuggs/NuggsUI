local T, C, L = Tukui:unpack()

-- Some basic things I want from my UI.
local NuggsUI_Worker = CreateFrame("Frame");

function NuggsUI_Worker:PLAYER_LOGIN()
	NuggsUI_Worker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	NuggsUI_Worker:UnregisterEvent("PLAYER_LOGIN");
end

-- Change tab keybinding when entering a PvP zone
function NuggsUI_Worker:PLAYER_ENTERING_WORLD(...)
	if (NuggsUI_IsPvP() == 1) then
		SetBinding("TAB","TARGETNEARESTENEMYPLAYER");
		SetBinding("SHIFT-TAB","TARGETNEARESTENEMY");
	else
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

	if event == "SPELL_AURA_APPLIED" and isDestEnemy then --UnitIsEnemy("player", destName) then -- UnitIsPlayer(destGUID) and
		spellId, spellName, spellSchool = select(12,...);
		if spellId == 42292 or spellId == 59752 then --if sourceGUID ~= destGUID then
			SendChatMessage(">>>> TRINKET USED ".." ["..destName.."] <<<<", "SAY");
		end
	end
end

NuggsUI_Worker:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end);
NuggsUI_Worker:RegisterEvent("PLAYER_LOGIN");
NuggsUI_Worker:RegisterEvent("PLAYER_ENTERING_WORLD");
