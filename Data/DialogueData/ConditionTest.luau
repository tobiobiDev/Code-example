--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientDataService = require(ReplicatedStorage.Source.PlayerData.ClientDataService)
local Types = require(ReplicatedStorage.Source.Types.DialogueSystemTypes)

local Conversation: Types.ConversationData = nil :: any

Conversation = {
	Id = "ConditionTest",
	StartNode = "intro",
	Nodes = {
		intro = {
			Speaker = "System",
			Text = "Welcome to the Condition Test. Do you have the secret item?",
			Choices = {
				{
					Id = "secret_success",
					Text = "Yes, I have it (Cheat)",
					Condition = function(_context: Types.DialogueContext?)
						local profile = ClientDataService.GetProfile()
						return if profile and profile.HasSecret == false then true else false
					end,
				},
				{
					Id = "secret_no",
					Text = "No, I don't.",
				},
				{
					Id = "auto_node",
					Text = `Auto-check secret.`,
				},
				{
					Id = "end",
					Text = "Goodbye. (End choice)",
					End = true,
				},
			},
		},
		auto_node = {
			-- This node has no text/choices, so it will auto-advance to Next or Fallback
			Condition = function(_context: Types.DialogueContext?)
				local profile = ClientDataService.GetProfile()
				local hasSecret = if profile and profile.HasSecret == true then true else false
				Conversation.Nodes.secret_fail.Text = `Liars and weaklings are not welcome here: ({hasSecret})`
				Conversation.Nodes.secret_success.Text = `Wow, you actually have it ({hasSecret})! You pass.`
				return hasSecret
			end,
			Fallback = "secret_fail",
			Next = "secret_success",
		},
		secret_success = {
			Speaker = "System",
			Text = "",
			Next = "bye",
		},
		secret_fail = {
			Speaker = "System",
			Text = "",
			Next = "bye",
		},
		secret_no = {
			Speaker = "System",
			Text = "Well, get it and then we can talk.",
			Next = "bye",
		},
		bye = {
			End = true,
		},
	},
}

return Conversation
