local dots = {} -- Stores all the dot textures.  Each dot is a separate texture
local dotSpacing = 9 -- The blank space between dots
local playerX = 0
local playerY = 0
local playerFacing = 0
local updateInterval = 0.1
local timeSinceLastUpdate = 0
local maxLineLength


function MapRulerFrame_Init( self )
	-- Setup the frame to overlay the map detail frame
	self:SetWidth(  self:GetParent():GetWidth() )
	self:SetHeight( self:GetParent():GetHeight() )
	
	-- The max line length we'll ever need is from one corner to the other of the currently displayed map.
	-- Simple distance formula
	maxLineLength = math.sqrt( ( ( WorldMapDetailFrame:GetHeight() ) ^ 2 ) + ( ( WorldMapDetailFrame:GetWidth()) ^ 2 ) )
	
	-- Setup the textures once and only once
	for i = 0, maxLineLength, dotSpacing do
		dots[i] = self:CreateTexture()
	end
end


-- Fires on frame update
function MapRuler_OnUpdate( self, elapsed )

	-- Inrcement the time
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed

	local percentX, percentY = GetPlayerMapPosition( 'player' )  -- Returns the player position as a percentage from top left
	
	-- Only fire on the interval and if the player is on the current map
	if ( timeSinceLastUpdate > updateInterval ) and ( percentX ~= 0 and percentY ~= 0 ) and GetPlayerFacing() then
		
		-- 0 is due north on the map 
		-- Have to add pi/2 to get back to where the player is pointed (angle in radians)
		local angle = GetPlayerFacing() + ( math.pi ) / 2
    
		-- Check to see if the player has moved or changed facing
		if ( percentX ~= playerX
    or   percentY ~= playerY
    or   playerFacing ~= angle 
    ) then
			-- Save the current position and facing so we can compare it next time
			playerX = percentX
			playerY = percentY
			playerFacing = angle

			-- ( percentX * self:GetWidth() ) ,  ( percentY * self:GetHeight() ) is the pixel location of the player on the map
			-- y-coords are kind of reversed in that the top of the screen is 0 so multiply it by -1
			showLine(self, percentX * self:GetWidth(), percentY * self:GetHeight() * -1, angle)
		end --inner if
		timeSinceLastUpdate = 0  -- The interval was achived so reset it
	else
		-- Make sure the player is not on the current map or in an instance
		if ( ( percentX == 0 and percentY == 0 ) or not GetPlayerFacing() ) then
			hideLine()
		end
	end
end  -- MapRuler_OnUpdate()


-- Places the dots on the line:
function showLine( parentFrame, startX, startY, angle )
	-- Set the values here so I'm not calculating them for each dot:
	xComponent = math.cos( angle )
	yComponent = math.sin( angle )

	for i = 0, maxLineLength, dotSpacing do
		dots[i]:SetAlpha( MapRulerOptions[ 'opacity' ] )
    -- spiralofhope fix for Azerothcore 3.3.5
    dots[i]:SetTexture( 'Interface\\ChatFrame\\ChatFrameBackground' )
    dots[i]:SetVertexColor( MapRulerOptions[ 'red' ], MapRulerOptions[ 'green' ], MapRulerOptions[ 'blue' ], 1 )
		
		dots[i]:SetHeight( MapRulerOptions[ 'size' ] )
		dots[i]:SetWidth(  MapRulerOptions[ 'size' ] )
		dots[i]:SetPoint( 'TOPLEFT', startX + ( xComponent * i ), startY + ( yComponent * i ) )
	end
end


function hideLine()
	for i = 0, maxLineLength, dotSpacing do
		dots[ i ]:SetAlpha( 0 )
	end
end
