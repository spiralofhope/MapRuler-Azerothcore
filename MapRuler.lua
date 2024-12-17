local dots = {} --stores all the dot textures.  Each dot is a separate texture
local dotSpacing = 10 --the blank space between dots
local playerX = 0
local playerY = 0
local playerFacing = 0
local updateInterval = 0.1
local timeSinceLastUpdate = 0
local maxLineLength


function MapRulerFrame_Init(self)
	--setup the frame to overlay the map detail frame
	self:SetWidth(self:GetParent():GetWidth())
	self:SetHeight(self:GetParent():GetHeight())
	
	--max line length we'll ever need is from one corner to the other of the currently displayed map.
	--simple distance formula
	maxLineLength = math.sqrt(((WorldMapDetailFrame:GetHeight()) ^ 2) + ((WorldMapDetailFrame:GetWidth()) ^ 2))
	
	--setup the textures once and only once
	createDots(self)
end --MapRulerFrame_Init()


--fires on frame update
function MapRuler_OnUpdate(self, elapsed) 

	--incement the time
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed;

	--only fire on the interval or if it's showing a continent or smaller zone
	if (timeSinceLastUpdate > updateInterval) and (GetCurrentMapContinent() > 0) then
		
		local percentX, percentY = GetPlayerMapPosition("player") --returns the player position as a percentage from top left
		
		-- 0 is due north on the map 
		-- have to add pi/2 to get back to where the player is pointed (angle in radians)
		local angle = GetPlayerFacing() + (math.pi)/2  

		--check to see if the player has moved or changed facing
		if ((percentX ~= playerX or percentY ~= playerY or playerFacing ~= angle) and (percentX ~= 0 and percentY ~= 0)) then
			--save the current position and facing so we can compare it next time
			playerX = percentX
			playerY = percentY
			playerFacing = angle

			-- (percentX * self:GetWidth()) ,  (percentY * self:GetHeight()) is the pixel location of the player on the map
			-- y-coords are kind of reversed in that the top of the screen is 0 so multiply it by -1
			showLine(self, percentX * self:GetWidth(), percentY * self:GetHeight() * -1, angle)
		end --inner if
		timeSinceLastUpdate = 0 --the interval was achived so reset it
	else 
		if(GetCurrentMapContinent() < 1) then --we're looking at a continent or bigger
			hideLine()
		end
	end --top if-else
	
end --MapRuler_OnUpdate()


--Creates the dot textures
function createDots(parentFrame)
	for i = 0, maxLineLength, dotSpacing do
		dots[i] = parentFrame:CreateTexture()
		dots[i]:SetHeight(3)
		dots[i]:SetWidth(3)
		dots[i]:SetColorTexture(0,0,0)
		dots[i]:SetAlpha(.5)
	end --for
	
end --createDots()


--Places the dots on the line
function showLine(parentFrame, startX, startY, angle)
	
	--set the values here so I'm not calculating them for each dot
	xComponent = math.cos(angle) -- x-component of the vector
	yComponent = math.sin(angle) -- ycomponent of the vector
	
	for i = 0, maxLineLength, dotSpacing do
		dots[i]:SetAlpha(.5)
		dots[i]:SetPoint("TOPLEFT", startX + (xComponent * i), startY + (yComponent * i))
	end --for

end --line()


--hide the line (just like the name says)
function hideLine()
	for i = 0, maxLineLength, dotSpacing do
		dots[i]:SetAlpha(0)
	end --for
end

















