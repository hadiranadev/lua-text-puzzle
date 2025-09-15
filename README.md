## Haunted House – A tiny text-based puzzle game in Lua
A bite-sized, terminal adventure written in Lua. 
> Built for Lua 5.4. Runs in any terminal.

---

## Run
```bash
# Clone then run
lua main.lua
```

---

## Commands
Movement: north, south, east, west
Interact: search, use <item>, enter code ####
Info: inventory, help, quit

---

If you don’t have Lua installed:

* **macOS**: `brew install lua`
* **Linux**: use your package manager (e.g., `sudo apt install lua5.4`)
* **Windows**: download a Lua 5.4 build or use `choco install lua`.

---

## How to play

Type commands into the prompt:

* **Movement**: `north`, `south`, `east`, `west`
* **Interact**: `search` (reveals context actions), `use <item>`
* **Puzzles**: certain rooms accept `enter code ####`
* **Info**: `inventory`, `help`, `quit`

> Tip: After `search`, try the shown context actions (e.g., `cut vines`, `pull book`, `lift blanket`). Some actions only appear once you’ve seen the right hint.

---

## Example session

```
> search
You scan the room... (you notice a tangle of vines over a trapdoor)
> use knife
You slice through the vines...
> east
Secret Study
> search
You notice scratch marks beneath the desk.
```

---

## Project structure

```
.
├── color.lua        # color helpers
├── inventory.lua    # list/add/remove & display
├── items.lua        # item database & helpers
├── main.lua         # main game loop & command routing
├── parser.lua       # (Not yet available) higher-level command parsing
├── player.lua       # stats & location & inventory helpers
├── rooms.lua        # rooms, actions, movement, search
├── utils.lua        # item-use implementations & helpers
├── world.lua        # star puzzle functionality
├── README.md        # this file
└── LICENSE
```

---

## Week 1 — refactor & quality fixes

This week focused on behavioural cleanups along with a few tiny fixes:

* Trimmed long modules and tightened guardrails (nil‑safe descriptions, clearer helpers).
* `use <item>` accepts **display names** in addition to ids (e.g., `use Old Map`).
* Garden trowel logic now using proper boolean action so for correct functionality.
* Greenhouse knife reward logic is no longer duplicated (single source of truth in rooms.lua).

> These were picked to be small, readable changes—great for easing back into the code and setting up future features.

---

## Future roadmap

* **Week 2**: Simple natural‑language layer

  * Map common synonyms to contextual actions (e.g., `look under blanket` -> `lift blanket`).
  * Small QoL tweaks (UX messages, more helpful `help`).

* **Week 3**: Saves/clears & serialization

  * JSON‑based Save Manager (single `GameState` table: player, inventory, room states).
  * Commands: `save <slot>`, `load <slot>`, `clearsave <slot>`, `listsaves`.

---

## Extending the game (quick guide)

**Add an item**

```lua
-- items.lua
Items.data["rope"] = {
  name = "Rope",
  description = "A sturdy length of rope."
}
```

**Place it in a room**

```lua
-- rooms.lua
["garden"] = {
  items = { "rope" },
}
```

**Use behavior**

```lua
-- utils.lua
function Utils.useItem(item_id, ctx)
  if item_id == "rope" and ctx.room == "well" then
    return "You secure the rope and climb down."
  end
  return "Nothing interesting happens."
end
```

---

## Troubleshooting

* **No color?** Your terminal may not support colors but gameplay should still work.
* **Lua version**: If you’re on Lua 5.1/5.2, update to 5.4 for best results (I tested with 5.4).

---

## License

MIT (see `LICENSE`).

---

## Credits
Designed and written by Hadi Rana.

