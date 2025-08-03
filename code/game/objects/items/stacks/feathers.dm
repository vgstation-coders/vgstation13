//color mapping for feathers
var/list/feather_colors = list(
	"emerald" = list(hex = "#3de47b", name = "emerald"),
	"azure"   = list(hex = "#3d9be4", name = "azure"),
	"brown"   = list(hex = "#a67c52", name = "brown"),
	"white"   = list(hex = "#ffffff", name = "white"),
	"green"   = list(hex = "#808D11", name = "green"), // Default just in case...
	"gray"    = list(hex = "#808080", name = "gray")
)

//procs
/proc/get_vox_color_key(s_tone)
	switch(s_tone)
		if(VOXEMERALD)
			return "emerald"
		if(VOXAZURE)
			return "azure"
		if(VOXBROWN)
			return "brown"
		if(VOXGREEN)
			return "green"
		if(VOXGRAY)
			return "gray"
		else
			return "green"

/obj/item/stack/sheet/feather
	name = "feather"
	desc = "A locally-sourced feather."
	singular_name = "feather"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "feather-single"
	w_type = RECYK_BIOLOGICAL
	flammable = TRUE
