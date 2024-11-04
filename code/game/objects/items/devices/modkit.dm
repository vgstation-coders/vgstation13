//Was previously used exclusively to convert hardsuits. I've modified it so it can convert absolutely any item into any other item -Deity Link (24/08/2015)
/obj/item/device/modkit
	name = "modification kit"
	desc = "A kit containing all the needed tools and parts to modify an item into another one."
	icon_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"
	var/list/parts = list()		//how many times can this kit perform a given modification
	var/list/original = list()	//the starting parts
	var/list/finished = list()	//the finished products
	toolsounds = list('sound/items/Screwdriver.ogg')

/obj/item/device/modkit/New()
	..()
	parts = new/list(2)
	original = new/list(2)
	finished = new/list(2)

	parts[1] =	1
	original[1] = /obj/item/clothing/suit/space/rig
	finished[1] = /obj/item/clothing/suit/cardborg

/obj/item/device/modkit/afterattack(obj/O, mob/user as mob)
	if(get_dist(O,user) > 1)//For all those years you could use it at any range, what the actual fuck?
		return

	var/to_type = null
	var/parts_left = 0
	var/j = 0

	for(var/i=1;i<=original.len;i++)
		var/original_type = original[i]
		if(istype(O,original_type))
			to_type = finished[i]
			parts_left = parts[i]
			j = i
	if(!to_type)
		to_chat(user, "<span class='warning'>You cannot modify \the [O] with this kit.</span>")
		return
	if(parts_left <= 0)
		to_chat(user, "<span class='warning'>This kit has no parts for this modification left.</span>")
		return
	if(istype(O,to_type))
		to_chat(user, "<span class='notice'>\The [O] is already modified.</span>")
		return
	if(!isturf(O.loc))
		to_chat(user, "<span class='warning'>\The [O] must be safely placed on the ground for modification.</span>")
		return
	playtoolsound(user.loc, 100)
	var/N = new to_type(O.loc)
	user.visible_message("<span class='warning'>[user] opens \the [src] and modifies \the [O] into \the [N].</span>","<span class='warning'>You open \the [src] and modify \the [O] into \the [N].</span>")
	qdel(O)


	var/has_parts = 0
	for(var/i=1;i<=original.len;i++)
		if(i == j)
			parts[i]--
		if(parts[i] > 0)
			has_parts = 1
	if(!has_parts)
		qdel(src)

/obj/item/device/modkit/storm_rig
	name = "stormtrooper hardsuit modification kit"

/obj/item/device/modkit/storm_rig/New()
	..()
	parts = new/list(3)
	original = new/list(3)
	finished = new/list(3)

	parts[1] =	1
	original[1] = /obj/item/clothing/suit/space/rig/security
	finished[1] = /obj/item/clothing/suit/space/rig/security/stormtrooper
	parts[2] =	3
	original[2] = /obj/item/weapon/gun/energy/laser
	finished[2] = /obj/item/weapon/gun/energy/laser/blaster

// /vg/: Old atmos hardsuit.
/obj/item/device/modkit/gold_rig
	name = "gold atmos hardsuit modification kit"

/obj/item/device/modkit/gold_rig/New()
	..()
	parts = new/list(2)
	original = new/list(2)
	finished = new/list(2)

	parts[1] =	1
	original[1] = /obj/item/clothing/suit/space/rig/atmos
	finished[1] = /obj/item/clothing/suit/space/rig/atmos/gold

/obj/item/device/modkit/fatsec_rig
	name = "gut expansion hardsuit modification kit"

/obj/item/device/modkit/fatsec_rig/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	1
	original[1] = /obj/item/clothing/suit/space/rig/security
	finished[1] = /obj/item/clothing/suit/space/rig/security/fat

/obj/item/device/modkit/syndi_commander
	name = "syndicate commander hardsuit modification kit"
	desc = "For showing who's the boss. Apply to hardsuit."

/obj/item/device/modkit/syndi_commander/New()
	..()

	parts =	list(1) //less shitcode when you only got one part
	original = list(/obj/item/clothing/suit/space/rig/syndi)
	finished = list(/obj/item/clothing/suit/space/rig/syndi/commander)

/obj/item/device/modkit/spur_parts
	name = "suspicious set of metallic parts"
	desc = "You can identify what looks like a gun barrel and various other miscellaneous parts. Clearly these must have some use..."
	icon_state = "spur_parts"

/obj/item/device/modkit/spur_parts/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	1
	original[1] = /obj/item/weapon/gun/energy/polarstar
	finished[1] = /obj/item/weapon/gun/energy/polarstar/spur

/obj/item/device/modkit/aeg_parts
	name = "advanced energy gun modkit"
	desc = "A kit containing all the needed tools and parts to modify an energy gun into an advanced energy gun, granting it the ability to recharge itself."
	icon_state = "modkit"

/obj/item/device/modkit/aeg_parts/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	1
	original[1] = /obj/item/weapon/gun/energy/gun
	finished[1] = /obj/item/weapon/gun/energy/gun/nuclear

/obj/item/device/modkit/plasmacutter
	name = "plasma cutter conversion kit"
	desc = "A set of tools that enables conversion of a mining diamond drill into a plasma cutter. Needs to be loaded with the parts of a proto-kinetic accelerator first."

/obj/item/device/modkit/plasmacutter/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	0
	original[1] = /obj/item/weapon/pickaxe/drill/diamond
	finished[1] = /obj/item/weapon/pickaxe/plasmacutter/accelerator

/obj/item/device/modkit/plasmacutter/attackby(atom/target, mob/user, proximity_flag)
	if(proximity_flag && parts[1] == 1 && istype(target, /obj/item/weapon/gun/energy/kinetic_accelerator))
		to_chat(user, "<span class='warning'>\The [src] is already loaded!</span>")
		return

	else if(proximity_flag && istype(target, /obj/item/weapon/gun/energy/kinetic_accelerator))
		parts[1] = 1
		qdel(target)


/obj/item/device/modkit/demolition
	name = "Lawgiver modkit"
	desc = "A kit containing all the needed tools and parts to modify the Lawgiver into the demolition variant, granting it access to high explosive and double whammy rounds."
	icon_state = "modkit"

/obj/item/device/modkit/demolition/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	1
	original[1] = /obj/item/weapon/gun/lawgiver
	finished[1] = /obj/item/weapon/gun/lawgiver/demolition

/obj/item/device/modkit/antiaxe_kit
	name = "antimatter axe kit"
	desc = "A matter inverter from the secret labs of the Cloud IX engineering facility. It will turn your ordinary axe into an antimatter axe."

/obj/item/device/modkit/antiaxe_kit/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	1
	original[1] = /obj/item/weapon/fireaxe
	finished[1] = /obj/item/weapon/fireaxe/antimatter

/obj/item/device/modkit/kineticshotgun
	name = "proto-kinetic pump-shotgun conversion kit"
	desc = "A set of tools that enables conversion of a proto-kinetic accelerator into a proto-kinetic pump-shotgun, capable of pump-action self-charging."
	icon_state = "modkit_kinetic"
	item_state = "modkit"

/obj/item/device/modkit/kineticshotgun/New()
	..()
	parts = new/list(1)
	original = new/list(1)
	finished = new/list(1)

	parts[1] =	1
	original[1] = /obj/item/weapon/gun/energy/kinetic_accelerator
	finished[1] = /obj/item/weapon/gun/energy/kinetic_accelerator/shotgun
