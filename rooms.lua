-- Copyright (c) 2025 Hadi Rana. All rights reserved.

-- rooms.lua
-- mini database, moving, searching functions. 

local Inventory = require("inventory")
local Items = require("items")
local C = require("color")

local Rooms = {}

-- ===========
-- Constellation puzzle data
Rooms.world = { 
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
  
    Rooms.world.constellations = counts -- stars per constellation
    Rooms.world.sq_code = code -- four-digit code derived from counts
end
  
initStarPuzzle()
-- ===========

-- All rooms (Room Data)
Rooms.data = {
    ["entrance"] = {
        name = "Entrance Hall",
        description = "A dimly lit hall with cold stone walls and an ornate wooden door to the north. A cracked painting hangs crookedly, its surface barely visible through layers of dust. A small pedestal stands in the center, waiting for something to be placed upon it.",
        exits = { north = "library" , east = "garden", south = "dining_hall"}, -- directions
        searched = false, -- for 'search' to find any items in 'items'
        items = {"map"}, -- items privy to this room.
        section = 1, -- if more floors are added; memory clearing ideally.
        actions = { -- contextual actions
            ["examine painting"] = function() 
                return "The cracked painting shows a family of three. Their faces are faded, but their eyes... they seem to follow you." 
            end, 
            ["inspect pedestal"] = function() 
                return "The pedestal has a small indentation. It looks like it was made for a particular object. And that object is in shambles across the floor." 
            end
        }
    },
    ["library"] = {
        name = "Ancient Library",
        description = "Rows of dusty shelves stretch high above, filled with brittle, unreadable tomes. A faint smell of parchment lingers, and one book seems newer than the rest, jutting out unnaturally.",
        exits = { south = "entrance", east = "study", west = "crypt"},
        searched = false,
        items = {}, 
        section = 1,
        state = {niche_opened = false}, -- for logical progression checks
        actions = {
            ["pull book"] = function(room) 
                    if not room.state.niche_opened then
                        room.state.niche_opened = true
                        local Inventory = require("inventory")
                        Inventory.add("observatory_key")
                        return "You pull the newer book. A panel slides open with a click—inside, an intricate key glints. (You take the Observatory Key.)"
                    else
                        return "The niche is already open; its contents long taken."
                    end
                end, 
            ["examine shelves"] = function() 
                return "Dusty tomes crumble to touch, but one book seems newer, its leather cover unmarked by time." 
            end
        }
    },
    ["study"] = {
        name = "Secret Study",
        description = "A cramped study with an old desk. On the desk lies a closed journal with a broken lock, and faint scratch marks line the floor beneath.",
        exits = { west = "library", north = "observatory"},
        searched = false,
        items = {}, 
        section = 1, 
        state = {rug_moved = false, trapdoor_revealed = false, journal_read = false, study_dusted = false},
        actions = {
            ["read journal"] = function(room)
                room.state.journal_read = true
                return "The journal rambles about nights spent charting ◇, ✶, ☾, ♄... 'Begin where light is sharpest, end where time is slowest.'"
            end, 
            ["dust study"] = function(room)
                local Inventory = require("inventory")
                if not Inventory.has("todo_list") then
                    return "Why dust now? You don't feel particularly compelled."
                end
                if room.state.study_dusted then
                    return "The study is as clean as it’s going to get."
                end
                room.state.study_dusted = true
                return "You sweep dust along the desk’s edge. Scratch marks line up where the rug bunches—something’s hidden under it."
            end,
            ["move rug"] = function(room) -- Available 'once unlocked'.
                if not room.state.study_dusted then
                    return "You don't know there's something under the rug yet."
                end
                if room.state.trapdoor_revealed then
                    return "The trapdoor is already exposed."
                end
                room.state.trapdoor_revealed = true
                return "You move the rug, revealing a trapdoor!"
            end,
            ["descend"] = function(room)
                if not room.state.trapdoor_revealed then
                    return "You don't see a way down."
                end
                local Inventory = require("inventory")
                if not Inventory.has("trapdoor_key") then
                    return "The trapdoor is locked tight."
                end
                local has_light = Inventory.has("candle") or Inventory.has("lantern") -- lantern in case they come back up in the future.
                if not has_light then
                    return "It’s pitch black below. You’ll need a light source."
                end
                if not Inventory.has("rope") then
                    return "It’s too far to drop safely. You’ll need a rope."
                end
                -- End the game
                return "[END] You tie off the rope, light your way, and descend into the dark below...\nAs the trapdoor closes overhead, a cold wind rises. To be continued."
            end
        } 
    },
    ["garden"] = {
        name = "Overgrown Garden",
        description = "The garden is choked with tall grass and creeping vines. A stone path leads north to a locked greenhouse door, and a half-buried statue leans to one side.",
        exits = { west = "entrance", north = "greenhouse" },
        searched = false,
        items = {},
        section = 1, 
        state = {soil_dug = false, soil_spotted = false},
        actions = {
            ["examine statue"] = function() 
                return "The statue depicts a robed figure holding a bowl. There’s a faint inscription: 'Feed the earth, reap the sky'." 
            end, 
            ["dig grass"] = function(room)
                room.state = room.state or {}
                if room.state.soil_dug then
                    return "The disturbed patch of earth has already been dug up."
                end
                local Inventory = require("inventory")
                if not room.state.soil_spotted then
                    return "You don’t see a good place to dig yet."
                end
                if not Inventory.has("trowel") then
                    return "You need a small hand tool to dig here."
                end
                room.state.soil_dug = true
                Inventory.add("rope")
                return "You dig into the disturbed soil and uncover a folded scrap of paper. (You take the Rope.)"
            end,            
            ["search grass"] = function(room)
                room.state = room.state or {}
                if room.state.soil_dug then 
                    return "The disturbed patch of earth has already been dug up."
                end
                room.state.soil_spotted = true
                return "You find a patch of disturbed soil. A hand tool would make quick work of this..."
            end
        }
    },
    ["greenhouse"] = {
        name = "Glass Greenhouse",
        description = "A shattered dome lets in slivers of gray light. Strange vines twitch as if sensing your presence, and an overturned pot glistens with damp soil.",
        exits = { south = "garden" },
        searched = false,
        items = {},
        locked = true,
        section = 1, 
        state = {vines_cut = false, trowel_taken = false, vines_seen = false},
        actions = {
            ["inspect pot"] = function(room) 
                room.state = room.state or {}
                if not room.state.trowel_taken then
                    room.state.trowel_taken = true
                    local Inventory = require("inventory")
                    Inventory.add("trowel")
                    return "The overturned pot spills dark soil across the floor. Something metallic glints faintly inside. (You take the Trowel.)" 
                else
                    return "You've already inspected the pot; its contents long taken."
                end
            end, 
            ["examine vines"] = function(room) 
                room.state = room.state or {}
                room.state.vines_seen = true
                if room.state.vines_cut then
                    return "The severed vines lay still, oozing sap that smells like copper."
                else
                    return "The vines shiver when you draw near, like they can sense your warmth. A blade might help..."
                end 
            end,
            ["cut vines"] = function(room)
                room.state = room.state or {}
                if room.state.vines_cut then 
                    return "You've already cut through the vines."
                end
                local Inventory = require("inventory")
                if not Inventory.has("knife") then
                    return "You could probably do that with a sharp blade..."
                end
                room.state.vines_cut = true
                Inventory.add("trapdoor_key")
                return "You hack through the living tangle. Something clatters free and hits your boot. (You take the Trapdoor Key.)"
            end
        }
    },
    ["crypt"] = {
        name = "Ancient Crypt",
        description = "The air is freezing and reeks of damp earth. An ornate coffin rests at the center, carved with symbols you can’t understand. Something rattles faintly in the darkness.",
        exits = { east = "library" },
        searched = false,
        items = {},
        section = 1,
        state = {coffin_examined = false, symbols_seen = false, fire_poker_taken = false},
        actions = {
            ["inspect coffin"] = function(room) 
                room.state.coffin_examined = true
                return "The coffin's carvings are intricate, but one panel looks looser than the rest—as though it can be pried." 
            end, 
            ["examine symbols"] = function(room) 
                room.state.symbols_seen = true
                Rooms.world.ring_seen = true  -- for star puzzle.
                return "You trace four glyphs arranged in a ring: ◇, ✶, ☾, ♄. They feel like an order, not decoration."
            end,
            ["pry coffin panel"] = function(room)
                if not room.state.coffin_examined then
                    return "You don’t yet see a place that looks like it could be pried."
                end
                local Inventory = require("inventory")
                if not Inventory.has("knife") then
                    return "You need a thin, sturdy edge—your fingers won’t do. A blade, perhaps."
                end
                if room.state.fire_poker_taken then
                    return "The panel is already open; the compartment within is empty."
                end
                room.state.fire_poker_taken = true
                Inventory.add("fire_poker")
                return "You work the blade under the loose seam. With a crack, the panel gives. Inside lies a long iron poker. (You take the Fire Poker.)"
            end
        }
    },
    ["dining_hall"] = {
        name = "Dining Hall",
        description = "A long wooden table stretches the length of the room, covered in tarnished silverware and plates caked with dust. A grand chandelier hangs precariously above.",
        exits = { north = "entrance", south = "kitchen" },
        searched = false,
        items = {"servants_key"},
        section = 1,
        state = {chandelier_examined = false, chandelier_dropped = false, table_dusted = false, key_taken = false},
        actions = {
            ["examine chandelier"] = function(room) 
                room.state = room.state or {}
                room.state.chandelier_examined = true
                return "The chandelier hangs precariously, its crystals covered in dust. One loose chain might drop it at any moment." 
            end, 
            ["dust table"] = function(room)
                local Inventory = require("inventory")
                if not Inventory.has("todo_list") then
                    return "You brush at the dust... why are you doing this again?"
                end
                room.state = room.state or {}
                if room.state.table_dusted then
                    return "The table is already dusted."
                end
                room.state.table_dusted = true
                -- reveal the key directly
                if not room.state.key_taken then
                    room.state.key_taken = true
                    Inventory.add("servants_key")
                    return "Dust plumes from under the plates. Taped beneath the tabletop edge, your hand finds cold iron. (You take the Servants’ Quarters Key.)"
                end
                return "You finish dusting. Nothing else turns up."
            end,
            ["search table"] = function() 
                return "The table is covered in a disarray of plates, cutlery, and lots of dust." 
            end,
            ["drop chandelier"] = function(room)
                room.state = room.state or {}
                if room.state.chandelier_dropped then
                    return "The chandelier has already been dropped."
                end
                local Inventory = require("inventory")
                if not Inventory.has("fire_poker") then
                    return "You can’t safely reach the loose chain. A long tool might help."
                end
                room.state.chandelier_dropped = true
                Inventory.add("candle")
                return "You hook the chain with the fire poker. With a thunderous crash, the chandelier falls, scattering wax stubs.\nYou pocket a usable candle."
            end
        }
    },
    ["kitchen"] = {
        name = "Kitchen",
        description = "Rusted pots sway from hooks, and shattered jars litter the floor. A faint smell of herbs lingers, and a large pantry door sits ajar to the side.",
        exits = { north = "dining_hall", south = "servants_quarters" },
        searched = false,
        items = { "knife" },
        section = 1,
        state = { pantry_examined = false, drawer_taken = false },
        actions = {
            ["examine pantry"] = function(room) 
                room.state = room.state or {}
                room.state.pantry_examined = true
                return "The pantry is empty except for a small drawer that looks like it hasn't been opened in years." 
            end, 
            ["search drawer"] = function(room)
                room.state = room.state or {}
                if not room.state.pantry_examined then
                    return "Which drawer? You should examine the pantry first."
                end
                if room.state.drawer_taken then
                    return "The drawer is empty now."
                end
                room.state.drawer_taken = true
                local Inventory = require("inventory")
                Inventory.add("todo_list")
                return "Inside the stiff old drawer you find a crumpled note. (You take the Servants' To-Do List.)"
            end,
            ["search jars"] = function() 
                return "Most jars are broken and empty; the rest are spoiled and useless." 
            end
        }
    },
    ["servants_quarters"] = {
        name = "Servants' Quarters",
        description = "Narrow beds line the walls, each covered in sheets yellowed with age. One bed has a lump beneath the blanket that seems... oddly shaped.",
        exits = { north = "kitchen" },
        searched = false,
        items = {},
        locked = true,
        section = 1,
        state = { box_opened = false, box_seen = false },
        actions = {
            ["lift blanket"] = function(room) 
                room.state.box_seen = true
                return "Under the blanket: a wooden lockbox etched with tiny celestial marks."
            end,
            ["open box"] = function(room)
                if room.state.box_opened then
                    return "The lockbox is open; its secret already taken."
                end
                return "The lock resists simple force. A 4-digit code might open it. (Try: enter code ####)"
            end
        }
    },
    ["observatory"] = {
        name = "Observatory",
        description = "The cracked glass dome reveals a dim, swirling sky. A massive telescope points toward nothing in particular, and scattered star charts are strewn across the floor.",
        exits = { south = "study" },
        searched = false,
        items = {},
        locked = true,
        section = 1,
        state = { telescope_checked = false, charts_studied = false },
        actions = {
            ["examine telescope"] = function(room) 
                room.state.telescope_checked = true
                if room.state.charts_studied then Rooms.world.sq_hint_seen = true end

                local c = Rooms.world.constellations or {}
                -- fallbacks in case something odd happens
                local d  = c["◇"] or 4
                local st = c["✶"] or 5
                local m  = c["☾"] or 3
                local s  = c["♄"] or 6

                return ("Through the scope, four figures resolve:\n" ..
                        "☾ glows with %d; ♄ is ringed by %d; ◇ shows %d sharp points; ✶ burns with %d."):format(m, s, d, st)
            end, 
            ["inspect star charts"] = function(room) 
                room.state.charts_studied = true
                if room.state.telescope_checked then Rooms.world.sq_hint_seen = true end
                return "A marginal note: 'Count the points that burn in each. Order per the crypt’s ring.'"
            end
        }
    }    
}

-- Functions (Room Functions)

-- Get room description
function Rooms.describe(room_id)
    local room = Rooms.data[room_id]

    local title = C.paint(C.paint(room.name, "bold"), "yellow")
    local desc  = C.paint(room.description, "bold")

    if room then
        return title .. "\n" .. desc
    else
        return "You see nothing but darkness."
    end
end

-- Move to another room (returns next room ID if valid)
function Rooms.move(current_room, direction)
    local room = Rooms.data[current_room]
    if room and room.exits[direction] then
        local destination = room.exits[direction]
        if Rooms.data[destination].locked then
            return nil, "The door is locked."
        end
        return destination
    else
        return nil -- invalid move
    end
end

-- Search a room (could trigger items later)
function Rooms.search(room_id)
    local room = Rooms.data[room_id]
    if not room then return "You can't search here." end

    if room.searched then
        return "You've already searched this room."
    else
        -- Searches if condition is right based on items in room. 
        -- could add RNG in future? Not needed for puzzle game.
        room.searched = true
        if #room.items > 0 then
            local item_id = table.remove(room.items, 1) -- get first item.
            Inventory.add(item_id)
            return "You searched the room and found a " .. item_id .. "!"
        else
            return "You search the room but find nothing of interest... yet."
        end
    end
end

-- Showing only available exits.
function Rooms.getAvailableExits(room_id)
    local room = Rooms.data[room_id]
    if not room then return {} end
    local available = {}
    for direction, destination in pairs(room.exits) do
        if Rooms.data[destination].locked then
            table.insert(available, direction .. " (locked)")
        else
            table.insert(available, direction)
        end
    end
    return available
end

-- Using keys for doors or items.
function Rooms.unlock(room_id)
    if Rooms.data[room_id] then
        Rooms.data[room_id].locked = false
        return room_id .. " has been unlocked."
    else
        return "There is nothing to unlock here."
    end
end

-- Will show actions privy to a room
function Rooms.getAvailableActions(room_id)
    local room = Rooms.data[room_id]
    if not room or not room.actions then return {} end

    local available = {}
    for name, _ in pairs(room.actions) do
        if Rooms.canShowAction(room, name) then
            table.insert(available, name)
        end
    end
    return available
end


-- To interact with a displayed action.
function Rooms.performAction(room_id, action)
    local room = Rooms.data[room_id]
    if not room or not room.actions then
        return "There is nothing special to do here."
    end
    -- Check for exact action
    if room.actions[action] then
        if type(room.actions[action]) == "function" then
            return room.actions[action](room) -- will return the function contents not 0x... (the function itself)
        else
            return room.actions[action] -- any other static case where it's not in a function.
        end
    else
        return "You can't do that here."
    end
end

-- Helper function to see actions based on state in Rooms.data
function Rooms.canShowAction(room, action_name)
    -- Default: show unless conditions hide it

    -- Study Trapdoor
    if room.name == "Secret Study" and action_name == "move rug" then
        room.state = room.state or {}
        return room.state.study_dusted and not room.state.trapdoor_revealed
    end
    -- Greenhouse 'cut' if knife in inventory and uncut
    if room.name == "Glass Greenhouse" and action_name == "cut vines" then
        local Inventory = require("inventory")
        room.state = room.state or {}
        return room.state.vines_seen and (not room.state.vines_cut) and Inventory.has("knife")
    end
    -- Only shows descend when trapdoor is revealed.
    if room.name == "Secret Study" and action_name == "descend" then
        return room.state and room.state.trapdoor_revealed == true
    end
    -- Only shows "dust study" if you have the list and it's not done
    if room.name == "Secret Study" and action_name == "dust study" then
        local Inventory = require("inventory")
        room.state = room.state or {}
        return Inventory.has("todo_list") and not room.state.study_dusted
    end
    -- For Crypt coffin prying after examining coffin.
    if room.name == "Ancient Crypt" and action_name == "pry coffin panel" then
        local Inventory = require("inventory")
        room.state = room.state or {}
        return room.state.coffin_examined == true and Inventory.has("knife")
    end
    -- Open Servants' Quarters lockbox only when lifting blanket.
    if room.name == "Servants' Quarters" and action_name == "open box" then
        return room.state and room.state.box_seen == true
    end
    -- Examine Chandelier in Dining Hall.
    if room.name == "Dining Hall" and action_name == "drop chandelier" then
        local Inventory = require("inventory")
        room.state = room.state or {}
        return room.state.chandelier_examined and not room.state.chandelier_dropped and Inventory.has("fire_poker")
    end
    -- Search pantry in Kitchen before searching drawer.
    if room.name == "Kitchen" and action_name == "search drawer" then
        room.state = room.state or {}
        return room.state.pantry_examined and not room.state.drawer_taken
    end
    -- Show "dust table" in Dining Hall only if you have the to-do list and haven’t dusted yet
    if room.name == "Dining Hall" and action_name == "dust table" then
        local Inventory = require("inventory")
        room.state = room.state or {}
        return Inventory.has("todo_list") and not room.state.table_dusted
    end
    -- Show "dig grass" in Garden after spotting the soil and if you have the trowel
    if room.name == "Overgrown Garden" and action_name == "dig grass" then
        local Inventory = require("inventory")
        room.state = room.state or {}
        return room.state.soil_spotted and (not room.state.soil_dug) and Inventory.has("trowel")
    end

    
    -- Add more conditions per room/action as needed
    return true
end

-- Handle Servants' Quarters pin code.
function Rooms.trySQCode(code)
    local sq = Rooms.data["servants_quarters"]
    if not sq or not Rooms.world.sq_code then
        return "The mechanism doesn’t respond."
    end
    if sq.state and sq.state.box_opened then
        return "The lockbox is already open."
    end
    if not (Rooms.world.sq_hint_seen and Rooms.world.ring_seen) then
        return "You don’t yet understand the order of the figures. Study the sky and the carved ring first."
    end
    if tostring(code) == tostring(Rooms.world.sq_code) then
        sq.state = sq.state or {}
        sq.state.box_opened = true
        local Inventory = require("inventory")
        Inventory.add("greenhouse_key")
        return "The tumblers click in sequence. The lid lifts and reveals a small brass key with a floral engraving. (You take the Greenhouse Key.)"
    else
        return "The code is wrong. The lock resets with a soft click."
    end
end

return Rooms