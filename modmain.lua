local _G = GLOBAL

Assets = {
    Asset("ATLAS", "images/inventoryimages/rope_bridge_item.xml"),
    Asset("IMAGE", "images/inventoryimages/rope_bridge_item.tex"),
    Asset("ANIM", "anim/ui_construction_4x1.zip"),
}

PrefabFiles =
{
    "rope_bridge",
    "rope_bridge_item",
    "rope_bridge_decor",
    "rope_bridge_proj",
}

local old_ExtraDeployDist = _G.ACTIONS.DEPLOY.extra_arrive_dist
local old_strfn = _G.ACTIONS.DEPLOY.strfn

local function new_ExtraDeployDist(doer, dest, bufferedaction)
	if dest ~= nil then
	    if not bufferedaction.invobject:HasTag("usedeployspacingasoffset_onland") then
	        return old_ExtraDeployDist(doer, dest, bufferedaction)
	    end
	    
		return ((bufferedaction ~= nil and bufferedaction.invobject ~= nil and
		        bufferedaction.invobject.replica.inventoryitem ~= nil and
		        bufferedaction.invobject.replica.inventoryitem:DeploySpacingRadius()) or 0) + 1.0
        end
    return 0
end


local function new_strfn(act)
	return (act.invobject ~= nil and (act.invobject:HasTag("rope_bridge") and "ROPE_BRIDGE")) or old_strfn(act)
end


_G.ACTIONS.DEPLOY.extra_arrive_dist=new_ExtraDeployDist
_G.ACTIONS.DEPLOY.strfn=new_strfn

_G.STRINGS.ACTIONS.DROP.ROPE_BRIDGE="Place Rope Bridge"
_G.STRINGS.ACTIONS.DEPLOY.ROPE_BRIDGE="Place Rope Bridge"
_G.STRINGS.ACTIONS.TOGGLE_DEPLOY_MODE.ROPE_BRIDGE="Place Rope Bridge"

AddMinimapAtlas("images/inventoryimages/rope_bridge_item.xml")


AddPrefabPostInit("player_classified", function(inst)
    inst.rope_bridge_force_toss_state = _G.net_bool(inst.GUID, "rope_bridge_force_toss_state", "rope_bridge_force_toss_state")
    inst:ListenForEvent("rope_bridge_force_toss_state", function(inst,data)
        local parent=inst.entity:GetParent()
        if parent ~= nil and parent.sg ~= nil then
            parent.sg:GoToState("throw")
        end
    end)
    -- I'm adding this to the player_classified to avoid the client to make weird unecessary computations
    inst:DoTaskInTime(2*_G.FRAMES, function(inst)
        local parent=inst.entity:GetParent()
        if parent.components.ropebridgewalker == nil then
            parent:AddComponent("ropebridgewalker")
        end
        parent.components.ropebridgewalker:Start()
        parent.rope_bridge_deploy_string_boards=""
        parent.rope_bridge_deploy_string_rope=""
        parent.rope_bridge_deploy_string_colour_boards={0,0,0,0}
        parent.rope_bridge_deploy_string_colour_rope={0,0,0,0}
    end)
end)


local function AddRopeBridgeHUD(self)

	self.inst:DoTaskInTime( 0, function()

        local RopeBridgeHUD = require "widgets/rope_bridge_hud"
		self.rope_bridge_hud = self:AddChild( RopeBridgeHUD(self.owner) )
		local hud_scale = self.containerroot:GetScale()
	    local screensize_x, screensize_y
	    screensize_x, screensize_y=_G.TheSim:GetScreenSize()
        local ssx=screensize_x/1432./hud_scale.x
        local ssy=screensize_y/812./hud_scale.y
        self.rope_bridge_hud:MoveToBack()
        self.rope_bridge_hud:SetScale(ssx,ssy)
		self.rope_bridge_hud:Hide()
	end)

end

AddClassPostConstruct( "widgets/controls", AddRopeBridgeHUD )


-- I don't like to use global variables, but its much easier in this case
_G.rope_bridge_max_distance=GetModConfigData("ROPE_BRIDGE_DISTANCE")
_G.rope_bridge_boards_factor=GetModConfigData("ROPE_BRIDGE_BOARDS_RATIO")
_G.rope_bridge_rope_factor=GetModConfigData("ROPE_BRIDGE_ROPE_RATIO")


AddRecipe("rope_bridge_item",
	{
		GLOBAL.Ingredient("boards", 1),
		GLOBAL.Ingredient("rope", 1),
	},
	GLOBAL.RECIPETABS.SURVIVAL,
	GLOBAL.TECH.SCIENCE_ONE,
	nil, -- placer
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	nil, -- builder_tag
	"images/inventoryimages/rope_bridge_item.xml", -- atlas
	"rope_bridge_item.tex" -- image
)



GLOBAL.STRINGS.NAMES.ROPE_BRIDGE_ITEM = "Rope Bridge"
GLOBAL.STRINGS.RECIPE_DESC.ROPE_BRIDGE_ITEM = "What could possibly go wrong?"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROPE_BRIDGE_ITEM = "What could possibly go wrong?"

GLOBAL.STRINGS.NAMES.ROPE_BRIDGE_STUMP = "Rope Bridge"
GLOBAL.STRINGS.RECIPE_DESC.ROPE_BRIDGE_STUMP = "What could possibly go wrong?"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROPE_BRIDGE_STUMP = "What could possibly go wrong?"
