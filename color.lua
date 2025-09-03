-- Copyright (c) 2025 Hadi Rana. All rights reserved.

-- color.lua
-- formatting with colours.

local C = {}
C.codes = {
  reset = "\27[0m",
  dim   = "\27[2m",
  red   = "\27[31m",
  green = "\27[32m",
  yellow= "\27[33m",
  blue  = "\27[34m",
  magenta="\27[35m",
  cyan  = "\27[36m",
  bold  = "\27[1m",
}
function C.paint(s, code) return (C.codes[code] or "") .. tostring(s) .. C.codes.reset end
return C
