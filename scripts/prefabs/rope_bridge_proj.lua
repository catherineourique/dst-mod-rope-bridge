local assets =
{
    Asset("ANIM", "anim/rope_bridge_item.zip"),
    Asset("ATLAS", "images/inventoryimages/rope_bridge_item.xml"),
    Asset("IMAGE", "images/inventoryimages/rope_bridge_item.tex"),

}


local prefabs =
{
}

local function SpawnBridgeNodes(inst, attacker, target)
    local pos=inst.ipos
    local pt =inst.fpos
    local node=SpawnPrefab("rope_bridge_node")
    node.Transform:SetPosition(pos.x,0,pos.z)
    node.is_main=true
    node.brother=SpawnPrefab("rope_bridge_node")
    node.brother.brother=node
    node.brother.is_main=false
    node.brother.Transform:SetPosition(pt.x,0,pt.z)
    node.brother_pos_x=pt.x
    node.brother_pos_z=pt.z
    
    node.PlaceBridge(node)
    inst:Remove()
end

local function UpdateDecor(inst)
    local pos=inst:GetPosition()
    local dx=pos.x-inst.ipos_x:value()
    local dy=pos.y-inst.ipos_y:value()
    local dz=pos.z-inst.ipos_z:value()
    local dr=math.sqrt(dx*dx+dz*dz)
    
    for k,v in pairs(inst.decor) do
        v.Transform:SetPosition(
            -dr+(k-1)*dr/inst.num_decor,
            -dy+(k-1)*dy/inst.num_decor,
            0    
        )

    end

end

local function proj_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetDontRemoveOnSleep(true)

 	inst:AddTag("rope_bridge")
 	inst:AddTag("noclick")
 	inst:AddTag("projectile")

    inst.AnimState:SetBank("rope_bridge_item")
    inst.AnimState:SetBuild("rope_bridge_item")
    inst.AnimState:PlayAnimation("fly",true)
    
    
    inst.ipos=Vector3(0,0,0)
    inst.fpos=Vector3(0,0,0)
    
    inst.ipos_x=net_float(inst.GUID,"ipos_x")
    inst.ipos_y=net_float(inst.GUID,"ipos_y")
    inst.ipos_z=net_float(inst.GUID,"ipos_z")
    
    
    inst.num_decor=100
    
    if not TheNet:IsDedicated() then -- client-side decor
        inst.decor={}
        local decor
        for i=1,inst.num_decor do
            decor=SpawnPrefab("rope_bridge_knot_decor")
            decor.AnimState:SetPercent("knot",1)
            decor.entity:SetParent(inst.entity)
            table.insert(inst.decor,decor)
        end
        inst._update_decor_task=inst:DoPeriodicTask(FRAMES,UpdateDecor)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst:AddComponent("complexprojectile")
    
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 0, 0))
    inst.components.complexprojectile:SetOnHit(SpawnBridgeNodes)
    
    inst.onload = function(inst,data) inst:Remove() end

    return inst
end


return Prefab("rope_bridge_proj", proj_fn, assets, prefabs)
