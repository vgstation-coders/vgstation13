/obj/item/device/rcd/tile_painter
	name				= "tile painter"
	desc				= "A device used to paint floors in various colours and fashions."

	icon_state			= "tile_painter"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	starting_materials	= list(MAT_IRON = 75000, MAT_GLASS = 37500)

	origin_tech			= "engineering=2;materials=1"

	sparky				= 0

	schematics = list(/datum/rcd_schematic/clear_decals)

/obj/item/device/rcd/tile_painter/New()
	schematics += typesof(/datum/rcd_schematic/tile) - /datum/rcd_schematic/tile/emagged
	. = ..()

/obj/item/device/rcd/tile_painter/emag_act(var/mob/emagger)
	emagged = 1
	spark(src, 5, FALSE)
	to_chat(emagger, "<span class='warning'>You short out the selection circuitry in the [src].</span>")
	var/datum/rcd_schematic/tile/emagged/schematic = new /datum/rcd_schematic/tile/emagged(src)
	schematics = list(schematic)
	selected = schematic

/obj/item/device/rcd/tile_painter/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is spraying tile paint into \his mouth! It looks like \he's trying to commit suicide!</span>")
	playsound(src, 'sound/effects/spray3.ogg', 15, 1)
	return (SUICIDE_ACT_TOXLOSS)

/obj/item/device/rcd/tile_painter/attack_self(var/mob/user)
	if(!emagged)
		return ..()
	to_chat(user, "<span class='warning'>You press the button on the [src], but nothing seems to happen.</span>")
