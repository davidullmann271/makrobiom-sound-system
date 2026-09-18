function onValueChanged(valueName)
  if self.values[valueName] == 1 then
    self.parent:findByName("drums_length_select_half").values.x = 0
    self.parent:findByName("drums_length_select_one").values.x = 0
    self.parent:findByName("drums_length_select_two").values.x = 0
    self.parent:findByName("drums_length_select_four").values.x = 0
  end
end