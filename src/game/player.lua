-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- src/game/player.lua
-- stats, location, inventory

local Inventory = require("src.game.inventory")
local C = require("src.core.color")

local Player = {}

-- Stats 
-- These will be expanded on later if PVP added.
Player.stats = {
    health = 100,
    sanity = 100
}

-- Starting location 
Player.location = "entrance"

-- Get current stats
function Player.getStats()
    local line = "+-----------------------+"
    local health = "| Health: " .. string.format("%3d", Player.stats.health) .. "        |"
    local sanity = "| Sanity: " .. string.format("%3d", Player.stats.sanity) .. "        |"
    local box = table.concat({line, health, sanity, line}, "\n")
    return C.paint(box, "magenta")
end

-- Modify health.
function Player.changeHealth(amount)
    Player.stats.health = math.max(0, math.min(100, Player.stats.health + amount))
    return "Health is now " .. Player.stats.health
end

-- Modify sanity.
function Player.changeSanity(amount)
    Player.stats.sanity = math.max(0, math.min(100, Player.stats.sanity + amount))
    return "Sanity is now " .. Player.stats.sanity
end

-- Setting Location 
function Player.setLocation(new_location)
    Player.location = new_location
end

-- Location Getter
function Player.getLocation()
    return Player.location
end

-- Inventory wrapper functions

function Player.pickUp(item_id)
    return Inventory.add(item_id)
end

-- Functionality for 'use item' with other conditions soon.
function Player.drop(item_id)
    return Inventory.remove(item_id)
end

-- Functionality to show stats and other important information on inventory menu.
function Player.showInventory()
    local inventory = Inventory.list()
    local stats = Player.getStats()
    return inventory .. "\n" .. stats
end

return Player