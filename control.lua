local NORTH	= defines.direction.north
local EAST	= defines.direction.east
local SOUTH	= defines.direction.south
local WEST	= defines.direction.west
local ROTATION = table_size(defines.direction)

---@alias NarrowedSplitterPriority
---| "left"
---| "right"

---@alias PlayerSutoFilterSetting
---| "no-auto
---| "single-output"
---| "fully-defined"

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

local fallback = "deconstruction-planner"

---@param player number
---@return string
local function get_player_filter_item(player)
	local ply_setting = settings.get_player_settings(player)
	local value = ply_setting["btqbuslodtswfowap-filter-item"].value
	if prototypes.item[value] then
		return value --[[@as string]]
	end
	game.print{"", "[color=red]", {"btqbuslodtswfowap.filter-item-wrong", value}, "[/color]"}
	ply_setting["btqbuslodtswfowap-filter-item"] = {value = fallback}
	return fallback
end

---@param player number
---@return PlayerSutoFilterSetting
local function get_player_auto_filter(player)
	return settings.get_player_settings(player)["btqbuslodtswfowap-auto-filter"].value --[[@as PlayerSutoFilterSetting]]
end

---@param entity LuaEntity
local function get_entity_type(entity)
	if entity == nil or not entity.valid then return end
	local typ = entity.type
	return typ == "entity-ghost" and entity.ghost_type or typ
end

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

---@param splitter LuaEntity
---@param filter string
---@param priority NarrowedSplitterPriority
local function set_splitter_settings(splitter, filter, priority)
	splitter.splitter_filter = filter
	splitter.splitter_output_priority = priority
end

script.on_event(defines.events.on_player_flipped_entity, function(event --[[@as EventData.on_player_flipped_entity]])
	local splitter = event.entity
	local typ = get_entity_type(splitter)
	if typ == "splitter" then
		local dir = splitter.direction
		if (dir ~= NORTH and dir ~= SOUTH and event.horizontal) or (dir ~= EAST and dir ~= WEST and not event.horizontal) then return end
		local outputs = splitter.belt_neighbours.outputs
		if #outputs ~= 1 or splitter.splitter_filter ~= nil or splitter.splitter_output_priority ~= "none" or splitter.splitter_input_priority ~= "none" then return end

		set_splitter_settings(
			splitter,
			get_player_filter_item(event.player_index),
			get_unused_lane(splitter --[[@as LuaEntity]], outputs[1]--[[@as LuaEntity]])
		)
	elseif typ == "lane-splitter" then
		-- local neighbours = splitter.belt_neighbours
		if splitter.splitter_filter ~= nil or splitter.splitter_output_priority ~= "none" or splitter.splitter_input_priority ~= "none" then return end
		set_splitter_settings(
			splitter,
			get_player_filter_item(event.player_index),
			"right"
		)
		-- if #neighbours.outputs == 0 then
		-- else
		-- 	local outputs = splitter.belt_neighbours.outputs
			
		-- 	---@param lane LuaTransportLine
		-- 	---@param text any
		-- 	local function render_transport_line_end(lane, text)
		-- 		local pos = lane.get_line_item_position(0)
		-- 		rendering.draw_circle{
		-- 			surface = splitter.surface_index,
		-- 			target= pos,
		-- 			radius = 0.1,
		-- 			filled = true,
		-- 			color = {1, 1, 1}
		-- 		}
		-- 		rendering.draw_text{
		-- 			surface = splitter.surface_index,
		-- 			target = pos,
		-- 			text = text,
		-- 			color = {0, 0, 0},
		-- 			vertical_alignment = "middle",
		-- 			alignment = "center",
		-- 			scale = 0.5,
		-- 		}
		-- 	end
			
		-- 	---@param belt LuaEntity
		-- 	local function traverse_belt(belt)
		-- 		if belt.type ~= "belt" then return end
		-- 		return output
		-- 	end
		-- 	-- game.print("huh")
		-- end
	-- else
	-- 	game.print("huh")
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.get_player(event.player_index)
	local evt_ele_tags = event.element.tags
	if not player or not evt_ele_tags["btqbuslodtswfowap_action"] then return end
	local splitter = player.opened --[[@as LuaEntity]]
	local typ = get_entity_type(splitter)
	if typ == "splitter" then
		local outputs = splitter.belt_neighbours.outputs
		if #outputs ~= 1 then return end

		set_splitter_settings(
			splitter --[[@as LuaEntity]],
			get_player_filter_item(event.player_index),
			get_unused_lane(splitter --[[@as LuaEntity]], outputs[1]--[[@as LuaEntity]])
		)
	elseif typ == "lane-splitter" then
		set_splitter_settings(
			splitter,
			get_player_filter_item(event.player_index),
			"right"
		)
	end
end)

---@param event EventData.on_built_entity
local function created_entity(event)
	local splitter = event.entity
	local player = game.get_player(event.player_index)
	if not splitter or not splitter.valid or (player and player.is_cursor_blueprint()) then return end
	
	
	local neighbours = splitter.belt_neighbours
	local outputs = neighbours.outputs
	local player_setting = get_player_auto_filter(event.player_index)
	local in_c, out_c = #neighbours.inputs, #outputs
	
	if (
		player_setting == "fully-defined" and in_c == 2 and out_c == 1
		or player_setting == "single-output" and out_c == 1
	) then
		set_splitter_settings(
			splitter,
			get_player_filter_item(event.player_index),
			get_unused_lane(splitter --[[@as LuaEntity]], outputs[1]--[[@as LuaEntity]])
		)
	end
end

script.on_event(
	defines.events.on_built_entity,
	created_entity,
	{
		{filter="type", type="splitter"},
		{filter="ghost_type", type="splitter", mode="or"},
	}
)
