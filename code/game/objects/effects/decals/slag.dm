/obj/effect/decal/slag
	name = "slag puddle"
	desc = "The molten remains of something."
	gender = PLURAL
	icon = 'icons/effects/effects.dmi'
	icon_state = "slagcold"
	melt_temperature=0
	light_color = LIGHT_COLOR_ORANGE

	starting_materials = list()

/obj/effect/decal/slag/proc/slaggify(var/obj/O)
	// This is basically a crude recycler doohicky
	if (O.recycle(materials))
		if(melt_temperature==0)
			// Set up our solidification temperature.
			melt_temperature=O.melt_temperature
		else
			// Ensure slag solidifies at a lower temp, if needed.
			src.melt_temperature=min(src.melt_temperature,O.melt_temperature)
		qdel(O)
		if(!molten)
			molten=1
			icon_state="slaghot"
			processing_objects.Add(src)
			set_light(2)

/obj/effect/decal/slag/Destroy()
	set_light(0)
	processing_objects.Remove(src)
	..()

/obj/effect/decal/slag/process()
	if(!molten)
		processing_objects.Remove(src)
		return
	var/turf/T=loc
	var/datum/gas_mixture/env = T.return_air()
	if(melt_temperature > env.temperature && molten && prob(5))
		molten=0
		solidify()
		return 1



/obj/effect/decal/slag/examine(mob/user)
	..()
	if(molten)
		to_chat(user, "<span class=\"warning\">Jesus, it's hot!</span>")

	var/list/bits=list()
	for(var/mat_id in materials.storage)
		var/datum/material/mat=materials.getMaterial(mat_id)
		if(materials.storage[mat_id] > 0)
			bits.Add(mat.processed_name)

	if(bits.len>0)
		to_chat(user, "<span class=\"info\">It appears to contain bits of [english_list(bits)].</span>")
	else
		to_chat(user, "<span class=\"warning\">It appears to be completely worthless.</span>")

/obj/effect/decal/slag/solidify()
	icon_state="slagcold"
	set_light(0)

/obj/effect/decal/slag/melt()
	icon_state="slaghot"
	set_light(2)

/obj/effect/decal/slag/Crossed(M as mob)
	..()
	if(!molten)
		return
	if(!M)
		return
	if(istype(M, /mob/dead/observer))
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H=M
		H.apply_damage(3, BURN, LIMB_LEFT_LEG, 0, 0, "Slag")
		H.apply_damage(3, BURN, LIMB_RIGHT_LEG, 0, 0, "Slag")
	else if(istype(M,/mob/living))
		var/mob/living/L=M
		L.apply_damage(125, BURN)

/obj/effect/decal/slag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(molten)
		user.show_message("<span class=\"warning\">You need to wait for \the [src] to cool.</span>")
		return
	if(W.force >= 5 && W.w_class >= W_CLASS_MEDIUM)
		user.visible_message("<span class=\"danger\">\The [src] is broken apart with the [W.name] by [user.name]!</span>", \
			"<span class=\"danger\">You break apart \the [src] with your [W.name]!", \
			"You hear the sound of rock crumbling.")
		var/obj/item/stack/ore/slag/slag = drop_stack(/obj/item/stack/ore/slag, loc)
		slag.materials = src.materials
		slag.materials.holder = slag
		qdel(src)
	else
		user.visible_message("<span class=\"attack\">[user.name] hits \the [src] with \his [W.name].</span>", \
			"<span class=\"attack\">You fail to damage \the [src] with your [W.name]!</span>", \
			"You hear someone hitting something.")
