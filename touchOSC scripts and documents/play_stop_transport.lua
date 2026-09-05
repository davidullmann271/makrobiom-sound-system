-- updated for v11

function onValueChanged(valueName)
  local value = self.values[valueName]

  -- Only react to finger-down, ignore x/y/release changes.
  if valueName == 'touch' and value == true then
    root:notify('transport_button_pressed')
  end

  return true
end