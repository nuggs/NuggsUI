local T, C, L, G = unpack(Tukui)
if not C["datatext"].iglguild or C["datatext"].iglguild == 0 then return end
local NextRosterUpdate = -1;
local guildRoster, guildXP, guildMotD = {}, {}, ""
local totalOnline = 0;

local function updateRoster()
	totalOnline = 0;
	if guildRoster then wipe(guildRoster); end

	local _, memName, memRank, memLevel, memZone, memNote, memOfficerNote, memOnline, memStatus, memClassFileName, memIsMobile;
	for i = 1, GetNumGuildMembers() do
		--memName, memRank, memRankIndex, memLevel, memLocalizedClass, memZone, memNote, memOfficerNote, memOnline, memStatus, memClassFileName, memAchievementPoints, memAchievementRank, memIsMobile, memCanSoR, memReputationStanding
		memName, memRank, _, memLevel, _, memZone, memNote, memOfficerNote, memOnline, memStatus, memClassFileName, _, _, memIsMobile, _, _ = GetGuildRosterInfo(i);
		if memStatus == 1 then
			memStatus = "|cffff0000["..AFK.."]|r"
		elseif memStatus == 2 then
			memStatus = "|cffff0000["..DND.."]|r" 
		else
			memStatus = ""
		end
		
		guildRoster[i] = { memName, memRank, memLevel, memZone, memNote, memOfficerNote, memOnline, memStatus, memClassFileName, memIsMobile }
		if memOnline then totalOnline = totalOnline + 1 end
	end
	table.sort(guildRoster, function(a, b)
		if a and b then
			return a[1] < b[1]
		end
	end)
	print("Updated Roster");
end

local function updateGuildXP()
	local currentXP, remainingXP = UnitGetGuildXP("player")
	local nextLevelXP = currentXP + remainingXP

	if nextLevelXP == 0 or maxDailyXP == 0 then return end
	
	local percentTotal = tostring(math.ceil((currentXP / nextLevelXP) * 100))
	
	guildXP[0] = { currentXP, nextLevelXP, percentTotal }
end

local function updateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local Stat = CreateFrame("Frame", "NuggsUIIGLDatatext");

local function guildRosterChange(EventId, SourceGuild, ActionVerb, ...)
	if (EventId == IGLAPIConstants.WOW_EVENT_GUILD_ROSTER_UPDATE) then
		local timeNow = time();
		local updateNow = false;

		if (ActionVerb == IGLAPIConstants.API_VERB_ROSTER_MEMBER_NEW) then
			updateNow = true;
		elseif (timeNow > NextRosterUpdate) then
			updateNow = true;
			NextRosterUpdate = timeNow + IGLAPIConstants.WOW_ROSTER_THROTTLE_UPDATE_SECONDS;
		end;

		if (updateNow) then
			updateRoster()
			print(SourceGuild);
		end;
	end
end

IGLInterop.RegisterAllyEventListener("NuggsUI", IGLAPIConstants.WOW_EVENT_GUILD_ROSTER_UPDATE, guildRosterChange);