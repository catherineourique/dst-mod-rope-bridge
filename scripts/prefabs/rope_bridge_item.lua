require "prefabutil"
local easing = require("easing")
local GetPoints = require "prefabs/rope_bridge_getpoints"


local assets =
{
    Asset("ANIM", "anim/rope_bridge_item.zip"),
    Asset("ATLAS", "images/inventoryimages/rope_bridge_item.xml"),
    Asset("IMAGE", "images/inventoryimages/rope_bridge_item.tex"),

}


local prefabs =
{
    "rope_bridge_proj"
}


local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("rope_bridge_proj")
    projectile.Transform:SetPosition(x, y+1, z)
    projectile.ipos=inst:GetPosition()
    projectile.fpos=targetpos
    
    projectile.ipos_x:set(projectile.ipos.x)
    projectile.ipos_y:set(projectile.ipos.y)
    projectile.ipos_z:set(projectile.ipos.z)

    local g=25
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = math.sqrt(rangesq)
    local speed = math.sqrt(g*maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-g)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end


local function CountItem(inst,pfb)
    local num_item=0
    if inst.components.inventory ~= nil then
        for k,v in pairs(inst.components.inventory:FindItems(function(inst) return inst.prefab==pfb end)) do
            if v.components.stackable then
                num_item=num_item+v.components.stackable:StackSize()
            else
                num_item=num_item+1
            end
        end
    elseif inst.replica.inventory ~= nil then
        local inv = inst.replica.inventory:GetItems()
        for k,v in pairs(inv) do
            if v.prefab==pfb then
                if v.replica.stackable then
                    num_item=num_item+v.replica.stackable:StackSize()
                else
                    num_item=num_item+1
                end
            end
        end
        local backpack = inst.replica.inventory:GetOverflowContainer()
        if backpack ~= nil then
            inv = backpack:GetItems()
            for k,v in pairs(inv) do
                if v.prefab==pfb then
                    if v.replica.stackable then
                        num_item=num_item+v.replica.stackable:StackSize()
                    else
                        num_item=num_item+1
                    end
                end
            end
        end
    
    end
    return num_item
end

local function OnDeploy(inst, pt, deployer, rot)
    local pos=deployer:GetPosition()
    local boards,angle,angle_perp = GetPoints(pos,pt,inst.board_max_distance)
    if boards == nil or #boards < 3 then
        return false
    end
    
    local inv_boards=CountItem(deployer,"boards")
    local inv_rope=CountItem(deployer,"rope")
    
    local dx = boards[#boards][1]-boards[1][1]
    local dz = boards[#boards][2]-boards[1][2]
    local dr = math.sqrt(dx*dx+dz*dz)
    
    if dr > inst.deploy_distance then
        return false
    end
    
    if not (inv_boards >= math.ceil(dr*rope_bridge_boards_factor) and inv_rope >= math.ceil(dr*rope_bridge_rope_factor)) then
        return false
    end
    
    deployer.components.inventory:ConsumeByName("boards",math.ceil(dr*rope_bridge_boards_factor))
    deployer.components.inventory:ConsumeByName("rope",math.ceil(dr*rope_bridge_rope_factor))

    local throw_point=Vector3(boards[#boards][1],0,boards[#boards][2])

    LaunchProjectile(deployer,throw_point)
    
    if deployer.player_classified ~= nil then
        deployer.player_classified.rope_bridge_force_toss_state:set(not deployer.player_classified.rope_bridge_force_toss_state:value())
    end
    inst:Remove()
    return true

end

local function CanDeploy(inst, pt, mouseover, deployer)

    local pos=deployer:GetPosition()
    if not TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false) or not TheWorld.Map:IsPassableAtPoint(pos.x, 0, pos.z, false) then
        return false
    end
    if (pos.x-pt.x)*(pos.x-pt.x)+(pos.z-pt.z)*(pos.z-pt.z) < 9 then
        return false
    end
    local boards,angle,angle_perp = GetPoints(pos,pt,inst.board_max_distance)
    if boards == nil or #boards < 3 then
        return false
    end
    
    local inv_boards=CountItem(deployer,"boards")
    local inv_rope=CountItem(deployer,"rope")
    
    local dx = boards[#boards][1]-boards[1][1]
    local dz = boards[#boards][2]-boards[1][2]
    local dr = math.sqrt(dx*dx+dz*dz)
    
    if dr > inst.deploy_distance then
        return false
    end
    
    if not (inv_boards >= math.ceil(dr*rope_bridge_boards_factor) and inv_rope >= math.ceil(dr*rope_bridge_rope_factor)) then
        return false
    end
    
    if not TheWorld.Map:IsPassableAtPoint(pt.x-math.cos(angle)*inst.check_distance, 0, pt.z-math.sin(angle)*inst.check_distance, false)
        and not TheWorld.Map:IsPassableAtPoint(pos.x+math.cos(angle)*inst.check_distance, 0, pos.z+math.sin(angle)*inst.check_distance, false) then
        return true
    end
    
end


local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", 0, 0.8)

 	inst:AddTag("usedeployspacingasoffset_onland")
 	inst:AddTag("rope_bridge")

    inst.AnimState:SetBank("rope_bridge_item")
    inst.AnimState:SetBuild("rope_bridge_item")
    inst.AnimState:PlayAnimation("idle")
    
    inst.deploy_distance=rope_bridge_max_distance

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.deployable.DeploySpacingRadius = function(self) return 50 end -- The real range is limited by GetPoints
	inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
	inst._custom_candeploy_fn = CanDeploy
	inst.components.deployable.deploystring = "deploy"
	
	inst.check_distance=4
    inst.board_max_distance=1.25

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/rope_bridge_item.xml"
    inst.components.inventoryitem.imagename = "rope_bridge_item"
	inst.components.inventoryitem:EnableMoisture(false)

	MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

local function CheckForBoardsRope(inst)
    local inv = inst.replica.inventory:GetItems()
    local num_boards=0
    local num_rope=0
    for k,v in pairs(inv) do
        if v.prefab=="boards" then
            if v.replica.stackable then
                num_boards=num_boards+v.replica.stackable:StackSize()
            else
                num_boards=num_boards+1
            end
        end
        if v.prefab=="rope" then
            if v.replica.stackable then
                num_rope=num_rope+v.replica.stackable:StackSize()
            else
                num_rope=num_rope+1
            end
        end
    end
    local backpack = inst.replica.inventory:GetOverflowContainer()
    if backpack ~= nil then
        inv = backpack:GetItems()
        for k,v in pairs(inv) do
            if v.prefab=="boards" then
                if v.replica.stackable then
                    num_boards=num_boards+v.replica.stackable:StackSize()
                else
                    num_boards=num_boards+1
                end
            end
            if v.prefab=="rope" then
                if v.replica.stackable then
                    num_rope=num_rope+v.replica.stackable:StackSize()
                else
                    num_rope=num_rope+1
                end
            end
        end
    end
    return num_boards,num_rope
end

local function HidePlacer(inst)
     for k,v in pairs(inst.boards) do
        v.Transform:SetPosition(-1000, -1000, -1000)
    end
    for k,v in pairs(inst.stumps) do
        v.Transform:SetPosition(-1000, -1000, -1000)
    end 
end

local function UpdatePlacer(inst)
    ThePlayer.rope_bridge_deploy_string_boards=""
    ThePlayer.rope_bridge_deploy_string_rope=""
    ThePlayer.rope_bridge_deploy_string_colour_boards={ .75, .25, .25, 1 }
    ThePlayer.rope_bridge_deploy_string_colour_rope={ .75, .25, .25, 1 }
    local pos=ThePlayer:GetPosition() -- Since the player is client-side, I think there is no problem to use "ThePlayer" here
    local pt=inst:GetPosition()
    local boards,angle,angle_perp = GetPoints(pos,pt,inst.board_max_distance)
    local ddr=math.sqrt((pos.x-pt.x)*(pos.x-pt.x)+(pos.z-pt.z)*(pos.z-pt.z))
    
    if not TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false) or not TheWorld.Map:IsPassableAtPoint(pos.x, 0, pos.z, false) then
        ThePlayer.rope_bridge_deploy_string_boards="   Not "
        ThePlayer.rope_bridge_deploy_string_rope="passable        "
        HidePlacer(inst)
        return
    end
    
    if boards == nil or 
      not TheWorld.Map:IsPassableAtPoint(pt.x+math.cos(angle)*inst.check_distance, 0, pt.z+math.sin(angle)*inst.check_distance, false) or
      not TheWorld.Map:IsPassableAtPoint(pos.x-math.cos(angle)*inst.check_distance, 0, pos.z-math.sin(angle)*inst.check_distance, false) then
        ThePlayer.rope_bridge_deploy_string_boards="       Missing "
        ThePlayer.rope_bridge_deploy_string_rope="edge    "
        HidePlacer(inst)
        return
    end
        
    if #boards < 3 or ddr < 3 then
        print(boards)
        ThePlayer.rope_bridge_deploy_string_boards="Too "
        ThePlayer.rope_bridge_deploy_string_rope="close"
        HidePlacer(inst)
        return
    end
    
    for k,v in pairs(inst.boards) do
        if k <= #boards then
            v.Transform:SetPosition(boards[k][1]-pt.x, 0, boards[k][2]-pt.z)
            v.Transform:SetRotation(angle_perp*180/math.pi+90)
        else
            v.Transform:SetPosition(-1000, -1000, -1000)
        end
    end
    
    local dx=-1.1
    local dz=1.0
    local cangle=math.cos(angle_perp)
    local sangle=math.sin(angle_perp)
    inst.stumps[1].Transform:SetPosition(boards[1][1]-( cangle*dx+sangle*dz)-pt.x, 0, boards[1][2]-(-sangle*dx+cangle*dz)-pt.z)
    inst.stumps[2].Transform:SetPosition(boards[1][1]-(-cangle*dx+sangle*dz)-pt.x, 0, boards[1][2]-( sangle*dx+cangle*dz)-pt.z)
    inst.stumps[3].Transform:SetPosition(boards[#boards][1]-( cangle*dx-sangle*dz)-pt.x, 0, boards[#boards][2]-(-sangle*dx-cangle*dz)-pt.z)
    inst.stumps[4].Transform:SetPosition(boards[#boards][1]-(-cangle*dx-sangle*dz)-pt.x, 0, boards[#boards][2]-( sangle*dx-cangle*dz)-pt.z)
    
    local dx = boards[#boards][1]-boards[1][1]
    local dz = boards[#boards][2]-boards[1][2]
    local dr = math.sqrt(dx*dx+dz*dz)
    
    if dr > rope_bridge_max_distance then
        ThePlayer.rope_bridge_deploy_string_boards=" Maximum"
        ThePlayer.rope_bridge_deploy_string_rope="distance  "
        return
    end

    local required_boards=math.ceil(dr*rope_bridge_boards_factor)
    local required_rope=math.ceil(dr*rope_bridge_rope_factor)
    
    local inv_boards_num,inv_rope_num
    inv_boards_num,inv_rope_num=CheckForBoardsRope(ThePlayer)
    
    ThePlayer.rope_bridge_deploy_string_boards=string.format("%i/%i", inv_boards_num, required_boards)
    ThePlayer.rope_bridge_deploy_string_rope=string.format("%i/%i", inv_rope_num, required_rope)
    if inv_boards_num >= required_boards then
        ThePlayer.rope_bridge_deploy_string_colour_boards={ .25, .75, .25, 1 }
    end
    if inv_rope_num >= required_rope then
        ThePlayer.rope_bridge_deploy_string_colour_rope={ .25, .75, .25, 1 }
    end
    
end

local function placer_postinit_fn(inst)
    ThePlayer:PushEvent("rope_bridge_hud")
    ThePlayer.rope_bridge_placer_inst=inst
    ThePlayer.rope_bridge_required_boards=0
    ThePlayer.rope_bridge_required_rope=0
    ThePlayer.rope_bridge_distance=0
    ThePlayer.rope_bridge_deploy_string_boards=""
    ThePlayer.rope_bridge_deploy_string_rope=""
    ThePlayer.rope_bridge_deploy_string_colour_boards={0,0,0,0}
    ThePlayer.rope_bridge_deploy_string_colour_rope={0,0,0,0}
    
    inst.interval=FRAMES
    inst.check_distance=4
    
    inst.max_boards=50 -- That much? rly?
    
    inst.boards={}
    inst.stumps={}
    inst.board_max_distance=1.25
    
    for i=1,inst.max_boards do
        local decor=SpawnPrefab("rope_bridge_board_decor")
        decor.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(decor)
        for u,l in pairs(decor.parts) do
            inst.components.placer:LinkEntity(l)
        end
        -- Well, it is weird, but since the "Hide" doenst work here (the like unhide the entity), this is my best choice
        --decor:Hide()
        decor.Transform:SetPosition(-1000, -1000, -1000)
        table.insert(inst.boards,decor)
    end
    
    for i=1,4 do
        local decor=SpawnPrefab("rope_bridge_stump_decor")
        decor.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(decor)
        decor.Transform:SetPosition(-1000, -1000, -1000)
        table.insert(inst.stumps,decor)
    end
    
    inst.update_task=inst:DoPeriodicTask(inst.interval, UpdatePlacer)
    
    return

end


return Prefab("rope_bridge_item", item_fn, assets, prefabs),
    MakePlacer("rope_bridge_item_placer", nil,nil,nil, true, nil, nil, 1, nil, nil, placer_postinit_fn)
