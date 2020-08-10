local BehaviourDispatch = {}
BehaviourDispatch.all_ecs_objects = {}

function BehaviourDispatch:Register(obj)
    table.insert(BehaviourDispatch.all_ecs_objects, obj)
    print("Behaviour register:"..#BehaviourDispatch.all_ecs_objects..type(obj))
end

function BehaviourDispatch:OnLoad()
    print("Behaviour onload"..#BehaviourDispatch.all_ecs_objects)
end

return BehaviourDispatch
