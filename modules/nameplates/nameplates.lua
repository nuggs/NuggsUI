local T, C, L = Tukui:unpack()

local NamePlates = T["NamePlates"]

-- Finish later

--function NamePlates:UpdateDebuffs()
--end
--npDebuffs = CreateFrame("Frame")

local npframe = CreateFrame("Frame");

function npframe:PLAYER_ENTERING_WORLD(...)
	if (NuggsUI_IsPvP() == 1) then
		SetCVar("nameplateShowFriends", 1);
	else
		SetCVar("nameplateShowFriends", 0);
	end
end

npframe:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end);
npframe:RegisterEvent("PLAYER_ENTERING_WORLD");

--[[
local namePlateIndex

local cfg = {}
cfg.scale                   = 0.35
cfg.font                    = STANDARD_TEXT_FONT
cfg.healthbar_fontsize      = 26
cfg.castbar_fontsize        = 26
cfg.aura_stack_fontsize     = 24
cfg.aura_cooldown_fontsize  = 28
cfg.point                   = {"CENTER",0,-16}
cfg.notFocusedPlateAlpha    = 0.5
cfg.start                   = false

local NUM_MAX_AURAS = 40

local unitDB                = {}  --unit table by guid
local nSpellDB                 --aura table by spellid


nSpellDB.disabled = false

local AuraModule = CreateFrame("Frame")
AuraModule.playerGUID       = nil
AuraModule.petGUID          = nil
AuraModule.updateTarget     = false
AuraModule.updateMouseover  = false

local function CreateNamePlateAuraFunctions(blizzPlate)
    blizzPlate.auras = {}
    blizzPlate.auraButtons = {}
    function blizzPlate:CreateAuraHeader()
        local auraHeader = CreateFrame("Frame",nil,self.newPlate)
        auraHeader:SetScale(cfg.scale)
        auraHeader:SetPoint("BOTTOMLEFT",self.newPlate.healthBar,"TOPLEFT",0,15)
        auraHeader:SetSize(60,45)
        blizzPlate.auraHeader = auraHeader
    end
    function blizzPlate:UpdateAura(startTime,expirationTime,unitCaster,spellID,stackCount)
        if not nSpellDB then return end
        if not nSpellDB[spellID] then return end
        if nSpellDB[spellID].blacklisted then return end
        if not expirationTime then
            expirationTime = startTime+nSpellDB[spellID].duration
        elseif not startTime then
            startTime = expirationTime-nSpellDB[spellID].duration
        end
        self.auras[spellID] = {
            spellId         = spellID,
            name            = nSpellDB[spellID].name,
            texture         = nSpellDB[spellID].texture,
            startTime       = startTime,
            expirationTime  = expirationTime,
            duration        = nSpellDB[spellID].duration,
            unitCaster      = unitCaster,
            stackCount      = stackCount,
        }
    end
    function blizzPlate:RemoveAura(spellID)
        if self.auras[spellID] then
            self.auras[spellID] = nil
        end
    end
    function blizzPlate:ScanAuras(unit,filter)
        if not nSpellDB then return end
        if nSpellDB.disabled then return end
        for index = 1, NUM_MAX_AURAS do
            local name, _, texture, stackCount, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, filter)
            if not name then break end
            if spellID and (unitCaster == "player" or unitCaster == "pet") and not nSpellDB[spellID] then
                nSpellDB[spellID] = {
                    name        = name,
                    texture     = texture,
                    duration    = duration,
                    blacklisted = false,
                }
                print(an,"AuraModule","adding new spell to db",spellID,name)
            end
            if spellID and (unitCaster == "player" or unitCaster == "pet") then
                self:UpdateAura(nil,expirationTime,unitCaster,spellID,stackCount)
            end
        end
    end
    function blizzPlate:CreateAuraButton(index)
      if not self.auraHeader then
        self:CreateAuraHeader()
      end
      local button = CreateFrame("Frame",nil,self.auraHeader)
      button:SetSize(self.auraHeader:GetSize())
      button.bg = button:CreateTexture(nil,"BACKGROUND",nil,-8)
      button.bg:SetTexture(1,1,1)
      button.bg:SetVertexColor(0,0,0,0.8)
      button.bg:SetAllPoints()
      button.icon = button:CreateTexture(nil,"BACKGROUND",nil,-7)
      button.icon:SetPoint("TOPLEFT",3,-3)
      button.icon:SetPoint("BOTTOMRIGHT",-3,3)
      button.icon:SetTexCoord(0.1,0.9,0.2,0.8)
      button.cooldown = button:CreateFontString(nil, "BORDER")
      button.cooldown:SetFont(cfg.font, cfg.aura_cooldown_fontsize, "OUTLINE")
      button.cooldown:SetPoint("BOTTOM",button,0,-5)
      button.cooldown:SetJustifyH("CENTER")
      button.stack = button:CreateFontString(nil, "BORDER")
      button.stack:SetFont(cfg.font, cfg.aura_stack_fontsize, "OUTLINE")
      button.stack:SetPoint("TOPRIGHT",button,5,5)
      button.stack:SetJustifyH("RIGHT")
      if index == 1 then
        button:SetPoint("CENTER")
      else
        button:SetPoint("LEFT",self.auraButtons[index-1],"RIGHT",10,0)
      end
      button:Hide()
      self.auraButtons[index] = button
      return button
    end
    function blizzPlate:UpdateAllAuras()
      local buttonIndex = 1
      for index, button in next, self.auraButtons do
        button:Hide()
      end
      for spellID, data in next, self.auras do
        local cooldown = data.expirationTime-GetTime()
        if cooldown < 0 then
          self:RemoveAura(spellID)
        else
          local button = self.auraButtons[buttonIndex] or self:CreateAuraButton(buttonIndex)
          --set texture
          button.icon:SetTexture(data.texture)
          --set cooldown
          button.cooldown:SetText(GetFormattedTime(cooldown))
          --set stackCount
          if data.stackCount and data.stackCount > 1 then
            button.stack:SetText(data.stackCount)
          else
            button.stack:SetText("")
          end
          button:Show()
          buttonIndex = buttonIndex + 1
        end
      end
    end
end

function AuraModule:PLAYER_TARGET_CHANGED(...)
    if not nSpellDB then return end
    if nSpellDB.disabled then return end
    if UnitGUID("target") and UnitExists("target") and not UnitIsUnit("target","player") and not UnitIsDead("target") then
        self.updateTarget = true
    else
        self.updateTarget = false
    end
end

function AuraModule:UPDATE_MOUSEOVER_UNIT(...)
    if not nSpellDB then return end
    if nSpellDB.disabled then return end
    if UnitGUID("mouseover") and UnitExists("mouseover") and not UnitIsUnit("mouseover","player") and not UnitIsDead("mouseover") then
        self.updateMouseover = true
    else
        self.updateMouseover = false
    end
end

function AuraModule:UNIT_PET(...)
    if UnitGUID("pet") and UnitExists("pet") then
        self.petGUID = UnitGUID("pet")
    end
end

function AuraModule:PLAYER_LOGIN(...)
    if UnitGUID("player") then
        self.playerGUID = UnitGUID("player")
    end
    if UnitGUID("pet") and UnitExists("pet") then
        self.petGUID = UnitGUID("pet")
    end
end

AuraModule.CLEU_FILTER = {
    ["SPELL_AURA_APPLIED"]      = true, --UpdateAura
    ["SPELL_AURA_REFRESH"]      = true, --UpdateAura
    ["SPELL_AURA_APPLIED_DOSE"] = true, --UpdateAura
    ["SPELL_AURA_REMOVED_DOSE"] = true, --UpdateAura
    ["SPELL_AURA_STOLEN"]       = true, --RemoveAura
    ["SPELL_AURA_REMOVED"]      = true, --RemoveAura
    ["SPELL_AURA_BROKEN"]       = true, --RemoveAura
    ["SPELL_AURA_BROKEN_SPELL"] = true, --RemoveAura
}

function AuraModule:COMBAT_LOG_EVENT_UNFILTERED(...)
    if not nSpellDB then return end
    if nSpellDB.disabled then return end
    local _, event, _, srcGUID, _, _, _, destGUID, _, _, _, spellID, spellName, _, _, stackCount = ...
    if self.CLEU_FILTER[event] then
        if not unitDB[destGUID] then return end --no corresponding nameplate found
        if not nSpellDB[spellID] then return end --no spell info found
        local unitCaster = nil
        if srcGUID == self.playerGUID then
            unitCaster = "player"
        elseif srcGUID == self.petGUID then
            unitCaster = "pet"
        else
            return
        end
        if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
            unitDB[destGUID]:UpdateAura(GetTime(),nil,unitCaster,spellID,stackCount)
        else
            unitDB[destGUID]:RemoveAura(spellID)
        end
    end
end

function AuraModule:UNIT_AURA(unit)
    if not nSpellDB then return end
    if nSpellDB.disabled then return end
    local guid = UnitGUID(unit)
    if guid and unitDB[guid] and not UnitIsUnit(unit,"player") then
        unitDB[guid]:ScanAuras(unit,"HELPFUL")
        unitDB[guid]:ScanAuras(unit,"HARMFUL")
    end
end

function AuraModule:ADDON_LOADED(name,...)
    self:UnregisterEvent("ADDON_LOADED")
    if not rNP_SPELL_DB then
        rNP_SPELL_DB = {}
    end
    nSpellDB = rNP_SPELL_DB --variable is bound by reference. there is no way this can fuck up. like no way.
    print("AuraModule","loading spell db")
    if nSpellDB.disabled then
        print("AuraModule","spell db is currently disabled on this character")
    end

    --if NamePlates.guid and guid ~= NamePlates.guid then
        print("lol")
        CreateNamePlateAuraFunctions(NamePlates)
        --unitDB[NamePlates.guid] = nil
        --wipe(NamePlates.auras)
        NamePlates:UpdateAllAuras() --hide visible buttons
    --end
end

local function NamePlateSetGUID(blizzPlate,guid)
    if blizzPlate.guid and guid ~= blizzPlate.guid then
      unitDB[blizzPlate.guid] = nil
      wipe(blizzPlate.auras)
      blizzPlate:UpdateAllAuras() --hide visible buttons
      blizzPlate.guid = guid
      unitDB[guid] = blizzPlate
    elseif not blizzPlate.guid then
      blizzPlate.guid = guid
      unitDB[guid] = blizzPlate
    end
end

local function NamePlateOnShow(blizzPlate)
    NamePlateSetup(blizzPlate)
    blizzPlate.newPlate:Show()
end
  
AuraModule:RegisterEvent("ADDON_LOADED")
AuraModule:RegisterEvent("PLAYER_LOGIN")
--ok unit_aura is important. otherwise new auras will only be found if they are preset on frame init.
--one cannot add new spells to the DB via CLEU. there is missing data (duration).
AuraModule:RegisterUnitEvent("UNIT_AURA","target","mouseover")
AuraModule:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
AuraModule:RegisterUnitEvent("UNIT_PET", "player")
AuraModule:RegisterEvent("PLAYER_TARGET_CHANGED")
AuraModule:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
AuraModule:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local countFramesWithFullAlpha = 0
local targetPlate = nil
local delayCounter = 0
local timer = 0.0
local interval = 0.1

function NamePlates:Update()
	for NamePlates, NewPlate in pairs(self.Container) do
		if NamePlates:IsShown() then
			NewPlate:SetPoint("CENTER", NameplateParent, "BOTTOMLEFT", NamePlates:GetCenter())
			NewPlate:Show()

			if NamePlates:GetAlpha() == 1 then
				NewPlate:SetAlpha(1)
			else
				NewPlate:SetAlpha(C.NamePlates.NonTargetAlpha)
			end
			
			self.UpdateAggro(NamePlates)
			
			if C.NamePlates.HealthText then
				self.UpdateHealthText(NamePlates)
			end

            if AuraModule.updateTarget and NewPlate:GetAlpha() == 1 then
                countFramesWithFullAlpha = countFramesWithFullAlpha + 1
                targetPlate = NamePlates
            end

            if AuraModule.updateMouseover and NamePlates:IsShown() and UnitGUID("mouseover") and UnitExists("mouseover") then
                NamePlateSetGUID(NamePlates,UnitGUID("mouseover"))
                NewPlate:ScanAuras("mouseover","HELPFUL")
                NewPlate:ScanAuras("mouseover","HARMFUL")
                AuraModule.updateMouseover = false
            end

            if timer > interval then
                NamePlates:UpdateAllAuras()
            end

            if timer > interval then
                timer = 0
            end

            if AuraModule.updateTarget and countFramesWithFullAlpha == 1 and UnitGUID("target") and UnitExists("target") and not UnitIsDead("target") then
                --this may look wierd but is actually needed.
                --when the PLAYER_TARGET_CHANGED event fires the nameplate need one cycle to update the alpha, otherwise the old target would be tagged.
                if delayCounter == 1 then
                    NamePlateSetGUID(targetPlate,UnitGUID("target"))
                    targetPlate:ScanAuras("target","HELPFUL")
                    targetPlate:ScanAuras("target","HARMFUL")
                    AuraModule.updateTarget = false
                    delayCounter = 0
                    targetPlate = nil
                else
                    delayCounter = delayCounter + 1
                end
            end

            if not namePlateIndex then
                for _, NamePlates in next, {self:GetChildren()} do
                    local name = NamePlates:GetName()
                    if name and string.match(name, "^NamePlate%d+$") then
                        namePlateIndex = string.gsub(name,"NamePlate","")
                        break
                    end
                end
            end
		else
			NewPlate:Hide()
		end
    end
end

function NamePlates:OnUpdate(elapsed)
	NamePlates:Search()
	NamePlates:Update()
end
]]--