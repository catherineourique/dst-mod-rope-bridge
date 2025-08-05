require "prefabutil"
local GetPoints = require "prefabs/rope_bridge_getpoints"

local assets =
{
    Asset("ANIM", "anim/rope_bridge.zip"),
    Asset("ATLAS", "images/inventoryimages/rope_bridge_item.xml"),
    Asset("IMAGE", "images/inventoryimages/rope_bridge_item.tex"),
}

local prefabs =
{
    "collapse_small",
    "rope_bridge_rope_decor",
    "rope_bridge_string_decor",
}

local function hammered_aux(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
end

local function onhammered_board(inst, worker)
    hammered_aux(inst)
    for k,v in pairs(inst.parts) do
        v:Remove()
    end
    inst:Remove()
end

local function onhammered(inst, worker)
    if inst.master == nil then
        hammered_aux(inst)
        inst:Remove()
        return
    end
    if worker ~= inst.master then
        inst.master.RemoveBridge(inst.master)
        return
    end

    hammered_aux(inst)
    
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    --inst.SoundEmitter:PlaySound("dontstarve/common/winter_meter_craft")
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn_board()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 
    inst.entity:AddNetwork()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "rope_bridge_item.tex" )

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("board")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    
    inst.AnimState:SetFloatParams(-0.05, 0.5, 1)

    inst:AddTag("structure")
    inst:AddTag("noclick")
    inst:AddTag("rope_bridge_walkable")
    inst:AddTag("rope_bridge_part")
    
    inst.length=0.6
    inst.width=2.2

    inst.entity:SetPristine()
    
    inst:DoTaskInTime(0.1, function(inst)
        if not TheNet:IsDedicated() then -- decor are placed in the client, not in the server
            local rope
            local rope_pos={
                {"rope_bridge_rope_decor",   0, 0.00,  inst.width/1.9},
                {"rope_bridge_string_decor", 0, 0.65,  inst.width/1.9},
                {"rope_bridge_rope_decor",   0, 0.00, -inst.width/1.9},
                {"rope_bridge_string_decor", 0, 0.65, -inst.width/1.9},
            }
            for k,v in pairs(rope_pos) do
                rope=SpawnPrefab(v[1])
                rope.entity:SetParent(inst.entity)
                rope.Transform:SetPosition(v[2],v[3],v[4])
                --rope.Transform:SetRotation(angle)
                --table.insert(inst.parts,rope)
            end
        end
    end)
    

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.parts={}  
    
    inst:DoTaskInTime(0.1, function(inst)
        local pos=inst:GetPosition()
        local angle=inst:GetRotation()
        local coords={  {inst.length/2, inst.width/2},
                        {inst.length/2, -inst.width/2},
                        {-inst.length/2, inst.width/2},
                        {-inst.length/2, -inst.width/2}}
        local dx, dz, ccos, csin
        ccos=math.cos(angle/180.*math.pi)
        csin=math.sin(angle/180.*math.pi)
        for i=1,4 do
            dx=coords[i][1]*ccos+coords[i][2]*csin
            dz=-coords[i][1]*csin+coords[i][2]*ccos
            local stick=SpawnPrefab("rope_bridge_stick")
            stick.Transform:SetPosition(pos.x+dx,0, pos.z+dz)
            table.insert(inst.parts,stick)
        end
    end)
    
    inst.OnLoad = function(inst, data) inst:Remove() end

    return inst
end

local function fn_stick()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst,0.25)

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("stick")
    inst.AnimState:SetFloatParams(-0.05, 0.0, 1)

    inst:AddTag("structure")
    inst:AddTag("noclick")
    inst:AddTag("rope_bridge_part")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.OnLoad = function(inst, data) inst:Remove() end

    return inst
end

local function fn_stump()
    local inst = CreateEntity()

    inst.entity:AddTransform() 
    inst.entity:AddAnimState() 
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst,0.3)

    inst.AnimState:SetBank("rope_bridge")
    inst.AnimState:SetBuild("rope_bridge")
    inst.AnimState:PlayAnimation("edgestick")

    inst:AddTag("structure")
    inst:AddTag("rope_bridge_part")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst.OnLoad = function(inst, data) inst:Remove() end

    return inst
end

local function OnSaveNode(inst,data)
    data.is_main = inst.is_main
    if inst.is_main then
        data.brother_pos_x=inst.brother_pos_x
        data.brother_pos_z=inst.brother_pos_z
    end
end

local function OnLoadNode(inst,data)
    if not data.is_main then
        inst:Remove()
    else
        local brother=SpawnPrefab("rope_bridge_node")
        inst.is_main=true
        brother.is_main=false
        
        inst.brother_pos_x=data.brother_pos_x
        inst.brother_pos_z=data.brother_pos_z
        
        inst.brother=brother
        brother.brother=inst
        brother.Transform:SetPosition(inst.brother_pos_x,0,inst.brother_pos_z)
        
        inst.PlaceBridge(inst)
    end

end

local function CheckForValidPoints(inst)
    if inst.brother == nil or not inst.brother:IsValid() then
        return
    end
    local pos=inst:GetPosition()
    local pt=inst.brother:GetPosition()
    return GetPoints(pos,pt,inst.board_max_distance)
end

local function RemoveBridge(inst)
    for k,v in pairs(inst.boards) do
        onhammered_board(v,inst)
    end
    for k,v in pairs(inst.stumps) do
        onhammered(v,inst)
    end
    if inst ~= nil then
        if inst.brother ~= nil then
            inst.brother:Remove()
        end
        inst:Remove()
    end        
end

local function PlaceBridge(inst)
    inst.boards={}
    inst.stumps={}
    
    local bridge, angle, angle_perp=inst.CheckForValidPoints(inst)
    if bridge == nil then
        inst.brother:Remove()
        inst:Remove()
        return
    end
    
    inst.bridge=bridge
    
    for k,v in pairs(bridge) do
        local collision=TheSim:FindEntities(v[1],0,v[2],1,{"rope_bridge_part"})
        if #collision > 0 then
            for k,v in pairs(collision) do
                if v.master then
                    v.master.RemoveBridge(v.master)
                end
            end
        end
        local board=SpawnPrefab("rope_bridge_board")
        board.master=inst
        board.Transform:SetRotation(angle_perp*180/math.pi+90)
        board.Transform:SetPosition(v[1],0,v[2])
        table.insert(inst.boards,board)
    end
    
    angle=angle_perp
    local pos, stump
    local dx=-1.1
    local dz=1.0
    local cangle=math.cos(angle)
    local sangle=math.sin(angle)
    local ipos=inst.boards[1]:GetPosition()
    local fpos=inst.boards[#inst.boards]:GetPosition()
    local stump_pos={
            { ipos.x-( cangle*dx+sangle*dz), ipos.z-(-sangle*dx+cangle*dz)},
            { ipos.x-(-cangle*dx+sangle*dz), ipos.z-( sangle*dx+cangle*dz)},
            { fpos.x-( cangle*dx-sangle*dz), fpos.z-(-sangle*dx-cangle*dz)},
            { fpos.x-(-cangle*dx-sangle*dz), fpos.z-( sangle*dx-cangle*dz)},
            }
    
    for k,v in pairs(stump_pos) do
        stump=SpawnPrefab("rope_bridge_stump")
        stump.master=inst
        stump.Transform:SetPosition(v[1], 0, v[2])
        table.insert(inst.stumps,stump)
    end
    
    inst.CheckTask = inst:DoPeriodicTask(inst.check_interval, function(inst)
        for i=1,#inst.boards do
            local pos=inst.boards[i]:GetPosition()
            local dx=pos.x-inst.bridge[i][1]
            local dz=pos.z-inst.bridge[i][2]
            if dx*dx+dz*dz > inst.threshold then
                inst.RemoveBridge(inst)
            end
        end
    end)
    
end


local function fn_node()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.is_main=false
    inst.brother=nil
    inst.boards={}
    inst.bridge={}
    inst.stump={}
    inst.brother_pos_x=0
    inst.brother_pos_z=0
    inst.threshold=0.1
    inst.check_interval=1
    
    inst.board_max_distance=1.25
    
    inst.CheckForValidPoints=CheckForValidPoints
    inst.RemoveBridge=RemoveBridge
    inst.PlaceBridge=PlaceBridge
    inst.OnSave = OnSaveNode
    inst.OnLoad = OnLoadNode
    

    return inst
end

return Prefab("rope_bridge_board", fn_board, assets, prefabs),
        Prefab("rope_bridge_stick", fn_stick, assets, prefabs),
        Prefab("rope_bridge_stump", fn_stump, assets, prefabs),
        Prefab("rope_bridge_node", fn_node, assets, prefabs)
