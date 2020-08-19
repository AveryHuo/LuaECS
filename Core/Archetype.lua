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

return Archetype