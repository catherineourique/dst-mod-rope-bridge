local function CheckForRopeBridge(inst)
    if inst:HasTag("playerghost") or (inst.weremode ~= nil and inst.weremode:value() == 3) then
        inst.components.ropebridgewalker.ison_rope_bridge=false
        return
    end
    local pos=inst:GetPosition()
    if #TheSim:FindEntities(pos.x,pos.y,pos.z,inst.components.ropebridgewalker.radius,{'rope_bridge_walkable'}) > 0 then
        if not inst.components.ropebridgewalker.ison_rope_bridge then
            inst.components.ropebridgewalker:TurnOnWalkable()
        end
    else
        if inst.components.ropebridgewalker.ison_rope_bridge then
            inst.components.ropebridgewalker:TurnOffWalkable()
        end
    end
end

local RopeBridgeWalker = Class(function(self, inst)
    self.inst = inst
    self.radius = 1.5
    self.interval = 2*FRAMES
    self.ison_rope_bridge=false
end)

function RopeBridgeWalker:Start()
    self.task=self.inst:DoPeriodicTask(self.interval,CheckForRopeBridge)
end

function RopeBridgeWalker:TurnOnWalkable()
    if self.inst:HasTag("playerghost") then
        return
    end
    if (self.inst.sg ~= nil and self.inst.sg.currentstate.name ~= "run") or (self.inst.weremode ~= nil and self.inst.weremode:value() == 3) then
        return
    end
    self.ison_rope_bridge=true
    self.inst.Physics:ClearCollisionMask()
    self.inst.Physics:CollidesWith(COLLISION.GROUND)
    self.inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    self.inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    self.inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    self.inst.Physics:CollidesWith(COLLISION.GIANTS)
    if self.inst.components.locomotor then
        self.inst.components.locomotor.allow_platform_hopping=false
    end
    if self.inst.components.drownable ~= nil then
        self.inst.components.drownable.enabled=false
    end
end

function RopeBridgeWalker:ClosestPassableMonteCarlo(tries, var_width)
    local pos=self.inst:GetPosition()
    local px=2*var_width
    local pz=2*var_width
    local width=var_width
    local x,z
    for i=1,tries do
        x=width*2*(math.random()-0.5)
        z=width*2*(math.random()-0.5)
        if TheWorld.Map:IsPassableAtPoint(pos.x+x, 0, pos.z+z, false) then
            if x*x+z*z < px*px+pz*pz then
                px=x
                pz=z
                width=math.sqrt(x*x+z*z)+1
                print(px,pz,width)
            end
        end
    end
    if px*px+pz*pz < width*width then
        self.inst.Transform:SetPosition(pos.x+px, 0, pos.z+pz) 
    else -- If the player somehow get stuck, just clear the collisions
        self.inst:DoTaskInTime(2,function(inst)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.GROUND)
        end)
    end
end

function RopeBridgeWalker:TurnOffWalkable()
    self.ison_rope_bridge=false
    if self.inst.components.locomotor then
        self.inst.components.locomotor.allow_platform_hopping=true
    end
    if self.inst:HasTag("playerghost") then
        return
    end
    if (self.inst.weremode ~= nil and self.inst.weremode:value() == 3) then
        return
    end
    
    self.inst.Physics:ClearCollisionMask()
    self.inst.Physics:CollidesWith(COLLISION.WORLD)
    self.inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    self.inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    self.inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    self.inst.Physics:CollidesWith(COLLISION.GIANTS) 
    if self.inst.components.drownable ~= nil then
        self.inst.components.drownable.enabled=true
        if self.inst.components.drownable:ShouldDrown() then
            if self.inst.sg ~= nil then
                self.inst.sg:GoToState("sink_fast")
            end
        end
    else
        local pos=self.inst:GetPosition()
        if not TheWorld.Map:IsPassableAtPoint(pos.x, 0, pos.z, false) then
            self.inst:PushEvent("death")
            self.inst.AnimState:PlayAnimation("sink",false)
            self.inst.AnimState:SetTime(1.5)
            self.inst:DoTaskInTime(FRAMES, function(inst) inst.AnimState:PlayAnimation("sink",false) inst.AnimState:SetTime(1.5) end)
            self.inst:DoTaskInTime(2.5, function(inst) if not TheWorld.ismastersim then return end inst.components.ropebridgewalker:ClosestPassableMonteCarlo(1000,100) end)
        end
    end
end


return RopeBridgeWalker
