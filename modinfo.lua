name = "Rope Bridge"
description = [[
Enable the creation of rope bridges

Recipe: 1 Boards and 1 Rope in the Science Machine (Survival Tab)

How to use: Take your Rope Bridge, get close to an edge and aim on the place you want to place a bridge to. You will see in the screen how many boards and ropes you need to create this bridge, so, if you have it, just place it!

It also works in the caves or between boats

NOTE-1: If you place it on a boat, it will be destroyed if the boats moves.
NOTE-2: You can not take your materials back from a bridge you have placed.

Mod Options:
-- Rope Bridge range limit
-- Rope Bridge boards requirement factor
-- Rope Bridge rope requirement factor

Changelog:

--v1.11-1.12: Fixed a duplication bug;
--v1.01-1.10: Added some extra verifications;
--v1.00: Release;



]]
author = "Gleenus and Catherine"
version = "1.12"
forumthread = ""
api_version = 10
dst_compatible = true

all_clients_require_mod = true
client_only_mod = false

server_filter_tags = {"gcmods"}

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

----------------------------
-- Configuration settings --
----------------------------


configuration_options = 
{
    {
		name = "ROPE_BRIDGE_DISTANCE",
		label = "Maximum distance",
		hover = "Maximum distance to throw a rope bridge (in tiles).",
		options =	
		{
		    {description = "1 tile   ", data = 4},
		    {description = "2 tiles", data =  8},
		    {description = "3 tiles", data =  12},
		    {description = "4 tiles", data =  16},
            {description = "5 tiles", data =  20},
			{description = "6 tiles", data = 24},
			{description = "7 tiles", data = 28},
			{description = "8 tiles", data = 32},
			{description = "9 tiles", data = 36},
			{description = "10 tiles", data = 40},
		},
		default = 16,
	},
    {
		name = "ROPE_BRIDGE_BOARDS_RATIO",
		label = "Boards consumption ratio",
		hover = "Number of boards per tile to throw a rope bridge.",
		options =	
		{
		    {description = "0   ", data = 0},
		    {description = "0.25", data =  0.0625},
		    {description = "0.5 ", data =  0.125},
		    {description = "0.75", data =  0.1875},
            {description = "1   ", data =  0.25},
			{description = "1.5 ", data = 0.375},
			{description = "2   ", data = 0.5},
			{description = "3   ", data = 0.75},
			{description = "4   ", data = 1},
			{description = "5   ", data = 1.25},
		},
		default = 0.375,
	},
    {
		name = "ROPE_BRIDGE_ROPE_RATIO",
		label = "Rope consumption ratio",
		hover = "Number of ropes per tile to throw a rope bridge.",
		options =	
		{
		    {description = "0   ", data = 0},
		    {description = "0.25", data =  0.0625},
		    {description = "0.5 ", data =  0.125},
		    {description = "0.75", data =  0.1875},
            {description = "1   ", data =  0.25},
			{description = "1.5 ", data = 0.375},
			{description = "2   ", data = 0.5},
			{description = "3   ", data = 0.75},
			{description = "4   ", data = 1},
			{description = "5   ", data = 1.25},
		},
		default = 0.375,
	},
}

