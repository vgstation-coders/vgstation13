/**
 * Rework of bunsen burners to use real liquid heating simulations.
 * Oh, and better sprites.
 */
/obj/machinery/bunsen_burner
	name = "bunsen burner"
	desc = "Apply heat to chemical, get violent explosions."
	icon = 'icons/obj/device.dmi'
	icon_state = "bunsen0"

	var/heating = 0		//whether the bunsen is turned on
	var/obj/item/weapon/reagent_containers/held_container

	var/heat_energy = 60 // In Watts

	var/overlay_offset_x = 0
	var/overlay_offset_y = 18

/obj/machinery/bunsen_burner/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers))
		if(held_container)
			user << "\red You must remove the [held_container] first."
		else
			user.drop_item(src)
			held_container = W
			held_container.loc = src
			user << "\blue You put the [held_container] onto the [src]."
			var/image/I = image("icon"=W, "layer"=FLOAT_LAYER)
			I.pixel_x = overlay_offset_x
			I.pixel_y = overlay_offset_y
			overlays += I
	else
		user << "\red You can't put the [W] onto the [src]."

/obj/machinery/bunsen_burner/attack_hand(mob/user as mob)
	if(held_container)
		overlays = null
		user << "\blue You remove the [held_container] from the [src]."
		held_container.loc = src.loc
		held_container.attack_hand(user)
		held_container = null
	else
		user << "\red There is nothing on the [src]."

/obj/machinery/bunsen_burner/verb/toggle()
	set src in view(1)
	set name = "Toggle bunsen burner"
	set category = "Object"

	heating = !heating
	icon_state = "bunsen[heating]"

/obj/machinery/bunsen_burner/process()
	..()
	if(!heating)
		return

	held_container.reagents.process_heat(heat_energy)
	held_container.reagents.handle_reactions()
