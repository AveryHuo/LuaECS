---@class ArchetypeManager 对应archetype的管理器
local ArchetypeManager = class()

---ArchetypeManager构造函数
function ArchetypeManager:ctor(  )
    self.archeTypes = {}
end

---[静态函数]通过types数组获取一个archetype的key。 当前以：分隔
---@param ComponentType类型的对象数组
---@param 个数
---@return types的key
function ArchetypeManager.GetTypesStr( types, count )
    local names = {}
    for i=1,count do
        table.insert(names, ECS.TypeManager.GetTypeNameByIndex(types[i].TypeIndex))
    end
    table.sort(names)
    return table.concat(names, ":")
end

---通过已经注册的类型名列表，生成类型数组
---@param 类型名字
---@param 类型个数
---@return 每一个类型的ComponentType及个数
function ArchetypeManager.GenTypeArray( typeNames, count )
    local cachedArcheTypes = {}
    for i=1,count do
        table.insert(cachedArcheTypes,ECS.ComponentType.Create(typeNames[i]))
    end
    return cachedArcheTypes, #cachedArcheTypes
end

---获取或创建一个archetype，并将此archetype与与之类型匹配的group相关联
---@param ComponentType类型的对象数组
---@param 个数
---@param EntityGroup管理器 此archetype与与之类型匹配的group相关联
---@return 对应的archetype对象
function ArchetypeManager:GetOrCreateArchetype( types, count, groupManager )
	local type = self:GetExistingArchetype(types, count)
    return type~=nil and type or self:CreateArchetypeInternal(types, count, groupManager)
end

---获取本地的archetype
---@param ComponentType类型的对象数组
---@param 个数
---@return 已存在的archetype
function ArchetypeManager:GetExistingArchetype( types, count )
    local type_str = ArchetypeManager.GetTypesStr(types, count)
    return self.archeTypes[type_str]
end

---[内部]创建archetype
---@param ComponentType类型的对象数组
---@param 个数
---@param EntityGroup管理器
---@return 创建生成一个archetype
function ArchetypeManager:CreateArchetypeInternal( types, count, groupManager )
    local type = ECS.Archetype.new(types, count, groupManager)

    -- 找到前面的archetype关联
    type.PrevArchetype = self.lastArcheType
    self.lastArcheType = type

    -- types以":"分隔为KEY，添加此archetype
    local type_str = ArchetypeManager.GetTypesStr(types, count)
    self.archeTypes[type_str] = type

    groupManager:AddArchetypeIfMatching(type)

    return type
end

---在chunk中开辟一段空间给archetype
---@param archetype 对应的archetype对象
---@param chunk 对应的chunk对象
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

---从archetype中拿一个chunk
---@param 对应的archetype对象
---@return 新创建的chunk对象
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