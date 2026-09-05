-- Root container script

local multiplier = 0.003

-- Variables to store the previous pointer positions
local lastX = nil
local lastY = nil
local radial = nil  -- Reference to the radial object

function init()
    self.interactive = true  -- Make the container interactive
    self.grabFocus = true    -- Retain focus even when pointer moves outside bounds

    -- Find the radial child by type or name
    radial = self:findByType(ControlType.RADIAL, true)  -- Recursive search for radial control
    if not radial then
        error("Radial object not found as a child!")
    end
end

function onPointer(pointers)
    if #pointers > 0 then
        local pointer = pointers[1]  -- Get the first pointer
        local currentX, currentY = pointer.x, pointer.y  -- Current pointer position

        -- Reinitialize on every new touch event
        if pointer.state == PointerState.BEGIN then
            lastX = currentX
            lastY = currentY
            print("New touch detected, reinitializing pointer.")
            return  -- Avoid calculating deltas on the first touch
        end

        -- Calculate deltas only if there is actual movement
        local dx = currentX - lastX
        local dy = -currentY + lastY  -- Reverse Y so up is positive

        -- Calculate the single delta as the sum of dx and dy
        local delta = (dx + dy) * multiplier  -- Multiply delta by 0.003

        -- Adjust the X value of the radial
        radial.values.x = math.clamp(radial.values.x + delta, 0, 1)

        -- Print the updated X value
        print(string.format("Radial X updated to: %f", radial.values.x))

        -- Update last known positions
        lastX, lastY = currentX, currentY
    end
end