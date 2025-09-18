-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- src/io/map.lua
-- map display and modification.

local Map = {}

local SECTION1_MAP = [[
+------------------ SECTION 1 ------------------+

                      [Observatory]
                            |
  [Crypt] - [Library] -- [Study]
                |     
                |     (Greenhouse)
                |           |
            [Entrance] - [Garden]
                |
          [Dining Hall]
                |
            [Kitchen] 
                |
       [Servants' Quarters]
        
+-----------------------------------------------+
]]

-- exact tokens in SECTION1_MAP
local TOKENS = {
  entrance           = "[Entrance]",
  library            = "[Library]",
  study              = "[Study]",
  observatory        = "[Observatory]",
  crypt              = "[Crypt]",
  garden             = "[Garden]",
  dining_hall        = "[Dining Hall]",
  kitchen            = "[Kitchen]",
  servants_quarters  = "[Servants' Quarters]",
  greenhouse         = "(Greenhouse)",
}

-- Helpers for Map.render
-- Search map string for location (target), swap with replacement text.
local function replace_first(text, target, replacement)
  local start_idx, end_idx = string.find(text, target, 1, true)
  if not start_idx then return text end
  return text:sub(1, start_idx - 1) .. replacement .. text:sub(end_idx + 1)
end

-- Match spaces for ASCII map consistency.
local function pad_to_width(s, width)
    local padding = width - #s
    return padding > 0 and (s .. string.rep(" ", padding))
end

-- Load map with current location using helpers.
function Map.render(current_room)
    local map = SECTION1_MAP
    local token = TOKENS[current_room]
    if token then 
        local here = "[HERE]"
        local padded = pad_to_width(here, #token)
        map = replace_first(map, token, padded)
    end
    return map
end

return Map