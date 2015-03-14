----------------------------------------------------------------------------------------
--	Target Talents(TipTacTalents by Aezay)
----------------------------------------------------------------------------------------
local T, C, L = unpack(Tukui)
--[[
if( C["tooltip"]["enable"] ~= true ) then return end

local TALENTS_PREFIX = TALENTS .. ":|cffffffff "
local CACHE_SIZE = 25
local INSPECT_DELAY = 0.2
local INSPECT_FREQ = 2

local ttt = CreateFrame( "Frame", "TipTacTalents" )
local cache = {}
local current = {}

lastInspectRequest = 0

ttt.cache = cache
ttt.current = current
ttt:Hide()

local function GatherTalents( mouseover )
	if( mouseover == 1 ) then
		local currentSpecID = GetInspectSpecialization( "mouseover" )
		local currentSpecName = currentSpecID and select( 2, GetSpecializationInfoByID( currentSpecID ) ) or L.tooltip_LOADING_TALENT
		current.tree = currentSpecName
	else
		local currentSpec = GetSpecialization()
		local currentSpecName = currentSpec and select( 2, GetSpecializationInfo( currentSpec ) ) or L.tooltip_NO_TALENTS
		current.tree = currentSpecName
	end

	if( mouseover == 0 ) then
		GameTooltip:AddLine( TALENTS_PREFIX .. current.tree )
	elseif( GameTooltip:GetUnit() ) then
		for i = 2, GameTooltip:NumLines() do
			if( ( _G["GameTooltipTextLeft" .. i]:GetText() or "" ):match( "^" .. TALENTS_PREFIX ) ) then
				_G["GameTooltipTextLeft" .. i]:SetFormattedText( "%s%s", TALENTS_PREFIX, current.tree )
				break
			end
		end
	end

	local cacheSize = CACHE_SIZE
	for i = #cache, 1, -1 do
		if( current.name == cache[i].name ) then
			tremove( cache, i )
			break
		end
	end
	if( #cache > cacheSize ) then
		tremove( cache, 1 )
	end

	if( cacheSize > 0 ) then
		cache[#cache + 1] = CopyTable( current )
	end
end

ttt:SetScript( "OnEvent", function( self, event, guid )
	self:UnregisterEvent( event )
	if( guid == current.guid ) then
		GatherTalents( 1 )
	end
end )

ttt:SetScript( "OnUpdate", function( self, elapsed )
	self.nextUpdate = ( self.nextUpdate - elapsed )
	if( self.nextUpdate <= 0 ) then
		self:Hide()

		if( UnitGUID( "mouseover" ) == current.guid ) then
			lastInspectRequest = GetTime()
			self:RegisterEvent( "INSPECT_READY" )

			if( InspectFrame ) then
				InspectFrame.unit = "player"
			end
			NotifyInspect( current.unit )
		end
	end
end )

GameTooltip:HookScript( "OnTooltipSetUnit", function( self, ... )
	ttt:Hide()

	local _, unit = self:GetUnit()
	if( not unit ) then
		local mFocus = GetMouseFocus()
		if( mFocus and mFocus.unit ) then
			unit = mFocus.unit
		end
	end

	if( not unit or not UnitIsPlayer( unit ) ) then
		return
	end

	local level = UnitLevel( unit )
	if( level > 9 or level == -1 ) then
		wipe( current )
		current.unit = unit
		current.name = UnitName( unit )
		current.guid = UnitGUID( unit )

		if( UnitIsUnit( unit, "player" ) ) then
			GatherTalents( 0 )
			return
		end

		local isInspectOpen = ( InspectFrame and InspectFrame:IsShown() ) or ( Examiner and Examiner:IsShown() )
		local cacheLoaded = false
		for _, entry in ipairs( cache ) do
			if( current.name == entry.name and not isInspectOpen ) then
				self:AddLine( TALENTS_PREFIX .. entry.tree )
				current.tree = entry.tree
				cacheLoaded = true
				break
			end
		end

		if( CanInspect( unit ) and not isInspectOpen ) then
			local lastInspectTime = GetTime() - lastInspectRequest
			ttt.nextUpdate = ( lastInspectTime > INSPECT_FREQ ) and INSPECT_DELAY or ( INSPECT_FREQ - lastInspectTime + INSPECT_DELAY )
			ttt:Show()
			if( not cacheLoaded ) then
				self:AddLine( TALENTS_PREFIX .. L.tooltip_LOADING_TALENT )
			end
		elseif( isInspectOpen ) then
			self:AddLine( TALENTS_PREFIX .. L.tooltip_INSPECTOPEN )
		end
	end
end )
]]--