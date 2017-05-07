#define BLOODPACK_NORMAL 1
#define BLOODPACK_CUT 2

/obj/item/weapon/reagent_containers/blood
	name = "\improper bloodpack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200

	var/blood_type = null
	var/holes = 0
	var/mode = BLOODPACK_NORMAL

/obj/item/weapon/reagent_containers/blood/New()
	..()
	if(blood_type != null)
		name = "\improper[blood_type] bloodpack"
	reagents.add_reagent(BLOOD, 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null, "virus2"=list()))
	update_icon()

/obj/item/weapon/reagent_containers/blood/on_reagent_change()
	update_icon()

	if (mode == BLOODPACK_CUT)
		return

	if(reagents.total_volume == 0 && name != "\improper empty bloodpack")
		name = "\improper empty bloodpack"
		desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	else if (reagents.reagent_list.len > 0)
		var/target_type = null
		var/the_volume = 0
		for(var/datum/reagent/A in reagents.reagent_list)
			if(A.volume > the_volume && ("blood_type" in A.data))
				the_volume = A.volume
				target_type = A.data["blood_type"]
		if (target_type)
			name = "\improper [target_type] bloodpack"
			desc = "A bloodpack filled with [target_type] blood."
			blood_type = target_type
		else
			name = "\improper murky bloodpack"
			desc = "A bloodpack that's clearly not filled with blood."

/obj/item/weapon/reagent_containers/blood/update_icon()
	if (mode == BLOODPACK_CUT)
		name = "cut bloodpack"
		icon_state = "[icon_state]_cut"
		desc = "You can see several cuts in it. It's no longer usable."
		overlays.len = 0
		return

	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 79)
				filling.icon_state = "[icon_state]75"
			if(80 to 90)
				filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.icon *= mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		overlays += filling

/obj/item/weapon/reagent_containers/blood/examine(mob/user)
	//I don't want this to be an open container.
	..()
	if(mode == BLOODPACK_CUT)
		return

	if(get_dist(user,src) > 3)
		to_chat(user, "<span class='info'>You can't make out the contents.</span>")
		return
	if(reagents)
		to_chat(user, "It contains:")
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				if (R.id == BLOOD)
					var/type = R.data["blood_type"]
					to_chat(user, "<span class='info'>[R.volume] units of [R.name], of type [type]</span>")
				else
					to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
		else
			to_chat(user, "<span class='info'>Nothing.</span>")

/obj/item/weapon/reagent_containers/blood/fits_in_iv_drip()
	if (mode == BLOODPACK_NORMAL)
		return 1

//These should be kept for legacy purposes, probably. At least until they disappear from maps.
/obj/item/weapon/reagent_containers/blood/APlus
	blood_type = "A+"

/obj/item/weapon/reagent_containers/blood/AMinus
	blood_type = "A-"

/obj/item/weapon/reagent_containers/blood/BPlus
	blood_type = "B+"

/obj/item/weapon/reagent_containers/blood/BMinus
	blood_type = "B-"

/obj/item/weapon/reagent_containers/blood/OPlus
	blood_type = "O+"

/obj/item/weapon/reagent_containers/blood/OMinus
	blood_type = "O-"

/obj/item/weapon/reagent_containers/blood/empty
	name = "\improper empty bloodpack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "bloodpack"
	New()
		..()
		blood_type = null
		reagents.clear_reagents()
		update_icon()

/obj/item/weapon/reagent_containers/blood/chemo
	name = "\improper phalanximine IV kit"
	desc = "IV kit for chemotherapy."

//if cancer gets re-introduced, someone will need to update on_reagent_change()
//else&if you are able to make chemo via chemistry, chemopacks will be seen as "murky bloodpacks"
//(unless they are being spawned in the map at roundstart like the other common bloodpacks)
/////////////////////////////////////////
//not needed anymore
//	icon = 'icons/obj/chemopack.dmi'
////////////////////////////////////////
	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent(PHALANXIMINE, 200)
		update_icon()

/obj/item/weapon/reagent_containers/blood/attackby(obj/item/W as obj, mob/user as mob)
	var/turf/T = get_turf(src)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list

	if(mode == BLOODPACK_CUT)
		return

	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		var/datum/reagent/blood/S = locate(/datum/reagent/blood) in W.reagents.reagent_list
		//if a syringe with infected blood is used, it infects the blood inside the bloodpack.
		if (S != null && S.data["virus2"] && reagents.has_reagent(BLOOD))
			var/list/virus = B.data["virus2"]
			virus |= virus_copylist(S.data["virus2"])
		return //stops from punching holes

	if (W.sharpness_flags & (SHARP_BLADE|SHARP_TIP|HOT_EDGE))

		if(!holes)
			processing_objects.Add(src)

		if (user.a_intent == I_HELP)
			holes += 1
			to_chat(user, "<span class='warning'>You quietly stab the [src].</span>")

		if (user.a_intent == I_HURT)
			if (do_after (user, src, 20))

				if (reagents.total_volume != 0)
					user.visible_message("<span class='warning'>[user] stabs the [src] repeatedly, making a mess!</span>", "<span class='warning'>You stab the [src] repeatedly, making a mess!</span>")
					playsound(T, 'sound/effects/splat.ogg', 50, 1)

					if(reagents.has_reagent(BLOOD))
						var/list/virus = B.data["virus2"]
						var/color = B.data["blood_colour"]

						for(var/i=reagents.get_reagent_amount(BLOOD), i>=21, i-=60)
							bloodmess_splatter(T, virus, null, null, color)
							reagents.remove_reagent(BLOOD, 60)

						while (reagents.get_reagent_amount(BLOOD)!=0 && reagents.get_reagent_amount(BLOOD)<=20)
							bloodmess_drip(T, virus, null, null, color)
							reagents.remove_reagent(BLOOD, 20)

					//it will never have blood at this point
					for(var/i=reagents.total_volume, i>0, i-=60)
						var/list/directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
						var/H = get_step(src, pick(directions))
						splash_sub(reagents, T, 10)
						splash_sub(reagents, H, 50)

				mode = BLOODPACK_CUT
				update_icon()

/obj/item/weapon/reagent_containers/blood/process()
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
	var/turf/T = get_turf(src)

	if(mode == BLOODPACK_CUT)
		processing_objects.Remove(src)
		return
	if(reagents.total_volume == 0)
		return

	if (holes)
		for(var/number_holes = 1 to holes)
			var/A //since I'm handling blood & reagents in different places, I don't want blood to be emptied twice as fast.
			if(reagents.reagent_list.len>1 && reagents.has_reagent(BLOOD))
				A = 5
			else
				A = 10

			if(reagents.has_reagent(BLOOD))
				blood_splatter (T, B, 0) //drip
				reagents.remove_reagent(BLOOD,A)

			for(var/datum/reagent/R in reagents.reagent_list)
				if(R.id == BLOOD)
					continue
				else
					R.reaction_turf(T, A)
					reagents.remove_reagent(R.id, A)

/obj/item/weapon/reagent_containers/blood/Destroy()
	processing_objects.Remove(src)
	..()
