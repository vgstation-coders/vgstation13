// Tiny green chickens from outer space

/mob/living/carbon/monkey/vox
	name = "chicken"
	voice_name = "chicken"
	icon_state = "chickengreen"
	speak_emote = list("clucks","croons")
	attack_text = "pecks"
	species_type = /mob/living/carbon/monkey/vox
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/raw_vox_chicken
	canWearClothes = 0
	canWearGlasses = 0
	safe_oxygen_min = 0
	var/eggsleft
	var/eggcost = 250
	languagetoadd = LANGUAGE_VOX
	var/vox_feather_regenerating = FALSE
	var/original_icon_state = null

/mob/living/carbon/monkey/vox/attack_hand(mob/living/carbon/human/M as mob)
	if((M.a_intent == I_HELP) && !(locked_to) && (isturf(src.loc)) && (M.get_active_hand() == null)) //Unless their location isn't a turf!
		scoop_up(M)

	// Feather plucking logic for Vox chickens (on grab intent)
	if(!stat && M.a_intent == I_GRAB && icon_state != "chickengreen_dead")
		if(butchering_drops && butchering_drops.len)
			for(var/datum/butchering_product/BP in butchering_drops)
				if(istype(BP, /datum/butchering_product/feathers))
					var/datum/butchering_product/feathers/FBP = BP
					if(FBP.amount > 0)
						FBP.amount--
						var/feather_hex = "#3de47b" // Default green
						var/feather_color_name = "green"
						// Use the butchering product's color if set
						if(FBP.feather_hex) feather_hex = FBP.feather_hex
						if(FBP.feather_color_name) feather_color_name = FBP.feather_color_name
						var/obj/item/stack/feather/F = new /obj/item/stack/feather(get_turf(src), 1, feather_hex, feather_color_name, "[feather_color_name] vox feather")
						F.animal_type = src.type
						M.visible_message("<span class='notice'>[M] plucks a feather from [src]!</span>", "<span class='notice'>You pluck a feather from [src].</span>")
						playsound(src, 'sound/voice/chicken.ogg', rand(10,30), 1)
						// If this was the last feather, bite the player and make them drop the chicken if held
						if(FBP.amount == 0)
							M.visible_message("<span class='warning'>[src] bites [M] as you pluck the last feather!</span>", "<span class='warning'>[src] bites you as you pluck the last feather!</span>")
							playsound(src, 'sound/voice/chicken.ogg', 50, 1)
							icon_state = "chickengreen_plucked"
							update_icons()
							M.u_equip(src)
							src.forceMove(get_turf(M))
							// Start feather regeneration for Vox chickens
							src.start_vox_feather_regeneration()
						return
			to_chat(M, "<span class='warning'>[src] has no feathers to pluck!</span>")
			return
	..()


// Start feather regeneration for Vox chickens
/mob/living/carbon/monkey/vox/proc/start_vox_feather_regeneration()
	if(vox_feather_regenerating)
		return
	vox_feather_regenerating = TRUE
	if(isnull(original_icon_state))
		original_icon_state = "chickengreen"
	spawn(54000) // 15 minutes
		if(src && !stat)
			src.regenerate_vox_feathers()

// Restore feathers and icon for Vox chickens
/mob/living/carbon/monkey/vox/proc/regenerate_vox_feathers()
	if(butchering_drops && butchering_drops.len)
		for(var/datum/butchering_product/BP in butchering_drops)
			if(istype(BP, /datum/butchering_product/feathers))
				BP.amount = BP.initial_amount
	icon_state = original_icon_state || "chickengreen"
	update_icons()
	vox_feather_regenerating = FALSE


/mob/living/carbon/monkey/vox/New()

	..()
	setGender(NEUTER)
	dna.mutantrace = "vox"
	greaterform = "Vox"
	alien = 1
	eggsleft = rand(1,6)
	set_hand_amount(1)
	butchering_drops = get_butchering_products()

/mob/living/carbon/monkey/vox/skeletal
	name = "skeleton chicken"
	voice_name = "chicken skeleton"
	icon_state = "chickenskeleton"
	flag = NO_BREATHE

/mob/living/carbon/monkey/vox/skeletal/New()

	..()
	dna.mutantrace = "skelevox"
	greaterform = "Skeletal Vox"
	eggsleft = 0

/mob/living/carbon/monkey/vox/Life()
	..()
	if(prob(5) && eggsleft > 4)
		lay_egg()

/mob/living/carbon/monkey/vox/say(var/message)
	if (prob(25))
		message += pick("  sqrk", "  bok bok", ",bwak", ",cluck!")

	return ..(message)

/mob/living/carbon/monkey/vox/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat) || istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom)) //feedin' dem green chickens
		if(!stat && eggsleft < 8)
			if(!user.drop_item(O, failmsg = TRUE))
				return

			user.visible_message("<span class='notice'>[user] feeds [O] to [name]! It clucks happily.</span>","<span class='notice'>You feed [O] to [name]! It clucks happily.</span>")
			qdel(O)
			eggsleft += rand(1, 4)
//			to_chat(world, eggsleft)
		else
			to_chat(user, "<span class='notice'>[name] doesn't seem hungry!</span>")
	else
		..()

/mob/living/carbon/monkey/vox/put_in_hand_check(var/obj/item/W) //Silly chicken, you don't have hands
	if(src.reagents.has_reagent(GRAVY) || src.reagents.has_reagent(METHYLIN) || (is_dexterous))
		return 1
	else
		return 0

//Cant believe I'm doing this
/mob/living/carbon/monkey/vox/proc/lay_egg()
	if(!stat && nutrition > 250 && eggsleft > 0)
		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
		nutrition -= eggcost
		eggsleft--
		var/obj/item/weapon/reagent_containers/food/snacks/egg/vox/E = new(get_turf(src))
		E.pixel_x = rand(-6,6) * PIXEL_MULTIPLIER
		E.pixel_y = rand(-6,6) * PIXEL_MULTIPLIER
		if(prob(25))
			processing_objects.Add(E)

/mob/living/carbon/monkey/vox/verb/layegg()
	set name = "Lay egg"
	set category = "IC"
	lay_egg()
	return

/mob/living/carbon/monkey/vox/proc/eggstats()
	stat(null, "Nutrition level - [nutrition]")
	stat(null, "Eggs left - [eggsleft]")

/mob/living/carbon/monkey/vox/Stat()
	..()
	if(statpanel("Status"))
		eggstats()
