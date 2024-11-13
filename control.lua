local NORTH	= defines.direction.north
local EAST	= defines.direction.east
local SOUTH	= defines.direction.south
local WEST	= defines.direction.west
local ROTATION = table_size(defines.direction)

---@param player LuaPlayer
local function create_gui(player)
	if player.gui.relative.btqbuslodtswfowap then return end
	local anchor = {gui=defines.relative_gui_type.splitter_gui, position=defines.relative_gui_position.right}
	player.gui.relative
		.add{type="frame", name="btqbuslodtswfowap", anchor=anchor, caption={"btqbuslodtswfowap.block-lane"}}
		.add{type="sprite-button", tooltip={"btqbuslodtswfowap.block-lane"}, sprite="virtual-signal/signal-deny", tags={btqbuslodtswfowap_action=true}}
end

script.on_init(function()
	for _, player in pairs(game.players) do
		create_gui(player)
	end
end)

script.on_event(defines.events.on_player_created, function(event --[[@as EventData.on_player_created]])
	create_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
end)

---@param splitter LuaEntity
---@param output LuaEntity
---@return "left"|"right"
local function get_unused_lane(splitter, output)
	local direction = splitter.direction
	local pos = splitter.position
	local x1, y1 = pos.x, pos.y
	local other_pos = output.position
	local x2, y2 = other_pos.x, other_pos.y
	
	if direction == EAST then
		return y2 < y1 and "right" or "left"
	elseif direction == NORTH then
		return x2 < x1 and "right" or "left"
	elseif direction == SOUTH then
		return x1 < x2 and "right" or "left"
	else
		return y1 < y2 and "right" or "left"
	end
end

script.on_event(defines.events.on_player_flipped_entity, function(event --[[@as EventData.on_player_flipped_entity]])
	local splitter = event.entity
	if splitter == nil or not (splitter.type == "splitter" or (splitter.type == "entity-ghost" and splitter.ghost_name == "splitter")) then return end
	local dir = splitter.direction
	if (dir ~= NORTH and dir ~= SOUTH and event.horizontal) or (dir ~= EAST and dir ~= WEST and not event.horizontal) then return end
	local outputs = splitter.belt_neighbours.outputs
	if #outputs ~= 1 or splitter.splitter_filter ~= nil or splitter.splitter_output_priority ~= "none" or splitter.splitter_input_priority ~= "none" then return end

	splitter.splitter_filter = "deconstruction-planner"
	splitter.splitter_output_priority = get_unused_lane(splitter --[[@as LuaEntity]], outputs[1]--[[@as LuaEntity]])
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.get_player(event.player_index)
	local evt_ele_tags = event.element.tags
	if not player or not evt_ele_tags["btqbuslodtswfowap_action"] then return end
	local splitter = player.opened
	if splitter == nil or (splitter.type ~= "splitter" and splitter.type ~= "entity-ghost" and splitter.ghost_name ~= "splitter") then return end
	local outputs = splitter.belt_neighbours.outputs
	if #outputs ~= 1 then return end

	splitter.splitter_filter = "deconstruction-planner"
	splitter.splitter_output_priority = get_unused_lane(splitter --[[@as LuaEntity]], outputs[1]--[[@as LuaEntity]])
end)
