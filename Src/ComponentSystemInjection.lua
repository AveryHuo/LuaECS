local ComponentSystemInjection = {}

local IsFindInStrList = function ( str_list, find_str )
	if not str_list then return false end
	
	for k,v in pairs(str_list) do
		if v == find_str then
			return true
		end
	end
	return false
end

function ComponentSystemInjection.Inject( componentSystem, world, entityManager,
            outInjectGroups, outInjectFromEntityData )
	local inject_info_list = componentSystem:GetInjectInfoList()
	for i,v in ipairs(inject_info_list) do
		local inject_field_name = v[1]
		local inject_info = v[2]
		
		local group = ECS.InjectComponentGroupData.CreateInjection(inject_field_name, inject_info, componentSystem)
		table.insert(outInjectGroups, group)
	end
end

function ComponentSystemInjection:InjectConstructorDependencies( manager, world, field_info, inject_field_name )
	manager[inject_field_name] = world:GetOrCreateManager(field_info[2])	
end

return ComponentSystemInjection