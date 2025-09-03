-- Copyright (c) 2025 Hadi Rana. All rights reserved.

-- utils.lua
-- item functionality, returning displays.

local Rooms = require("rooms")
local Inventory = require("inventory")

local Utils = {}

-- Toggle: should keys be removed after use
local CONSUME_KEYS = true

-- Helpers / Pattern Utilities.
local function trim(s) return (s and s:gsub("^%s*(.-)%s*$", "%1") or "") end
local function norm(s) return (s and trim(s:lower()) or "") end

-- ASCII map for Section 1
local SECTION1_MAP = [[
+------------------ SECTION 1 ------------------+

                    [Observatory]
                          |
  [Crypt] - [Library] - [Study]
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

-- ASCII for to-do list.
local TODO_LIST = [[
+----------- SERVANTS' TO-DO -----------+
- Pantry: check the little drawer.
- Dining Hall: dust under plates; check below the feast.
- Study: dust the floorboards where the desk meets the rug.
- Observatory: confirm charts match the carved order.
- Crypt: note the ring of marks on the coffin.
+---------------------------------------+
]]

-- Table for keys – Where each key is valid to use, and what it unlocks
local KEY_BINDINGS = {
    greenhouse_key  = { room = "garden",            unlock = "greenhouse",         door_dir = "north" },
    servants_key    = { room = "kitchen",           unlock = "servants_quarters",  door_dir = "south" },
    observatory_key = { room = "study",             unlock = "observatory",        door_dir = "north" },
}

local function unlock_with_key(item_id, ctx)
  
  local bind = KEY_BINDINGS[item_id]
  if not bind then
    return "That doesn't seem to be a key you can use here."
  end
    
  -- Check room from table and variable
  local here = ctx and ctx.room or ""
  if norm(here) ~= norm(bind.room) then
    return "There's nothing here that this key fits."
  end
  
  -- Check unlock from table and variable 'target'
  local target_id = bind.unlock
  local target = Rooms.data[target_id]
  if not target then
    return "You try the key, but nothing here matches that lock."
  end
  
  -- If it's not locked, say so
  if not target.locked then
    return "It's already unlocked."
  end
  
  -- Unlock using Rooms method for consistency
  local msg = Rooms.unlock(target_id)
  
  -- Optionally consume the key
  if CONSUME_KEYS then
    Inventory.remove(item_id)
  end
  
  -- Shows direction in unlock message which is very unnecessary but nice.
  if bind.door_dir then
    return ("You unlock the %s door to the %s.\n%s"):format(target_id:gsub("_", " "), bind.door_dir, msg)
  else
    return msg
  end
end

-- Tool actions
local function use_knife(context)

  -- Knife not used in greenhouse.
  if norm(context.room or ""):lower() ~= "greenhouse" then
    return "You brandish the knife, but there’s nothing to cut here."
  end

  -- Checks if greenhouse state is true (vines cut)
  local gh = require("rooms").data["greenhouse"]
  gh.state = gh.state or {}
  if gh.state.vines_cut then
    return "The vines are already severed."
  end
    -- Cut vines -> grant trapdoor_key
    gh.state.vines_cut = true
    local Inventory = require("inventory")
    Inventory.add("trapdoor_key")
    return "You slice through the writhing vines. Something drops with a clink... a key. (You take the Trapdoor Key.)"
end
  

local function use_trowel(context)

  -- Trowel not used in garden.
  if norm(context.room or ""):lower() ~= "garden" then
    return "You scrape the ground a little. Wrong place for digging."
  end

  -- Haven't examined grass.
  local g = require("rooms").data["garden"]
  g.state = g.state or {}
  if not g.state.soil_dug then
    return "You don’t see a good place to dig yet. Look for disturbed soil first."
  end
  
  -- If already dug.
  if g.state.soil_dug then
    return "You've already dug up this patch of soil."
  end

  -- Dig soil -> grant rope
  g.state.soil_dug = true
  local Inventory = require("inventory")
  Inventory.add("rope")
  return "You dig into the disturbed soil and uncover tightly coiled rope. (You take the Rope.)"
end

-- Use an item by ID. Context can carry room_id, etc.
function Utils.useItem(item_id, context)
  item_id = norm(item_id)

  -- Map usage
  if item_id == "map" then
      return SECTION1_MAP
  end
  -- Key usage
  if KEY_BINDINGS[item_id] then
      return unlock_with_key(item_id, context)
  end

    -- Tools
  if item_id == "knife" then
      return use_knife(context)
  elseif item_id == "trowel" then
      return use_trowel(context)
  end

  -- Candle is passive: it'll check for it before entering dark areas later
  if item_id == "candle" then
      return "You cup your hand around the candle flame. It pushes back the darkness a little."
  end
  
  -- Returns to-do list
  if item_id == "todo_list" then
    return TODO_LIST
  end

  return "You can't use that here."
end

return Utils

