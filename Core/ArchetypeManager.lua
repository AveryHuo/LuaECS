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
    cachedArcheTypes[1] = ECS.ComponentType.Create(ECS.Entity.Name)
    for i=1,count do
        ECS.SortingUtility.InsertSorted(cachedArcheTypes, i + 1, ECS.ComponentType.Create(requiredComponents[i]))
    end
    return cachedArcheTypes, count + 1
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
    local type = {}
    type.TypesCount = count
    type.Types = types
    type.EntityCount = 0
    type.ChunkCount = 0

    type.TypesMap = {}
    type.TotalLength = 0
    for k,v in pairs(types) do
        local typeName = ECS.TypeManager.GetTypeNameByIndex(v.TypeIndex)
        local typeInfo = ECS.TypeManager.GetTypeInfoByIndex(v.TypeIndex)
        type.TypesMap[typeName] = true
        type.TotalLength = type.TotalLength + typeInfo.TypeSize
    end

    -- 找到前面的archetype关联
    type.PrevArchetype = self.lastArcheType
    self.lastArcheType = type

    -- 创建chunk列表
    type.ChunkList = ECS.LinkedList()
    ECS.LinkedList.InitializeList(type.ChunkList)

    -- types以":"分隔为KEY，添加此archetype
    local type_str = GetTypesStr(types, count)
    self.archeTypes[type_str] = type

    groupManager:AddArchetypeIfMatching(type)
    return type
end

function ArchetypeManager:ConstructChunk( archetype, chunk )
	chunk.Archetype = archetype

    chunk.Id = archetype.ChunkCount+1
    chunk.EntityCount = 0

    chunk.Buffer = {}
    for k,v in pairs(archetype.Types) do
        local componentName = ECS.TypeManager.GetTypeNameByIndex(v.TypeIndex)
        chunk.Buffer[componentName] = {}
    end
    
    archetype.ChunkList:Add(chunk.ChunkListNode)
    archetype.ChunkCount = archetype.ChunkCount+1
end

-- 在chunk中开辟一段空间给archetype
-- 返回：分配好的的EntityID
function ArchetypeManager:AllocateIntoChunk( archetype, chunk)
    -- 不允许为0的archetype设置
    if archetype.TotalLength == 0 then
        archetype.TotalLength = 4
    end
    -- 设置最新的
    self:SetChunkSize(chunk, chunk.UsedSize + archetype.TotalLength)
    -- 默认分配索引号后一位
    local allocatedIdx = chunk.EntityCount + 1
    -- 在已有的索引下查找，如果有空位，由分配此空位索引
    for i = 1, chunk.EntityCount do
        if not chunk.Buffer[ECS.Entity.Name][i] then
            print("chunk里的索引："..i.."，有空位")
            allocatedIdx = i
            break
        end
    end

    chunk.EntityCount = chunk.EntityCount + 1 --设置Entity个数
    chunk.Archetype = archetype
    chunk.Archetype.EntityCount = chunk.Archetype.EntityCount + 1
    return allocatedIdx
end

-- 增加chunk里存储大小，并做判断是否新建一个新的chunk
function ArchetypeManager:SetChunkSize( chunk, newCount )
    local capacity = chunk.Capacity

    if newCount == 0 then  -- 释放Chunk以清空
        chunk.Archetype.ChunkCount = chunk.Archetype.ChunkCount - 1
        chunk.Archetype = nil
        chunk.ChunkListNode:Remove()
    elseif newCount >= capacity then -- Chunk已经满了
        chunk = self:CreateNewChunk(chunk.Archetype)
        -- 刷新最新的chunk使用情况，占用一个archetype的大小
        chunk.UsedSize = chunk.Archetype.TotalLength
    else
        -- 刷新最新的chunk使用情况
        chunk.UsedSize = newCount
    end
end

-- 从archetype中拿一个chunk
function ArchetypeManager:GetChunk( archetype )

    -- 先从当前archetype的chunk列表拿
    if not archetype.ChunkList:IsEmpty() then
        local lastChunkNode = archetype.ChunkList:Last()
        local chunk = lastChunkNode:GetChunk()
        return chunk
    end

    --创建一个新的
    local newChunk = self:CreateNewChunk(archetype)
    return newChunk
end

-- 创建一个Chunk
function ArchetypeManager:CreateNewChunk( archetype )
    local newChunk
    --- 尝试从池子拿一个chunk块
    --if not self.emptyChunkPool or self.emptyChunkPool:IsEmpty() then
    --    -- 新建一个chunk
    --    newChunk = ECS.Chunk.new()
    --else
    --    -- 从池子里拿一个,并将当前Chunk结点移出
    --    newChunk = self.emptyChunkPool:Last()
    --    -- 从池子链表中移出来
    --    newChunk:Remove()
    --    -- 获取真实chunk数据
    --    newChunk = newChunk:GetChunk()
    --end

    -- 初始化chunk，设置大小，指向，链表指针等信息
    newChunk = ECS.Chunk.new()
    self:ConstructChunk(archetype, newChunk)

    return newChunk
end





return ArchetypeManager