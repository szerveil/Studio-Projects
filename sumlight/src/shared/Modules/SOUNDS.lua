local Sounds = {}

function Sounds.GetSound(Name: string)
	return Sounds[Name]
end

function Sounds.AddSound(Name: string, SoundRefrence: Sound)
	Sounds[Name] = SoundRefrence
	SoundRefrence.Ended:Once(function()
		Sounds[Name] = nil
	end)
end

return Sounds
