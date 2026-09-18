local CLOCKS_PER_BEAT = 24

local beatNames = {
  'beat_ul',
  'beat_ur',
  'beat_rt',
  'beat_rb',
  'beat_br',
  'beat_bl',
  'beat_lb',
  'beat_lt'
}

local lights = {}
local transportButton = nil

local beatClocks = 0
local step = 1
local isPlaying = false

local idlePhase = 0
local idleSpeed = 0.035
local lastUpdateSeconds = nil

local black = Color(0, 0, 0)
local white = Color(1, 1, 1)
local green = Color(0, 1, 0)
local red = Color(1, 0, 0)

local dayNightStops = {
  { 0.4000, 0.5882, 0.7294 },
  { 0.4000, 0.5882, 0.7294 },
  { 0.4000, 0.5882, 0.7294 },
  { 0.4000, 0.5882, 0.7294 },
  { 0.8863, 0.8902, 0.5451 },
  { 0.9059, 0.6471, 0.3255 },
  { 0.4941, 0.2941, 0.4078 },
  { 0.1608, 0.1608, 0.3961 },
  { 0.1608, 0.1608, 0.3961 },
  { 0.1608, 0.1608, 0.3961 },
  { 0.1608, 0.1608, 0.3961 },
  { 0.4941, 0.2941, 0.4078 },
  { 0.9059, 0.6471, 0.3255 },
  { 0.8863, 0.8902, 0.5451 },
  { 0.4000, 0.5882, 0.7294 },
  { 0.4000, 0.5882, 0.7294 },
  { 0.4000, 0.5882, 0.7294 },
  { 0.4000, 0.5882, 0.7294 }
}

local MIDI_CC_CHANNEL_9 = 0xB8

local START_CC = 0
local STOP_CC = 1

local MT = MIDIMessageType or {}
local SHAPE = Shape or {}

local MIDI_CLOCK = 248
local MIDI_START = 250
local MIDI_CONTINUE = 251
local MIDI_STOP = 252
local MIDI_SONGPOSITION = 242


local function clamp(value)
  if value < 0 then
    return 0
  end

  if value > 1 then
    return 1
  end

  return value
end


local function nowSeconds()
  if getMillis then
    return getMillis() / 1000
  end

  return nil
end


local function isMessage(message, rawByte, enumValue)
  return message[1] == rawByte or message[1] == enumValue
end


local function lerp(a, b, t)
  return a + (b - a) * t
end


local function dayNightColor(position)
  local segmentCount = #dayNightStops - 1
  local scaled = (position % 1) * segmentCount
  local index = math.floor(scaled) + 1
  local t = scaled - math.floor(scaled)

  if index > segmentCount then
    index = segmentCount
    t = 1
  end

  local a = dayNightStops[index]
  local b = dayNightStops[index + 1]

  return Color(
    lerp(a[1], b[1], t),
    lerp(a[2], b[2], t),
    lerp(a[3], b[3], t)
  )
end


local function setLight(i, color)
  if lights[i] then
    lights[i].visible = true
    lights[i].background = true
    lights[i].outline = false
    lights[i].color = color
  end
end


local function showIdleSpectrum()
  for i = 1, #beatNames do
    local position = (i - 1) / #beatNames
    local cyclePosition = (position + idlePhase) % 1

    setLight(i, dayNightColor(cyclePosition))
  end
end


local function showStep()
  for i = 1, #beatNames do
    setLight(i, (i == step) and white or black)
  end
end


local function advanceStep()
  step = step + 1

  if step > #beatNames then
    step = 1
  end

  showStep()
end


local function setTransportButtonState()
  if transportButton then
    transportButton.color = isPlaying and red or green

    if SHAPE.RECTANGLE and SHAPE.TRIANGLE then
      transportButton.shape =
        isPlaying and SHAPE.RECTANGLE or SHAPE.TRIANGLE
    end
  end
end


local function sendMomentaryCC(cc)
  sendMIDI({ MIDI_CC_CHANNEL_9, cc, 127 })
  sendMIDI({ MIDI_CC_CHANNEL_9, cc, 0 })
end


local function sendTransportCC(cc)
  sendMomentaryCC(cc)
end


local function alignToSongPosition(message)
  local lsb = message[2] or 0
  local msb = message[3] or 0

  local sixteenthNotes = lsb + msb * 128
  local quarterNotes = math.floor(sixteenthNotes / 4)

  beatClocks = 0
  step = (quarterNotes % #beatNames) + 1
end


function init()
  lights = {}

  for i = 1, #beatNames do
    lights[i] = self:findByName(beatNames[i], true)

    if not lights[i] then
      print('MISSING', beatNames[i])
    end
  end

  transportButton = self:findByName('transport_btn', true)

  if not transportButton then
    print('MISSING transport_btn')
  end

  isPlaying = false
  beatClocks = 0
  step = 1
  lastUpdateSeconds = nowSeconds()

  setTransportButtonState()
  showIdleSpectrum()
end


function update()
  if isPlaying then
    return
  end

  local now = nowSeconds()
  local dt = 0.016

  if now then
    if lastUpdateSeconds then
      dt = now - lastUpdateSeconds
    end

    lastUpdateSeconds = now
  end

  idlePhase = (idlePhase + idleSpeed * dt) % 1

  showIdleSpectrum()
end


function onReceiveMIDI(message, connections)

  if isMessage(message, MIDI_START, MT.START) then
    isPlaying = true
    beatClocks = 0
    step = 1

    setTransportButtonState()
    showStep()

    return
  end


  if isMessage(message, MIDI_CONTINUE, MT.CONTINUE) then
    isPlaying = true

    setTransportButtonState()
    showStep()

    return
  end


  if isMessage(message, MIDI_STOP, MT.STOP) then
    isPlaying = false
    beatClocks = 0
    step = 1

    setTransportButtonState()
    showIdleSpectrum()

    return
  end


  if isMessage(message, MIDI_SONGPOSITION, MT.SONGPOSITION) then
    alignToSongPosition(message)

    if isPlaying then
      showStep()
    end

    return
  end


  if isMessage(message, MIDI_CLOCK, MT.CLOCK) and isPlaying then
    beatClocks = beatClocks + 1

    if beatClocks >= CLOCKS_PER_BEAT then
      beatClocks = 0
      advanceStep()
    end
  end
end


function onReceiveNotify(key, value)
  if key == 'transport_button_pressed' then

    if isPlaying then
      sendTransportCC(STOP_CC)
    else
      sendTransportCC(START_CC)
    end

    return
  end
end