if !SERVER then return end
resource.AddWorkshop( "1678717400" ) -- Make sure clients can actually SEE the menu. (resource.AddFile NEVER works, so I have clients download this exact addon instead.)

--I wasn't able to get the ChatPrint to work on the clientside scripts, so I networked variables to the server instead.
util.AddNetworkString("DoNZCounterHideChatResponse1")
util.AddNetworkString("DoNZCounterHideChatResponse2")
util.AddNetworkString("DoNZCounterHideCounterResponse1")
util.AddNetworkString("DoNZCounterHideCounterResponse2")
util.AddNetworkString("DoNZCounterPositionProgressInvertChatResponse1")
util.AddNetworkString("DoNZCounterPositionProgressInvertChatResponse2")
util.AddNetworkString("DoNZCounterPreviewChatResponse1")
util.AddNetworkString("DoNZCounterPreviewChatResponse2")
util.AddNetworkString("DoNZCounterPreviewChatResponse3")
util.AddNetworkString("DoNZCounterPreviewChatResponse4")
util.AddNetworkString("NZCounterSharedVariableForPrint")
util.AddNetworkString("DoNZCounterPosPresetChatResponse1")
util.AddNetworkString("DoNZCounterPosPresetChatResponse2")
util.AddNetworkString("DoNZCounterPosPresetChatResponse3")
util.AddNetworkString("DoNZCounterPosPresetChatResponse4")
util.AddNetworkString("DoNZCounterPosPresetChatResponse5")
util.AddNetworkString("DoNZCounterPosPresetChatResponse6")
util.AddNetworkString("DoNZCounterPositionConfigureChatResponse1")
util.AddNetworkString("DoNZCounterPositionConfigureChatResponse2")
-- I couldn't pass these variables in RunConsoleCommand lines so I networked these as well.
util.AddNetworkString("DoNZCommitBarInnerColorCmd") 
util.AddNetworkString("DoNZCommitBarOuterColorCmd")
util.AddNetworkString("DoNZCommitCounterColorCmd")
util.AddNetworkString("DoNZCommitCustomPositionX")
util.AddNetworkString("DoNZCommitCustomPositionY")
util.AddNetworkString("DoNZCommitFixPosCommand")

local doneprintingotchat = false -- Variable stops printing the same message to chat more than once.

net.Receive("DoNZCommitFixPosCommand", function( len, ply )
	local cmdtoenter = net.ReadInt(32)
	ply:ConCommand("nz_zombiesbarpos "..cmdtoenter)
end)

net.Receive("DoNZCommitBarInnerColorCmd", function( len, ply )
	local cmdtoenter = net.ReadString()
	ply:ConCommand("nz_zombiebarinnercolor "..cmdtoenter)
end)

net.Receive("DoNZCommitBarOuterColorCmd", function( len, ply )
	local cmdtoenter = net.ReadString()
	ply:ConCommand("nz_zombiebaroutercolor "..cmdtoenter)
end)

net.Receive("DoNZCommitCounterColorCmd", function( len, ply )
	local cmdtoenter = net.ReadString()
	ply:ConCommand("nz_zombiecountercolor "..cmdtoenter)
end)

net.Receive("DoNZCommitCustomPositionX", function( len, ply )
	local cmdtoenter = net.ReadInt(32)
	ply:ConCommand("nz_zombiebarcustomposx "..cmdtoenter)
end)
net.Receive("DoNZCommitCustomPositionY", function( len, ply )
	local cmdtoenter = net.ReadInt(32)
	ply:ConCommand("nz_zombiebarcustomposy "..cmdtoenter)
end)

net.Receive("DoNZCounterHideChatResponse1", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("The NZ Progress Bar will now show up again.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)
net.Receive("DoNZCounterHideChatResponse2", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("The NZ Progress Bar will no longer show up.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)

net.Receive("DoNZCounterHideCounterResponse1", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("The NZ Zombie Counter will no longer show up.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)
net.Receive("DoNZCounterHideCounterResponse2", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("The NZ Zombie Counter will now show up again.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)

net.Receive("DoNZCounterPositionProgressInvertChatResponse1", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("The NZ Progress Bar's progression will now appear on the opposite side.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)
net.Receive("DoNZCounterPositionProgressInvertChatResponse2", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("The NZ Progress Bar's progression will now appear normally.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)

net.Receive("DoNZCounterPreviewChatResponse1", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("You are now previewing the NZ Progress Bar.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)
net.Receive("DoNZCounterPreviewChatResponse2", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("You cannot preview the NZ Progress Bar because it is already showing!")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)
net.Receive("DoNZCounterPreviewChatResponse3", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("Preview mode for the NZ Progress Bar has been stopped.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)

net.Receive("DoNZCounterPreviewChatResponse4", function( len, ply )
	if doneprintingotchat == false then -- Variable stops printing the same message to chat more than once.
		ply:ChatPrint("You cannot preview the NZ Progress Bar because it has been set to hidden.")
		doneprintingotchat = true
		timer.Simple(0.1, function()
			doneprintingotchat = false
		end)
	end
end)

net.Receive("NZCounterSharedVariableForPrint", function( len, ply )
	ply:ChatPrint("Custom NZ Progress Bar Scale successfully changed to "..net.ReadInt(32).."!")
end)

net.Receive("DoNZCounterPosPresetChatResponse1", function( len, ply )
	ply:ChatPrint("Successfully set the NZ Progress Bar's position to preset: 'Top middle'")
end)
net.Receive("DoNZCounterPosPresetChatResponse2", function( len, ply )
	ply:ChatPrint("Successfully set the NZ Progress Bar's position to preset: 'Top right'")
end)
net.Receive("DoNZCounterPosPresetChatResponse3", function( len, ply )
	ply:ChatPrint("Successfully set the NZ Progress Bar's position to preset: 'Top left'")
end)
net.Receive("DoNZCounterPosPresetChatResponse4", function( len, ply )
	ply:ChatPrint("Successfully set the NZ Progress Bar's position to preset: 'Bottom middle'")
end)
net.Receive("DoNZCounterPosPresetChatResponse5", function( len, ply )
	ply:ChatPrint("Successfully set the NZ Progress Bar's position to preset: 'Bottom right'")
end)
net.Receive("DoNZCounterPosPresetChatResponse6", function( len, ply )
	ply:ChatPrint("Successfully set the NZ Progress Bar's position to preset: 'Bottom left'")
end)

net.Receive("DoNZCounterPositionConfigureChatResponse1", function( len, ply )
	ply:ChatPrint("NZ Progress Bar Positioning Mode enabled.")
end)
net.Receive("DoNZCounterPositionConfigureChatResponse2", function( len, ply )
	ply:ChatPrint("Custom NZ Progress Bar position successfully set!")
end)
-------------------------------------------------------------------------------------------------------

function SecondGatherTotalnZombies() -- This version of the function runs every time a zombie is killed.
	
	for k,v in pairs(player.GetAll()) do 
		v:ConCommand("nz_totalzombiesbar") 
	end
	
	SetGlobalInt("NZCountKilledZombiesPercentage", nzRound:GetZombiesKilled() / nzRound:GetZombiesMax() * 1) -- Get the percentage of zombies killed for the DProgressBar.
	SetGlobalInt("NZCountKilledZombies", nzRound:GetZombiesKilled())
end

function GatherTotalnZombies() -- This version of the function only runs at the start of a new round.
	for k,v in pairs(player.GetAll()) do 
		v:ConCommand("nz_cleartotalzombiesbar") 
		v:ConCommand("nz_totalzombiesbar") 
	end
	SetGlobalInt("NZCountTotalZombies", nzRound:GetZombiesMax())
	SetGlobalInt("NZCountKilledZombies", 0)
end
hook.Add("OnRoundStart", "NZCountRoundIsBeingPrepared", GatherTotalnZombies)

function NZCounterActivelyChange(zombie, dmginfo)
	if zombie:IsValidZombie() then
		ClearAllPreviousCounterGUIs()
		SecondGatherTotalnZombies()
	end
end
hook.Add("OnZombieKilled", "NZCounterActivelyChange", NZCounterActivelyChange)

AcknowledgedRoundIDLE = false
function ClearAllPreviousCounterGUIs() -- Don't show the progress anymore if the round has ended.
	if nzRound:GetState() == 2.00 then 
		if AcknowledgedRoundIDLE == false then -- When the round is about to start, this function is called several times, so we have to fix the spam.
			SetGlobalInt("NZCountKilledZombies", 0)
			for k,v in pairs(player.GetAll()) do 
				v:ConCommand("nz_resetzombiesbar") 
				AcknowledgedRoundIDLE = true
				timer.Simple(GetConVar("nz_round_prep_time"):GetInt(), function()
					AcknowledgedRoundIDLE = false
				end)
			end
		end 
	end
end
hook.Add("OnRoundPreparation", "NZCountRoundHasEnded", ClearAllPreviousCounterGUIs)

function ClearAllCounterGUIs()
	for k,v in pairs(player.GetAll()) do 
		v:ConCommand("nz_resetzombiesbar") 
	end
	SetGlobalInt("NZCountKilledZombies", 0)
end

function IsTheProgressBarIrrelevantNow() -- Don't show the progress anymore if the game ends.
	if nzRound:InState(ROUND_GO) then
		 ClearAllCounterGUIs()	
	end
end
hook.Add("PlayerDeath", "IsTheProgressBarIrrelevantNowTwo", IsTheProgressBarIrrelevantNow)
hook.Add("OnPlayerDropOut", "IsTheProgressBarIrrelevantNowThree", IsTheProgressBarIrrelevantNow) 
hook.Add("PlayerDisconnected", "IsTheProgressBarIrrelevantNowFour", IsTheProgressBarIrrelevantNow) 

function IsTheProgressBarIrrelevantNowDelayed() -- Don't show the progress anymore if the game ends.
	timer.Simple(0.2, function()
		if nzRound:InState(ROUND_GO) then
			ClearAllCounterGUIs()	
		end
	end)
end
hook.Add("PlayerDowned", "IsTheProgressBarIrrelevantNow", IsTheProgressBarIrrelevantNowDelayed)
hook.Add("OnPlayerDropOut", "IsTheProgressBarIrrelevantNowThree", IsTheProgressBarIrrelevantNowDelayed) 