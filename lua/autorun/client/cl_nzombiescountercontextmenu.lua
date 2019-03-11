CustomNZBarPosModeConfig = CreateClientConVar( "nz_zombiebarenablepositionmode", "0", true, false ) -- Allow players to very easily change the progress bar's position to their liking.
CustomNZBarInnerColorConfig = CreateClientConVar( "nz_zombiebarinnercolor", "255 0 0 255", true, false ) -- Allow players to very easily tweak the progress bar's inner color to whatever color they want.
CustomNZBarOuterColorConfig = CreateClientConVar( "nz_zombiebaroutercolor", "171 171 171 255", true, false ) -- Allow players to very easily tweak the progress bar's outer color to whatever color they want.
CustomNZCounterColorConfig = CreateClientConVar( "nz_zombiecountercolor", "171 171 171 255", true, false ) -- Allow players to very easily tweak the zombie counter's text color to whatever they want.
NZCounterInvertBarConfig = CreateClientConVar( "nz_zombieinvertbar", "0", true, false ) -- Allow players to reverse the progression in the bar if they want to.. for some reason.
NZCOUNTERCOLORR = CreateClientConVar( "nz_zombiecounter_R", "", true, false ) -- These values are combined later on and sent to the other color commands.
NZCOUNTERCOLORG = CreateClientConVar( "nz_zombiecounter_G", "", true, false )
NZCOUNTERCOLORB = CreateClientConVar( "nz_zombiecounter_B", "", true, false )
NZCOUNTERCOLORA = CreateClientConVar( "nz_zombiecounter_A", "", true, false )

NZCounterBypass = false

cvars.AddChangeCallback("nz_zombieinvertbar", function()
	if NZCounterBoxWasToggledAgain == false then
		if NZCounterInvertBarConfig:GetInt() > 0 then
			net.Start("DoNZCounterPositionProgressInvertChatResponse1", false)	
			net.SendToServer("DoNZCounterPositionProgressInvertChatResponse1")
		else
			net.Start("DoNZCounterPositionProgressInvertChatResponse2", false)	
			net.SendToServer("DoNZCounterPositionProgressInvertChatResponse2")
		end
	end
end)

cvars.AddChangeCallback("nz_zombiebarenablepositionmode", function() -- Show the custom positioning window if the player wants to manually set the position.
	if CustomNZBarPosModeConfig:GetInt() > 0 then 
		RunConsoleCommand("nz_zombiebarenablepositionmode", "0") -- Make sure the option never stays checked.
		RunConsoleCommand("nz_zombiebarpreview", "0") -- The previewer completely breaks this so we need to always disable it.
		
		if NZCounterBoxWasToggledAgain == false then
			net.Start("DoNZCounterPositionConfigureChatResponse1", false)	
			net.SendToServer("DoNZCounterPositionConfigureChatResponse1")
			NZCounterNZCounterPositionerBlurScreens = {}
			NZCounterPositionerBlurScreen = vgui.Create("DFrame")
			table.insert(NZCounterNZCounterPositionerBlurScreens, NZCounterPositionerBlurScreen)
			NZCounterPositionerBlurScreen:ShowCloseButton(false)
			NZCounterPositionerBlurScreen:SetDraggable(false)
			NZCounterPositionerBlurScreen:SetTitle("")
			NZCounterPositionerBlurScreen:SetSize(ScrW(), ScrH())
			NZCounterPositionerBlurScreen:Center()	
			NZCounterPositionerBlurScreen:MakePopup()
			NZCounterBypass = true -- Bypass all the 'return end' checks to make this possible.
			NZZombieCountDrawVGUIBar() -- Show the bar.
			
			if IsValid(nzcounterwindow) then
				nzcounterwindow:Hide()			
			end
			
			local ContextMenuForceClosed = false
			
			NZCounterPositioningTip = vgui.Create( "DTooltip" )
			NZCounterPositioningTip:SetText("Click to set the position!") -- Let the user know what to do.
			NZCounterPositioningTip:SetSize(250, 20)
			NZCounterPositioningTip:OpenForPanel(NZTotalZombieBar)
			
			TheNZCounterConfirmationMenuIsOpen = false
			function NZCounterPositionerBlurScreen:Paint()	
				surface.SetDrawColor(255,255,255,3)
				surface.DrawRect(0, 0, ScrW(), ScrH()) -- Indicate that the screen is covered.	
								
				if ContextMenuForceClosed == false then -- Prevent console spam.
					RunConsoleCommand("-menu_context") -- Stop the context menu from ruining the user's experience.
					ContextMenuForceClosed = true
				end
							
				if IsValid(NZTotalZombieBar) then	
					if TheNZCounterConfirmationMenuIsOpen == false then
						NZTotalZombieBar:SetPos(input.GetCursorPos())
						NZTotalZombieBar:SetPos(NZTotalZombieBar.x - NZTotalZombieBar:GetSize() / 2, NZTotalZombieBar.y) -- Make sure the bar appears somewhat centered so that it is possible to position anywhere.
						
						if !IsValid(NZCounterPositioningTip) then
							NZCounterPositioningTip = vgui.Create( "DTooltip" )
							NZCounterPositioningTip:SetText("Click to set the position!") -- Let the user know what to do.
							NZCounterPositioningTip:SetSize(250, 20)
							NZCounterPositioningTip:OpenForPanel(NZTotalZombieBar)
						else						
							NZCounterPositioningTip:SetPos(NZTotalZombieBar.x + NZTotalZombieBar.x, NZTotalZombieBar.y) 
							NZCounterPositioningTip:PositionTooltip()
														
							if gui.IsConsoleVisible() == true or gui.IsGameUIVisible() == true then -- If the user has no interest in positioning it then abort.
								notification.AddLegacy("Custom Progress Bar Positioning aborted!", NOTIFY_ERROR, 5 )
								NZCounterBypass = false
								for k,v in pairs(AllZombieBars) do
									if IsValid(v) then
										v:Remove()
									end
								end
								NZZombieCountDrawVGUIBar()
								for k,v in pairs(NZCounterNZCounterPositionerBlurScreens) do
									if IsValid(v) then
										v:Remove()
									end
								end
							end
							
							if input.IsMouseDown(MOUSE_LEFT) == true then
								if NZTotalZombieBar.x + NZTotalZombieBar:GetSize() > ScrW() then
									NZTotalZombieBar:SetPos(ScrW() - NZTotalZombieBar:GetSize(), NZTotalZombieBar.y)
								end
								
								if NZTotalZombieBar.x < 0 then
									NZTotalZombieBar:SetPos(0, NZTotalZombieBar.y)
								end
								
								NZCounterPositionerSavedMouseCursor = input.GetCursorPos()
								NZCounterPositioningTip:Close()
								TheNZCounterConfirmationMenuIsOpen = true -- Hide the mouse cursor stuff in the background.
								NZCounterPositionerDoConfirmation() -- Ask the user if they really want to set the position to where their cursor is.
							end
						end
					end
				end				
			end
		end
	end
end)

NZCounterConfirmationWindows = {}
function NZCounterPositionerDoConfirmation()
	local ConfirmationWindow = vgui.Create("DFrame")
	local ConfirmationWindowYesButton = vgui.Create("DButton", ConfirmationWindow)
	local ConfirmationWindowNoButton = vgui.Create("DButton", ConfirmationWindow)
	table.insert(NZCounterConfirmationWindows, ConfirmationWindow)	
	
	ConfirmationWindow:MakePopup()
	ConfirmationWindow:SetSize(320, 100)
	ConfirmationWindow:SetBackgroundBlur(true)
	ConfirmationWindow:ShowCloseButton(false)
	ConfirmationWindow:Center()
	ConfirmationWindowYesButton:SetPos(12, 30)
	ConfirmationWindowYesButton:SetSize(145, 60)
	ConfirmationWindowYesButton:SetText("Yes")
	ConfirmationWindowNoButton:SetPos(162, 30)
	ConfirmationWindowNoButton:SetSize(145, 60)
	ConfirmationWindowNoButton:SetText("No")
	
	function ConfirmationWindow:PaintOver()
		ConfirmationWindow:MoveToFront() -- Stop anything from showing over the window.
		
		if gui.IsConsoleVisible() == true or gui.IsGameUIVisible() == true then -- If the user has no interest in positioning it then abort.
			notification.AddLegacy( "Custom Progress Bar Positioning aborted!", NOTIFY_ERROR, 5 )
			NZCounterBypass = false
			for k,v in pairs(AllZombieBars) do
				if IsValid(v) then
					v:Remove()
				end
			end
			NZZombieCountDrawVGUIBar()
			for k,v in pairs(NZCounterNZCounterPositionerBlurScreens) do
				if IsValid(v) then
					v:Remove()
				end
			end
			for k,v in pairs(NZCounterConfirmationWindows) do
				if IsValid(v) then
					v:Remove()
				end
			end
		end
	end
	
	ConfirmationWindowNoButton.DoClick = function()	
		TheNZCounterConfirmationMenuIsOpen = false
		ConfirmationWindow:Close()
	end
	
	ConfirmationWindowYesButton.DoClick = function()	
		net.Start("DoNZCommitCustomPositionX", false)	
		net.WriteInt(NZTotalZombieBar.x, 32)	
		net.SendToServer("DoNZCommitCustomPositionX")

		net.Start("DoNZCommitCustomPositionY", false)	
		net.WriteInt(NZTotalZombieBar.y, 32)
		net.SendToServer("DoNZCommitCustomPositionY")
		
		for k,v in pairs(NZCounterNZCounterPositionerBlurScreens) do
			if IsValid(v) then
				v:Remove()
			end
		end
		for k,v in pairs(AllZombieBars) do
			if IsValid(v) then
				v:Remove()
			end
		end
		for k,v in pairs(NZCounterConfirmationWindows) do
			if IsValid(v) then
				v:Remove()
			end
		end
		notification.AddLegacy( "Successfully set the NZ Progress Bar's position!", NOTIFY_GENERIC, 4 )
		NZCounterPresetPositions:SetValue("No preset") -- They are no longer using a preset so set the value to this to prevent confusion.
		RunConsoleCommand("nz_zombiesbarpos", "-1") -- Make sure the preset is actually removed off the user.
		NZCounterPresetBugForceValue = -1	
	end
	ConfirmationWindow:SetTitle("Are you sure you want to set the position there?")
end

if !CLIENT then return end

list.Set(
	"DesktopWindows",
	"NZ_ZombieBar",
	{
		title = "NZ Progress Bar",
		icon = "nzcounter/nzcounterprogressbar.png",
		width = 706,
		height = 736,
		onewindow = true,
		init = function(icon, nzcounterwindow)
			nzcounterwindow:SetSkin(SKIN)
			nzcounterwindow:SetTitle("")
			nzcounterwindow:SetDraggable(true)
			nzcounterwindow:ShowCloseButton(true)					
			
			local AllTheDarnThings = {}
			
			local NZCounterStyle = vgui.Create( "DImage", nzcounterwindow )
			NZCounterStyle:SetPos(0,0)
			NZCounterStyle:SetSize(706, 736)
			NZCounterStyle:SetImage("nzcounter/nzcountervgui")
			
			local NZCounterHideBarButton = vgui.Create("DCheckBox",nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterHideBarButton)
			NZCounterHideBarButton:SetWidth(23)	
			NZCounterHideBarButton:SetHeight(23)	
			NZCounterHideBarButton:SetPos(30, 47)
			NZCounterHideBarButton:MoveToFront()
			NZCounterHideBarButton:SetAlpha(0)
			NZCounterHideBarButton.OnChange = function()
				if NZCounterBoxWasToggled == true then
					NZCounterBoxWasToggled = false
					NZCounterBoxWasToggledAgain = true
					NZCounterHideBarButton:Toggle()
				else
					NZCounterHideBarButton:SetConVar("nz_zombiesbarhide")													
				end
			end

			local NZCounterHideCounterButton = vgui.Create("DCheckBox",nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterHideCounterButton)
			NZCounterHideCounterButton:SetWidth(23)	
			NZCounterHideCounterButton:SetHeight(23)	
			NZCounterHideCounterButton:SetPos(30, 152)
			NZCounterHideCounterButton:MoveToFront()
			NZCounterHideCounterButton:SetAlpha(0)
			NZCounterHideCounterButton.OnChange = function()
				if NZCounterBoxWasToggled == true then
					NZCounterBoxWasToggled = false
					NZCounterBoxWasToggledAgain = true
					NZCounterHideCounterButton:Toggle()
				else
					NZCounterHideCounterButton:SetConVar("nz_zombiecounterhide")													
				end
			end	
			
			local NZInvertBarButton = vgui.Create("DCheckBox",nzcounterwindow)
			table.insert(AllTheDarnThings, NZInvertBarButton)
			NZInvertBarButton:SetWidth(23)	
			NZInvertBarButton:SetHeight(23)	
			NZInvertBarButton:SetPos(30, 266)
			NZInvertBarButton:MoveToFront()
			NZInvertBarButton:SetAlpha(0)
			NZInvertBarButton.OnChange = function()
				if NZCounterBoxWasToggled == true then
					NZCounterBoxWasToggled = false
					NZCounterBoxWasToggledAgain = true
					NZInvertBarButton:Toggle()
				else
					NZInvertBarButton:SetConVar("nz_zombieinvertbar")													
				end
			end		
			
			local NZCounterPreviewBarButton = vgui.Create("DCheckBox", nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterPreviewBarButton)
			NZCounterPreviewBarButton:SetWidth(23)	
			NZCounterPreviewBarButton:SetHeight(23)	
			NZCounterPreviewBarButton:SetPos(nzcounterwindow.x + 120, nzcounterwindow.y + 128)
			NZCounterPreviewBarButton:MoveToFront()
			NZCounterPreviewBarButton:SetPos(30, 368)
			NZCounterPreviewBarButton:SetAlpha(0)
			
			NZCounterPreviewBarButton.OnChange = function()
				if NZCounterBoxWasToggledAgain == false then
					if NZCounterPreviewBarButton:GetChecked() == false then	
						if IsValid(NZTotalZombieBarPreview) then	
							NZTotalZombieBarPreview:Remove()
							timer.Remove("NZCounterSimulationLoop")
						end
					end
				end
					
					
				if NZCounterBoxWasToggled == true then
					NZCounterBoxWasToggled = false
					NZCounterBoxWasToggledAgain = true
					NZCounterPreviewBarButton:SetConVar("nz_zombiebarpreview")
					if IsValid(NZTotalZombieBar) then	
						NZCounterPreviewBarButton:SetChecked(false)
					end
					if NZCounterPreviewBarButton:GetChecked() == false then	
						NZCounterPreviewBarButton:Toggle()
					end
					if NZCounterPreviewBarButton:GetChecked() == true then		
						NZCounterPreviewBarButton:Toggle()
					end
				else
					NZCounterPreviewBarButton:SetConVar("nz_zombiebarpreview")
				end
			end
			
			local NZCounterPositioningBarButton = vgui.Create("DCheckBox", nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterPositioningBarButton)
			NZCounterPositioningBarButton:SetWidth(23)	
			NZCounterPositioningBarButton:SetHeight(23)	
			NZCounterPositioningBarButton:MoveToFront()
			NZCounterPositioningBarButton:SetPos(30, 483)
			NZCounterPositioningBarButton:SetAlpha(0)
			
			NZCounterPositioningBarButton.OnChange = function()
				if NZCounterPositioningBarButton:GetChecked() == true then
					NZCounterPositioningBarButton:Toggle() -- Fixes an extremely annoying bug where the user has to double click it to make it function correctly.
				end
				NZCounterPositioningBarButton:SetConVar("nz_zombiebarenablepositionmode")
			end
			
			NZCounterPresetPositions = vgui.Create("DComboBox", nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterPresetPositions)
			NZCounterPresetPositions:SetSize(187, 13)				
			NZCounterPresetPositions:SetPos(68, 640)
			NZCounterPresetPositions:MoveToFront()
			NZCounterPresetPositions:SetValue("Top middle") -- Name it to what the default value is.
			NZCounterPresetPositions:AddChoice("Top middle")
			NZCounterPresetPositions:AddChoice("Top right")
			NZCounterPresetPositions:AddChoice("Top left")
			NZCounterPresetPositions:AddChoice("Bottom middle")	
			NZCounterPresetPositions:AddChoice("Bottom right")	
			NZCounterPresetPositions:AddChoice("Bottom left")	
			if CustomNZBarPosConfig:GetInt() == 1 then		
				NZCounterPresetPositions:SetValue("Top middle")
			end
			if CustomNZBarPosConfig:GetInt() == 2 then		
				NZCounterPresetPositions:SetValue("Top right")
			end
			if CustomNZBarPosConfig:GetInt() == 3 then		
				NZCounterPresetPositions:SetValue("Top left")
			end
			if CustomNZBarPosConfig:GetInt() == 4 then		
				NZCounterPresetPositions:SetValue("Bottom middle")
			end
			if CustomNZBarPosConfig:GetInt() == 5 then		
				NZCounterPresetPositions:SetValue("Bottom right")
			end	
			if CustomNZBarPosConfig:GetInt() == 6 then		
				NZCounterPresetPositions:SetValue("Bottom left")
			end	
			if CustomNZBarPosConfig:GetInt() == -1 then -- Secret position that is set when a custom position is chosen to prevent the bar from breaking.
				NZCounterPresetPositions:SetValue("No preset")
			end 	
			
			NZCounterPresetPositions.OnSelect = function()
				if NZCounterPresetPositions:GetValue() == "Top middle" then
					RunConsoleCommand("nz_zombiesbarpos", "1")
					NZCounterPresetBugForceValue = 1
				end
				if NZCounterPresetPositions:GetValue() == "Top right" then	
					RunConsoleCommand("nz_zombiesbarpos", "2")
					NZCounterPresetBugForceValue = 2
				end
				if NZCounterPresetPositions:GetValue() == "Top left" then	
					RunConsoleCommand("nz_zombiesbarpos", "3")
					NZCounterPresetBugForceValue = 3
				end
				if NZCounterPresetPositions:GetValue() == "Bottom middle" then
					RunConsoleCommand("nz_zombiesbarpos", "4")
					NZCounterPresetBugForceValue = 4
				end
				if NZCounterPresetPositions:GetValue() == "Bottom right" then
					RunConsoleCommand("nz_zombiesbarpos", "5")
					NZCounterPresetBugForceValue = 5
				end
				if NZCounterPresetPositions:GetValue() == "Bottom left" then
					RunConsoleCommand("nz_zombiesbarpos", "6")
					NZCounterPresetBugForceValue = 6
				end
				if NZCounterPresetPositions:GetValue() == "No preset" then
					RunConsoleCommand("nz_zombiesbarpos", "-1")
					NZCounterPresetBugForceValue = -1	
				end
			end	
			
			local NZCounterBarWidth = vgui.Create("DNumSlider", nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterBarWidth)
			NZCounterBarWidth:SetWidth(405)	
			NZCounterBarWidth:SetHeight(10)	
			NZCounterBarWidth:MoveToFront()
			NZCounterBarWidth:SetPos(205, 85)
			NZCounterBarWidth:SetMin(-ScrW() / 19 + 8)
			NZCounterBarWidth:SetMax(ScrW() / 19 - 1) 
			NZCounterBarWidth:SetDecimals(0)
			NZCounterBarWidth:SetValue(CustomNZBarWidthConfig:GetInt())
			NZCounterBarWidth.OnValueChanged = function( panel, value )
				if NZCounterBoxWasToggled == false then
					NZCounterBarWidth:SetConVar("nz_zombiesbarwidth")	
				end
			end 
			
			local NZCounterBarHeight = vgui.Create("DNumSlider", nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterBarHeight)
			NZCounterBarHeight:SetWidth(405)	
			NZCounterBarHeight:SetHeight(10)	
			NZCounterBarHeight:MoveToFront()
			NZCounterBarHeight:SetPos(205, 190)
			NZCounterBarHeight:SetMin(4) -- Below 4 and you won't really see it anymore.
			NZCounterBarHeight:SetMax(ScrH() / 2) -- If the max is too high, then it will just cover the screen making navigation impossible!
			NZCounterBarHeight:SetDecimals(0)
			NZCounterBarHeight:SetValue(CustomNZBarWidthConfig:GetInt())
			NZCounterBarHeight.OnValueChanged = function( panel, value )
				if NZCounterBoxWasToggled == false then
					NZCounterBarHeight:SetConVar("nz_zombiesbarheight")	
				end
			end 
			
			local NZCounterSize = vgui.Create("DNumSlider", nzcounterwindow)
			table.insert(AllTheDarnThings, NZCounterSize)
			NZCounterSize:SetWidth(405)	
			NZCounterSize:SetHeight(10)	
			NZCounterSize:MoveToFront()
			NZCounterSize:SetPos(205, 300)
			NZCounterSize:SetMin(10) -- Below 10 and you won't really see it anymore.
			NZCounterSize:SetMax(ScrH() / 8 - 30) 
			NZCounterSize:SetDecimals(0)
			NZCounterSize:SetValue(CustomNZBarWidthConfig:GetInt())
			NZCounterSize.OnValueChanged = function( panel, value )
				if NZCounterBoxWasToggled == false then
					NZCounterSize:SetConVar("nz_zombiescountersize")	
				end
			end 
			
				surface.CreateFont( "NZCounterNZombiesFont", {
					font = "DK Umbilical Noose", 
					size = 34,
					weight = 300,
					antialias = true,
				} )
				
				surface.CreateFont( "NZCounterNZombiesFont2", {
					font = "Arial", 
					size = 23,
					weight = 300,
					antialias = true,
				} )			
				
				local nzcounterpercentagefixed = false
				function nzcounterwindow:PaintOver(w,h)	-- Had to paint over since the panel is covered with an image.
					if IsValid(NZCounterPositionerBlurScreen) then
					
					end
					if IsValid(NZTotalZombieBar) then
						NZTotalZombieBar:SetFraction(GetGlobalInt("NZCountKilledZombiesPercentage")) -- For an unknown reason the percentage resets when this is opened, so I had to add this code.
						nzcounterpercentagefixed = true
					end
				
					surface.SetDrawColor(string.ToColor(CustomNZBarInnerColorConfig:GetString())) -- Converts color command to color for the button.
					surface.DrawRect( 379, 388, 262, 21 )
					surface.SetDrawColor(string.ToColor(CustomNZBarOuterColorConfig:GetString())) 
					surface.DrawRect( 379, 515, 262, 21 )
					surface.SetDrawColor(string.ToColor(CustomNZCounterColorConfig:GetString())) 
					surface.DrawRect( 379, 644, 262, 21 )
					
					if CustomNZBarHideConfig:GetInt() > 0 then
						surface.SetFont( "NZCounterNZombiesFont2" )
						surface.SetTextColor( 0, 255, 0, 255 )
						surface.SetTextPos(NZCounterHideBarButton.x + 3, NZCounterHideBarButton.y - 2)
						surface.DrawText( "✔" )
					end
					if CustomNZCounterHideConfig:GetInt() > 0 then
						surface.SetFont( "NZCounterNZombiesFont2" )
						surface.SetTextColor( 0, 255, 0, 255 )
						surface.SetTextPos(NZCounterHideCounterButton.x + 3, NZCounterHideCounterButton.y - 2)
						surface.DrawText( "✔" )
					end
					if NZCounterInvertBarConfig:GetInt() > 0 then
						surface.SetFont( "NZCounterNZombiesFont2" )
						surface.SetTextColor( 0, 255, 0, 255 )
						surface.SetTextPos(NZInvertBarButton.x + 3, NZInvertBarButton.y - 2)
						surface.DrawText( "✔" )
					end
					if CustomNZBarPreviewConfig:GetInt() > 0 then
						surface.SetFont( "NZCounterNZombiesFont2" )
						surface.SetTextColor( 0, 255, 0, 255 )
						surface.SetTextPos(NZCounterPreviewBarButton.x + 3, NZCounterPreviewBarButton.y - 2)
						surface.DrawText( "✔" )
					end
					if CustomNZBarPosModeConfig:GetInt() > 0 then
						surface.SetFont( "NZCounterNZombiesFont2" )
						surface.SetTextColor( 0, 255, 0, 255 )
						surface.SetTextPos(NZCounterPositioningBarButton.x + 3, NZCounterPositioningBarButton.y - 2)
						surface.DrawText( "✔" )
					end
				end
				
				
				-----------------------Progress bar: Inner-color selection menu-------------------------------
				function CheckTheThingsRN()
					if !IsValid(NZCounterBarInnerColorSelectorPanel) then
						timer.Remove("NZCounterPositionCheckTimer") -- Delete it so it doesn't run forever..
					return end
					
					if nzcounterwindow:GetPos() != NZCounterBarInnerColorSelectorPanel:GetPos() then
						NZZombieCounterWindowMovedPosition = NZCounterBarInnerColorSelectorPanel:GetPos()
					end
				end
				
				InnerColorStuff = {}				
				local function NZCounterInnerColorSelector()
					local NZCounterBarInnerColorSelectorPanel = vgui.Create("DFrame")
					table.insert(InnerColorStuff, NZCounterBarInnerColorSelectorPanel)
					NZCounterBarInnerColorSelectorPanel:SetBackgroundBlur(true)
					NZCounterBarInnerColorSelectorPanel:SetPos(nzcounterwindow.x, nzcounterwindow.y)
					NZCounterBarInnerColorSelectorPanel:SetSize(706, 556)
					NZCounterBarInnerColorSelectorPanel:MakePopup() 
					NZCounterBarInnerColorSelectorPanel:SetTitle("Choose a color for the progression of the bar.")	
					NZCounterBarInnerColorSelectorPanel:SetParent(g_ContextMenu)	
					timer.Create("NZCounterPositionCheckTimer", 0.1, 0, function() -- OnStopDragging didn't work and Paint was ruining the menu, so I used a timer instead.
							if IsValid(NZCounterBarInnerColorSelectorPanel) then
								NZCounterBarInnerColorSelectorPanel:MoveToFront()
							end
							if IsValid(NZTotalZombieBarPreview) then
								if IsValid(NZCounterBarInnerColorSelectorPanel) then
									NZCounterBarInnerColorSelectorPanel:SetBackgroundBlur(false) -- Let the user see what their color looks like in real-time if the simulation is running.
								end
							end
						
						if !IsValid(NZCounterBarInnerColorSelectorPanel) then
							timer.Remove("NZCounterPositionCheckTimer") -- Delete it so it doesn't run forever..
						return end
						
						NZZombieCounterWindowMovedPositionX = NZCounterBarInnerColorSelectorPanel.x
						NZZombieCounterWindowMovedPositionY = NZCounterBarInnerColorSelectorPanel.y
						nzcounterwindow:SetPos(NZZombieCounterWindowMovedPositionX, NZZombieCounterWindowMovedPositionY) -- Instead of moving it when the timer is removed, we do it every frame for smoothness.
					end) 
				
					NZCounterBarInnerColorSelectorPanel.Close = function()
						for k,v in pairs(InnerColorStuff) do
							v:Remove()
						end
						nzcounterwindow:Show()
					end
					local NZCounterBarInnerColorSelector = vgui.Create("DColorMixer", NZCounterBarInnerColorSelectorPanel)
					table.insert(InnerColorStuff, NZCounterBarInnerColorSelector)
					NZCounterBarInnerColorSelector:SetPos(7, 30)
					NZCounterBarInnerColorSelector:SetSize(690, 560)	
					NZCounterBarInnerColorSelector:SetConVarR("nz_zombiecounter_R")
					NZCounterBarInnerColorSelector:SetConVarG("nz_zombiecounter_G")
					NZCounterBarInnerColorSelector:SetConVarB("nz_zombiecounter_B")
					NZCounterBarInnerColorSelector:SetConVarA("nz_zombiecounter_A")
					local BarColorChanged = false
					function NZCounterBarInnerColorSelector:Paint() -- Used Paint() instead of ValueChanged() for the fastest color swap speed possible.
						if BarColorChanged == false then
							BarColorChanged = true  -- Variable necessary or else it sets the color forever making customization impossible.
							NZCounterBarInnerColorSelector:SetColor(string.ToColor(CustomNZBarInnerColorConfig:GetString())) -- Make sure the color is what the user previously selected.
						end
					end
									
					function NZCounterBarInnerColorSelector:ValueChanged(col)	
						timer.Simple(0.1, function()
							net.Start("DoNZCommitBarInnerColorCmd", false)	
							net.WriteString(NZCOUNTERCOLORR:GetString().." "..NZCOUNTERCOLORG:GetString().." "..NZCOUNTERCOLORB:GetString().." "..NZCOUNTERCOLORA:GetString())
							net.SendToServer("DoNZCommitBarInnerColorCmd")
						end)
					end
				end
				-------------------------Progress bar: Outer-color selection menu------------------------------------------------------------------				
				OuterColorStuff = {}				
				local function NZCounterOuterColorSelector()
					local NZCounterBarOuterColorSelectorPanel = vgui.Create("DFrame")
					table.insert(OuterColorStuff, NZCounterBarOuterColorSelectorPanel)
					NZCounterBarOuterColorSelectorPanel:SetBackgroundBlur(true)
					NZCounterBarOuterColorSelectorPanel:SetPos(nzcounterwindow.x, nzcounterwindow.y)
					NZCounterBarOuterColorSelectorPanel:SetSize(706, 556)
					NZCounterBarOuterColorSelectorPanel:MakePopup() 
					NZCounterBarOuterColorSelectorPanel:SetTitle("Choose a color for the progress bar.")	
					NZCounterBarOuterColorSelectorPanel:SetParent(g_ContextMenu)	
					
					timer.Create("NZCounterPositionCheckTimer", 0.1, 0, function() -- OnStopDragging didn't work and Paint was ruining the menu, so I used a timer instead.
						if IsValid(NZCounterBarOuterColorSelectorPanel) then
							NZCounterBarOuterColorSelectorPanel:MoveToFront()
							if IsValid(NZTotalZombieBarPreview) then
								if IsValid(NZCounterBarOuterColorSelectorPanel) then
									NZCounterBarOuterColorSelectorPanel:SetBackgroundBlur(false) -- Let the user see what their color looks like in real-time if the simulation is running.
								end
							end
						end
						
						if !IsValid(NZCounterBarOuterColorSelectorPanel) then
							timer.Remove("NZCounterPositionCheckTimer") -- Delete it so it doesn't run forever..
						return end
						
						NZZombieCounterWindowMovedPositionX = NZCounterBarOuterColorSelectorPanel.x
						NZZombieCounterWindowMovedPositionY = NZCounterBarOuterColorSelectorPanel.y
						nzcounterwindow:SetPos(NZZombieCounterWindowMovedPositionX, NZZombieCounterWindowMovedPositionY) -- Instead of moving it when the timer is removed, we do it every frame for smoothness.
					end) 
				
					NZCounterBarOuterColorSelectorPanel.Close = function()
						for k,v in pairs(OuterColorStuff) do
							v:Remove()
						end
						nzcounterwindow:Show()
					end
					
					local NZCounterBarOuterColorSelector = vgui.Create("DColorMixer", NZCounterBarOuterColorSelectorPanel)
					table.insert(OuterColorStuff, NZCounterBarOuterColorSelector)
					NZCounterBarOuterColorSelector:SetPos(7, 30)
					NZCounterBarOuterColorSelector:SetSize(690, 560)
					NZCounterBarOuterColorSelector:SetConVarR("nz_zombiecounter_R")
					NZCounterBarOuterColorSelector:SetConVarG("nz_zombiecounter_G")
					NZCounterBarOuterColorSelector:SetConVarB("nz_zombiecounter_B")
					NZCounterBarOuterColorSelector:SetConVarA("nz_zombiecounter_A")
					
					local BarColorChanged = false
					function NZCounterBarOuterColorSelector:Paint()	-- Used Paint() instead of ValueChanged() for the fastest color swap speed possible.
						if BarColorChanged == false then
							BarColorChanged = true -- Variable necessary or else it sets the color forever making customization impossible.
							NZCounterBarOuterColorSelector:SetColor(string.ToColor(CustomNZBarOuterColorConfig:GetString())) -- Make sure the color is what the user previously selected.
						end
					end
					
					function NZCounterBarOuterColorSelector:ValueChanged(col)							
						timer.Simple(0.1, function()
							net.Start("DoNZCommitBarOuterColorCmd", false)	
							net.WriteString(NZCOUNTERCOLORR:GetString().." "..NZCOUNTERCOLORG:GetString().." "..NZCOUNTERCOLORB:GetString().." "..NZCOUNTERCOLORA:GetString())
							net.SendToServer("DoNZCommitBarOuterColorCmd")
						end)
					end
				end
				-------------------------Progress bar: Zombie counter color selection menu------------------------------------------------------------------
				
				CounterColorStuff = {}				
				local function NZCounterColorSelector()
					local NZCounterColorSelectorPanel = vgui.Create("DFrame")
					table.insert(CounterColorStuff, NZCounterColorSelectorPanel)
					NZCounterColorSelectorPanel:SetBackgroundBlur(true)
					NZCounterColorSelectorPanel:SetPos(nzcounterwindow.x, nzcounterwindow.y)
					NZCounterColorSelectorPanel:SetSize(706, 556)
					NZCounterColorSelectorPanel:MakePopup() 
					NZCounterColorSelectorPanel:SetTitle("Choose a color for the progress bar.")	
					NZCounterColorSelectorPanel:SetParent(g_ContextMenu)	
					
					timer.Create("NZCounterPositionCheckTimer", 0.1, 0, function() -- OnStopDragging didn't work and Paint was ruining the menu, so I used a timer instead.
						if IsValid(NZCounterColorSelectorPanel) then
							NZCounterColorSelectorPanel:MoveToFront()
							if IsValid(NZTotalZombieBarPreview) then
								if IsValid(NZCounterColorSelectorPanel) then
									NZCounterColorSelectorPanel:SetBackgroundBlur(false) -- Let the user see what their color looks like in real-time if the simulation is running.
								end
							end
						end

						if !IsValid(NZCounterColorSelectorPanel) then
							timer.Remove("NZCounterPositionCheckTimer") -- Delete it so it doesn't run forever..
						return end
						
						NZZombieCounterWindowMovedPositionX = NZCounterColorSelectorPanel.x
						NZZombieCounterWindowMovedPositionY = NZCounterColorSelectorPanel.y
						nzcounterwindow:SetPos(NZZombieCounterWindowMovedPositionX, NZZombieCounterWindowMovedPositionY) -- Instead of moving it when the timer is removed, we do it every frame for smoothness.
					end) 
				
					NZCounterColorSelectorPanel.Close = function()
						for k,v in pairs(CounterColorStuff) do
							v:Remove()
						end
						nzcounterwindow:Show()
					end
					
					local NZCounterColorSelectorPanel = vgui.Create("DColorMixer", NZCounterColorSelectorPanel)
					table.insert(OuterColorStuff, NZCounterColorSelectorPanel)
					NZCounterColorSelectorPanel:SetPos(7, 30)
					NZCounterColorSelectorPanel:SetSize(690, 560)	
					NZCounterColorSelectorPanel:SetConVarR("nz_zombiecounter_R")
					NZCounterColorSelectorPanel:SetConVarG("nz_zombiecounter_G")
					NZCounterColorSelectorPanel:SetConVarB("nz_zombiecounter_B")
					NZCounterColorSelectorPanel:SetConVarA("nz_zombiecounter_A")
					
					local BarColorChanged = false
					
					function NZCounterColorSelectorPanel:Paint() -- Used Paint() instead of ValueChanged() for the fastest color swap speed possible.
						if BarColorChanged == false then
							BarColorChanged = true -- Variable necessary or else it sets the color forever making customization impossible.
							NZCounterColorSelectorPanel:SetColor(string.ToColor(CustomNZCounterColorConfig:GetString())) -- Make sure the color is what the user previously selected.
						end
					end
					
					function NZCounterColorSelectorPanel:ValueChanged(col)	
						timer.Simple(0.1, function()					
							net.Start("DoNZCommitCounterColorCmd", false)	
							net.WriteString(NZCOUNTERCOLORR:GetString().." "..NZCOUNTERCOLORG:GetString().." "..NZCOUNTERCOLORB:GetString().." "..NZCOUNTERCOLORA:GetString())
							net.SendToServer("DoNZCommitCounterColorCmd")
						end)
					end
				end
				-------------------------------------------------------------------------------------------
				
				local NZCounterBarColorInnerButton = vgui.Create("DButton", nzcounterwindow)
				NZCounterBarColorInnerButton:SetPos(379,388)
				NZCounterBarColorInnerButton:SetSize(261,20)
				NZCounterBarColorInnerButton:SetAlpha(0)
				NZCounterBarColorInnerButton.DoClick = function() -- Show the inner-bar color selector menu.
					nzcounterwindow:Hide()
					NZCounterInnerColorSelector()
				end
				
				local NZCounterBarColorOuterButton = vgui.Create("DButton", nzcounterwindow)
				NZCounterBarColorOuterButton:SetPos(379,515)
				NZCounterBarColorOuterButton:SetSize(261,20)
				NZCounterBarColorOuterButton:SetAlpha(0)
				NZCounterBarColorOuterButton.DoClick = function() -- Show the inner-bar color selector menu.
					nzcounterwindow:Hide()
					NZCounterOuterColorSelector()
				end
				
				local NZCounterCounterColorButton = vgui.Create("DButton", nzcounterwindow)
				NZCounterCounterColorButton:SetPos(379,644)
				NZCounterCounterColorButton:SetSize(261,20)
				NZCounterCounterColorButton:SetAlpha(0)
				NZCounterCounterColorButton.DoClick = function() -- Show the inner-bar color selector menu.
					nzcounterwindow:Hide()
					NZCounterColorSelector()
				end
				
				
				
				NZCounterBoxWasToggled = false
				timer.Simple(0.2, function() -- Fixes the extremely annoying bug where you have to set a value twice for it to visually change to that value.
					NZCounterBoxWasToggled = true
					NZCounterHideBarButton:SetValue(1)
					NZCounterHideBarButton:SetValue(0)
					NZCounterHideBarButton:SetValue(CustomNZBarHideConfig:GetInt())
					NZCounterHideCounterButton:SetValue(1)
					NZCounterHideCounterButton:SetValue(0)
					NZCounterHideCounterButton:SetValue(CustomNZCounterHideConfig:GetInt())
					NZInvertBarButton:SetValue(1)
					NZInvertBarButton:SetValue(0)
					NZInvertBarButton:SetValue(NZCounterInvertBarConfig:GetInt())
					NZCounterPreviewBarButton:SetValue(1)
					NZCounterPreviewBarButton:SetValue(0)
					NZCounterPreviewBarButton:SetValue(CustomNZBarPreviewConfig:GetInt())
					NZCounterPositioningBarButton:SetValue(1)
					NZCounterPositioningBarButton:SetValue(0)
					NZCounterPositioningBarButton:SetValue(CustomNZBarPosModeConfig:GetInt())
					NZCounterBarWidth:SetValue(CustomNZBarWidthConfig:GetInt())
					NZCounterBarWidth:SetValue(0)
					NZCounterBarWidth:SetValue(CustomNZBarWidthConfig:GetInt())
					NZCounterBarHeight:SetValue(CustomNZBarHeightConfig:GetInt())
					NZCounterBarHeight:SetValue(0)
					NZCounterBarHeight:SetValue(CustomNZBarHeightConfig:GetInt())
					NZCounterSize:SetValue(NZCounterSizeConfig:GetInt())
					NZCounterSize:SetValue(0)
					NZCounterSize:SetValue(NZCounterSizeConfig:GetInt())
				end)
				
			timer.Simple(0.5, function()
				NZCounterBoxWasToggledAgain = false
			end)				
		end
	}
)