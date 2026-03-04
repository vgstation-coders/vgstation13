/obj/item/stack/sheet/feather
	name = "feather"
	desc = "A locally-sourced feather."
	singular_name = "feather"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "feather-single"
	w_type = RECYK_BIOLOGICAL
	flammable = TRUE

/obj/item/stack/sheet/feather/New(var/loc, var/amount=null)
	recipes = feather_recipes
	return ..()

//color mapping for feathers
var/list/feather_colors = list(
	"emerald" = list(hex = "#3de47b", name = "emerald"),
	"azure"   = list(hex = "#3d9be4", name = "azure"),
	"brown"   = list(hex = "#a67c52", name = "brown"),
	"white"   = list(hex = "#ffffff", name = "white"),
	"green"   = list(hex = "#808D11", name = "green"), // Default just in case...
	"gray"    = list(hex = "#808080", name = "gray"),
	"black"   = list(hex = "#808080", name = "black") // Chickens don't have black feathers, but they're named black when its clearly gray...
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

/obj/item/stack/sheet/feather/update_icon()
	if(amount > 1)
		icon_state = "feather-stack"
	else
		icon_state = "feather-single"

//So the feathers stack with their own colors only.
/obj/item/stack/sheet/feather/can_stack_with(obj/item/stack/sheet/feather)
	if(!..(feather))
		return FALSE
	return src.color == feather.color

//So that feathers keep their color when they leave the stack.
/obj/item/stack/sheet/feather/transfer_data_from(var/obj/item/stack/sheet/feather/S, var/amount)
	..()
	if(istype(S, /obj/item/stack/sheet/feather))
		src.color = S.color
