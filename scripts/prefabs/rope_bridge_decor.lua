require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/rope_bridge.zip"),
}

local prefabs =
{
}


local function fn_board()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("board")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetPercent("board",1)
    inst.AnimState:SetLightOverride(1)
    
    inst.length=0.6
    inst.width=2.2
    
    inst:AddTag("decor")
    inst:AddTag("noclick")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("placer")
    
    inst.AnimState:SetFloatParams(-0.05, 0.5, 1)
    
    inst.parts={}
    
    local parts={
        {"rope_bridge_rope_decor",   0, 0.00,  inst.width/1.9, "rope"},
        {"rope_bridge_string_decor", 0, 0.65,  inst.width/1.9, "rope"},
        {"rope_bridge_rope_decor",   0, 0.00, -inst.width/1.9, "rope"},
        {"rope_bridge_string_decor", 0, 0.65, -inst.width/1.9, "rope"},
        {"rope_bridge_stick_decor",   inst.length/2, 0,  inst.width/2, "stick"},
        {"rope_bridge_stick_decor",   inst.length/2, 0, -inst.width/2, "stick"},
        {"rope_bridge_stick_decor",  -inst.length/2, 0,  inst.width/2, "stick"},
        {"rope_bridge_stick_decor",  -inst.length/2, 0, -inst.width/2, "stick"},
    }
    
    local part
    for k,v in pairs(parts) do
        part=SpawnPrefab(v[1])
        part:AddTag("CLASSIFIED")
        part:AddTag("placer")
        part.AnimState:SetLightOverride(1)
        part.AnimState:SetPercent(v[5],1)
        part.entity:SetParent(inst.entity)
        part.Transform:SetPosition(v[2],v[3],v[4])
        table.insert(inst.parts,part)
    end

    return inst
end

local function fn_stick()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("stick")
    inst.AnimState:SetFloatParams(-0.05, 0.0, 1)

    inst:AddTag("decor")
    inst:AddTag("noclick")

    return inst
end

local function fn_rope()
    local inst = CreateEntity()
    
    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("rope")
    
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_GROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFloatParams(-0.05, 0.0, 1)

    inst:AddTag("decor")
    inst:AddTag("noclick")

    return inst
end

local function fn_stump()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("edgestick")

    inst:AddTag("decor")
    inst:AddTag("noclick")

    return inst
end

local function fn_string()
    local inst = CreateEntity()
    
    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("rope")
    
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFloatParams(-0.05, 0.0, 1)

    inst:AddTag("decor")
    inst:AddTag("noclick")

    return inst
end

local function fn_knot()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("knot")

    inst:AddTag("decor")
    inst:AddTag("noclick")

    return inst
end


return Prefab("rope_bridge_board_decor", fn_board, assets, prefabs),
        Prefab("rope_bridge_stick_decor", fn_stick, assets, prefabs),
        Prefab("rope_bridge_stump_decor", fn_stump, assets, prefabs),
        Prefab("rope_bridge_rope_decor", fn_rope, assets, prefabs),
        Prefab("rope_bridge_string_decor", fn_string, assets, prefabs),
        Prefab("rope_bridge_knot_decor", fn_knot, assets, prefabs)
