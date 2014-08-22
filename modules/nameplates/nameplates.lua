local T, C, L = unpack(Tukui)
if( C["tooltip"]["enable"] ~= true ) then return end

local npframe = CreateFrame("Frame");

local function NuggsUI_IsPvP()
	SetMapToCurrentZone();
	_, instance = IsInInstance();
	if (instance == "pvp" or instance == "arena") then
		return 1;
	end
	return nil;
end

function npframe:PLAYER_ENTERING_WORLD(...)
	if (NuggsUI_IsPvP() == 1) then
		SetCVar("nameplateShowFriends", 1);
	else
		SetCVar("nameplateShowFriends", 0);
	end
end

npframe:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end);
npframe:RegisterEvent("PLAYER_ENTERING_WORLD");
