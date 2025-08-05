local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local InvSlot = require "widgets/invslot"

local function RopeBridgeHUDOpen(self)
    if  self.owner ~= nil then
        local mouse_pos=TheInput:GetScreenPosition()
        self:SetPosition(mouse_pos.x+self.shift_x, mouse_pos.y+self.shift_y,0)
        self.bg:GetAnimState():PlayAnimation("open", false)
        self.is_open=true
        self.is_closing=false
        self.slot_height=1
        self.slot_boards:SetScale(1,1)
        self.slot_rope:SetScale(1,1)
        self:Show()
        self:StartUpdating()
        return true
    end
    return false
end



local RopeBridgeHUD = Class(Widget, function(self, owner)
	self.owner = owner
    Widget._ctor(self, "RopeBridgeHUD")
    
    self.screensize_x, self.screensize_y=TheSim:GetScreenSize()
    self.ssx=self.screensize_x/1432.
    self.ssy=self.screensize_y/812.
    
    self.shift_x=200*self.ssx
    self.shift_y=100*self.ssy
    

    self.bg = self:AddChild(UIAnim())
    self.bg:GetAnimState():SetBank("ui_construction_4x1")
    self.bg:GetAnimState():SetBuild("ui_construction_4x1")
    self.bg:SetScale(0.35,0.4)
    self.bg:GetAnimState():PlayAnimation("open", false)
    
    self.shift_x_slot=40
    self.shift_y_slot=7
    
    self.slot_boards=self:AddChild(InvSlot(1, "images/hud.xml", "inv_slot_construction.tex", self.owner, nil))    
    self.slot_rope=self:AddChild(InvSlot(1, "images/hud.xml", "inv_slot_construction.tex", self.owner, nil))

    self.slot_boards:SetPosition(-self.shift_x_slot,-self.shift_y_slot,0)
    self.slot_rope:SetPosition(self.shift_x_slot,-self.shift_y_slot,0)
    
    self.slot_boards:SetBGImage2("images/inventoryimages.xml", "boards.tex", { 1, 1, 1, .4 })
    self.slot_rope:SetBGImage2("images/inventoryimages.xml", "rope.tex", { 1, 1, 1, .4 })
    
    self.inv_boards_num=0
    self.inv_rope_num=0
    
    self.slot_boards:SetLabel( string.format("%i/%i", self.inv_boards_num, 0), { .25, .75, .25, 1 } )
    self.slot_rope:SetLabel( string.format("%i/%i", self.inv_rope_num, 0), { .25, .75, .25, 1 } )
    
    
    self.slot_height=1
    
    self.last_time=-1
    self.is_closing_duration=0.1
    self.is_open = false
    self.is_closing = false
    
    self.inst:ListenForEvent("rope_bridge_hud", function(inst)
        RopeBridgeHUDOpen(self)
    end, self.owner)
    
end)


function RopeBridgeHUD:OnUpdate(dt)
    if (ThePlayer.rope_bridge_placer_inst == nil or not ThePlayer.rope_bridge_placer_inst:IsValid()) and not self.is_closing then
        self.is_closing=true
        self.last_time=GetTime()
        self.bg:GetAnimState():PlayAnimation("close", false)
    end
    
    if self.is_closing then
        self.slot_height=0.7*self.slot_height
        self.slot_boards:SetScale(1,self.slot_height)
        self.slot_rope:SetScale(1,self.slot_height)
        if GetTime()-self.last_time > self.is_closing_duration then
            self.is_closing=false
            self.is_open=false
            self:Hide()
            self:StopUpdating()
        end
    end
    
    if ThePlayer.rope_bridge_deploy_string_boards ~= nil and ThePlayer.rope_bridge_deploy_string_colour_boards ~= nil then
        self.slot_boards:SetLabel( ThePlayer.rope_bridge_deploy_string_boards, ThePlayer.rope_bridge_deploy_string_colour_boards)
        if ThePlayer.rope_bridge_deploy_string_colour_boards[2] > 0.5 then
            self.slot_boards.bgimage2:SetTint(1,1,1,1)
        else
            self.slot_boards.bgimage2:SetTint(1,1,1,0.4)
        end
    end
    if ThePlayer.rope_bridge_deploy_string_rope ~= nil and ThePlayer.rope_bridge_deploy_string_colour_rope ~= nil then
        self.slot_rope:SetLabel( ThePlayer.rope_bridge_deploy_string_rope, ThePlayer.rope_bridge_deploy_string_colour_rope)
        if ThePlayer.rope_bridge_deploy_string_colour_rope[2] > 0.5 then
            self.slot_rope.bgimage2:SetTint(1,1,1,1)
        else
            self.slot_rope.bgimage2:SetTint(1,1,1,0.4)
        end
    end
    
    local mouse_pos=TheInput:GetScreenPosition()
    self:SetPosition(mouse_pos.x+self.shift_x, mouse_pos.y+self.shift_y,0)
end

return RopeBridgeHUD
