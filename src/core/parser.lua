-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 Hadi Rana

-- src/core/parser.lua
-- synonym mapping to existing actions/exits for less CLI nonsense.

local Parser = {}

-- Pattern Helper Utility
local function norm(s)
    if not s then return "" end
    s = s:lower()
    s = s:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", " ")
    return s
end

-- All acceptable commands for directions
local DIRECTIONS = {
    n = "north", 
    s = "south", 
    e = "east", 
    w = "west",
    north = "north", 
    south = "south", 
    east = "east", 
    west = "west",
}

-- Other synonyms so not explicitly one word. 
-- for actions.
local VERB_SYNS = {
    lift   = { "lift", "raise", "look under", "check under", "peek under", "move" },
    pull   = { "pull", "tug", "yank" },
    cut    = { "cut", "slice", "clear", "use knife" },
    read   = { "read", "study", "examine", "inspect" },
    search = { "search", "scan", "look around", "observe" },
    push   = { "push", "press" },
    open   = { "open", "unlock" },
    light  = { "light", "ignite" },
}

-- Helper Utility.
-- Returns if string s is in phrase 
local function phrase_in(s, phrase)
-- Spacing instead of frontier patterns because simpler.
    s = " " .. s .. " "
    phrase = " " .. phrase .. " "
    return s:find(phrase, 1, true) ~= nil
end

-- Direction parser - check if available
local function try_direction(raw)
    local s = norm(raw)
    -- Exact input.
    if DIRECTIONS[s] then return DIRECTIONS[s] end 

    -- Picks up direction in a sentence like 'let's go west' or something.
    for i, v in pairs(DIRECTIONS) do
        if phrase_in(s, i) then return v end
    end
    return nil
end

-- action parser - will allow actions with synonyms.
local function try_action(raw, actions)
    local s = norm(raw)
    if not actions or #actions == 0 then return nil end

    -- exact match first
    for _, act in ipairs(actions) do
        if s == norm(act) then return act end
    end

    -- synonym mapping - verb match + one or more words from object
    for _, act in ipairs(actions) do
        local verb, rest = act:match("^(%w+)%s+(.+)$")
        local syns = verb and VERB_SYNS[verb]
        if syns then
        for _, syn in ipairs(syns) do
            if phrase_in(s, syn) then
                for word in rest:gmatch("%w+") do
                    if phrase_in(s, word) then return act end
                    end
                end
            end
        end
    end
    return nil
end

-- 
function Parser.parse(raw, context)
    local s = norm(raw)
    -- directions
    local dir = try_direction(s)
    if dir then return dir end

    -- keep codes strict
    if s:match("^enter%s+code%s+%d+$") then return s end

    -- let main handle `use <item>`
    if s:match("^use%s+.+$") then return s end

    -- try to map to one of the visible actions
    local act = try_action(s, context and context.actions or nil)
    if act then return act end

    -- allow “search” synonyms
    if phrase_in(s, "search") or phrase_in(s, "look around") or phrase_in(s, "scan") then
        return "search"
    end
    return nil
end

return Parser