local Archetype = class()

function Archetype:ctor(types, count, groupManager)
    self.TypesCount = count
    self.Types = types
    self.EntityCount = 0
    self.ChunkCount = 0

    self.TypesMap = {}
    self.TotalLength = 0
    for k,v in pairs(types) do
        local typeName = ECS.TypeManager.GetTypeNameByIndex(v.TypeIndex)
        local typeInfo = ECS.TypeManager.GetTypeInfoByIndex(v.TypeIndex)
        self.TypesMap[typeName] = true
        self.TotalLength = self.TotalLength + typeInfo.TypeSize
    end

    -- 创建chunk列表
    self.ChunkList = ECS.LinkedList()
end

function Archetype:GetIndexInTypeArray( typeIndex )
    local types = self.Types
    local typeCount = self.TypesCount
    for i=1,typeCount do
        if typeIndex == types[i].TypeIndex then
            return i
        end
    end
    return -1
end

function Archetype:IsTypeNameInArchetype(  typeName )
    local result = self and self.TypesMap and self.TypesMap[typeName]
    return result ~= nil
end


-- 增加chunk里存储大小，并做判断是否新建一个新的chunk
function Archetype:SetChunkSize( chunk, newCount )
    local capacity = chunk.Capacity

    if newCount == 0 then  -- 释放Chunk以清空
        chunk.Archetype.ChunkCount = chunk.Archetype.ChunkCount - 1
        chunk.Archetype.ChunkList:Delete(chunk)
        chunk.Archetype = nil
    elseif newCount >= capacity then -- Chunk已经满了
        chunk = self:GetChunkFromArchetype()
        -- 刷新最新的chunk使用情况，占用一个archetype的大小
        chunk.UsedSize = chunk.Archetype.TotalLength
    else
        -- 刷新最新的chunk使用情况
        chunk.UsedSize = newCount
    end
end

-- 创建一个Chunk
function Archetype:CreateNewChunk()
    --- TODO:尝试从池子拿一个chunk块

    ECS.IdCounter = ECS.IdCounter + 1
    -- 初始化chunk，设置大小，指向，链表指针等信息
    local newChunk = {
        Id = 0,
        Archetype = nil,--所属的archetype
        EntityCount = 0,--当前Entity的数量
        Capacity = 16 * 1024, --固定容量
        UsedSize = 0
    }

    newChunk.SetData = function(chunk, componentName, id, data)
        chunk.Buffer[componentName][id] = data
    end

    newChunk.GetData = function( chunk, componentName, id )
        local data = nil
        data = chunk.Buffer[componentName][id]

        if data ~= nil then
            return data
        else
            -- 非entity类型的component，第一次使用时才进行取值，lazy init
            local typeInfo = ECS.TypeManager.GetTypeInfoByName(componentName)
            data = ECS.TableUtility.DeepCopy(typeInfo.Prototype)
            chunk:SetData(componentName, id, data)
            return data
        end
    end

    return newChunk
end

function Archetype:ConstructChunk( chunk )
    chunk.Archetype = self

    chunk.Id = self.ChunkCount+1
    chunk.EntityCount = 0

    chunk.Buffer = {}
    for k,v in pairs(self.Types) do
        local componentName = ECS.TypeManager.GetTypeNameByIndex(v.TypeIndex)
        chunk.Buffer[componentName] = {}
    end

    self.ChunkList:Push(chunk)
    self.ChunkCount = self.ChunkCount+1
end

function Archetype:GetChunkFromArchetype(  )
    --- TODO:尝试从池子拿一个chunk块

    -- 初始化chunk，设置大小，指向，链表指针等信息
    local newChunk = self:CreateNewChunk()

    self:ConstructChunk(newChunk)

    return newChunk
end


return Archetype