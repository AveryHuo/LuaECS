local TypeManager = {}
ECS.TypeManager = TypeManager

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

function TypeManager:CleanAllTypes()
	TypeManager.s_Types = {}
	TypeManager.s_Systems = {}
	TypeManager.s_Count = 0
	TypeManager.StaticTypeLookup = {}
end


function TypeManager.GetTypeIndexByName( type_name )
	assert(type_name and type_name ~= "", "wrong type name!")
	local index = TypeManager.StaticTypeLookup[type_name]
	assert(index, "had no register type : "..type_name)
	if index then
		return index
	end
end

function TypeManager.GetTypeInfoByIndex( typeIndex )
	return TypeManager.s_Types[typeIndex]
end

function TypeManager.GetTypeInfoByName( typeName )
	local index = TypeManager.GetTypeIndexByName(typeName)
	return TypeManager.s_Types[index]
end

function TypeManager.GetTypeNameByIndex( typeIndex )
	local info = TypeManager.s_Types[typeIndex]
	return info and info.Name or "UnkownTypeName"
end

function TypeManager.RegisterSystemType( name, system )
	assert(TypeManager.s_Systems[name]==nil, "had register system :"..name)
	TypeManager.s_Systems[name] = system
end

function TypeManager.GetSystemType( name )
	return TypeManager.s_Systems[name]
end

function TypeManager.GetSystemTypeMap( )
	return TypeManager.s_Systems
end

return TypeManager