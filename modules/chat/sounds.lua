local T, C, L, G = unpack(Tukui) 
if C["chat"].enable ~= true then return end

if C.chat.whispersound then
	local SoundSys = CreateFrame("Frame")
	SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
	SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
	--[[ oqueue update ]]--
	SoundSys:HookScript("OnEvent", function(self, event, msg, ...)
	--[[ oqueue update ]]--
		if event == "CHAT_MSG_WHISPER" or "CHAT_MSG_BN_WHISPER" then
	--[[ oqueue update ]]--
	if (msg:sub(1,3) == "OQ,") then return false, msg, ... ; end
	--[[ oqueue update ]]--
			PlaySoundFile(C["media"].whisper)
		end
	end)
	G.Chat.Sound = SoundSys
end