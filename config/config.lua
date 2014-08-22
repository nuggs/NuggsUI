--[[local T, C, L, G = unpack(Tukui)

 C["unitframes"] = {
	["style"] = "NuggsUI";
}]]--

--[[ setup our additional datatext
C["datatext"].iglguild = 0;

TukuiConfigUILocalization.datatextiglguild = L.datatext_INTERGUILD;
local myPlayerRealm = GetCVar("realmName");
local myPlayerName  = UnitName("player");

--if we do not have data yet, init
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
end]]--
