local ArchetypeManager = class()
ECS.ArchetypeManager = ArchetypeManager

function ArchetypeManager:ctor(  )
    self.archeTypes = {}
end

-- 获取类型KEY
local GetTypesStr = function ( types, count )
    local names = {}
    for i=1,count do
        table.insert(names, ECS.TypeManager.GetTypeNameByIndex(types[i].TypeIndex))
    end
    table.sort(names)
    return table.concat(names, ":")
end
ArchetypeManager.GetTypesStr = GetTypesStr

-- 生成类型数组
local GenTypeArray = function( requiredComponents, count )
    local cachedArcheTypes = {}
    for i=1,count do
        table.insert(cachedArcheTypes,ECS.ComponentType.Create(requiredComponents[i]))
    end
    return cachedArcheTypes, #cachedArcheTypes
end
ArchetypeManager.GenTypeArray = GenTypeArray

-- 获取或创建一个archetyp
function ArchetypeManager:GetOrCreateArchetype( types, count, groupManager )
	local type = self:GetExistingArchetype(types, count)
    return type~=nil and type or self:CreateArchetypeInternal(types, count, groupManager)
end           

-- 获取本地的archetype
function ArchetypeManager:GetExistingArchetype( types, count )
    local type_str = GetTypesStr(types, count)
    return self.archeTypes[type_str]
end

-- 内部：创建archetype
function ArchetypeManager:CreateArchetypeInternal( types, count, groupManager )
    local type = ECS.Archetype.new(types, count, groupManager)

    -- 找到前面的archetype关联
    type.PrevArchetype = self.lastArcheType
    self.lastArcheType = type

    -- types以":"分隔为KEY，添加此archetype
    local type_str = GetTypesStr(types, count)
    self.archeTypes[type_str] = type

    groupManager:AddArchetypeIfMatching(type)

    return type
end

-- 在chunk中开辟一段空间给archetype
-- 返回：分配好的的EntityID
function ArchetypeManager:AllocateIntoChunk( archetype, chunk)
    -- 不允许为0的archetype设置
    if archetype.TotalLength == 0 then
        archetype.TotalLength = 4
    end
    -- 设置最新的
    archetype:SetChunkSize(chunk, chunk.UsedSize + archetype.TotalLength)

    chunk.EntityCount = chunk.EntityCount + 1 --设置Entity个数
    chunk.Archetype = archetype
    chunk.Archetype.EntityCount = chunk.Archetype.EntityCount + 1
end

-- 从archetype中拿一个chunk
function ArchetypeManager:GetChunk( archetype )
    -- 先从当前archetype的chunk列表拿
    if not archetype.ChunkList:IsEmpty() then
        return archetype.ChunkList:GetLast()
    end

    --创建一个新的
    local newChunk = archetype:GetChunkFromArchetype()
    return newChunk
end

return ArchetypeManager