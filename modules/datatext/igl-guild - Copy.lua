local T, C, L, G = unpack(Tukui)
local NuggsUI_GuildStat = CreateFrame("Frame", "NuggsUI_GuildStat");
local initialized, nStat, nText = 0, 0, 0;

local tthead, ttsubh, ttoff, activezone, inactivezone, displayString, guildInfoString, guildInfoString2;
local guildMotDString, levelNameString, levelNameStatusString, nameRankString, noteString, officerNoteString;
local guildTable, guildXP, guildMotD = {}, {}, ""
local totalOnline = 0

local function BuildGuildTable()
	totalOnline = 0
	wipe(guildTable)
	local _, name, rank, level, zone, note, officernote, connected, status, class, isMobile
	for i = 1, GetNumGuildMembers() do
		name, rank, _, level, _, zone, note, officernote, connected, status, class, _, _, isMobile = GetGuildRosterInfo(i)
		
		if status == 1 then
			status = "|cffff0000["..AFK.."]|r"
		elseif status == 2 then
			status = "|cffff0000["..DND.."]|r" 
		else
			status = ""
		end
		
		guildTable[i] = { name, rank, level, zone, note, officernote, connected, status, class, isMobile }
		if connected then totalOnline = totalOnline + 1 end
	end
	table.sort(guildTable, function(a, b)
		if a and b then
			return a[1] < b[1]
		end
	end)
end

local function UpdateGuildXP()
	local currentXP, remainingXP = UnitGetGuildXP("player")
	local nextLevelXP = currentXP + remainingXP
	
	-- prevent 4.3 division / 0
	if nextLevelXP == 0 or maxDailyXP == 0 then return end
	
	local percentTotal = tostring(math.ceil((currentXP / nextLevelXP) * 100))
	
	guildXP[0] = { currentXP, nextLevelXP, percentTotal }
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

function NuggsUI_GuildStat:OnEvent(self, event, ...)
	print("debug on event enter");
	if event == "PLAYER_ENTERING_WORLD" then
		print("test");
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if IsInGuild() and not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
	end

	print("debug on event Middle");

	if IsInGuild() then
		print("IsInGuild check");
		totalOnline = 0
		local name, rank, level, zone, note, officernote, connected, status, class
		for i = 1, GetNumGuildMembers() do
			local connected = select(9, GetGuildRosterInfo(i))
			if connected then totalOnline = totalOnline + 1 end
		end
		print("setting text");
		nText:SetFormattedText(displayString, L.datatext_guild, totalOnline)
	else
		print("setting text other");
		nText:SetText(L.datatext_noguild)
	end

	nStat:SetAllPoints(nText);
	print("Finished onevent");
end

local menuFrame = CreateFrame("Frame", "NuggsUIGuildRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true,notCheckable=true},
	{ text = INVITE, hasArrow = true,notCheckable=true,},
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true,notCheckable=true,}
}

local function inviteClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	InviteUnit(arg1)
end

local function whisperClick(self,arg1,arg2,checked)
	menuFrame:Hide()
	SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )
end

local function ToggleGuildFrame()
	if IsInGuild() then
		if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
		GuildFrame_Toggle();
		GuildFrame_TabClicked(GuildFrameTab2);
	else
		if not LookingForGuildFrame then LoadAddOn("Blizzard_LookingForGuildUI") end
		LookingForGuildFrame_Toggle();
	end
end

function NuggsUI_GuildStat.MouseDown(self, button)
	if button=="LeftButton" then
		ToggleGuildFrame();
	end
end

function NuggsUI_GuildStat.MouseUp(self, button)
	if button ~= "RightButton" or not IsInGuild() then return end
	
	GameTooltip:Hide();

	local classc, levelc, grouped;
	local menuCountWhispers = 0;
	local menuCountInvites = 0;

	menuList[2].menuList = {};
	menuList[3].menuList = {};

	for i = 1, #guildTable do
		if (guildTable[i][7] and guildTable[i][1] ~= T.myname) then
			local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[guildTable[i][9]], GetQuestDifficultyColor(guildTable[i][3]);

			if UnitInParty(guildTable[i][1]) or UnitInRaid(guildTable[i][1]) then
				grouped = "|cffaaaaaa*|r";
			else
				grouped = ""
				if not guildTable[i][10] then
					menuCountInvites = menuCountInvites + 1;
					menuList[2].menuList[menuCountInvites] = {text = string.format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, guildTable[i][3], classc.r*255,classc.g*255,classc.b*255, guildTable[i][1], ""), arg1 = guildTable[i][1],notCheckable=true, func = inviteClick};
				end
			end
			menuCountWhispers = menuCountWhispers + 1;
			menuList[3].menuList[menuCountWhispers] = {text = string.format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, guildTable[i][3], classc.r*255,classc.g*255,classc.b*255, guildTable[i][1], grouped), arg1 = guildTable[i][1],notCheckable=true, func = whisperClick};
		end
	end
	EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2);
end

function NuggsUI_GuildStat.OnEnter(self)
	if InCombatLockdown() or not IsInGuild() then return end

	GuildRoster();
	UpdateGuildMessage();
	BuildGuildTable();

	local name, rank, level, zone, note, officernote, connected, status, class, isMobile;
	local zonec, classc, levelc;
	local online = totalOnline;
	local GuildInfo = GetGuildInfo('player');
	local GuildLevel = GetGuildLevel();

	local anchor, panel, xoff, yoff = T.DataTextTooltipAnchor(nText);
	GameTooltip:SetOwner(panel, anchor, xoff, yoff);
	GameTooltip:ClearLines();
	if GuildInfo and GuildLevel then
		GameTooltip:AddDoubleLine(string.format(guildInfoString, GuildInfo, GuildLevel), string.format(guildInfoString2, L.datatext_guild, online, #guildTable),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b);
	end

	if guildMotD ~= "" then GameTooltip:AddLine(' ') GameTooltip:AddLine(string.format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1) end

	local col = T.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b);
	GameTooltip:AddLine' ';
	if GuildLevel and GuildLevel ~= 25 then
		--UpdateGuildXP()
		if guildXP[0] then
			local currentXP, nextLevelXP, percentTotal = unpack(guildXP[0]);
			GameTooltip:AddLine(string.format(col..GUILD_EXPERIENCE_CURRENT, "|r |cFFFFFFFF"..T.ShortValue(currentXP), T.ShortValue(nextLevelXP), percentTotal));
		end
	end
	
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
	if standingID ~= 8 then -- Not Max Rep
		barMax = barMax - barMin;
		barValue = barValue - barMin;
		barMin = 0;
		GameTooltip:AddLine(string.format("%s:|r |cFFFFFFFF%s/%s (%s%%)",col..COMBAT_FACTION_CHANGE, T.ShortValue(barValue), T.ShortValue(barMax), math.ceil((barValue / barMax) * 100)));
	end
	
	if online > 1 then
		GameTooltip:AddLine(' ');
		for i = 1, #guildTable do
			if online <= 1 then
				if online > 1 then GameTooltip:AddLine(format("+ %d More...", online - modules.Guild.maxguild),ttsubh.r,ttsubh.g,ttsubh.b); end
				break
			end

			name, rank, level, zone, note, officernote, connected, status, class, isMobile = unpack(guildTable[i]);
			if connected and name ~= T.myname then
				if GetRealZoneText() == zone then zonec = activezone else zonec = inactivezone end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level);
				
				if isMobile then zone = "" end
				
				if IsShiftKeyDown() then
					GameTooltip:AddDoubleLine(string.format(nameRankString, name, rank), zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b);
					if note ~= "" then GameTooltip:AddLine(string.format(noteString, note), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
					if officernote ~= "" then GameTooltip:AddLine(string.format(officerNoteString, officernote), ttoff.r, ttoff.g, ttoff.b ,1) end
				else
					GameTooltip:AddDoubleLine(string.format(levelNameStatusString, levelc.r*255, levelc.g*255, levelc.b*255, level, name, status), zone, classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b);
				end
			end
		end
	end
	GameTooltip:Show();
end

function NuggsUI_GuildStat.OnLeave(self)
	GameTooltip:Hide();
end	

function NuggsUI_GuildStat:LoadCVars(C)
	C["datatext"].iglguild = 0;
	local myPlayerRealm = GetCVar("realmName");
	local myPlayerName  = UnitName("player");

	if not _G.TukuiConfigAll then _G.TukuiConfigAll = {} end

	local tca = _G.TukuiConfigAll;
	local private = _G.TukuiConfigPrivate;
	local public = _G.TukuiConfigPublic;

	if not tca[myPlayerRealm] then tca[myPlayerRealm] = {}; end
	if not tca[myPlayerRealm][myPlayerName] then tca[myPlayerRealm][myPlayerName] = false; end

	if tca[myPlayerRealm][myPlayerName] == true and not private then return; end
	if tca[myPlayerRealm][myPlayerName] == false and not public then return; end

	local setting;
	if tca[myPlayerRealm][myPlayerName] == true then
		setting = private;
	else
		setting = public;
	end 

	if(setting["datatext"].iglguild) then
		C["datatext"].iglguild = setting["datatext"].iglguild;
	end
end

function NuggsUI_GuildStat:init()
	NuggsUI_GuildStat:LoadCVars(C);

	if C["datatext"].iglguild and C["datatext"].iglguild > 0 then
		local Stat = CreateFrame("Frame", "NuggsUI_GuildStat");
	
		Stat:EnableMouse(true);
		Stat:SetFrameStrata("BACKGROUND");
		Stat:SetFrameLevel(3);
		Stat.Option = C.datatext.iglguild;
		Stat.Color1 = T.RGBToHex(unpack(C.media.datatextcolor1));
		Stat.Color2 = T.RGBToHex(unpack(C.media.datatextcolor2))
		G.DataText.iglguild = Stat;

		local Text  = Stat:CreateFontString("NuggsUI_GuildStatText", "OVERLAY");
		Text:SetFont(C.media.font, C["datatext"].fontsize);
		T.DataTextPosition(C["datatext"].iglguild, Text);
		G.DataText.iglguild.Text = Text;
		NuggsUI_GuildStat.text = Text;
		Stat.text = Text;

		Stat:SetScript("OnMouseUp", NuggsUI_GuildStat.MouseUp);
		Stat:SetScript("OnMouseDown", NuggsUI_GuildStat.MouseDown);
		Stat:SetScript("OnEnter", NuggsUI_GuildStat.OnEnter);
		Stat:SetScript("OnLeave", NuggsUI_GuildStat.OnLeave);
		Stat:SetScript("OnEvent", NuggsUI_GuildStat.OnEvent);
		Stat:RegisterEvent("PLAYER_ENTERING_WORLD");

		tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
		activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
		displayString = string.join("", Stat.Color1.."%s: |r", Stat.Color2, "%d|r")
		guildInfoString = "%s [%d]"
		guildInfoString2 = "%s: %d/%d"
		guildMotDString = "  %s |cffaaaaaa- |cffffffff%s"
		levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
		levelNameStatusString = "|cff%02x%02x%02x%d|r %s %s"
		nameRankString = "%s |cff999999-|cffffffff %s"
		noteString = "  '%s'"
		officerNoteString = "  o: '%s'"
		nStat = Stat;
		nText = Text;

		--NuggsUI_GuildStat.datatext = T.AddOn:GetModule("datatext");
		print("Tukui DataText registered");
	end
end

if (initialized == 0) then
	print("not initialized, initliazing");
	NuggsUI_GuildStat:init(); 
	initialized = 1; 
end

local function processEvent(EventIdentifier, SourceGuild, ...)
	if (EventIdentifier == IGLAPIConstants.WOW_EVENT_GUILD_ROSTER_UPDATE) then
		print("lol doing stuff");
	end
end

IGLInterop.RegisterAllyEventListener("NuggsUI_GuildStat"
	, {	IGLAPIConstants.WOW_EVENT_GUILD_ROSTER_UPDATE	}
	, processEvent
);