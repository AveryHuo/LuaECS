local MoveData = {}

local pos = "pos"
local x = "x"
local y = "y"
local z = "z"

local offset = "offset"

MoveData[pos] = {}
MoveData[pos][x] = 2
MoveData[pos][y] = 3
MoveData[pos][z] = 4

MoveData[offset] = 2.15

-- 设定此Component长度
MoveData.Length = 50
return MoveData