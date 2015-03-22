local T, C, L = Tukui:unpack()

local DataText = T["DataTexts"]

local showIcon = false
local FactionGroup, ConquestIcon = nil, nil

if showIcon then
    FactionGroup = UnitFactionGroup( "player" )
    ConquestIcon = "Interface\\Icons\\pvpcurrency-conquest-"..FactionGroup
end

local CONQUEST, currentAmount, _, _, weeklyMax  = "Conquest Points", nil, nil

local Update = function(self, event)
	if (not IsLoggedIn()) then
		return
	end

    local name, amount, txt, thisWeek, weekly, total = GetCurrencyInfo(390)

    CONQUEST = name
    currentAmount = amount
    weeklyMax = weekly

    if not showIcon then
        self.Text:SetFormattedText("%sCQ: %s%d%s/%s%d|r", DataText.NameColor, DataText.ValueColor, currentAmount, DataText.NameColor, DataText.ValueColor, weeklyMax)
    else
        self.Text:SetFormattedText("|T"..ConquestIcon..":0|t %s%d%s/%s%d|r", DataText.ValueColor, currentAmount, DataText.NameColor, DataText.ValueColor, weeklyMax)
    end
end


local OnMouseDown = function(self)
    if PVPUIFrame:IsVisible() and not ConquestFrame:IsVisible() then
        PVPQueueFrameCategoryButton2:Click()
    elseif not PVPUIFrame:IsVisible() then
        TogglePVPUI()
        PVPQueueFrameCategoryButton2:Click()
    else
        TogglePVPUI()
    end
end


local Enable = function(self)
    if not IsAddOnLoaded("Blizzard_PVPUI") then
        LoadAddOn("Blizzard_PVPUI")
    end
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW")
    self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnEvent", Update)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseDown", nil)
end

DataText:Register(CONQUEST, Enable, Disable, Update)
