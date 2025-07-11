local TTS = {}

local TextToSpeech = workspace:WaitForChild("AudioTextToSpeech")

function TTS.play(Text: string, Pitch: number?, Speed: number?, VoiceID: number?, SignalInstance: any?)
	assert(Text, "[TTSModule text argument not provided]")

	TextToSpeech.Pitch = Pitch ~= nil and Pitch or TextToSpeech.Pitch
	TextToSpeech.Speed = Speed ~= nil and Speed or TextToSpeech.Speed
	TextToSpeech.VoiceId = VoiceID ~= nil and VoiceID or TextToSpeech.VoiceId

	TextToSpeech.Text = Text
	TextToSpeech:Play()

	TextToSpeech.Ended:Connect(function()
		if SignalInstance then
			SignalInstance:Fire()
		end
	end)
end

function TTS.stop()
	TextToSpeech:Stop()
end

function TTS:AdjustSpeed(Speed: number)
	assert(Speed, "[TTSModule speed argument not provided]")

	TextToSpeech.Speed = Speed
end

return TTS
