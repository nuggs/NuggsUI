local T, C, L = Tukui:unpack()

-- global functions
function NuggsUI_IsInArena()
	local _, instanceType = IsInInstance()
	return instanceType == "arena"
end

function NuggsUI_IsPvP()
	SetMapToCurrentZone();
	_, instance = IsInInstance();
	if (instance == "pvp" or instance == "arena") then
		return 1;
	end
	return nil;
end
