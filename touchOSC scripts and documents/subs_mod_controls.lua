function onValueChanged(key)
  if key ~= 'x' then return end
  local v = self.values.x

  local tri  = 1 - math.abs(v * 2 - 1)   -- 0 → 127 → 0
  local ramp = math.max(0, v * 2 - 1)    -- 0 →   0 → 127

  sendMIDI({ MIDIMessageType.CONTROLCHANGE + 1, 20, math.floor(tri  * 127 + 0.5) })
  sendMIDI({ MIDIMessageType.CONTROLCHANGE + 1, 88, math.floor(ramp * 127 + 0.5) })
end