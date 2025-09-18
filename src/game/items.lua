-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- src/game/items.lua
-- item database, methods, helpers.

local Items = {}

Items.data = {
    ["candle"] = {
        name = "Candle",
        description = "A thick wax candle. It flickers but holds a steady flame."
    },
    ["todo_list"] = {
        name = "Servants' To-Do List",
        description = "A crumpled list of chores with oddly specific notes and arrows."
    },
    ["faded_note"] = { -- useless right now.
        name = "Faded Note",
        description = "Smudged ink: 'Feed the earth, reap the sky.' The rest is unreadable."
    },
    ["rusty_sword"] = { -- useless right now.
        name = "Rusty Sword",
        description = "An old sword with a dull blade. Better than nothing."
    },
    ["healing_potion"] = { -- useless right now.
        name = "Healing Potion",
        description = "A small vial of red liquid. Restores some health."
    },
    ["coin"] = { -- useless right now.
        name = "Gold Coin",
        description = "Shiny, but not particularly useful right now."
    },
    ["mysterious_relic"] = { -- useless right now.
        name = "Mysterious Relic",
        description = "An ancient artifact radiating strange energy."
    },
    ["lantern"] = { -- unimplemented right now.
        name = "Lantern",
        description = "An oil lantern. Could help in very dark places."
    },
    ["ancient_book"] = { -- useless right now.
        name = "Ancient Book",
        description = "Its pages are filled with strange runes and symbols."
    },
    ["strange_amulet"] = { -- useless right now.
        name = "Strange Amulet",
        description = "It hums faintly, like it’s alive."
    },
    ["rope"] = {
        name = "Rope",
        description = "Strong and sturdy. Can help you descend safely."
    },
    ["fire_poker"] = {
        name = "Fire Poker",
        description = "A long iron poker. Great for prodding things from a distance."
    },
    ["greenhouse_key"] = {
        name = "Greenhouse Key",
        description = "A small brass key with a faint floral engraving."
    },
    ["observatory_key"] = {
        name = "Observatory Key",
        description = "An intricate key with tiny star patterns carved into it."
    },
    ["servants_key"] = {
        name = "Servants’ Quarters Key",
        description = "An old iron key, cold to the touch."
    },
    ["knife"] = {
        name = "Knife",
        description = "A sharp kitchen knife. Could cut through stubborn vines."
    },
    ["trowel"] = {
        name = "Garden Trowel",
        description = "A small hand tool, useful for digging in soil."
    },
    ["map"] = {
        name = "Old Map",
        description = "A faded map showing the layout of the building. How convenient."
    },
    ["trapdoor_key"] = {
        name = "Trapdoor Key",
        description = "An iron key that unlocks the hidden trapdoor beneath the rug."
    }   
}

-- Pattern utility
local function norm(s)
    if not s then return "" end
    s = s:lower():gsub("^%s*(.-)%s*$", "%1")
    return s
end

-- For showing executables in inventory (ex. todo_list with "Servants' To-Do List")
function Items.label(item_id)
    local item = Items.data[item_id]
    if not item then return item_id end
    return string.format("%s [%s]", item.name or item_id, item_id) 
end

-- For inventory formatting descriptions.
function Items.desc(item_id)
    local item = Items.data[item_id]
    return (item and item.description) or ""
end
  
-- Take either exact ID or display name w/ case-insensitivity
function Items.resolve(input)
    input = norm(input)
    if Items.data[input] then return input end  -- exact ID
    for item_id, item in pairs(Items.data) do
        if norm(item.name) == input then
        return item_id
        end
    end
    return nil
end

-- Get item description
function Items.describe(item_name)
    local item = Items.data[item_name]
    if item then
        return item.name .. ": " .. item.description
    else
        return "Unknown item."
    end
end

-- Item randomizer. Subject to change.
function Items.random()
    local keys = {}
    for k in pairs(Items.data) do
        table.insert(keys, k)
    end
    local choice = keys[math.random(#keys)]
    return choice
end

return Items