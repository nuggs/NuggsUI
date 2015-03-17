local T, C, L = Tukui:unpack()
local _G = _G

local TukuiActionBars = T["ActionBars"];
local Panels = T["Panels"]
local Movers = T["Movers"];
local ExtraActionBarFrame = _G['ExtraActionBarFrame'];

local EAB = CreateFrame("Frame", nil, UIParent);

function EAB:ADDON_LOADED()
    ActionBarUpButton:Disable();
    ActionBarDownButton:Disable();
end

function EAB:PLAYER_LOGIN()
    -- Set up bindings
    BINDING_HEADER_NUGGSUI = "Extra Bar Buttons";
    BINDING_NAME_NUGGSUIBUTTON1 = "Button 1";
    BINDING_NAME_NUGGSUIBUTTON2 = "Button 2";
    BINDING_NAME_NUGGSUIBUTTON3 = "Button 3";
    BINDING_NAME_NUGGSUIBUTTON4 = "Button 4";
    BINDING_NAME_NUGGSUIBUTTON5 = "Button 5";
    BINDING_NAME_NUGGSUIBUTTON6 = "Button 6";
    BINDING_NAME_NUGGSUIBUTTON7 = "Button 7";
    BINDING_NAME_NUGGSUIBUTTON8 = "Button 8";
    BINDING_NAME_NUGGSUIBUTTON9 = "Button 9";
    BINDING_NAME_NUGGSUIBUTTON10 = "Button 10";
    BINDING_NAME_NUGGSUIBUTTON11 = "Button 11";
    BINDING_NAME_NUGGSUIBUTTON12 = "Button 12";
end

function EAB:ACTIONBAR_PAGE_CHANGED()
    if GetActionBarPage() ~= 1 then
        ChangeActionBarPage(1);
    end
end

function EAB:UPDATE_BINDINGS()
    for i=1, 12, 1 do
        local Button = _G["ExtraBarButton"..i];
        local id = Button:GetID();

        local hotkey = _G[Button:GetName().."HotKey"];
        local key = GetBindingKey("NUGGSUIBUTTON"..i);
        local text = GetBindingText(key, "KEY_", 1);

        if text == "" then
            hotkey:SetText(RANGE_INDICATOR);
            hotkey:SetPoint("TOPLEFT", Button, "TOPLEFT", 1, -2);
            hotkey:Hide();
        else
            hotkey:SetText(text);
            hotkey:SetPoint("TOPLEFT", Button, "TOPLEFT", -2, -2);
            hotkey:Show();
            SetOverrideBindingClick(Button, true, key, Button:GetName(), "LeftButton");
		end
	end
end

function EAB_OnUpdate()
    for i=1, 12, 1 do
        if not UnitAffectingCombat("player") then
            if MainMenuBar:IsShown() == 1 and _G["ExtraBarButton"..i]:IsShown() == nil then
                _G["ExtraBarButton"..i]:Show();
            elseif MainMenuBar:IsShown() == nil and _G["ExtraBarButton"..i]:IsShown() == 1 then
                _G["ExtraBarButton"..i]:Hide();
            end
        end
    end
end

local function NuggsUI_SetupExtraBar()
    local Size = C.ActionBars.NormalButtonSize;
	local PetSize = C.ActionBars.PetButtonSize
    local Spacing = C.ActionBars.ButtonSpacing;

    local A8 = CreateFrame("Frame", "TukuiActionBar6", UIParent, "SecureHandlerStateTemplate");
	A8:SetPoint("RIGHT", UIParent, "RIGHT", -66, -14);
	A8:SetHeight((Size * 12) + (Spacing * 13));
	A8:SetWidth((Size * 1) + (Spacing * 2));
	A8:SetFrameStrata("BACKGROUND");
	A8:SetFrameLevel(2);
	A8.Backdrop = CreateFrame("Frame", nil, A8);
	A8.Backdrop:SetAllPoints();

    if (not C.ActionBars.HideBackdrop) then
        A8.Backdrop:SetTemplate();
    end

	ExtraActionBarFrame:SetParent(A8);
	ExtraActionBarFrame:SetScript("OnHide", function() A8.Backdrop:Hide() end);
	ExtraActionBarFrame:SetScript("OnShow", function() A8.Backdrop:Show() end);
	A8.Backdrop:Show();

    for id=13, 24 do
        local Button = CreateFrame("CheckButton", "ExtraBarButton"..(id-12), UIParent, "ActionBarButtonTemplate");
        local PreviousButton = _G["ExtraBarButton"..(id-13)];

        Button:SetSize(Size, Size);
        Button:SetAttribute("action", id);
        Button:SetID(id);
        if (id == 13) then
            Button:SetPoint("TOPRIGHT", A8, -Spacing, -Spacing)
        else
            Button:SetPoint("TOP", PreviousButton, "BOTTOM", 0, -Spacing)
		end
        Button:Show();
    end

    for i=1, 12 do
		local Button = _G[format("ExtraBarButton%d", i)];
		Button:SetAttribute("showgrid", 1);
		Button:SetAttribute("statehidden", nil);
		ActionButton_ShowGrid(Button);
    end

	Panels.ActionBar6 = A8

    Movers:RegisterFrame(A8);
    RegisterStateDriver(A8, "visibility", "[vehicleui][petbattle][overridebar] hide; show");
end

EAB:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end);
EAB:SetScript("OnUpdate", EAB_OnUpdate);
EAB:RegisterEvent("PLAYER_LOGIN");
EAB:RegisterEvent("ADDON_LOADED");
EAB:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
EAB:RegisterEvent("UPDATE_BINDINGS");

NuggsUI_SetupExtraBar();