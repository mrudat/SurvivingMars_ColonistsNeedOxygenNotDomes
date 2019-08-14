DefineClass("ModOptions_VdfZ0nh", {
	__parents = {
		"ModOptionsObject",
	},
	properties = {
		{
			default = 10,
			editor = "number",
			id = "AirAndWaterPerColonist",
			max = 100,
			min = 1,
			name = T("Oxygen and Water used by 1000 colonists"),
			slider = true,
		},
		{
			default = 50,
			editor = "number",
			id = "PowerPerColonist",
			max = 100,
			min = 0,
			name = T("Power used by 1000 colonists"),
			slider = true,
		},
		{
			default = 25,
			editor = "number",
			id = "WaterPerGeoscapeColonist",
			max = 100,
			min = 1,
			name = T("Water used by 1000 colonists in a geoscape dome"),
			slider = true,
		},
		{
			default = false,
			editor = "bool",
			id = "Disable",
			name = T("Disable for uninstall"),
		},
	},
})