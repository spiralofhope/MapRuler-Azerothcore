--[[
Handles all the options 
opacity
color
dot spacing
dot size
--]]

MapRulerOptions = {}

-- Setup Options Frame
local MROptionsFrame = CreateFrame( 'Frame', 'Map Ruler', InterfaceOptionsFramePanelContainer )
MROptionsFrame.name = 'Map Ruler'
MROptionsFrame.default = MRSetDefaultOptions
MROptionsFrame:SetPoint( 'CENTER' )
MROptionsFrame:SetSize( InterfaceOptionsFrame:GetWidth(), InterfaceOptionsFrame:GetHeight() )

-- Load the frame but don't display it, also runs the OnShow handler
MROptionsFrame:Hide()

MROptionsFrame:RegisterEvent( 'ADDON_LOADED' )

local OpacityEditBox  = CreateFrame( 'EditBox',      nil,            MROptionsFrame )
local MROpacitySlider = CreateFrame( 'Slider',      'MROSlider',     MROptionsFrame, 'OptionsSliderTemplate' )
local ColorButton     = CreateFrame( 'CheckButton', 'MRColorButton', MROptionsFrame, 'UIPanelButtonTemplate' )
local ResetButton     = CreateFrame( 'CheckButton', 'MRResetButton', MROptionsFrame, 'UIPanelButtonTemplate' )
local SizeSlider      = CreateFrame( 'Slider',      'MRSizeSlider',  MROptionsFrame, 'OptionsSliderTemplate' )
local SizeBox         = CreateFrame( 'EditBox',      nil,            MROptionsFrame )


local function MROpacitySliderOnValueChanged( self, value )
	if( MapRulerOptions[ 'opacity' ] ~= nil
    and value ~= MapRulerOptions[ 'opacity' ]
  ) then
		MapRulerOptions[ 'opacity' ] = math.floor( value ) / 100
		OpacityEditBox:SetText( MapRulerOptions[ 'opacity' ] * 100 )
	end
end


local function OpacityEditBoxEnterPressed(self)
	-- Only allow numbers from 0 to 100:
	local n = tonumber(self:GetText())
	if( n > 100 )  then  n = 100  end
	if( n <   0 )  then  n =   0  end
	self:SetText( n )
  
	-- When the slider value is changed MapRulerOptions[ 'opacity' ] will be updated.
	MROpacitySlider:SetValue( n )
	self:ClearFocus()
end


local function setupMROpacitySlider()
	MROpacitySlider:ClearAllPoints()
	MROpacitySlider:SetPoint( 'TOPLEFT', MROptionsFrame, 'TOPLEFT', 50, -80 )
	MROpacitySlider:SetValueStep( 1 )
	MROpacitySlider:SetMinMaxValues( 0, 100 )
	MROpacitySlider:SetValue(MapRulerOptions[ 'opacity' ] * 100 )
	-- MROpacitySlider.tooltipText = "You are here"  -- Creates a tooltip on mouseover.
	MROpacitySlider:SetScript( 'OnValueChanged', MROpacitySliderOnValueChanged )
	
	getglobal( MROpacitySlider:GetName() .. 'Low'  ):SetText(       '0' )  -- Sets the left-side slider text
	getglobal( MROpacitySlider:GetName() .. 'High' ):SetText(     '100' )  -- Sets the right-side slider text
	getglobal( MROpacitySlider:GetName() .. 'Text' ):SetText( 'Opacity' )  -- Sets the "title" text
end


local function setupOpacityBox()
	OpacityEditBox:ClearAllPoints()
	OpacityEditBox:SetWidth( 30 )
	OpacityEditBox:SetHeight( 20 )
	OpacityEditBox:SetFontObject( 'GameFontHighlight' )
	OpacityEditBox:SetMaxLetters( 3 )
	OpacityEditBox:SetJustifyH( 'CENTER' )
	OpacityEditBox:SetScript( 'OnEnterPressed', OpacityEditBoxEnterPressed )
	OpacityEditBox:SetNumeric( true )
	
	-- Does having this in here create a reference to backdrop that can never be cleared?
	local backdrop = {
				bgFile = nil,
				edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
				tile = false,
				tileSize = 0,
				edgeSize = 3,
				insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
	
	OpacityEditBox:SetBackdrop( backdrop )
	OpacityEditBox:SetPoint( 'TOPLEFT', MROptionsFrame, 'TOPLEFT', 220, -80 )
	OpacityEditBox:SetAutoFocus( false )
	OpacityEditBox:ClearFocus()
	OpacityEditBox:SetText( MapRulerOptions[ 'opacity' ] * 100 )
end


local function MRColorCallback( restore )
	local newR, newG, newB, newA
	if restore then
		-- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack( restore )
	else
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
	end

	MapRulerOptions[ 'red' ],MapRulerOptions[ 'green' ],MapRulerOptions[ 'blue' ],MapRulerOptions[ 'opacity' ] = 
		newR, newG, newB, newA
	
	-- This will also change the opacity textbox:
	MROpacitySlider:SetValue( MapRulerOptions[ 'opacity' ] * 100 )
end


local function ColorButtonClicked()
	ColorPickerFrame:SetColorRGB(MapRulerOptions['red'], MapRulerOptions['green'], MapRulerOptions['blue'])
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = ( MapRulerOptions['opacity'] ~= nil ), MapRulerOptions[ 'opacity' ]
	ColorPickerFrame.previousValues = {
    MapRulerOptions[ 'red'  ], MapRulerOptions[ 'green' ],
		MapRulerOptions[ 'blue' ], MapRulerOptions[ 'opacity' ]
  }
	ColorPickerFrame.func        = MRColorCallback
	ColorPickerFrame.opacityFunc = MRColorCallback
	ColorPickerFrame.cancelFunc  = MRColorCallback
	ColorPickerFrame:Hide()  -- Need to run the OnShow handler.
	ColorPickerFrame:Show()
end


local function setupColorButton()
	ColorButton:ClearAllPoints()
	ColorButton:SetPoint( 'TOPLEFT', MROptionsFrame, 'TOPLEFT', 50, -140 )
	ColorButton:SetHeight( 30 )
	ColorButton:SetWidth( 150 )
	ColorButton:SetText( 'Change Color' )
	ColorButton:SetScript( 'OnClick', ColorButtonClicked )
end


local function ResetButtonClicked()
	MapRulerOptions[ 'opacity' ] = .5
	MapRulerOptions[ 'red' ] = 0
	MapRulerOptions[ 'green'] = 0
	MapRulerOptions[ 'blue' ] = 0
	MapRulerOptions[ 'size' ] = 3
	MapRulerOptions[ 'spacing' ] = 9
	-- This will also change the opacity textbox:
	MROpacitySlider:SetValue( MapRulerOptions[ 'opacity' ] * 100 )
	SizeSlider:SetValue( MapRulerOptions[ 'size' ] )
end


local function setupResetButton()
	ResetButton:ClearAllPoints()
	ResetButton:SetPoint( 'TOPLEFT', MROptionsFrame, 'TOPLEFT', 215, -140 )
	ResetButton:SetHeight( 30 )
	ResetButton:SetWidth( 150 )
	ResetButton:SetText( 'Restore Defaults' )
	ResetButton:SetScript( 'OnClick', ResetButtonClicked )
end


local function MRSizeSliderOnValueChanged( self, value )
	if( MapRulerOptions['size'] ~= nil
  and value                   ~= MapRulerOptions['size']
  ) then
		MapRulerOptions['size'] = math.floor( value )
		SizeBox:SetText( MapRulerOptions[ 'size' ] )
	end
end


local function setupSizeSlider()
	SizeSlider:ClearAllPoints()
	SizeSlider:SetPoint( 'TOPLEFT', MROptionsFrame, 'TOPLEFT', 50, -30 )
	SizeSlider:SetValueStep( 1 )
	SizeSlider:SetMinMaxValues( 1, 10 )
	SizeSlider:SetValue( MapRulerOptions[ 'size' ] )
	SizeSlider:SetScript( 'OnValueChanged', MRSizeSliderOnValueChanged )
	getglobal( SizeSlider:GetName() .. 'Low'  ):SetText( '1' )        -- Sets the left-side slider text
	getglobal( SizeSlider:GetName() .. 'High' ):SetText( '10' )       -- Sets the right-side slider text
	getglobal( SizeSlider:GetName() .. 'Text' ):SetText( 'Dot Size' ) -- Sets the 'title' text
end


local function SizeBoxEnterPressed()
	-- Only allow numbers from 0 to 10:
	local n = tonumber(SizeBox:GetText())
	if( n > 10 ) then  n = 10  end
	if( n <  0 ) then  n =  0  end
	SizeBox:SetText( n )
  
	-- When the slider value is changed MapRulerOptions[ 'size' ] will be updated
	SizeSlider:SetValue( n )
	SizeBox:ClearFocus()
end


local function setupSizeBox()
	SizeBox:ClearAllPoints()
	
	SizeBox:SetWidth( 30 )
	SizeBox:SetHeight( 20 )
	SizeBox:SetFontObject( 'GameFontHighlight' )
	SizeBox:SetMaxLetters( 3 )
	SizeBox:SetJustifyH( 'CENTER' )
	SizeBox:SetScript( 'OnEnterPressed', SizeBoxEnterPressed )
	SizeBox:SetNumeric( true )
	
	-- Does having this in here create a reference to backdrop that can never be cleared?
	local backdrop = {
    bgFile = nil, 
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', 
    tile = false,
    tileSize = 0,
    edgeSize = 3,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
	
	SizeBox:SetBackdrop( backdrop )
	SizeBox:SetPoint( 'TOPLEFT', MROptionsFrame, 'TOPLEFT', 220, -30 )
	SizeBox:SetAutoFocus( false )
	SizeBox:ClearFocus()
	SizeBox:SetText( MapRulerOptions[ 'size' ] )
end


local function MROptionsEventHandler( self, event, ... )
	if event == 'ADDON_LOADED' and ... == 'MapRuler' then
		-- If nothing is loaded, then set defaults
		if MapRulerOptions[ 'spacing'] == nil then
			MapRulerOptions[ 'spacing' ] = 9
			MapRulerOptions[ 'opacity' ] = .5
			MapRulerOptions[ 'red' ] = 0
			MapRulerOptions[ 'green' ] = 0
			MapRulerOptions[ 'blue' ] = 0
			MapRulerOptions[ 'size' ] = 3
		end
		setupMROpacitySlider()
		setupOpacityBox()
		setupColorButton()
		setupResetButton()
		setupSizeSlider()
		setupSizeBox()
	end
end


-- This must be after the declaration of MROptionsEventHandler
MROptionsFrame:SetScript( 'OnEvent', MROptionsEventHandler )

-- Register the addon in the blizz interface window
InterfaceOptions_AddCategory( MROptionsFrame )
