Sound = Object:extend()

function Sound:new(audio, volume, timer, scale)
    self.volume = volume or 1
    self.scale = scale or 1
    self.volume = self.scale * self.volume
    self.timer = timer
    self.audio = {}
    for name, audio in pairs(audio) do
        self.audio[name] = {sound = audio, volume = self.volume, volume_percentage = 1, delay = 0.01, timer = 0.3}
        self.audio[name].sound:setVolume(self.audio[name].volume)
    end
end

function Sound:play(name, range, pitch, delay)
    if self.audio[name].timer <= 0 or (not self.timer) then
        range = range or 0.05
        pitch = pitch or random_float(1-range, 1+range)
        self.audio[name].sound:stop()
        self.audio[name].sound:setVolume(self.audio[name].volume)
        self.audio[name].sound:setPitch(1)
        self.audio[name].sound:setPitch(pitch)
        self.audio[name].sound:play()
        self.audio[name].timer = delay or self.audio[name].delay
    end
end

function Sound:fade_out(name, dur, after)
    if round(self.audio[name].volume_percentage) == 0 then return end
    self.audio[name].fade = dur
    self.audio[name].dir = 'out'
    self.audio[name].fade_length = dur
    self.audio[name].after = after
end

function Sound:fade_in(name, dur, after)
    if round(self.audio[name].volume_percentage) == 1 then return end
    self.audio[name].fade = dur
    self.audio[name].dir = 'in'
    self.audio[name].fade_length = dur
    self.audio[name].after = after
end

function Sound:set_volume(vol)
    self.volume = vol * self.scale
    for name, audio in pairs(self.audio) do
        audio.volume = self.volume
        audio.sound:setVolume(audio.volume_percentage * self.volume)
    end
end

function Sound:stop(name)
    if name == nil then
        for _, audio in pairs(self.audio) do
            audio.sound:stop()
        end
    else
        self.audio[name].sound:stop()
    end
end

function Sound:loop(name, val)
    self.audio[name].sound:setLooping(val or true)
end

function Sound:set_soundtrack()
    for name, audio in pairs(self.audio) do
        audio.volume_percentage = 0
        audio.sound:setVolume(audio.volume * audio.volume_percentage)
        audio.sound:play()
        audio.sound:setLooping(true)
    end
end

function Sound:play_soundtrack(name)
    for n, _ in pairs(self.audio) do
        if n ~= name then
            self:fade_out(n, 1)
        end
    end
    self:fade_in(name, 0.5)
end

function Sound:update(dt)
    for _, audio in pairs(self.audio) do
        audio.timer = audio.timer - dt

        if audio.fade then
            audio.fade = audio.fade - dt
            if audio.dir == 'out' then
                audio.volume_percentage = audio.fade/audio.fade_length
            elseif audio.dir == 'in' then
                audio.volume_percentage = 1 - audio.fade/audio.fade_length
            end
            if audio.fade <= 0 then
                audio.fade = nil
                call(audio.after)
            end
        end

        audio.sound:setVolume(audio.volume * audio.volume_percentage)
    end
end