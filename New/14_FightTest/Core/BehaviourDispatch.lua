local BehaviourDispatch = {}
BehaviourDispatch.all_ecs_objects = {}

function BehaviourDispatch:Register(obj)
    table.insert(BehaviourDispatch.all_ecs_objects, obj)
    print("Behaviour register:"..#BehaviourDispatch.all_ecs_objects)
end

function BehaviourDispatch:Update()
    for i=1,#BehaviourDispatch.all_ecs_objects do
        if BehaviourDispatch.all_ecs_objects[i].Update then
            BehaviourDispatch.all_ecs_objects[i]:Update()
        end
    end
end

return BehaviourDispatch
