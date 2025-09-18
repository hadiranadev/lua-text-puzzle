-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- src/main.lua

local Player = require("src.game.player")
local Rooms = require("src.game.rooms")
local Utils = require("src.game.utils")
local Inventory = require("src.game.inventory")
local Items = require("src.game.items")
local C = require("src.core.color")
local Parser = require("src.core.parser")

-- Initial display.
local function showWelcome()

    print(C.paint(
[[
+-----------------------------+
|     WELCOME TO THE GAME     |
+-----------------------------+]], "cyan"))
  print(C.paint("Explore rooms, search for items, and find your way out.", "dim"))
  print("")
  print(C.paint("Available commands:", "bold"))
  print(C.paint("  north, south, east, west - Move", "dim"))
  print(C.paint("  search                   - Search the room", "dim"))
  print(C.paint("  inventory                - View inventory & stats", "dim"))
  print(C.paint("  map                      - Show the map (if you have it)", "dim"))
  print(C.paint("  use <item>               - Use by ID or Name (e.g., 'use map' or 'use Old Map')", "dim"))
  print(C.paint("  enter code ####          - Enter a 4-digit code (where applicable)", "dim"))
  print(C.paint("  help                     - List commands again", "dim"))
  print(C.paint("  quit                     - Exit game", "dim"))
  print("\n")
end

-- Pattern utilities
local function trim(s) return (s and s:gsub("^%s*(.-)%s*$", "%1") or "") end
local function normalize_spaces(s) return (s and s:gsub("%s+", " ") or "") end
local function normalize_command(s)
    if not s then return "" end
    s = s:lower()
    s = trim(s)
    s = normalize_spaces(s)
    return s
end

showWelcome()
print(Rooms.describe(Player.getLocation())) -- get initial location 
running = true 

-- MAIN GAME LOOP
while running do
    -- Declarations
    local location = Player.getLocation() -- shorthand location
    local exits = Rooms.getAvailableExits(location) -- availableExits
    local actions = Rooms.getAvailableActions(location) -- availableActions

    print(C.paint("You can go:", "yellow") .. " " .. table.concat(exits, ", "))
    if #actions > 0 then -- room has actions then show them.
        print(C.paint("You can also:", "yellow") .. " " .. table.concat(actions, ", "))
    end
    
    io.write(C.paint("\nCommand: ", "cyan"))
    local raw = io.read()
    if not raw then
        print("\nInput closed. Exiting.")
        break
    end
    local command = normalize_command(raw)

    -- Run through parser
    do
        local canonical = Parser.parse(raw, {actions = actions, exits = exits})
        if canonical then command = normalize_command(canonical) end
    end

    -- ===========================
    -- Command branches
    -- ===========================

    -- Quit game.
    if command == "quit" then
        print("Thanks for playing!")
        break
    
    -- Map command shortcut
    elseif command == "map" then
        if Inventory.has("map") then
            print(Utils.useItem("map", { room = Player.getLocation() }))
        else
            print("You don't have a map.")
        end
        goto continue_loop

    -- Use <item_id>
    elseif command:match("^use%s+") then
        -- Accept item IDs with letters, digits, and underscores
        local item_id = command:match("^use%s+(.+)$")
        if not item_id or item_id == "" then
            print("Use what?")
        else 
            -- Accept either item_id or display name.
            local resolved = Items.resolve(item_id) or item_id

            if not Inventory.has(resolved) then
                print("You don't have that item.")
            else
                local out = Utils.useItem(resolved, { room = Player.getLocation() })
                print(out)
            end
        end
        goto continue_loop

    -- If just 'use' entered
    elseif command == "use" then
        print("Use what? Try: use <item_id>  (e.g., 'use map')")
        goto continue_loop

    -- Search room. 
    elseif command == "search" then
        print(Rooms.search(Player.getLocation()))
        goto continue_loop
    
    -- Inventory & Stat display (like a pause menu)
    elseif command == "inventory" then
        print(Player.showInventory()) -- inventory and stats wrapper
        goto continue_loop

    -- Help command
    elseif command == "help" then 
        print(C.paint("Available commands:", "bold"))
        print(C.paint("  north, south, east, west - Move", "dim"))
        print(C.paint("  search                   - Search the room", "dim"))
        print(C.paint("  inventory                - View inventory & stats", "dim"))
        print(C.paint("  map                      - Show the map (if you have it)", "dim"))
        print(C.paint("  use <item>               - Use by ID or Name (e.g., 'use map' or 'use Old Map')", "dim"))
        print(C.paint("  enter code ####          - Enter a 4-digit code (where applicable)", "dim"))
        print(C.paint("  help                     - List commands again", "dim"))
        print(C.paint("  quit                     - Exit game", "dim"))
        print("\n")
        goto continue_loop

    -- Enter code (for Servants' Quarters lockbox)
    elseif command:match("^enter%s+code%s+%d+$") then
        local code = command:match("^enter%s+code%s+(%d+)$")
        if Player.getLocation() == "servants_quarters" then
            local out = Rooms.trySQCode(code)
            print(out)
        else
            print("There's nothing here that accepts a code.")
        end
        goto continue_loop
    end

    -- ===========================
    -- Action matching or movement
    -- ===========================

    -- Try matching an available action first (exact normalized match)
    do
        local did_action = false
        local norm_command = command
        for _, action_name in ipairs(actions) do
            local norm_action = normalize_command(action_name)
            if norm_command == norm_action then
                -- Perform action after conditional branch..
                local result = Rooms.performAction(location, action_name)
                print(result)
                -- Win condition
                if result:sub(1,5) == "[END]" then
                    print("\nThanks for playing!")
                    running = false -- end game
                    goto continue_loop -- skips anymore handling.
                    break -- breaks loop
                end
                did_action = true
                break
            end
        end
        
        if did_action then
            goto continue_loop
        end
        
        -- Movement if not action
        local next_room, err = Rooms.move(location, norm_command)
        if next_room then
            Player.setLocation(next_room)
            print(Rooms.describe(Player.getLocation()))
        else
            if err then
                print(err)
            else
                print("Invalid action or command.")
            end
        end
    end
    ::continue_loop::
end