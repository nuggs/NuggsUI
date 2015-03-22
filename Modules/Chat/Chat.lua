local T, C, L = Tukui:unpack()

local TukuiChat = T["Chat"]
local Noop = function() end

-- Change chat tab text color
local function StyleFrame(self, frame)
	local Frame = frame
	local FrameName = frame:GetName()
	local TabText = _G[FrameName.."TabText"]

	TabText:SetTextColor(0, .5, .7)
	TabText.SetTextColor = Noop
end
hooksecurefunc(TukuiChat, "StyleFrame", StyleFrame)

-- Move the toast frame to the top left of the screen.  :D
local Toast = BNToastFrame
local ToastCloseButton = BNToastFrameCloseButton

local function SkinToastFrame(self)
    Toast:HookScript("OnShow", function()
        Toast:SetTemplate("Transparent")
        Toast:ClearAllPoints()
        Toast:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 5, -5)
    end)
end
hooksecurefunc(TukuiChat, "SkinToastFrame", SkinToastFrame)
