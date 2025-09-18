## Haunted House – A tiny text-based puzzle game in Lua
A small, terminal-only puzzle game written in Lua. 
> Built for Lua 5.4. Should run anywhere you can run Lua.

---

## Run
```bash
lua src/main.lua
```

---

## Commands

Type commands into the prompt: 

Movement: `north`, `south`, `east`, `west`
Interact: `search` (reveals context actions), `use <item>`
Puzzles: certain interactions accept `enter code ####`
Info: `inventory`, `help`, `quit`

This is meant to be old-school where you enter in an option you're provided to execute it. I did add a few synonyms so don't get stuck verb-guessing.

---

## Example 

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

## Notes

* If you’re stuck, try using `search` in different rooms. 
* Some actions only appear once you’ve seen the right hint.
* Colours are purely cosmetic - some terminals may not support colours, but the game should still run.

---

## Features

* Text-only, zero deps, runs anywhere you can run Lua.
* Room and action commands (like `search`) are specific and locked to your current room.
* Inventory items have display names; `use` works by id or display name.
* Directions support `n/s/e/w` in addition to full words.
* A few common phrases map to listed actions (nothing fancy... yet). 
* The 'map' item will print out an ASCII map and marks your current room.
* A star puzzle with a randomized solution each run.
* Actions and rooms are locked behind hints and items. 

---

## What changed? (Week 2)

* Code has been moved under folders `src/` with `core/`, `game/`, and `/io` to make future features easier to slot in.
* A simple parser that allows for shorter directions (`n/s/e/w`) and a couple of action synonyms that map to actions you can already see. 
* A map renderer file is now in `io/` which marks your current room.

--- 

## Future Roadmap

* Save/clear/load using JSON-backed save slots – commands like `save <slot>`, `load <slot>`, `clearsave <slot>`, `listsaves` under a single `GameState` table.
* Map colouring instead of replacing the label since it'll look cleaner. 
* Possibly a parser polish to tighten matching (using frontier patterns), maybe (not an immediate priority) toggles for colours, parsers (helper vs strict), etc. 

---


## Troubleshooting

* **No colour?** No problem.
* **Lua version**: I'm on 5.4. Other versions will likely work, but they're untested by me.

---

## License

MIT (see `LICENSE`).

---

## Credits
Designed and written by Hadi Rana.

