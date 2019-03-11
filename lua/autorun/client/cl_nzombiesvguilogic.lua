CustomNZBarHideConfig = CreateClientConVar( "nz_zombiesbarhide", "0", true, false ) -- Allow players to manually hide the bar if they want to.
CustomNZCounterHideConfig = CreateClientConVar( "nz_zombiecounterhide", "0", true, false ) -- Allow players to manually hide the zombie counter if they want to.
CustomNZBarPosConfig = CreateClientConVar( "nz_zombiesbarpos", "1", true, false ) -- Allow players to manually change positions of the bar if they want to.
CustomNZBarWidthConfig = CreateClientConVar( "nz_zombiesbarwidth", "22", true, false ) -- Allow players to manually change the length of the bar if they want to.
CustomNZBarHeightConfig = CreateClientConVar( "nz_zombiesbarheight", "8", true, false ) -- Allow players to manually change the height of the bar if they want to.
NZCounterSizeConfig = CreateClientConVar( "nz_zombiescountersize", "20", true, false ) -- Allow players to manually change the size of the zombie counter if they want to.
CustomNZBarPreviewConfig = CreateClientConVar( "nz_zombiebarpreview", "0", true, false ) -- Allow players to preview the bar when a round is not in progress.
CustomNZBarCustomPosXConfig = CreateClientConVar( "nz_zombiebarcustomposx", "-1", true, false ) -- Command set in the NZ Bar Positioning overlay.
CustomNZBarCustomPosYConfig = CreateClientConVar( "nz_zombiebarcustomposy", "-1", true, false ) -- Command set in the NZ Bar Positioning overlay.

cvars.AddChangeCallback("nz_zombiescountersize", function() -- Update font or else the size will always remain the same regardless of what the value is!
	surface.CreateFont( "NZCounterZombieCounterFont", {
		font = "Arial",
		extended = false,
		size = NZCounterSizeConfig:GetInt(), -- Make sure the font size is what the player wants it to show as.
		weight = 1500,
		outline = true,
	} )
end)

cvars.AddChangeCallback("nz_zombiesbarpos", function() -- Make sure the custom position is removed if a postion preset is chosen.
	if CustomNZBarPosConfig:GetInt() != -1 then -- If the position is a preset then reset the custom position values.
		RunConsoleCommand("nz_zombiebarcustomposx", "-1")
		RunConsoleCommand("nz_zombiebarcustomposy", "-1")
	end
end)

cvars.AddChangeCallback("nz_zombiebarcustomposx", function() -- Actively change the position to the custom one if a custom position is changed.
	NZCounterBypass = false
	NZZombieCountClearBar()
	NZZombieCountDrawVGUIBar()
	RunConsoleCommand("nz_zombiesbarpos", "-1") -- Show 'No preset' in the presets tab, copies what 'Top middle' preset does as well to prevent the bar from breaking.
end)

cvars.AddChangeCallback("nz_zombiesbarhide", function() -- Hide or show the bar depending on what the player's setting is.
	if CustomNZBarHideConfig:GetInt() == 0 then
		if NZCounterBoxWasToggledAgain == false then
			NZZombieCountDrawVGUIBar()
			net.Start("DoNZCounterHideChatResponse1", false)	
			net.SendToServer("DoNZCounterHideChatResponse1")
		end
	end
	
	if CustomNZBarHideConfig:GetInt() > 0 then
		if NZCounterBoxWasToggledAgain == false then
			net.Start("DoNZCounterHideChatResponse2", false)	
			net.SendToServer("DoNZCounterHideChatResponse2")
			if NZTotalZombieBar != nil then
				for k,v in pairs(AllZombieBars) do
					if IsValid(v) then
						v:Remove()
						AllZombieBars = {}
					end
				end
			end
			RunConsoleCommand("nz_zombiebarpreview", "0") -- Discontinue the simulation after hiding the bar.
			if IsValid(NZTotalZombieBarPreview) then
				NZTotalZombieBarPreview:Remove()
				timer.Remove("NZCounterSimulationLoop")
			end
		end
	end
end)

cvars.AddChangeCallback("nz_zombiecounterhide", function() -- Inform the player of the state of their option like always..
	if NZCounterBoxWasToggledAgain == false then
		if CustomNZCounterHideConfig:GetInt() > 0 then	
			net.Start("DoNZCounterHideCounterResponse1", false)	
			net.SendToServer("DoNZCounterHideChatResponse1")
		end
		if CustomNZCounterHideConfig:GetInt() == 0 then	
			net.Start("DoNZCounterHideCounterResponse2", false)	
			net.SendToServer("DoNZCounterHideChatResponse2")
		end
	end
end)

AllZombieBarPreviews = {}
-------------------------------------------PROGRESS BAR SIMULATION----------------------------------------------------------------------------------
cvars.AddChangeCallback("nz_zombiebarpreview", function() -- Simulate what the progress bar and zombie counter will look like if there is no bar showing.
	if NZCounterBoxWasToggledAgain == false && CustomNZBarHideConfig:GetInt() > 0 then 
		net.Start("DoNZCounterPreviewChatResponse4", false)	
		net.SendToServer("DoNZCounterPreviewChatResponse4")	
		RunConsoleCommand("nz_zombiebarpreview", "0") -- Make sure it is set to 0 and appears unchecked in the menu since we are not doing anything.
	return end -- Don't preview the progress bar if the user wants to progress bar to be hidden.
	
	if NZCounterBoxWasToggledAgain == false && !IsValid(NZTotalZombieBarPreview) then
		if IsValid(NZTotalZombieBar) then					
			net.Start("DoNZCounterPreviewChatResponse2", false)	
			net.SendToServer("DoNZCounterPreviewChatResponse2")		
			RunConsoleCommand("nz_zombiebarpreview", "0") -- Make sure it is set to 0 and appears unchecked in the menu since we are not doing anything.			
		end
		
		if !IsValid(NZTotalZombieBar) then	
			if CustomNZBarPreviewConfig:GetInt() == 0 then
				net.Start("DoNZCounterPreviewChatResponse3", false)	
				net.SendToServer("DoNZCounterPreviewChatResponse3")	
			else
				DoTheNZCounterSimulation()
				net.Start("DoNZCounterPreviewChatResponse1", false)	
				net.SendToServer("DoNZCounterPreviewChatResponse1")	
			end
		end
	end
	
	function DoTheNZCounterSimulation()
		if IsValid(NZTotalZombieBar) then
			RunConsoleCommand("nz_zombiebarpreview", "0") -- Make sure previewing doesn't immediately start again after the player is done in the round.	
			if IsValid(NZTotalZombieBarPreview) then
				NZTotalZombieBarPreview:Remove()
				timer.Remove("NZCounterSimulationLoop")
			end
		end
		
		if !IsValid(NZTotalZombieBar) then			
			NZTotalZombieBarPreview = vgui.Create( "DProgress" )
			NZTotalZombieBarPreview:SetAlpha(0) -- This is replaced with our own custom-colored one.
			for k,v in pairs(AllZombieBarPreviews) do 
				if IsValid(v) && v != NZTotalZombieBarPreview then
					v:Remove()
				end
			end
		table.insert(AllZombieBarPreviews, NZTotalZombieBarPreview)
		
		if !timer.Exists("NZCounterSimulationLoop") then
			timer.Create("NZCounterSimulationLoop", 0.5, 0, function() DoTheNZCounterSimulation() end )
		end				
			NZCounterSimulationText = "0 zombies killed out of 4"
			timer.Simple(0.1, function()
				if IsValid(NZTotalZombieBarPreview) then
					NZCounterSimulationText = "1 zombies killed out of 4"
					NZTotalZombieBarPreview:SetFraction(0.25)
				end
			end)
			timer.Simple(0.2, function()
				if IsValid(NZTotalZombieBarPreview) then
					NZCounterSimulationText = "2 zombies killed out of 4"
					NZTotalZombieBarPreview:SetFraction(0.50)
				end
			end)
			timer.Simple(0.3, function()
				if IsValid(NZTotalZombieBarPreview) then
					NZCounterSimulationText = "3 zombies killed out of 4"
					NZTotalZombieBarPreview:SetFraction(0.75)
				end
			end)					
			timer.Simple(0.4, function()
				if IsValid(NZTotalZombieBarPreview) then
					NZCounterSimulationText = "4 zombies killed out of 4"
					NZTotalZombieBarPreview:SetFraction(1.0)
				end
			end)
		end
	end	
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------

function DoTheNZCounterThings()
NZTotalZombieBarPreview:SetFraction(0.0)
if CustomNZBarHideConfig:GetInt() > 0 then return end -- Don't try to delete something that doesn't even exist.
	if NZTotalZombieBarPreview != nil then
		for k,v in pairs(AllZombieBarPreviews) do
			if IsValid(v) then
				v:Remove()				
			end		
		end
	end
	if NZTotalZombieBarPreview == nil then return end
	DoTheNZCounterSimulation()
end

cvars.AddChangeCallback("nz_zombiesbarwidth", function() -- Simulate what the progress bar and zombie counter will look like if there is no bar showing.
	if IsValid(NZTotalZombieBarPreview) then
		for k,v in pairs(AllZombieBarPreviews) do
			if IsValid(v) then
				v:Remove()
			end			
		end
	end
	
	if IsValid(NZTotalZombieBar) then
		NZTotalZombieBar:SetFraction(0.0)
		NZZombieCountClearBar()
		if NZTotalZombieBar == nil then return end
		if nzRound:InState(ROUND_GO) then return end 
		if nzRound:GetState() == 0 then return end 
		NZZombieCountDrawVGUIBar()		
	end
end)

cvars.AddChangeCallback("nz_zombiesbarheight", function() -- Simulate what the progress bar and zombie counter will look like if there is no bar showing.
	if IsValid(NZTotalZombieBarPreview) then
		for k,v in pairs(AllZombieBarPreviews) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
	
	if IsValid(NZTotalZombieBar) then
		NZTotalZombieBar:SetFraction(0.0)
		NZZombieCountClearBar()
		if NZTotalZombieBar == nil then return end
		if nzRound:InState(ROUND_GO) then return end 
		if nzRound:GetState() == 0 then return end 
		NZZombieCountDrawVGUIBar()	
	end
end)

cvars.AddChangeCallback("nz_zombiesbarpos", function() -- Hide or show the bar depending on what the player's setting is.
	NZZombieCountClearBar()
	NZZombieCountDrawVGUIBar()

	if CustomNZBarPosConfig:GetInt() == 1 then		
		net.Start("DoNZCounterPosPresetChatResponse1", false)	
		net.SendToServer("DoNZCounterPosPresetChatResponse1")		
	end
	if CustomNZBarPosConfig:GetInt() == 2 then		
		net.Start("DoNZCounterPosPresetChatResponse2", false)	
		net.SendToServer("DoNZCounterPosPresetChatResponse2")
	end
	if CustomNZBarPosConfig:GetInt() == 3 then		
		net.Start("DoNZCounterPosPresetChatResponse3", false)	
		net.SendToServer("DoNZCounterPosPresetChatResponse3")
	end
	if CustomNZBarPosConfig:GetInt() == 4 then		
		net.Start("DoNZCounterPosPresetChatResponse4", false)	
		net.SendToServer("DoNZCounterPosPresetChatResponse4")
	end
	if CustomNZBarPosConfig:GetInt() == 5 then		
		net.Start("DoNZCounterPosPresetChatResponse5", false)	
		net.SendToServer("DoNZCounterPosPresetChatResponse5")
	end
	if CustomNZBarPosConfig:GetInt() == 6 then		
		net.Start("DoNZCounterPosPresetChatResponse6", false)	
		net.SendToServer("DoNZCounterPosPresetChatResponse6")
	end
end)


if !CLIENT then return end

local Show = false
hook.Add( "HUDPaint", "NZCounterAddZombieCounterByBar", function()
	if !IsValid(NZtotalZombieBar) then	-- Show the counter still, even if the bar doesn't exist.
		if CustomNZBarHideConfig:GetInt() == 1 && CustomNZCounterHideConfig:GetInt() == 0 then Show = true 		
		else
			Show = false
		end
		
		if string.ToColor(CustomNZCounterColorConfig:GetString()) == nil then Show = false end
		if nzRound:InState(ROUND_GO) then Show = false end -- Don't show the extra info if there is no progression to be made!
		if nzRound:GetState() == 0 then Show = false end --   ^
		
		if Show == true then
			if CustomNZBarPosConfig:GetInt() == 1 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then 
					draw.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW() * 0.5, 0, Color(string.ToColor(CustomNZCounterColorConfig:GetString())), TEXT_ALIGN_CENTER )
				else
					draw.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW() * 0.5, 0, string.ToColor(CustomNZCounterColorConfig:GetString()), TEXT_ALIGN_CENTER )				
				end
			end
			if CustomNZBarPosConfig:GetInt() == 2 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then 
					draw.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW() * 0.5, 0, Color(string.ToColor(CustomNZCounterColorConfig:GetString())), TEXT_ALIGN_RIGHT )
				else
					draw.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW(), 0, string.ToColor(CustomNZCounterColorConfig:GetString()), TEXT_ALIGN_RIGHT )				
				end
			end
			if CustomNZBarPosConfig:GetInt() == 3 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then 
					draw.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", 0, 0, Color(string.ToColor(CustomNZCounterColorConfig:GetString())), TEXT_ALIGN_LEFT )
				else
					draw.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", 0, 0, string.ToColor(CustomNZCounterColorConfig:GetString()), TEXT_ALIGN_LEFT )				
				end
			end
			if CustomNZBarPosConfig:GetInt() == 4 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then 
					draw.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW() * 0.5, ScrH() - NZCounterSizeConfig:GetInt(), Color(string.ToColor(CustomNZCounterColorConfig:GetString())), TEXT_ALIGN_CENTER )
				else
					draw.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW() * 0.5, ScrH() - NZCounterSizeConfig:GetInt(), string.ToColor(CustomNZCounterColorConfig:GetString()), TEXT_ALIGN_CENTER )				
				end
			end
			if CustomNZBarPosConfig:GetInt() == 5 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then 
					draw.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW() * 0.5, ScrH() - NZCounterSizeConfig:GetInt(), Color(string.ToColor(CustomNZCounterColorConfig:GetString())), TEXT_ALIGN_RIGHT )
				else
					draw.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", ScrW(), ScrH() - NZCounterSizeConfig:GetInt(), string.ToColor(CustomNZCounterColorConfig:GetString()), TEXT_ALIGN_RIGHT )				
				end
			end
			if CustomNZBarPosConfig:GetInt() == 6 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then 
					draw.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", 0, ScrH() - NZCounterSizeConfig:GetInt(), Color(string.ToColor(CustomNZCounterColorConfig:GetString())), TEXT_ALIGN_LEFT )
				else
					draw.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"), "NZCounterZombieCounterFont", 0, ScrH() - NZCounterSizeConfig:GetInt(), string.ToColor(CustomNZCounterColorConfig:GetString()), TEXT_ALIGN_LEFT )				
				end
			end
			surface.SetTextPos(CustomNZBarCustomPosXConfig:GetInt(), CustomNZBarCustomPosYConfig:GetInt())
			surface.SetFont("NZCounterZombieCounterFont")
			surface.SetTextColor(string.ToColor(CustomNZCounterColorConfig:GetString())) 
			if CustomNZBarPosConfig:GetInt() == -1 then 
				if GetGlobalInt("NZCountKilledZombies") == 1 then -- Have to fix the grammar mistake because it would annoy me too much if I didn't...					
					surface.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"))				
				else	
					surface.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"))
				end
			end
		end
	end
	
	if !IsValid(NZCounterPositionerBlurScreen) then
		if NZCounterPresetBugForceValue != nil then -- Fixes a major issue that occurs when a user changes a preset (It didn't actually set it half of the time.)
			if CustomNZBarPosConfig:GetInt() != NZCounterPresetBugForceValue then
				net.Start("DoNZCommitFixPosCommand")
				net.WriteInt(NZCounterPresetBugForceValue, 32)
				net.SendToServer("DoNZCommitFixPosCommand")
			end	
		end
	
	if IsValid(NZTotalZombieBarPreview) then -- We only want to render simulation text during the simulation. 
		if !IsValid(NZCounterPositionerBlurScreen) then -- Check if the Positioner is open.			
			if CustomNZBarPosConfig:GetInt() == 1 then -- Top middle preset position
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())			
				NZTotalZombieBarPreview:Center()
				NZTotalZombieBarPreview:SetPos(NZTotalZombieBarPreview.x, 0) -- We don't want it on the center of the screen, we want it on the top-center of the screen.		
			end 
			if CustomNZBarPosConfig:GetInt() == 2 then -- Top right preset position
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
				NZTotalZombieBarPreview:AlignRight() 
				NZTotalZombieBarPreview:SetPos(NZTotalZombieBarPreview.x, 0) 	
			end
			if CustomNZBarPosConfig:GetInt() == 3 then -- Top left preset position
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
				NZTotalZombieBarPreview:SetPos(0, 0) 	
			end
			if CustomNZBarPosConfig:GetInt() == 4 then -- Bottom middle preset position
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
				NZTotalZombieBarPreview:Center()
				NZTotalZombieBarPreview:SetPos(NZTotalZombieBarPreview.x, ScrH() - CustomNZBarHeightConfig:GetInt()) 			
			end
			if CustomNZBarPosConfig:GetInt() == 5 then -- Bottom right preset position
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, ScrH() + CustomNZBarHeightConfig:GetInt())	
				NZTotalZombieBarPreview:AlignRight() 
				NZTotalZombieBarPreview:SetPos(NZTotalZombieBarPreview.x, ScrH() - CustomNZBarHeightConfig:GetInt()) 		
			end
			if CustomNZBarPosConfig:GetInt() == 6 then -- Bottom left preset position
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, ScrH() + CustomNZBarHeightConfig:GetInt())	
				NZTotalZombieBarPreview:SetPos(0, ScrH() - CustomNZBarHeightConfig:GetInt()) 	
			end
			if CustomNZBarPosConfig:GetInt() == -1 then -- Secret position that is set when a custom position is chosen to prevent the bar from breaking.
				NZTotalZombieBarPreview:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())			
				NZTotalZombieBarPreview:Center()
				NZTotalZombieBarPreview:SetPos(NZTotalZombieBarPreview.x, 0) -- We don't want it on the center of the screen, we want it on the top-center of the screen.			
			 end 
		
			if CustomNZBarCustomPosXConfig:GetInt() != -1 && CustomNZBarCustomPosYConfig:GetInt() != -1 then -- Make sure the zombie bar is at the custom position if one is set.
				NZTotalZombieBarPreview:SetPos(CustomNZBarCustomPosXConfig:GetInt(), CustomNZBarCustomPosYConfig:GetInt())
				
				if NZTotalZombieBarPreview.x + NZTotalZombieBarPreview:GetSize() > ScrW() then -- Copy paste of the code I used for the positioning menu to stop the bar from going off-screen, same purpose here.
					NZTotalZombieBarPreview:SetPos(ScrW() - NZTotalZombieBarPreview:GetSize(), NZTotalZombieBarPreview.y)
				end	
				if NZTotalZombieBarPreview.x < 0 then
					NZTotalZombieBarPreview:SetPos(0, NZTotalZombieBarPreview.y)
				end
			end
		end
		surface.SetFont( "NZCounterZombieCounterFont" )
		surface.SetTextColor(string.ToColor(CustomNZCounterColorConfig:GetString()))
		surface.SetDrawColor(string.ToColor(CustomNZBarOuterColorConfig:GetString())) 
		surface.DrawRect(NZTotalZombieBarPreview.x, NZTotalZombieBarPreview.y, ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt()) -- Replaces the outer progress bar with our own, positions to exactly where it should.
		
		surface.SetDrawColor(string.ToColor(CustomNZBarInnerColorConfig:GetString())) 
		if NZTotalZombieBarPreview:GetFraction() == 0.0 then return end
		
		if NZCounterInvertBarConfig:GetInt() > 0 then -- Invert the progression if the user wants this to happen.		
			surface.DrawRect(NZTotalZombieBarPreview.x - 1 + NZTotalZombieBarPreview:GetWide() - NZTotalZombieBarPreview:GetWide() * NZTotalZombieBarPreview:GetFraction() + 1, NZTotalZombieBarPreview.y, NZTotalZombieBarPreview:GetWide() * NZTotalZombieBarPreview:GetFraction() + 1, CustomNZBarHeightConfig:GetInt()) -- Converted DProgressBar's percentage equation to be compatible with our new custom bar.
		else
			surface.DrawRect(NZTotalZombieBarPreview.x, NZTotalZombieBarPreview.y, NZTotalZombieBarPreview:GetWide() * NZTotalZombieBarPreview:GetFraction(), CustomNZBarHeightConfig:GetInt()) -- Converted DProgressBar's percentage equation to be compatible with our new custom bar.
		end
		
		if CustomNZCounterHideConfig:GetInt() > 0 then return end -- Don't show the counter if the user does not want it enabled.
		if NZTotalZombieBarPreview.y < 50 + NZCounterSizeConfig:GetInt() then -- Detect if the text above the bar is out of monitor bounds and if it is, fix it.
			surface.SetTextPos(NZTotalZombieBarPreview:GetPos() - NZCounterSizeConfig:GetInt() + NZTotalZombieBarPreview:GetSize() / 2 - string.len(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies")) - NZCounterSizeConfig:GetInt() * 3.30 + 10, NZTotalZombieBarPreview.y + 5 + CustomNZBarHeightConfig:GetInt()) -- Places text at the center of the bar no matter what the length, height or position of it is and no matter what size or length the text is.
		end
		if NZTotalZombieBarPreview.y >= 50 + NZCounterSizeConfig:GetInt() then
			surface.SetTextPos(NZTotalZombieBarPreview:GetPos() - NZCounterSizeConfig:GetInt() + NZTotalZombieBarPreview:GetSize() / 2 - string.len(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies")) - NZCounterSizeConfig:GetInt() * 3.30 + 10, NZTotalZombieBarPreview.y - 5 - NZCounterSizeConfig:GetInt())
		end	
			surface.DrawText(NZCounterSimulationText)
	return end
	
	if NZCounterBypass == nil then NZCounterBypass = false return end	
	if NZTotalZombieBar == nil && NZCounterBypass == false then return end
	if nzRound:InState(ROUND_GO) && NZCounterBypass == false then NZResetZombieVGUIBar() return end -- Don't show the extra info if there is no progression to be made!
	if nzRound:GetState() == 0 && NZCounterBypass == false then NZResetZombieVGUIBar() return end --   ^
	if NZTotalZombieBar.x == nil || NZTotalZombieBar.y == nil && NZCounterBypass == false then return end -- Don't attempt to show text at a position that doesn't exist!
	if string.ToColor(CustomNZCounterColorConfig:GetString()) == nil then return end

		if CustomNZBarPosConfig:GetInt() == 1 then -- Top middle preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())			
			NZTotalZombieBar:Center() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, 0) -- We don't want it on the center of the screen, we want it on the top-center of the screen.		
		end 
		if CustomNZBarPosConfig:GetInt() == 2 then -- Top right preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:AlignRight() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, 0) 	
		end
		if CustomNZBarPosConfig:GetInt() == 3 then -- Top left preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:SetPos(0, 0) 	
		end
		if CustomNZBarPosConfig:GetInt() == 4 then -- Bottom middle preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:Center()
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, ScrH() - CustomNZBarHeightConfig:GetInt()) 			
		end
		if CustomNZBarPosConfig:GetInt() == 5 then -- Bottom right preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, ScrH() + CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:AlignRight() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, ScrH() - CustomNZBarHeightConfig:GetInt()) 		
		end
		if CustomNZBarPosConfig:GetInt() == 6 then -- Bottom left preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, ScrH() + CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:SetPos(0, ScrH() - CustomNZBarHeightConfig:GetInt()) 	
		end
		if CustomNZBarPosConfig:GetInt() == -1 then -- Secret position that is set when a custom position is chosen.
			NZTotalZombieBar:SetPos(CustomNZBarCustomPosXConfig:GetInt(), CustomNZBarCustomPosYConfig:GetInt()) -- We don't want it on the center of the screen, we want it on the top-center of the screen.		
		end 
	end
			
	if !IsValid(NZCounterPositionerBlurScreen) then -- Check if the Positioner is open.
		if CustomNZBarCustomPosXConfig:GetInt() != -1 && CustomNZBarCustomPosYConfig:GetInt() != -1 then -- Make sure the zombie bar is at the custom position if one is set.
			NZTotalZombieBar:SetPos(CustomNZBarCustomPosXConfig:GetInt(), CustomNZBarCustomPosYConfig:GetInt())
			
			if NZTotalZombieBar.x + NZTotalZombieBar:GetSize() > ScrW() then -- Copy paste of the code I used for the positioning menu to stop the bar from going off-screen, same purpose here.
				NZTotalZombieBar:SetPos(ScrW() - NZTotalZombieBar:GetSize(), NZTotalZombieBar.y)
			end	
			if NZTotalZombieBar.x < 0 then
				NZTotalZombieBar:SetPos(0, NZTotalZombieBar.y)
			end
		end
	end
	
	surface.SetFont( "NZCounterZombieCounterFont" )
	surface.SetTextColor(string.ToColor(CustomNZCounterColorConfig:GetString()))
	
	surface.SetDrawColor(string.ToColor(CustomNZBarOuterColorConfig:GetString())) 
	surface.DrawRect(NZTotalZombieBar.x, NZTotalZombieBar.y, ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt()) -- Replaces the outer progress bar with our own, positions to exactly where it should.
	
	surface.SetDrawColor(string.ToColor(CustomNZBarInnerColorConfig:GetString())) 
	
	if NZCounterInvertBarConfig:GetInt() > 0 then -- Invert the progression if the user wants this to happen.		
		surface.DrawRect(NZTotalZombieBar.x - 1 + NZTotalZombieBar:GetWide() - NZTotalZombieBar:GetWide() * NZTotalZombieBar:GetFraction() + 1, NZTotalZombieBar.y, NZTotalZombieBar:GetWide() * NZTotalZombieBar:GetFraction() + 1, CustomNZBarHeightConfig:GetInt()) -- Converted DProgressBar's percentage equation to be compatible with our new custom bar.
	else
		surface.DrawRect(NZTotalZombieBar.x, NZTotalZombieBar.y, NZTotalZombieBar:GetWide() * NZTotalZombieBar:GetFraction(), CustomNZBarHeightConfig:GetInt()) -- Converted DProgressBar's percentage equation to be compatible with our new custom bar.
	end
	
	if CustomNZCounterHideConfig:GetInt() > 0 then return end -- Don't show the counter if the user does not want it enabled.
	if NZTotalZombieBar.y < 25 then -- Detect if the text above the bar is out of monitor bounds and if it is, fix it.
		surface.SetTextPos(NZTotalZombieBar:GetPos() - NZCounterSizeConfig:GetInt() + NZTotalZombieBar:GetSize() / 2 - string.len(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies")) - NZCounterSizeConfig:GetInt() * 3.30 + 10, NZTotalZombieBar.y + 5 + CustomNZBarHeightConfig:GetInt()) -- Places text at the center of the bar no matter what the length, height or position of it is and no matter what size or length the text is.
	else
		surface.SetTextPos(NZTotalZombieBar:GetPos() - NZCounterSizeConfig:GetInt() + NZTotalZombieBar:GetSize() / 2 - string.len(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies")) - NZCounterSizeConfig:GetInt() * 3.30 + 10, NZTotalZombieBar.y - 5 - NZCounterSizeConfig:GetInt()) -- Places text at the center of the bar no matter what the length, height or position of it is.
	end
	
	if NZCounterBypass == true then -- A game is not really running, the user is just manually positioning this bar and we need something to show them.
		surface.DrawText("1 zombie killed out of 4")
	else
		if GetGlobalInt("NZCountTotalZombies") == "" then return end
			if GetGlobalInt("NZCountKilledZombies") == 1 then -- Have to fix the grammar mistake because it would annoy me too much if I didn't...
				surface.DrawText("1 zombie killed out of "..GetGlobalInt("NZCountTotalZombies"))
			else
				surface.DrawText(GetGlobalInt("NZCountKilledZombies").." zombies killed out of "..GetGlobalInt("NZCountTotalZombies"))
			end
		end
end )

AllZombieBars = {}
function NZZombieCountDrawVGUIBar()	
	if NZCounterBypass == nil then return end
	if nzRound:InState(ROUND_GO) && NZCounterBypass == false then return end -- Don't show the bar if there is no progression to be made!
	if nzRound:GetState() == 0 && NZCounterBypass == false then return end --   ^
	if CustomNZBarHideConfig:GetInt() > 0 && NZCounterBypass == false then return end
	
	NZTotalZombieBar = vgui.Create( "DProgress" )
	
	
	if NZTotalZombieBar == nil then -- Prevent any errors early on.
		NZTotalZombieBar = vgui.Create( "DProgress" )
		NZZombieCountDrawVGUIBar()	
	end
	
	if NZTotalZombieBar != nil then
		NZTotalZombieBar:SetAlpha(0) -- We replace this entirely with our own later on, but we still use this for gathering info like position, width, height and percentage.
		NZZombieCountClearBar() -- Make sure that there is no more than 1 bar showing up at a time or else it could cause optimization issues down the line.
		table.insert(AllZombieBars, NZTotalZombieBar) -- NZTotalZombieBar:Remove() doesn't work half of the time, so instead I store them in tables to remove them all.
		table.insert(AllZombieBars, NZTotalZombieBarZCounterTxt)
	
		if CustomNZBarPosConfig:GetInt() == 1 then -- Top middle preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())			
			NZTotalZombieBar:Center() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, 0) -- We don't want it on the center of the screen, we want it on the top-center of the screen.		
		end 
		if CustomNZBarPosConfig:GetInt() == 2 then -- Top right preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:AlignRight() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, 0) 	
		end
		if CustomNZBarPosConfig:GetInt() == 3 then -- Top left preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:SetPos(0, 0) 	
		end
		if CustomNZBarPosConfig:GetInt() == 4 then -- Bottom middle preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:Center()
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, ScrH() - CustomNZBarHeightConfig:GetInt()) 			
		end
		if CustomNZBarPosConfig:GetInt() == 5 then -- Bottom right preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, ScrH() + CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:AlignRight() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, ScrH() - CustomNZBarHeightConfig:GetInt()) 		
		end
		if CustomNZBarPosConfig:GetInt() == 6 then -- Bottom left preset position
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, ScrH() + CustomNZBarHeightConfig:GetInt())	
			NZTotalZombieBar:SetPos(0, ScrH() - CustomNZBarHeightConfig:GetInt()) 	
		end
		if CustomNZBarPosConfig:GetInt() == -1 then -- Secret position that is set when a custom position is chosen to prevent the bar from breaking.
			NZTotalZombieBar:SetSize(ScrW() / 2 + CustomNZBarWidthConfig:GetInt() * 10, CustomNZBarHeightConfig:GetInt())			
			NZTotalZombieBar:Center() 
			NZTotalZombieBar:SetPos(NZTotalZombieBar.x, 0) -- We don't want it on the center of the screen, we want it on the top-center of the screen.		
		end 
		
		if NZCounterBypass == true then
			NZTotalZombieBar:SetFraction(0.25)
		else
			if GetGlobalInt("NZCountKilledZombiesPercentage") != "" then -- No timer so it shows the old value first instead of no value at all.
				NZTotalZombieBar:SetFraction(GetGlobalInt("NZCountKilledZombiesPercentage"))
			else
				NZTotalZombieBar:SetFraction(0.0)
			end
					
			timer.Simple(0.15, function() -- But in 0.15 seconds this value updates to the latest one.
				if IsValid(NZTotalZombieBar) then
					if GetGlobalInt("NZCountKilledZombiesPercentage") != "" then
						NZTotalZombieBar:SetFraction(GetGlobalInt("NZCountKilledZombiesPercentage"))
					else
						NZTotalZombieBar:SetFraction(0.0)
					end
				end
			end)
		end
	end
end
concommand.Add("nz_totalzombiesbar", NZZombieCountDrawVGUIBar)

function NZZombieCountClearBar()
	if CustomNZBarHideConfig:GetInt() > 0 then return end -- Don't try to delete something that doesn't even exist.
	if NZTotalZombieBar != nil then
		for k,v in pairs(AllZombieBars) do
			if IsValid(v) then
				v:Remove()
				AllZombieBars = {}
			end
		end
	end 
end
concommand.Add("nz_cleartotalzombiesbar", NZZombieCountClearBar)

function NZResetZombieVGUIBar() -- Called multiple times to hide the bar and zombie counter at certain times and also to improve performance by deleting old overriden GUI bars.
	if CustomNZBarHideConfig:GetInt() > 0 then return end
	if IsValid(NZTotalZombieBar) then
		NZTotalZombieBar:SetFraction(0.0)
		SetGlobalInt("NZCountKilledZombiesPercentage", 0.0)
		SetGlobalInt("NZCountKilledZombies", 0)
		NZZombieCountClearBar()
		if NZTotalZombieBar == nil then return end
		if nzRound:InState(ROUND_GO) then return end 
		if nzRound:GetState() == 0 then return end 
		SetGlobalInt("NZCountTotalZombies", 0)
	end
end
concommand.Add("nz_resetzombiesbar", NZResetZombieVGUIBar)