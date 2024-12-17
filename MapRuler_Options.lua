--[[
Handles all the options 
opacity
color
dot spacing
dot size
--]]

--a table to hold all the wonderful options
--must be declared before the client tries to use it 
MapRulerOptions = {}

--setup Options Frame
local MROptionsFrame = CreateFrame("Frame", "Map Ruler", InterfaceOptionsFramePanelContainer);
MROptionsFrame.name = "Map Ruler"
MROptionsFrame.default = MRSetDefaultOptions
MROptionsFrame:SetPoint("CENTER")
MROptionsFrame:SetSize(InterfaceOptionsFrame:GetWidth(), InterfaceOptionsFrame:GetHeight())

--load the frame but don't display it, also runs the OnShow handler
MROptionsFrame:Hide()

MROptionsFrame:RegisterEvent("ADDON_LOADED")

local OpacityEditBox = CreateFrame("EditBox", nil, MROptionsFrame)
local MROpacitySlider = CreateFrame("Slider", "MROSlider", MROptionsFrame, "OptionsSliderTemplate")
local ColorButton = CreateFrame("CheckButton", "MRColorButton", MROptionsFrame, "UIPanelButtonTemplate")
local ResetButton = CreateFrame("CheckButton", "MRResetButton", MROptionsFrame, "UIPanelButtonTemplate")
local SizeSlider = CreateFrame("Slider", "MRSizeSlider", MROptionsFrame, "OptionsSliderTemplate")
local SizeBox = CreateFrame("EditBox", nil, MROptionsFrame)


local function MROpacitySliderOnValueChanged(self, value)
	if(MapRulerOptions["opacity"] ~= nil and value ~= MapRulerOptions["opacity"]) then
		MapRulerOptions["opacity"] = math.floor(value) / 100
		OpacityEditBox:SetText(MapRulerOptions["opacity"] * 100)
	end --if
end --MROptionsOpacityHandler()


local function OpacityEditBoxEnterPressed(self)
	--only allow numbers from 0 to 100
	local theNumber = tonumber(self:GetText())
	if(theNumber > 100) then
		theNumber = 100
	end
	
	if(theNumber < 0) then
		theNumber = 0
	end
	
	self:SetText(theNumber)
	
	--when the slider value is changed MapRulerOptions["opacity"] will be updated
	MROpacitySlider:SetValue(theNumber)
	self:ClearFocus()
end --OpacityEditBoxEnterPressed()


local function setupMROpacitySlider()
	MROpacitySlider:ClearAllPoints()
	MROpacitySlider:SetPoint("TOPLEFT", MROptionsFrame, "TOPLEFT", 50, -80)
	MROpacitySlider:SetValueStep(1)
	MROpacitySlider:SetMinMaxValues(0, 100)
	MROpacitySlider:SetValue(MapRulerOptions["opacity"] * 100)
	--MROpacitySlider.tooltipText = "You are here" --Creates a tooltip on mouseover.
	MROpacitySlider:SetScript("OnValueChanged", MROpacitySliderOnValueChanged)
	
	getglobal(MROpacitySlider:GetName() .. 'Low'):SetText('0') --Sets the left-side slider text
	getglobal(MROpacitySlider:GetName() .. 'High'):SetText('100') --Sets the right-side slider text
	getglobal(MROpacitySlider:GetName() .. 'Text'):SetText('Opacity') --Sets the "title" text
end --setupMROpacitySlider()


local function setupOpacityBox()
	
	OpacityEditBox:ClearAllPoints()
	OpacityEditBox:SetWidth(30)
	OpacityEditBox:SetHeight(20)
	OpacityEditBox:SetFontObject("GameFontHighlight")
	OpacityEditBox:SetMaxLetters(3)
	OpacityEditBox:SetJustifyH("CENTER")
	OpacityEditBox:SetScript("OnEnterPressed", OpacityEditBoxEnterPressed)
	OpacityEditBox:SetNumeric(true) 
	
	--does having this in here create a reference to backdrop that can never be cleared?
	local backdrop = {
				bgFile = nil, 
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
				tile = false,
				tileSize = 0,
				edgeSize = 3,
				insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
	
	OpacityEditBox:SetBackdrop(backdrop)
	OpacityEditBox:SetPoint("TOPLEFT", MROptionsFrame, "TOPLEFT", 220, -80)
	OpacityEditBox:SetAutoFocus(false)
	OpacityEditBox:ClearFocus()
	OpacityEditBox:SetText(MapRulerOptions["opacity"] * 100)
end --setupOpacityBox()


local function MRColorCallback(restore)
	local newR, newG, newB, newA;
	if restore then
		-- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end

	MapRulerOptions["red"],MapRulerOptions["green"],MapRulerOptions["blue"],MapRulerOptions["opacity"] = 
		newR, newG, newB, newA
	
	--this will also change the opacity textbox
	MROpacitySlider:SetValue(MapRulerOptions["opacity"] * 100)
	
end


local function ColorButtonClicked()

	ColorPickerFrame:SetColorRGB(MapRulerOptions["red"], MapRulerOptions["green"], MapRulerOptions["blue"])
	
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = 
		(MapRulerOptions["opacity"] ~= nil), MapRulerOptions["opacity"]
	
	ColorPickerFrame.previousValues = 
		{MapRulerOptions["red"],MapRulerOptions["green"],
		MapRulerOptions["blue"],MapRulerOptions["opacity"]}
	
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 
		MRColorCallback, MRColorCallback, MRColorCallback
	
	ColorPickerFrame:Hide() -- Need to run the OnShow handler.
	ColorPickerFrame:Show()
	
end


local function setupColorButton()
	ColorButton:ClearAllPoints()
	ColorButton:SetPoint("TOPLEFT", MROptionsFrame, "TOPLEFT", 50, -140)
	ColorButton:SetHeight(30)
	ColorButton:SetWidth(150)
	ColorButton:SetText("Change Color")
	ColorButton:SetScript("OnClick", ColorButtonClicked)
end --setupColorButton()


local function ResetButtonClicked()

	MapRulerOptions["opacity"] = .5
	MapRulerOptions["red"] = 0
	MapRulerOptions["green"] = 0
	MapRulerOptions["blue"] = 0
	MapRulerOptions["size"] = 3
	MapRulerOptions["spacing"] = 9
	--this will also change the opacity textbox
	MROpacitySlider:SetValue(MapRulerOptions["opacity"] * 100)
	SizeSlider:SetValue(MapRulerOptions["size"])
	
end --end ResetButtonClicked()


local function setupResetButton()
	ResetButton:ClearAllPoints()
	ResetButton:SetPoint("TOPLEFT", MROptionsFrame, "TOPLEFT", 215, -140)
	ResetButton:SetHeight(30)
	ResetButton:SetWidth(150)
	ResetButton:SetText("Restore Defaults")
	ResetButton:SetScript("OnClick", ResetButtonClicked)
end


local function MRSizeSliderOnValueChanged(self, value)
	if(MapRulerOptions["size"] ~= nil and value ~= MapRulerOptions["size"]) then
		MapRulerOptions["size"] = math.floor(value)
		SizeBox:SetText(MapRulerOptions["size"])
	end --if
end --end MRSizeSliderOnValueChanged()


local function setupSizeSlider()
	SizeSlider:ClearAllPoints()
	SizeSlider:SetPoint("TOPLEFT", MROptionsFrame, "TOPLEFT", 50, -30)
	SizeSlider:SetValueStep(1)
	SizeSlider:SetMinMaxValues(1, 10)
	SizeSlider:SetValue(MapRulerOptions["size"])
	SizeSlider:SetScript("OnValueChanged", MRSizeSliderOnValueChanged)
	
	getglobal(SizeSlider:GetName() .. 'Low'):SetText('1') --Sets the left-side slider text
	getglobal(SizeSlider:GetName() .. 'High'):SetText('10') --Sets the right-side slider text
	getglobal(SizeSlider:GetName() .. 'Text'):SetText('Dot Size') --Sets the "title" text
end --end setupSizeSlider()


local function SizeBoxEnterPressed()

	--only allow numbers from 0 to 10
	local theNumber = tonumber(self:GetText())
	if(theNumber > 10) then
		theNumber = 10
	end
	
	if(theNumber < 0) then
		theNumber = 0
	end
	
	self:SetText(theNumber)
	
	--when the slider value is changed MapRulerOptions["opacity"] will be updated
	SizeSlider:SetValue(theNumber)
	self:ClearFocus()

end --SizeBoxEnterPressed()


local function setupSizeBox()
	SizeBox:ClearAllPoints()
	SizeBox:SetPoint("TOPLEFT", MROptionsFrame, "TOPLEFT", 220, -30)
	SizeBox:SetWidth(30)
	SizeBox:SetHeight(20)
	SizeBox:SetFontObject("GameFontHighlight")
	SizeBox:SetMaxLetters(3)
	SizeBox:SetJustifyH("CENTER")
	SizeBox:SetScript("OnEnterPressed", SizeBoxEnterPressed)
	SizeBox:SetNumeric(true) 
	
	--does having this in here create a reference to backdrop that can never be cleared?
	local backdrop = {
				bgFile = nil, 
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
				tile = false,
				tileSize = 0,
				edgeSize = 3,
				insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
	
	SizeBox:SetBackdrop(backdrop)
	SizeBox:SetAutoFocus(false)
	SizeBox:ClearFocus()
	SizeBox:SetText(MapRulerOptions["size"])

end --setupSizeBox()


local function MROptionsEventHandler (self, event, ...)
	if event == "ADDON_LOADED" and ... == "MapRuler" then
		--see if it acutally loaded anything
		if MapRulerOptions["spacing"] == nil then --set these defaults
			MapRulerOptions["opacity"] = .5
			MapRulerOptions["red"] = 0
			MapRulerOptions["green"] = 0
			MapRulerOptions["blue"] = 0
			MapRulerOptions["size"] = 3
			MapRulerOptions["spacing"] = 9
		end --if
		setupMROpacitySlider()
		setupOpacityBox()
		setupColorButton()
		setupResetButton()
		setupSizeSlider()
		setupSizeBox()
	end --if event
	
end --eventHandler()


--this must be after the declaration of MROptionsEventHandler
MROptionsFrame:SetScript("OnEvent", MROptionsEventHandler)

--register the addon in the blizz interface window
InterfaceOptions_AddCategory(MROptionsFrame)

























