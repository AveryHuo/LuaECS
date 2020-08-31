---@class TypeManager 全局Type管理器
local TypeManager = {}

TypeManager.TypeCategory = {
	ComponentData = 1,
	BufferData = 2,
	ISharedComponentData = 3,
	EntityData = 4,
	Class = 5,
}
TypeManager.s_Types = {}
TypeManager.s_Systems = {}
TypeManager.s_Count = 0
TypeManager.StaticTypeLookup = {}

---创建typeinfo信息
---@param name type名字
---@param type_desc type的数据
---@return typeinfo对象
function TypeManager.BuildComponentType( name, type_desc )
	local typeSize = 0
	if type(type_desc) == "table" and type_desc.Length then
		typeSize = type_desc.Length
	end
	local type_info = {
		Name = name,
		Prototype = type_desc,
		TypeIndex = TypeManager.s_Count,
		TypeSize = typeSize,
	}
	return type_info
end

---注册一个Type
------@param name type名字
-----@param type_desc type的数据
-----@return typeinfo对象
function TypeManager.RegisterType( name, type_desc )
	if TypeManager.StaticTypeLookup[name] then
		return TypeManager.s_Types[TypeManager.StaticTypeLookup[name]]
	end
	local type_info = TypeManager.BuildComponentType(name, type_desc)
	TypeManager.s_Types[TypeManager.s_Count] = type_info
	TypeManager.StaticTypeLookup[name] = TypeManager.s_Count
	TypeManager.s_Count = TypeManager.s_Count + 1
	return type_info
end

---删除全局的type信息
function TypeManager.CleanAllTypes()
	TypeManager.s_Types = {}
	TypeManager.s_Systems = {}
	TypeManager.s_Count = 0
	TypeManager.StaticTypeLookup = {}
end

---通过type名字获取typeindex
---@param type_name type名字
---@return typeindex
function TypeManager.GetTypeIndexByName( type_name )
	assert(type_name and type_name ~= "", "wrong type name!")
	local index = TypeManager.StaticTypeLookup[type_name]
	assert(index, "had no register type : "..type_name)
	if index then
		return index
	end
end

---通过typeindex获取typeinfo
---@param typeIndex typeindex
---@return typeinfo数据
function TypeManager.GetTypeInfoByIndex( typeIndex )
	return TypeManager.s_Types[typeIndex]
end

---通过typename获取typeinfo
---@param typeName type的名字
---@return typeinfo数据
function TypeManager.GetTypeInfoByName( typeName )
	local index = TypeManager.GetTypeIndexByName(typeName)
	return TypeManager.s_Types[index]
end

---通过typeindex获取type名字
---@param typeIndex typeindex
---@return type名字
function TypeManager.GetTypeNameByIndex( typeIndex )
	local info = TypeManager.s_Types[typeIndex]
	return info and info.Name or "UnkownTypeName"
end

---注册system到ECS的typemanager
---@param name 系统的名字
---@param system System类
function TypeManager.RegisterSystemType( name, system )
	assert(TypeManager.s_Systems[name]==nil, "had register system :"..name)
	TypeManager.s_Systems[name] = system
end

---通过名字获取System类
---@param name system名
---@return system类
function TypeManager.GetSystemType( name )
	return TypeManager.s_Systems[name]
end

---获取全局system的集合
---@return system集合
function TypeManager.GetSystemTypeMap( )
	return TypeManager.s_Systems
end

return TypeManager