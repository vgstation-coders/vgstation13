#define MAX_STORED_BAGS 10
//device to take core samples from mineral turfs - used for various types of analysis

/obj/item/weapon/storage/box/samplebags
	name = "sample bag box"
	desc = "A box containing sample bags."

/obj/item/weapon/storage/box/samplebags/New()
	for(var/i=0, i<7, i++)
		new/obj/item/weapon/storage/evidencebag/sample(src)
	..()

//////////////////////////////////////////////////////////////////

/obj/item/device/core_sampler
	name = "core sampler"
	desc = "Used to extract geological core samples for analysis of anomalous exotic energy signatures."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "sampler"
	item_state = "sampler"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	w_class = W_CLASS_TINY
	flags = FPRINT
	//slot_flags = SLOT_BELT
	var/obj/item/weapon/rocksliver/extracted

/obj/item/device/core_sampler/Destroy()
	if (extracted)
		QDEL_NULL(extracted)
	..()

/obj/item/device/core_sampler/examine(mob/user)
	..()
	if(get_dist(src, user) < 2)
		to_chat(user, "<span class='info'>This one [extracted ? "has a sample stored inside. Just click the sampler to extract it." : "is empty. Use on a rock wall to extract a sample."].</span>")

/obj/item/device/core_sampler/proc/sample_item(var/item_to_sample, var/mob/user)
	playsound(src, "sound/items/crank.ogg", 30, 0, -4, FALLOFF_SOUNDS, 0)
	if(do_after(user, src, 1 SECONDS))
		var/datum/geosample/geo_data
		if(istype(item_to_sample, /turf/unsimulated/mineral))
			var/turf/unsimulated/mineral/T = item_to_sample
			T.geologic_data.UpdateNearbyArtifactInfo(T)
			geo_data = T.geologic_data
			var/excav_overlay = "overlay_excv1_[rand(1,3)]"
			T.overlays += excav_overlay
		else if(istype(item_to_sample, /obj/item/weapon/strangerock))
			var/obj/item/weapon/strangerock/O = item_to_sample
			geo_data = O.geologic_data

		if(geo_data)
			if(extracted)
				to_chat(user, "<span class='warning'>\The [src] is full!</span>")
			else
				icon_state = "sampler-full"

				//put in a rock sliver
				extracted = new(src)
				extracted.geological_data = geo_data

				to_chat(user, "<span class='notice'>You extract a sample from \the [item_to_sample]'s core.</span>")
		else
			to_chat(user, "<span class='warning'>You are unable to take a sample of [item_to_sample].</span>")

/obj/item/device/core_sampler/attack_self(mob/user)
	if(extracted)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 0, -4, FALLOFF_SOUNDS, 0)
		to_chat(user, "<span class='notice'>You eject the sample.</span>")
		var/success = 0
		if(istype(src.loc, /mob))
			var/mob/M = src.loc
			success = M.put_in_inactive_hand(extracted)
		if(!success)
			extracted.forceMove(get_turf(src))
		extracted = null
		icon_state = "sampler"
	else
		to_chat(user, "<span class='warning'>The core sampler is empty.</span>")


/obj/item/weapon/storage/evidencebag/sample
	name = "sample bag"
	desc = "A bag for holding research samples."
	use_to_pickup = FALSE

#undef MAX_STORED_BAGS
