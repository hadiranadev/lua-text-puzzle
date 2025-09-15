-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- inventory.lua
-- adding, using, removing items, listing items.

local Items = require("items")
local C = require("color")

local Inventory = {}

Inventory.items = {} -- empty unless saving progress is added later.

-- Add item 
function Inventory.add(item_name)
    if not item_name or item_name == "" then
        return "You can't add anything to your inventory."
    end

    table.insert(Inventory.items, item_name)
    return item_name .. " has been added to your inventory."
end

-- Remove item
function Inventory.remove(item_name)
    for i, item in ipairs(Inventory.items) do
        if item == item_name then
            table.remove(Inventory.items, i)
            return item_name .. " has been removed from your inventory."
        end
    end
    return "You don't have " .. item_name .. " in your inventory."
end

-- Lists items in inventory
function Inventory.list()
    if #Inventory.items == 0 then
        return "+-----------------------+\n|  Inventory is empty   |\n+-----------------------+"
    else 
        local lines = {"+-----------------------+"}
        table.insert(lines, "|     INVENTORY         |")
        table.insert(lines, "+-----------------------+")
        for _, id in ipairs(Inventory.items) do
            -- id is the executable (like "todo_list")
            local label = Items.label(id)    -- "Servants' To-Do List [todo_list]"
            local desc  = Items.desc(id)     -- item description (string or empty)
            table.insert(lines, "| • " .. label)
            if desc and desc ~= "" then
                table.insert(lines, "|    — " .. desc)
            end
        end
        table.insert(lines, "+-----------------------+")
        local box = table.concat(lines, "\n")
        return C.paint(box, "magenta")
    end
end

-- Check if item exists in inventory (true/false)
function Inventory.has(item_name)
    for _, v in ipairs(Inventory.items) do
        if v == item_name then
            return true
        end
    end
    return false
end

return Inventory