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
        self.Text:SetText("Honor: "..currentAmount)
    else
        self.Text:SetText("|T"..HonorIcon..":0|t "..currentAmount)
    end

end

local OnMouseDown = function(self)
    TogglePVPUI()
    if PVPUIFrame:IsVisible() then
        PVPQueueFrameCategoryButton1:Click()
    end
end

local Enable = function(self)
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