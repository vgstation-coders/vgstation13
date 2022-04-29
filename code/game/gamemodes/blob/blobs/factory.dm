/obj/effect/blob/factory
	name = "factory blob"
	icon_state = "factory"
	desc = "A part of a blob. It makes the sound of organic tissue being torn."
	health = 100
	maxHealth = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 2
	var/spore_delay = 50
	spawning = 0
	layer = BLOB_FACTORY_LAYER
	destroy_sound = "sound/effects/blobsplatspecial.ogg"

	icon_new = "factory"
	icon_classic = "blob_factory"

//obj/effect/blob/factory/New(loc,newlook = "new") HALLOWEEN
/obj/effect/blob/factory/New(loc,newlook = null)
	..()
	if(icon_size == 64)
		flick("morph_factory",src)
		spore_delay = world.time + (2 SECONDS)

/obj/effect/blob/factory/run_action()
	if(spores.len >= max_spores)
		return 0
	if(spore_delay > world.time)
		return 0
	spore_delay = world.time + (40 SECONDS) // 30 seconds

	if(icon_size == 64)
		flick("factorypulse",src)
		anim(target = loc, a_icon = icon, flick_anim = "sporepulse", sleeptime = 15, lay = layer+0.5, offX = -16, offY = -16, alph = 220, plane = BLOB_PLANE)
		spawn(10)
			new/mob/living/simple_animal/hostile/blobspore(src.loc, src)
	else
		new/mob/living/simple_animal/hostile/blobspore(src.loc, src)

	return 1

/obj/effect/blob/factory/Destroy()
	if(spores.len)
		for(var/mob/living/simple_animal/hostile/blobspore/S in spores)
			S.death()
	if(!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>A factory blob that you had created has been destroyed.</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")
		overmind.special_blobs -= src
		overmind.DisplayUI("Blob Top Panel")
	..()

/obj/effect/blob/factory/update_icon(var/spawnend = 0)
	if(icon_size == 64)
		spawn(1)
			overlays.len = 0
			underlays.len = 0

			underlays += image(icon,"roots")

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"factoryconnect",dir = get_dir(src,B))
			if(spawnend)
				spawn(10)
					update_icon()

			..()

/////////////BLOB SPORE///////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/blobspore
	name = "Blob Spore"
	desc = "A form of blob antibodies that attack foreign entities."
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	pass_flags = PASSBLOB
	health = 30
	maxHealth = 30
	melee_damage_lower = 2
	melee_damage_upper = 4
	attacktext = "hits"
	attack_sound = 'sound/weapons/rapidslice.ogg'
	can_butcher = 0
	var/obj/effect/blob/factory/factory = null
	faction = "blob"
	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 360
	plane = BLOB_PLANE
	layer = BLOB_SPORE_LAYER
	var/looks = "new"

/mob/living/simple_animal/hostile/blobspore/New(loc, var/obj/effect/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
		icon = factory.icon
		looks = factory.looks
	..()

/mob/living/simple_animal/hostile/blobspore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	adjustBruteLoss(clamp(0.01 * exposed_temperature, 1, 5))

/mob/living/simple_animal/hostile/blobspore/blob_act()
	return

/mob/living/simple_animal/hostile/blobspore/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover, /obj/effect/blob))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blobspore/death(var/gibbed = FALSE)
	..(TRUE) //Gibs regardless
	var/sound = pick('sound/effects/gib1.ogg','sound/effects/gib2.ogg','sound/effects/gib3.ogg')
	playsound(src, sound, 50, 1)
	qdel(src)

/mob/living/simple_animal/hostile/blobspore/Destroy()
	//creating a pathogenic cloud upon death
	anim(target = loc, a_icon = icon, flick_anim = "blob_act", sleeptime = 15, direction = SOUTH, lay = BLOB_SPORE_LAYER, plane = BLOB_PLANE)
	if (!(looks in blob_diseases))
		CreateBlobDisease(looks)
	var/datum/disease2/disease/D = blob_diseases[looks]
	var/list/L = list()
	L["[D.uniqueID]-[D.subID]"] = D
	new /obj/effect/pathogen_cloud(get_turf(src), null, virus_copylist(L), FALSE)
	if(factory)
		factory.spores -= src
	..()

/mob/living/simple_animal/hostile/blobspore/unarmed_attack_mob(var/mob/living/target)
	. = ..()

	if (.)
		//if we damage our target, let's try and infect them
		if (!(looks in blob_diseases))
			CreateBlobDisease(looks)
		var/datum/disease2/disease/D = blob_diseases[looks]

		if (!target.check_contact_sterility(FULL_TORSO))//For simplicity's sake (for once), let's just assume that the blob strikes the torso.
			target.infect_disease2(D, notes="(Blob, from [src])")
