-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- world.lua
-- Star puzzle initialization 

local World = { 
    -- For testing
    -- sq_code = "5732", 
    -- sq_hint_seen = false 
    sq_code = nil, -- actual code for lockbox
    sq_hint_seen = false, -- telescope/star charts in observatory
    constellations = nil, -- map glyph -> star count
    ring_seen = false -- for puzzle order
}

local function initStarPuzzle()
    math.randomseed(os.time())
  
    -- The ring order shown in the Crypt – the order for the code.
    local ring = {"◇","✶","☾","♄"}
  
    -- Random star counts (2 .. 9) for each constellation
    local counts = {}
    for _, glyph in ipairs(ring) do
        counts[glyph] = math.random(2, 9)
    end
  
    -- Build the four digit code by crypt ring order
    local code = ""
    for _, glyph in ipairs(ring) do
        code = code .. tostring(counts[glyph])
    end
  
    World.constellations = counts -- stars per constellation
    World.sq_code = code -- four-digit code derived from counts
end
  
initStarPuzzle()
return World