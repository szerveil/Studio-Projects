--   MODULE   --
local DIALOGUE = {}
DIALOGUE.__index = DIALOGUE
--   GLOBALS   --
local TWEENSERVICE = game:GetService("TweenService")
local PLAYERS = game:GetService("Players")
local TouchInputService = game:GetService("TouchInputService")
--   TYPES   --
type DIALOGUEOUTLINE = { --         ////     ..DIALOGUEOUTLINE..
	END: string, --                ////     ..REQUIRED..
	TEXTITERATION: number, --     ////     ..REQUIRED..
	DELAY: number, --            ////     ..REQUIRED..
	FADE: FADEOUTLINE?, --      ////     ..OPTIONAL.. IF CHARACTER ITERATED AND NO FADE, REVERSE DIALOGUE
	SOUND: SOUNDFLAGS?, --     ////     ..OPTIONAL.. IF SOUNDFLAGS IS NOT PROVIDED, DEFAULTS
	SIGNAL: any?, --          ////     ..OPTIONAL.. IF SIGNAL GIVEN, SIGNAL FIRED AT END OF CURRENT DIALOGUE ITERATION
}
--     .......     --
type FADEOUTLINE = { --           ////     ..FADEOUTLINE..
	TIME: number, --        ////     ..REQUIRED..
	DELAY: number?, --     ////     ..OPTIONAL.. IF FADE_DELAY IS NOT PROVIDED, DEFAULTS
}
--     .......     --
type DIALOGUESEQUENCEOUTLINE = { --        ////     ..DIALOGUESEQUENCEOUTLINE..
	DIALOGUES: DIALOGUEOUTLINE, --        ////     ..REQUIRED..
	CONTINUOUSDIALOGUE: boolean?, --     ////     ..OPTIONAL..
}
--     .......     --
type DIALOGUEFLAGS = { --                              ////     ..DIALOGUEFLAGS..
	DIALOGUESEQUENCE: DIALOGUESEQUENCEOUTLINE, --     ////     ..REQUIRED..
	TARGET: TextLabel, --                            ////     ..REQUIRED..
}
--     .......     --
type SOUNDFLAGS = { --               ////     ..SOUNDFLAGS..
	RBXASSETID: number?, --         ////     ..OPTIONAL.. IF RBXASSETID IS NOT PROVIDED, DEFAULTS
	LOOPED: boolean?, --           ////     ..OPTIONAL.. IF LOOPED IS NOT PROVIDED, DEFAULTS
	PLAYBACKSPEED: number?, --    ////     ..OPTIONAL.. IF PLAYBACKSPEED IS NOT PROVIDED, DEFAULTS
	VOLUME: number?, --          ////     ..OPTIONAL.. IF VOLUME IS NOT PROVIDED, DEFAULTS
}

--- Constructs a new Dialogue.
-- @constructor DIALOGUE.new()
-- @param DIALOGUE (DIALOGUEFLAGS) Table of DIALOGUE FLAGS
-- @usage DIALOGUE.new({SEQUENCE = {}, TARGET = TextLabel})
-- @example
-- local Dialogue = DIALOGUE.new({
--     DIALOGUESEQUENCE = {
--          {
--                TEXT = "Hello, world!", ITERATION = 0.1, DELAY = 0.5,
--                FADE = { TIME = 1.0, DELAY = 0.2 },
--                SOUND = { RBXASSETID = 123456, LOOPED = false, PLAYBACKSPEED = 1.0, VOLUME = 0.5 },
--                SIGNAL = nil
--          },
--          CONTINUOUSDIALOGUE = true
--     },
--     TARGET = TextLabel,
-- })
function DIALOGUE.new(DIALOGUECONSTRUCTOR: DIALOGUEFLAGS)
	local self = setmetatable({}, DIALOGUECONSTRUCTOR)
	assert(
		self.DIALOGUESEQUENCE or self.PLAYER or self.TARGET,
		string.format(
			"[DialogueModule missing %s]",
			(not self.SEQUENCE and "DIALOGUE.SEQUENCE," or "")
				.. (not self.PLAYER and "DIALOGUE.PLAYER," or "")
				.. (not self.TARGET and "DIALOGUE.TARGET" or "")
		)
	)
	self.SEQUENCE = DIALOGUECONSTRUCTOR.DIALOGUESEQUENCE
	self.TARGET = DIALOGUECONSTRUCTOR.TARGET
	self.PLAYER = PLAYERS.LocalPlayer
	self.CHARACTER = PLAYERS.LocalPlayer.Character or PLAYERS.LocalPlayer.CharacterAdded:Wait()
	self.SOUND = self.SEQUENCE.SOUND and self.SEQUENCE.SOUND or nil
	return DIALOGUE
end

--- Runs SEQUENCE of DIALOGUE Constructor.
-- @treturn nil
-- @usage DIALOGUE:Play() or DIALOGUE.new({SEQUENCE = {}, TARGET = TextLabel}):Play()
function DIALOGUE:Play()
	task.spawn(function()
		local SEQUENCE = self.DIALOGUESEQUENCE
		local TARGET = self.TARGET
		local SOUND: Sound = self.SOUND
			or DIALOGUE:SETSOUND({ RBXASSETID = 17632631801, LOOPED = false, PLAYBACKSPEED = 0.45, VOLUME = 0.5 })
		local NEWDIALOGUE = SEQUENCE.NEWDIALOGUE or false
		local DELAY = SEQUENCE.TEXT.DELAY and task.wait(SEQUENCE.TEXT.DELAY) or false
		local FADE = SEQUENCE.FADE or false

		for DIALOGUE_INDEX, D in SEQUENCE do
			TARGET.Text = (TARGET.Text == "" or NEWDIALOGUE) and "" or TARGET.Text

			for NEXTCHARACTER = TARGET.Text ~= "" and string.len(TARGET.Text) or 1, #D.TEXT.END do
				TARGET.Text = string.sub(D.TEXT, 1, NEXTCHARACTER)
				if SOUND.IsPlaying then
					SOUND:Play()
				end
				task.wait(D.TEXT.ITERATION)

				if TARGET.Text == D.TEXT.END then
					local SIGNAL = SEQUENCE.SIGNAL and SEQUENCE.SIGNAL:Fire() or nil

					self.SOUND = nil
				end
			end

			if DIALOGUE_INDEX == table.maxn(SEQUENCE) then
				self.DIALOGUESEQUENCE = nil
				self.TARGET = nil
				self.SOUND = nil
			else
				if FADE then
					local TWEEN = TWEENSERVICE:Create(
						TARGET,
						TweenInfo.new(
							FADE.FADE_TIME,
							Enum.EasingStyle.Linear,
							Enum.EasingDirection.InOut,
							0,
							false,
							FADE.FADE_DELAY or 0
						),
						{ TextTransparency = 1 }
					)
					TWEEN:Play()
					TWEEN.Completed:Wait()
				else
					for NEXTCHARACTER = #TARGET.Text, 1, -1 do
						TARGET.Text = string.sub(TARGET.Text, 1, NEXTCHARACTER - 1)
						task.wait(D.TEXT.ITERATION)
					end
				end
			end
		end
	end)
end

--- Sets the sound properties for the Dialogue.
-- @param FLAGS (SOUNDFLAGS) Table of sound flags
-- @treturn Sound Instance with updated properties.
-- @usage DIALOGUE:SETSOUND({RBXASSETID = 123456, LOOPED = true, PLAYBACKSPEED = 1.0, VOLUME = 0.5})
-- @note This function should be called after the Dialogue constructor is created.
-- @note If the Dialogue constructor is not created, an assertion error will be raised.
-- @example
-- local dialogue = DIALOGUE.new({SEQUENCE = {}, TARGET = TextLabel})
-- dialogue:SETSOUND({RBXASSETID = 123456, LOOPED = true, PLAYBACKSPEED = 1.0, VOLUME = 0.5})
-- @see DIALOGUE.new
-- @see SOUNDFLAGS
function DIALOGUE:SETSOUND(FLAGS: SOUNDFLAGS)
	assert(self.DIALOGUESEQUENCE, "[DIALOGUE.SETSOUND] NO DIALOGUE CONSTRUCTOR CREATED")
	self.SOUND.SoundId = FLAGS["RBXASSETID"] and "rbxassetid://" .. FLAGS["RBXASSETID"] or self.SOUND.SoundId
	self.SOUND.Looped = FLAGS["LOOPED"] or self.SOUND.Looped
	self.SOUND.PlaybackSpeed = FLAGS["PLAYBACKSPEED"] or self.SOUND.PlaybackSpeed
	self.SOUND.Volume = FLAGS["VOLUME"] or self.SOUND.Volume
	return self.SOUND
end

return DIALOGUE
