local T, C, L = Tukui:unpack()

local TukuiChat = T["Chat"]

-- Move the toast frame to the top left of the screen.  :D
local Toast = BNToastFrame
local ToastCloseButton = BNToastFrameCloseButton
local DataTextRight = T.Panels.DataTextRight
local Chat = T.Chat

local function SkinToastFrame(self)
    Toast:HookScript("OnShow", function()
        Toast:SetTemplate("Transparent")
        Toast:ClearAllPoints()
        Toast:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 5, -5)
    end)
end
hooksecurefunc(Chat, "SkinToastFrame", SkinToastFrame)
