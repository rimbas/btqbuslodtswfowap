local default_value = "deconstruction-planner"

if mods["atan-null"] then
	default_value = "atan-null"
end

data:extend{
	{
		type="string-setting",
		name="btqbuslodtswfowap-filter-item",
		setting_type="runtime-per-user",
		default_value=default_value,
	},
	{
		type="string-setting",
		name="btqbuslodtswfowap-auto-filter",
		setting_type="runtime-per-user",
		default_value="no-auto",
		allowed_values={
			"no-auto",
			"single-output",
			"fully-defined",
		},
	},
}
