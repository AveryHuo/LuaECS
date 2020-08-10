local ECS = require "ECS"
local TestBaseClass = class()

function TestBaseClass:ctor(  )
	
end

function TestBaseClass:setUp(  )
	-- print('Cat:TestBaseClass.lua[setUp]')
	self.m_PreviousWorld = ECS.World.Active
    ECS.World.Active = ECS.World.new("Test World")
    self.m_World = ECS.World.Active
    self.m_Manager = self.m_World.entityManager
end

function TestBaseClass:tearDown(  )
	-- print('Cat:TestBaseClass.lua[tearDown]')
	if (m_Manager ~= nil) then
        self.m_World = nil
        ECS.World.Active = self.m_PreviousWorld
        self.m_PreviousWorld = nil
        self.m_Manager = nil
	end
end

return TestBaseClass