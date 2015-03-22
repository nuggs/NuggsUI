local T, C, L = Tukui:unpack()

local DataText = T["DataTexts"]

local showIcon = false
local FactionGroup, HonorIcon = nil, nil

if showIcon then
    FactionGroup = UnitFactionGroup( "player" )
    HonorIcon = "Interface\\Icons\\pvpcurrency-honor-"..FactionGroup
end

local HONOR, currentAmount = "Honor Points", nil

local Update = function(self, event)
	if (not IsLoggedIn()) then
		return
	end

    local name, amount = GetCurrencyInfo(392)

    HONOR = name
    currentAmount = amount

    if not showIcon then
        self.Text:SetFormattedText("%sHonor: %s%d|r", DataText.NameColor, DataText.ValueColor, currentAmount)
    else
        self.Text:SetFormattedText("|T"..HonorIcon..":0|t %s%d|r", DataText.ValueColor, currentAmount)
    end
end

local OnMouseDown = function(self)
    if PVPUIFrame:IsVisible() and not HonorFrame.BonusFrame:IsVisible() then
        PVPQueueFrameCategoryButton1:Click()
    elseif not PVPUIFrame:IsVisible() then
        TogglePVPUI()
        PVPQueueFrameCategoryButton1:Click()
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

DataText:Register(HONOR, Enable, Disable, Update)