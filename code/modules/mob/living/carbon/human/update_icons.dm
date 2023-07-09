	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.
	var/overlays_lying[19]			//For the lying down stance
	var/overlays_standing[19]		//For the standing stance
When we call update_icons, the 'lying' variable is checked and then the appropriate list is assigned to our overlays!
That in itself uses a tiny bit more memory (no more than all the ridiculous lists the game has already mind you).
On the other-hand, it should be very CPU cheap in comparison to the old system.
In the old system, we updated all our overlays every life() call, even if we were standing still inside a crate!
or dead!. 25ish overlays, all generated from scratch every second for every xeno/human/monkey and then applied.
More often than not update_clothing was being called a few times in addition to that! CPU was not the only issue,
all those icons had to be sent to every client. So really the cost was extremely cumulative. To the point where
update_clothing would frequently appear in the top 10 most CPU intensive procs during profiling.
Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.
In practice this means that:
	everytime you fall over, we just switch between precompiled lists. Which is fast and cheap.
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...
There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()
	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.
>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
		QueueUpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_targeted() // Updates the target overlay when someone points a gun at you
>	All of these procs update our overlays_lying and overlays_standing, and then call update_icons() by default.
	If you wish to update several overlays at once, you can set the argument to 0 to disable the update and call
	it manually:
		e.g.
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand()		//<---calls update_icons()
	or equivillantly:
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand(0)
		update_icons()
>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.
>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.
This system is confusing and is still a WIP. It's primary goal is speeding up the controls of the game whilst
reducing processing costs. So please bear with me while I iron out the kinks. It will be worth it, I promise.
If I can eventually free var/lying stuff from the life() process altogether, stuns/death/status stuff
will become less affected by lag-spikes and will be instantaneous! :3
If you have any questions/constructive-comments/bugs-to-report/or have a massivly devestated butt...
Please contact me on #coderbus IRC. ~Carn x //FUCK YOU CARN
*/
//THIS ENTIRE FILE NEEDS TO BE PURIFIED WITH FLAME
/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed
	var/icon/race_icon
	var/icon/deform_icon
	var/update_overlays = 0

/mob/living/carbon/human/proc/obj_to_plane_overlay(var/obj/abstract/Overlays/object,var/slot)
	var/image/I = new()
	I.appearance = object.appearance
	I.plane = FLOAT_PLANE
	obj_overlays[slot] = I
	overlays += I

/mob/living/carbon/human/proc/QueueUpdateDamageIcon(var/forced = 0)
	if(forced)
		UpdateDamageIcon(1)
		update_overlays = 0
		return
	update_overlays = 1

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
// - you never did, elly1989@rocketmail.com on Jun 13, 2012
/mob/living/carbon/human/update_icons()
	update_hud()		//TODO: remove the need for this
	update_overlays_standing()
	update_transform()
	update_hands_icons()
	if(istype(loc,/obj/structure/inflatable/shelter))
		var/obj/O = loc
		O.update_icon() //Shelters use an overlay of the human inside, so if we change state we want the appearance to reflect that.

/mob/living/carbon/human/proc/update_overlays_standing()
	if(species && species.override_icon)
		species_override_icon()
	else
		generate_overlays_icon()

/mob/living/carbon/human/proc/species_override_icon()
	//overlays.len = 0
	icon = species.override_icon
	icon_state = "[lowertext(species.name)]_[gender][ (species.anatomy_flags & CAN_BE_FAT ? (mutations & M_FAT) ? "_fat" : "" : "") ]"
	//temporary fix for having mutations on top of overriden icons for like muton, horror, etc
	overlays -= obj_overlays[MUTANTRACE_LAYER]


/mob/living/carbon/human/proc/generate_overlays_icon()
	icon = stand_icon

var/global/list/damage_icon_parts = list()

/mob/living/carbon/human/proc/get_damage_icon_part(damage_state, body_part,species_blood = "")
	var/icon/I = damage_icon_parts["[damage_state]/[body_part]/[species_blood]"]
	if(!I)//This should never happen anyway since all species damage icons are getting cached at roundstart (see cachedamageicons())
		var/icon/DI = icon('icons/mob/dam_human.dmi', damage_state)			// the damage icon for whole human
		DI.Blend(icon('icons/mob/dam_mask.dmi', body_part), ICON_MULTIPLY)	// mask with this organ's pixels
		if(species_blood)
			var/brute = copytext(damage_state,1,2)
			var/burn = copytext(damage_state,2)
			DI = icon('icons/mob/dam_human.dmi', "[brute]0-color")
			DI.Blend(species_blood, ICON_MULTIPLY)
			var/icon/DI_burn = icon('icons/mob/dam_human.dmi', "0[burn]")//we don't want burns to blend with the species' blood color
			DI.Blend(DI_burn, ICON_OVERLAY)
			DI.Blend(icon('icons/mob/dam_mask.dmi', body_part), ICON_MULTIPLY)
		damage_icon_parts["[damage_state]/[body_part]/[species_blood]"] = DI
		return DI
	else
		return I

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon(var/update_icons=1)
	if(monkeyizing)
		return
	var/image/standing_image = image('icons/mob/dam_human.dmi', "blank")

	// blend the individual damage states with our icons
	for(var/datum/organ/external/O in organs)
		if(!(O.status & ORGAN_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00")
				continue

			var/icon/DI

			DI = get_damage_icon_part(O.damage_state, O.icon_name, (species.blood_color == DEFAULT_BLOOD ? "" : species.blood_color))

			standing_image.overlays += DI
	var/obj/abstract/Overlays/O = obj_overlays[DAMAGE_LAYER]
	overlays -= O
	O.overlays.len = 0
	O.overlays += standing_image
	obj_to_plane_overlay(O,DAMAGE_LAYER)

	if(update_icons)
		update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(var/update_icons=1)
	if(monkeyizing)
		return

	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/necrosis_color_mod = rgb(10,50,0)

	var/husk = (M_HUSK in src.mutations)
	var/fat = (M_FAT in src.mutations) && (species && species.anatomy_flags & CAN_BE_FAT)
	var/hulk = (M_HULK in src.mutations) && !ishorrorform(src) && mind.special_role != HIGHLANDER // Part of the species.
	var/skeleton = (M_SKELETON in src.mutations)

	var/g = "m"
	if(gender == FEMALE)
		g = "f"

	var/datum/organ/external/chest = get_organ(LIMB_CHEST)
	stand_icon = chest.get_icon(g,fat)
	if(!skeleton)
		if(husk)
			stand_icon.ColorTone(husk_color_mod)
		else if(hulk)
			var/list/TONE = ReadRGB(hulk_color_mod)
			stand_icon.MapColors(rgb(TONE[1],0,0),rgb(0,TONE[2],0),rgb(0,0,TONE[3]))

	var/datum/organ/external/head = get_organ(LIMB_HEAD)
	var/has_head = 0
	if(head && !(head.status & ORGAN_DESTROYED))
		has_head = 1

	for(var/datum/organ/external/part in organs)
		if(!istype(part, /datum/organ/external/chest) && !(part.status & ORGAN_DESTROYED))
			var/icon/temp
			if (istype(part, /datum/organ/external/groin) || istype(part, /datum/organ/external/head))
				temp = part.get_icon(g,fat)
			else
				temp = part.get_icon()

			if(part.status & ORGAN_DEAD)
				temp.ColorTone(necrosis_color_mod)
				temp.SetIntensity(0.7)

			else if(!skeleton)
				if(husk)
					temp.ColorTone(husk_color_mod)
				else if(hulk)
					var/list/TONE = ReadRGB(hulk_color_mod)
					temp.MapColors(rgb(TONE[1],0,0),rgb(0,TONE[2],0),rgb(0,0,TONE[3]))

			//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
			//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
			if(part.icon_position&(LEFT|RIGHT))
				var/icon/temp2 = new('icons/mob/human.dmi',"blank")
				temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)
				if(!(part.icon_position & LEFT))
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(!(part.icon_position & RIGHT))
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				stand_icon.Blend(temp2, ICON_OVERLAY)
				temp2 = new('icons/mob/human.dmi',"blank")
				if(part.icon_position & LEFT)
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(part.icon_position & RIGHT)
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				stand_icon.Blend(temp2, ICON_UNDERLAY)
			else
				stand_icon.Blend(temp, ICON_OVERLAY)

	//Skin tone
	if(!skeleton && !husk && !hulk)
		if(species.anatomy_flags & MULTICOLOR)
			stand_icon.Blend(rgb(multicolor_skin_r, multicolor_skin_g, multicolor_skin_b), ICON_ADD)
		else if(species.anatomy_flags & RGBSKINTONE)
			my_appearance.r_hair = clamp(my_appearance.r_hair, 0, 80)	//So we don't get rainbow monkeymen roaches
			my_appearance.g_hair = clamp(my_appearance.g_hair, 0, 50)
			my_appearance.b_hair = clamp(my_appearance.b_hair, 0, 35)
			stand_icon.Blend(rgb(my_appearance.r_hair, my_appearance.g_hair, my_appearance.b_hair), ICON_ADD)
		else if(species.anatomy_flags & HAS_SKIN_TONE)
			if(my_appearance.s_tone >= 0)
				stand_icon.Blend(rgb(my_appearance.s_tone, my_appearance.s_tone, my_appearance.s_tone), ICON_ADD)
			else
				stand_icon.Blend(rgb(-my_appearance.s_tone,  -my_appearance.s_tone,  -my_appearance.s_tone), ICON_SUBTRACT)

	if(husk)
		var/icon/mask = new(stand_icon)
		var/icon/husk_over = new(race_icon,"overlay_husk")
		mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
		husk_over.Blend(mask, ICON_ADD)
		stand_icon.Blend(husk_over, ICON_OVERLAY)

	if(has_head)
		//Eyes
		if(!skeleton)
			var/icon/eyes = new/icon('icons/mob/hair_styles.dmi', species.eyes)
			eyes.Blend(rgb(my_appearance.r_eyes, my_appearance.g_eyes, my_appearance.b_eyes), ICON_ADD)
			stand_icon.Blend(eyes, ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(lip_style)
			stand_icon.Blend(new/icon('icons/mob/hair_styles.dmi', "lips_[lip_style]_s"), ICON_OVERLAY)

		if(eye_style)
			stand_icon.Blend(new/icon('icons/mob/hair_styles.dmi', "eyeshadow_[eye_style]_light_s"), ICON_OVERLAY)


	//Underwear
	var/list/undielist
	if(gender == MALE)
		undielist = underwear_m
	else
		undielist = underwear_f
	if(underwear >0 && underwear <= undielist.len && species.anatomy_flags & HAS_UNDERWEAR)
		if(!fat && !skeleton)
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)

	if(update_icons)
		update_icons()

	if(body_alphas.len)
		var/lowest_alpha = get_lowest_body_alpha()
		stand_icon -= rgb(0,0,0,lowest_alpha)

	//tail
	update_tail_showing(0)


//HAIR OVERLAY
/mob/living/carbon/human/update_hair(var/update_icons=1)
	if(monkeyizing)
		return

	overlays -= obj_overlays[HAIR_LAYER]

	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	if( !head_organ || (head_organ.status & ORGAN_DESTROYED) || head_organ.disfigured)
		if(update_icons)
			update_icons()
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/hair_styles.dmi',"bald_s")
	//to_chat(world, "Maskheadhair? [check_hidden_head_flags(MASKHEADHAIR)]")
	var/hair_suffix = check_hidden_head_flags(MASKHEADHAIR) ? "s2" : "s" // s2 = cropped icon

	if(my_appearance.f_style && !(check_hidden_flags(get_clothing_items(),HIDEBEARDHAIR))) //If the beard is hidden, don't draw it
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[my_appearance.f_style]
		if((facial_hair_style) && (src.species.name in facial_hair_style.species_allowed))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(my_appearance.r_facial, my_appearance.g_facial, my_appearance.b_facial), ICON_ADD)
			face_standing.Blend(facial_s, ICON_OVERLAY)
//		else
			//warning("Invalid my_appearance.f_style for [species.name]: [my_appearance.f_style]")

	//to_chat(world, "Hideheadhair? [check_hidden_flags(get_clothing_items(),HIDEHEADHAIR)]")
	if(my_appearance.h_style && !(check_hidden_flags(get_clothing_items(),HIDEHEADHAIR))) //If the hair is hidden, don't draw it
		var/datum/sprite_accessory/hair_style = hair_styles_list[my_appearance.h_style]
		if((hair_style) && (src.species.name in hair_style.species_allowed))
			var/icon/hair_s
			if(isvox(src))
				if(my_appearance.r_hair > 7)
					my_appearance.r_hair = rand(1,7)
				hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[my_appearance.r_hair]_[hair_suffix]")
			else
				hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[hair_suffix]")
				if(hair_style.do_colouration)
					hair_s.Blend(rgb(my_appearance.r_hair, my_appearance.g_hair, my_appearance.b_hair), ICON_ADD)
				if(hair_style.additional_accessories)
					hair_s.Blend(icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_acc"), ICON_OVERLAY)
			face_standing.Blend(hair_s, ICON_OVERLAY)
//		else
			//warning("Invalid my_appearance.h_style for [species.name]: [my_appearance.h_style]")

	if(body_alphas.len)
		var/lowest_alpha = get_lowest_body_alpha()
		face_standing -= rgb(0,0,0,lowest_alpha)

	//overlays_standing[HAIR_LAYER]	= image(face_standing)
	var/image/I = image(face_standing)
	var/obj/abstract/Overlays/O = obj_overlays[HAIR_LAYER]
	O.icon = I
	O.icon_state = I.icon_state
	obj_to_plane_overlay(O,HAIR_LAYER)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_mutations(var/update_icons=1)
	if(monkeyizing)
		return
	var/fat
	if(M_FAT in mutations)
		fat = "fat"

	overlays -= obj_overlays[MUTATIONS_LAYER]
	var/obj/abstract/Overlays/O = obj_overlays[MUTATIONS_LAYER]
	O.icon = 'icons/effects/genetics.dmi'
	O.icon_state = ""
	O.overlays.len = 0
	O.underlays.len = 0

	var/add_image = 0
	// DNA2 - Drawing underlays.
	var/g = gender == FEMALE ? "f" : "m"
	for(var/gene_type in active_genes)
		var/datum/dna/gene/gene = dna_genes[gene_type]
		if(!gene.block)
			continue
		var/underlay=gene.OnDrawUnderlays(src,g,fat)
		if(underlay)
			O.underlays += image('icons/effects/genetics.dmi', underlay)
			add_image = 1
	for(var/mut in mutations)
		switch(mut)
			if(M_LASER)
				O.overlays += image('icons/effects/genetics.dmi', "lasereyes_s")
				add_image = 1
	if((M_RESIST_COLD in mutations) && (M_RESIST_HEAT in mutations))
		if(!(src.species.name == "Vox") && !(src.species.name == "Skeletal Vox"))
			O.underlays	-= image('icons/effects/genetics.dmi', "cold[fat]_s")
			O.underlays	-= image('icons/effects/genetics.dmi', "fire[fat]_s")
			O.underlays	+= image('icons/effects/genetics.dmi', "coldfire[fat]_s")
		else if((src.species.name == "Vox") || (src.species.name == "Skeletal Vox"))
			O.underlays -= image('icons/effects/genetics.dmi', "coldvox_s")
			O.underlays	-= image('icons/effects/genetics.dmi', "firevox_s")
			O.underlays	+= image('icons/effects/genetics.dmi', "coldfirevox_s")

	//Cultist tattoos
	if (iscultist(src))
		var/datum/role/cultist/C = iscultist(src)
		add_image = 1
		for (var/T in C.tattoos)
			var/datum/cult_tattoo/tattoo = C.tattoos[T]
			if (tattoo)
				var/image/I = image(icon = 'icons/mob/cult_tattoos.dmi', icon_state = tattoo.icon_state)
				I.blend_mode = BLEND_MULTIPLY
				O.overlays += I

	if(add_image)
		obj_to_plane_overlay(O,MUTATIONS_LAYER)
	if(update_icons)
		update_icons()


/mob/living/carbon/human/proc/update_mutantrace(var/update_icons=1)
	if(monkeyizing)
		return
	var/fat
	if( M_FAT in mutations )
		fat = "fat"
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"
//BS12 EDIT
	var/skeleton = (M_SKELETON in src.mutations)
	if(skeleton)
		race_icon = 'icons/mob/human_races/r_skeleton.dmi'
	else
		//Icon data is kept in species datums within the mob.
		if(species && istype(species, /datum/species))
			species.updatespeciescolor(src)
		race_icon = species.icobase
		deform_icon = species.deform
	overlays -= obj_overlays[MUTANTRACE_LAYER]

	if(dna)
		switch(dna.mutantrace)
			if("slime","shadow")
				if(species && (!species.override_icon && species.has_mutant_race))
					var/obj/abstract/Overlays/O = obj_overlays[MUTANTRACE_LAYER]
					O.icon = 'icons/effects/genetics.dmi'
					O.icon_state = "[dna.mutantrace][fat]_[gender]_s"
					obj_to_plane_overlay(O,MUTANTRACE_LAYER)
				//overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_[gender]_s")
			//else
				//overlays_standing[MUTANTRACE_LAYER]	= null

	if(!dna || !(dna.mutantrace in list("golem","metroid")))
		update_body(0)

	update_hair(0)
	if(update_icons)
		update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted(var/update_icons=1)
	overlays -= obj_overlays[TARGETED_LAYER]
	if (targeted_by && target_locked)
		var/obj/abstract/Overlays/O = obj_overlays[TARGETED_LAYER]
		O.icon = target_locked
		O.icon_state = "locking" //Does not update to "locked" sprite, need to find a way to get icon_state from an image, or rewrite Targeted() proc
		obj_to_plane_overlay(O,TARGETED_LAYER)
		//overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	//if (!targeted_by)
		//overlays_standing[TARGETED_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_fire(var/update_icons=1)
	overlays -= obj_overlays[FIRE_LAYER]
	if(on_fire)
		var/obj/abstract/Overlays/O = obj_overlays[FIRE_LAYER]
		O.icon = fire_dmi
		O.icon_state = fire_sprite
		obj_to_plane_overlay(O,FIRE_LAYER)
		//overlays_standing[FIRE_LAYER] = image("icon"=fire_dmi, "icon_state"=fire_sprite, "layer"=-FIRE_LAYER)
	//else
		//overlays_standing[FIRE_LAYER] = null
	if(update_icons)
		update_icons()


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()//Changing the order of those procs doesn't change which layer appears on top! That's what the defines in setup.dm are for.
	..()
	if(monkeyizing)
		return
	update_fire(0)
	update_mutations(0)
	update_mutantrace(0)
	update_inv_w_uniform(0)
	update_inv_gloves(0)
	update_inv_glasses(0)
	update_inv_ears(0)
	update_inv_shoes(0)
	update_inv_s_store(0)
	update_inv_wear_mask(0)
	update_inv_head(0)
	update_inv_belt(0)
	update_inv_back(0)
	update_inv_wear_suit(0)
	update_inv_wear_id(0)
	update_inv_hands(0)
	update_inv_handcuffed(0)
	update_inv_mutual_handcuffed(0)
	update_inv_legcuffed(0)
	update_inv_pockets(0)
	QueueUpdateDamageIcon(1)
	update_icons()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[UNIFORM_LAYER]
	if(!w_uniform)
		var/list/drop_items = list(r_store, l_store, wear_id)
		if(!isbelt(belt))
			drop_items.Add(belt)
		// Automatically drop anything in store / id if you're not wearing a uniform.	//CHECK IF NECESARRY
		for( var/obj/item/thing in drop_items)						//
			if(thing)																			//
				u_equip(thing,1)																//
				if (client)																		//
					client.screen -= thing														//
																								//
				if (thing)																		//
					thing.forceMove(loc)																//
					//thing.dropped(src)														//
					thing.reset_plane_and_layer()

	else if(w_uniform && !check_hidden_body_flags(HIDEJUMPSUIT) && w_uniform.is_visible())
		w_uniform.screen_loc = ui_iclothing
		var/obj/abstract/Overlays/O = obj_overlays[UNIFORM_LAYER]
		O.color = null
		O.overlays.len = 0
		var/image/standing
		var/t_color = w_uniform._color
		var/is_fat = ((M_FAT in mutations) && (species.anatomy_flags & CAN_BE_FAT)) || species.anatomy_flags & IS_BULKY
		if(t_color)
			standing = image("icon_state" = "[t_color]_s", "icon" = 'icons/mob/uniform.dmi')

		if(is_fat)
			if(w_uniform.clothing_flags&ONESIZEFITSALL)
				standing.icon = 'icons/mob/uniform_fat.dmi'
			else
				to_chat(src, "<span class='warning'>You burst out of \the [w_uniform]!</span>")
				drop_from_inventory(w_uniform)
				return

		if(w_uniform.wear_override)
			standing = image("icon" = w_uniform.wear_override)

		var/obj/item/clothing/under/under_uniform = w_uniform
		if(species.name in under_uniform.species_fit) //Allows clothes to display differently for multiple species
			if(species.uniform_icons && has_icon(species.uniform_icons, "[w_uniform.icon_state]_s"))
				standing.icon = species.uniform_icons

		if((gender == FEMALE) && (w_uniform.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon, "[w_uniform.icon_state]_s_f"))
				standing.icon_state = "[w_uniform.icon_state]_s_f"

		if(w_uniform.icon_override)
			standing.icon	= w_uniform.icon_override

		if(w_uniform.dynamic_overlay)
			if(w_uniform.dynamic_overlay["[UNIFORM_LAYER]"])
				var/image/dyn_overlay = w_uniform.dynamic_overlay["[UNIFORM_LAYER]"]
				O.overlays += dyn_overlay

		if(w_uniform.blood_DNA && w_uniform.blood_DNA.len)
			var/blood_icon_state = "uniformblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "uniformblood-vox"
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
			bloodsies.color		= w_uniform.blood_color
			//standing.overlays	+= bloodsies
			O.overlays += bloodsies

		under_uniform.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		if(w_uniform.clothing_flags & COLORS_OVERLAY)
			O.color = w_uniform.color
		O.pixel_x = species.inventory_offsets["[slot_w_uniform]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_w_uniform]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,UNIFORM_LAYER)
		//overlays_standing[UNIFORM_LAYER]	= standing
		//overlays_standing[UNIFORM_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_wear_id(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[ID_LAYER]
	if(wear_id)
		wear_id.screen_loc = ui_id	//TODO
		if(w_uniform && w_uniform:displays_id)
			var/obj/abstract/Overlays/O = obj_overlays[ID_LAYER]
			var/obj/item/weapon/card/ID_worn = wear_id
			O.icon = 'icons/mob/ids.dmi'
			O.icon_state = ID_worn.icon_state
			if(species.name in ID_worn.species_fit) //Allows clothes to display differently for multiple species
				if(species.id_icons && has_icon(species.id_icons, ID_worn.icon_state))
					O.icon = species.uniform_icons
			if((gender == FEMALE) && (ID_worn.clothing_flags & GENDERFIT)) //genderfit
				if(has_icon(O.icon,"[ID_worn.icon_state]_f"))
					O.icon_state = "[ID_worn.icon_state]_f"

			O.overlays.len = 0
			if(wear_id.dynamic_overlay)
				if(wear_id.dynamic_overlay["[ID_LAYER]"])
					var/image/dyn_overlay = wear_id.dynamic_overlay["[ID_LAYER]"]
					O.overlays += dyn_overlay
			O.pixel_x = species.inventory_offsets["[slot_wear_id]"]["pixel_x"] * PIXEL_MULTIPLIER
			O.pixel_y = species.inventory_offsets["[slot_wear_id]"]["pixel_y"] * PIXEL_MULTIPLIER
			obj_to_plane_overlay(O,ID_LAYER)
			//overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id")
		//else
			//overlays_standing[ID_LAYER]	= null
	//else
		//overlays_standing[ID_LAYER]	= null

	hud_updateflag |= 1 << ID_HUD
	hud_updateflag |= 1 << WANTED_HUD

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_gloves(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[GLOVES_LAYER]
	var/obj/abstract/Overlays/O = obj_overlays[GLOVES_LAYER]
	O.overlays.len = 0
	O.color = null
	if(gloves && !check_hidden_body_flags(HIDEGLOVES) && gloves.is_visible())


		var/t_state = gloves.item_state
		if(!t_state)
			t_state = gloves.icon_state
		var/image/standing
		if(gloves.wear_override)
			standing = image("icon" = gloves.wear_override)
		else
			standing = image("icon" = ((gloves.icon_override) ? gloves.icon_override : 'icons/mob/hands.dmi'), "icon_state" = "[t_state]")

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_gloves, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in gloves.species_fit) //Allows clothes to display differently for multiple species
			if(S.gloves_icons && has_icon(S.gloves_icons, t_state))
				standing.icon = S.gloves_icons

		if((gender == FEMALE) && (gloves.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon,"[gloves.icon_state]_f"))
				standing.icon_state = "[gloves.icon_state]_f"

		if(gloves.dynamic_overlay)
			if(gloves.dynamic_overlay["[GLOVES_LAYER]"])
				var/image/dyn_overlay = gloves.dynamic_overlay["[GLOVES_LAYER]"]
				O.overlays += dyn_overlay

		if (istype(gloves, /obj/item/clothing/gloves))
			var/obj/item/clothing/gloves/actual_gloves = gloves
			if(actual_gloves.transfer_blood > 0 && actual_gloves.blood_DNA?.len)
				var/blood_icon_state = "bloodyhands"
				switch(get_species())
					if("Vox")
						blood_icon_state = "bloodyhands-vox"
					if("Insectoid")
						blood_icon_state = "bloodyhands-vox"
				var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
				bloodsies.color = actual_gloves.blood_color
				standing.overlays	+= bloodsies
				O.overlays += bloodsies
			else
				if (actual_gloves.blood_overlay)
					actual_gloves.overlays.Remove(actual_gloves.blood_overlay)
		gloves.screen_loc = ui_gloves

		gloves.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		if(gloves.clothing_flags & COLORS_OVERLAY)
			O.color = gloves.color
		O.pixel_x = species.inventory_offsets["[slot_gloves]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_gloves]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,GLOVES_LAYER)
	else
		if(bloody_hands > 0 && bloody_hands_data?.len)
			var/blood_icon_state = "bloodyhands"
			switch(get_species())
				if("Vox")
					blood_icon_state = "bloodyhands-vox"
				if("Insectoid")
					blood_icon_state = "bloodyhands-vox"
			O.icon = 'icons/effects/blood.dmi'
			O.icon_state = blood_icon_state
			O.color = bloody_hands_data["blood_colour"]
			obj_to_plane_overlay(O,GLOVES_LAYER)
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_glasses(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[GLASSES_LAYER]
	overlays -= obj_overlays[GLASSES_OVER_HAIR_LAYER]
	if(glasses && !check_hidden_head_flags(HIDEEYES) && glasses.is_visible())
		var/image/standing
		if(glasses.wear_override)
			standing = image("icon" = glasses.wear_override)
		else
			standing = image("icon" = ((glasses.icon_override) ? glasses.icon_override : 'icons/mob/eyes.dmi'), "icon_state" = "[glasses.icon_state]")

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in glasses.species_fit) //Allows clothes to display differently for multiple species
			if(S.glasses_icons && has_icon(S.glasses_icons, glasses.icon_state))
				standing.icon = S.glasses_icons

		if((gender == FEMALE) && (glasses.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon,"[glasses.icon_state]_f"))
				standing.icon_state = "[glasses.icon_state]_f"

		if(glasses.cover_hair)
			var/obj/abstract/Overlays/O = obj_overlays[GLASSES_OVER_HAIR_LAYER]
			O.color = null
			O.icon = standing
			O.icon_state = standing.icon_state
			if(glasses.clothing_flags & COLORS_OVERLAY)
				O.color = glasses.color
			O.overlays.len = 0
			if(glasses.dynamic_overlay)
				if(glasses.dynamic_overlay["[GLASSES_OVER_HAIR_LAYER]"])
					var/image/dyn_overlay = glasses.dynamic_overlay["[GLASSES_OVER_HAIR_LAYER]"]
					O.overlays += dyn_overlay
			obj_to_plane_overlay(O,GLASSES_OVER_HAIR_LAYER)
			//overlays_standing[GLASSES_OVER_HAIR_LAYER]	= standing
		else
			var/obj/abstract/Overlays/O = obj_overlays[GLASSES_LAYER]
			O.color = null
			O.icon = standing
			O.icon_state = standing.icon_state
			if(glasses.clothing_flags & COLORS_OVERLAY)
				O.color = glasses.color
			O.overlays.len = 0
			if(glasses.dynamic_overlay)
				if(glasses.dynamic_overlay["[GLASSES_LAYER]"])
					var/image/dyn_overlay = glasses.dynamic_overlay["[GLASSES_LAYER]"]
					O.overlays += dyn_overlay
			O.pixel_x = species.inventory_offsets["[slot_glasses]"]["pixel_x"] * PIXEL_MULTIPLIER
			O.pixel_y = species.inventory_offsets["[slot_glasses]"]["pixel_y"] * PIXEL_MULTIPLIER
			obj_to_plane_overlay(O,GLASSES_LAYER)
			//overlays_standing[GLASSES_LAYER]	= standing


	//else
		//overlays_standing[GLASSES_LAYER]	= null
		//overlays_standing[GLASSES_OVER_HAIR_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_ears(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[EARS_LAYER]
	if(ears && !check_hidden_head_flags(HIDEEARS) && ears.is_visible())
		var/image/standing
		if(ears.wear_override)
			standing = image("icon" = ears.wear_override)
		else
			standing = image("icon" = ((ears.icon_override) ? ears.icon_override : 'icons/mob/ears.dmi'), "icon_state" = "[ears.icon_state]")

		var/obj/item/I = ears

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.ears_icons && has_icon(S.ears_icons, ears.icon_state))
				standing.icon = S.ears_icons

		if((gender == FEMALE) && (ears.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon,"[ears.icon_state]_f"))
				standing.icon_state = "[ears.icon_state]_f"

		var/obj/abstract/Overlays/O = obj_overlays[EARS_LAYER]
		O.color = null
		O.icon = standing
		O.icon_state = standing.icon_state
		O.overlays.len = 0
		if(ears.dynamic_overlay)
			if(ears.dynamic_overlay["[EARS_LAYER]"])
				var/image/dyn_overlay = ears.dynamic_overlay["[EARS_LAYER]"]
				O.overlays += dyn_overlay
		if(I.clothing_flags & COLORS_OVERLAY)
			O.color = I.color
		O.pixel_x = species.inventory_offsets["[slot_ears]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_ears]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,EARS_LAYER)
		//overlays_standing[EARS_LAYER] = standing
	//else
		//overlays_standing[EARS_LAYER] = null

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_shoes(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[SHOES_LAYER]
	if(shoes && !check_hidden_body_flags(HIDESHOES) && shoes.is_visible())
		var/obj/abstract/Overlays/O = obj_overlays[SHOES_LAYER]
		O.color = null
		if(shoes.wear_override)
			O.icon = icon("icon" = shoes.wear_override)
		else
			O.icon = ((shoes.icon_override) ? shoes.icon_override : 'icons/mob/feet.dmi')
			O.icon_state = shoes.icon_state
		//var/image/standing	= image("icon" = ((shoes.icon_override) ? shoes.icon_override : 'icons/mob/feet.dmi'), "icon_state" = "[shoes.icon_state]")

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_shoes, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in shoes.species_fit) //Allows clothes to display differently for multiple species
			if(S.shoes_icons && has_icon(S.shoes_icons, shoes.icon_state))
				O.icon = S.shoes_icons

		if((gender == FEMALE) && (shoes.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(O.icon,"[shoes.icon_state]_f"))
				O.icon_state = "[shoes.icon_state]_f"

		if(shoes.clothing_flags & COLORS_OVERLAY)
			O.color = shoes.color
		O.overlays.len = 0
		if(shoes.dynamic_overlay)
			if(shoes.dynamic_overlay["[SHOES_LAYER]"])
				var/image/dyn_overlay = shoes.dynamic_overlay["[SHOES_LAYER]"]
				O.overlays += dyn_overlay
		if(shoes.blood_DNA && shoes.blood_DNA.len)
			var/blood_icon_state = "shoeblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "shoeblood-vox"
				if("Insectoid")
					blood_icon_state = "shoeblood-vox"
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
			bloodsies.color = shoes.blood_color
			//standing.overlays	+= bloodsies
			O.overlays += bloodsies
		//overlays_standing[SHOES_LAYER]	= standing

		shoes.generate_accessory_overlays(O)

		O.pixel_x = species.inventory_offsets["[slot_shoes]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_shoes]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,SHOES_LAYER)
	//else
		//overlays_standing[SHOES_LAYER]		= null
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_s_store(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[SUIT_STORE_LAYER]
	if(s_store)
		var/t_state = s_store.item_state
		if(!t_state)
			t_state = s_store.icon_state
		var/obj/abstract/Overlays/O = obj_overlays[SUIT_STORE_LAYER]
		O.icon = 'icons/mob/belt_mirror.dmi'
		O.icon_state = t_state
		O.overlays.len = 0
		if(s_store.dynamic_overlay)
			if(s_store.dynamic_overlay["[SUIT_STORE_LAYER]"])
				var/image/dyn_overlay = s_store.dynamic_overlay["[SUIT_STORE_LAYER]"]
				O.overlays += dyn_overlay
		O.pixel_x = (species.inventory_offsets["[slot_s_store]"]["pixel_x"]) * PIXEL_MULTIPLIER
		O.pixel_y = (species.inventory_offsets["[slot_s_store]"]["pixel_y"]) * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,SUIT_STORE_LAYER)
		//overlays_standing[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]")

		var/x_pixel_offset = initial(s_store.pixel_x)
		var/y_pixel_offset = initial(s_store.pixel_y)
		s_store.screen_loc = "WEST+2:[(10+x_pixel_offset)*PIXEL_MULTIPLIER],SOUTH:[(5+y_pixel_offset)*PIXEL_MULTIPLIER]"
	//else
		//overlays_standing[SUIT_STORE_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_head(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[HEAD_LAYER]
	if(head && head.is_visible())
		var/obj/abstract/Overlays/O = obj_overlays[HEAD_LAYER]
		O.color = null
		O.overlays.len = 0
		head.screen_loc = ui_head		//TODO
		var/image/standing
		if(head.wear_override)
			standing = image("icon" = head.wear_override)
		else
			standing = image("icon" = ((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[head.icon_state]")

		var/obj/item/I = head

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.head_icons && has_icon(S.head_icons, head.icon_state))
				standing.icon = S.head_icons

		if((gender == FEMALE) && (head.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon, "[head.icon_state]_f"))
				standing.icon_state = "[head.icon_state]_f"

		if(head.dynamic_overlay)
			if(head.dynamic_overlay["[HEAD_LAYER]"])
				var/image/dyn_overlay = head.dynamic_overlay["[HEAD_LAYER]"]
				O.overlays += dyn_overlay

		if(head.blood_DNA && head.blood_DNA.len)
			var/blood_icon_state = "helmetblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "helmetblood-vox"
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
			bloodsies.color = head.blood_color
			//standing.overlays	+= bloodsies
			O.overlays	+= bloodsies

		head.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		if(I.clothing_flags & COLORS_OVERLAY)
			O.color = I.color
		O.pixel_x = species.inventory_offsets["[slot_head]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_head]"]["pixel_y"] * PIXEL_MULTIPLIER
		//overlays_standing[HEAD_LAYER]	= standing
	//else
		//overlays_standing[HEAD_LAYER]	= null

		if(istype(head,/obj/item/clothing/head))
			var/obj/item/clothing/head/hat = head
			var/i = 1
			for(var/obj/item/clothing/head/above = hat.on_top; above; above = above.on_top)
				if(above.wear_override)
					standing = image("icon" = above.wear_override)
				else
					standing = image("icon" = ((above.icon_override) ? above.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[above.icon_state]")

				for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
					if(OE.species)
						S = OE.species
						break

				if(S.name in above.species_fit) //Allows clothes to display differently for multiple species
					if(S.head_icons && has_icon(S.head_icons, above.icon_state))
						standing.icon = S.head_icons

				if((gender == FEMALE) && (above.clothing_flags & GENDERFIT)) //genderfit
					if(has_icon(standing.icon, "[above.icon_state]_f"))
						standing.icon_state = "[above.icon_state]_f"

				standing.pixel_y = (species.inventory_offsets["[slot_head]"]["pixel_y"] + (2 * i)) * PIXEL_MULTIPLIER
				O.overlays += standing

				if(above.dynamic_overlay)
					if(above.dynamic_overlay["[HEAD_LAYER]"])
						var/image/dyn_overlay = above.dynamic_overlay["[HEAD_LAYER]"]
						dyn_overlay.pixel_y = (species.inventory_offsets["[slot_head]"]["pixel_y"] + (2 * i)) * PIXEL_MULTIPLIER
						O.overlays += dyn_overlay

				if(above.blood_DNA && above.blood_DNA.len)
					var/blood_icon_state =  "[hat.blood_overlay_type]blood"
					switch(get_species())
						if("Vox")
							blood_icon_state = "[blood_icon_state]-vox"
					var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
					bloodsies.color = above.blood_color
					//standing.overlays	+= bloodsies
					bloodsies.pixel_y = (species.inventory_offsets["[slot_head]"]["pixel_y"] + (2 * i)) * PIXEL_MULTIPLIER
					O.overlays	+= bloodsies

				//above.generate_accessory_overlays(O)
				i++

		obj_to_plane_overlay(O,HEAD_LAYER)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_belt(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[BELT_LAYER]
	if(belt && belt.is_visible())
		belt.screen_loc = ui_belt	//TODO
		var/t_state = belt.item_state
		if(!t_state)
			t_state = belt.icon_state
		var/image/standing = image("icon" = ((belt.icon_override) ? belt.icon_override : 'icons/mob/belt.dmi'), "icon_state" = "[t_state]")

		var/obj/item/I = belt

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_belt, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.belt_icons && has_icon(S.belt_icons, t_state))
				standing.icon = S.belt_icons

		if((gender == FEMALE) && (belt.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon,"[belt.icon_state]_f"))
				standing.icon_state = "[belt.icon_state]_f"

		var/obj/abstract/Overlays/O = obj_overlays[BELT_LAYER]
		O.color = null
		O.icon = standing
		O.icon_state = standing.icon_state
		if(I.clothing_flags & COLORS_OVERLAY)
			O.color = I.color
		O.overlays.len = 0
		if(belt.dynamic_overlay)
			if(belt.dynamic_overlay["[BELT_LAYER]"])
				var/image/dyn_overlay = belt.dynamic_overlay["[BELT_LAYER]"]
				O.overlays += dyn_overlay
		O.pixel_x = species.inventory_offsets["[slot_belt]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_belt]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,BELT_LAYER)
		//overlays_standing[BELT_LAYER]	= standing
	//else
		//overlays_standing[BELT_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_wear_suit(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[SUIT_LAYER]
	if( wear_suit && wear_suit.is_visible())	//TODO check this
		wear_suit.screen_loc = ui_oclothing	//TODO
		var/obj/abstract/Overlays/O = obj_overlays[SUIT_LAYER]
		O.color = null
		O.overlays.len = 0
		var/image/standing	= image("icon" = ((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "icon_state" = "[wear_suit.icon_state]")
		var/datum/species/SP = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_wear_suit, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				SP = OE.species
				break
		if((((M_FAT in mutations) && (species.anatomy_flags & CAN_BE_FAT)) || (species.anatomy_flags & IS_BULKY)) && !(wear_suit.icon_override))
			if(wear_suit.clothing_flags&ONESIZEFITSALL)
				standing.icon	= 'icons/mob/suit_fat.dmi'
				if(SP.name in wear_suit.species_fit) //Allows clothes to display differently for multiple species
					if(SP.fat_wear_suit_icons && has_icon(SP.fat_wear_suit_icons, wear_suit.icon_state))
						standing.icon = SP.wear_suit_icons
				if((gender == FEMALE) && (wear_suit.clothing_flags & GENDERFIT)) //genderfit
					if(has_icon(standing.icon,"[wear_suit.icon_state]_f"))
						standing.icon_state = "[wear_suit.icon_state]_f"
			else
				to_chat(src, "<span class='warning'>You burst out of \the [wear_suit]!</span>")
				drop_from_inventory(wear_suit)
		else
			if(SP.name in wear_suit.species_fit) //Allows clothes to display differently for multiple species
				if(SP.wear_suit_icons && has_icon(SP.wear_suit_icons, wear_suit.icon_state))
					standing.icon = SP.wear_suit_icons
			if((gender == FEMALE) && (wear_suit.clothing_flags & GENDERFIT)) //genderfit
				if(has_icon(standing.icon,"[wear_suit.icon_state]_f"))
					standing.icon_state = "[wear_suit.icon_state]_f"



		if(wear_suit.dynamic_overlay)
			if(wear_suit.dynamic_overlay["[SUIT_LAYER]"])
				var/image/dyn_overlay = wear_suit.dynamic_overlay["[SUIT_LAYER]"]
				O.overlays += dyn_overlay

		if(istype(wear_suit, /obj/item/clothing/suit/strait_jacket) )
			drop_hands()

		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/C = wear_suit
			if(C.blood_DNA && C.blood_DNA.len)
				var/blood_icon_state = "[C.blood_overlay_type]blood"
				switch(get_species())
					if("Vox")
						blood_icon_state = "[blood_icon_state]-vox"
				var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
				bloodsies.color = wear_suit.blood_color
				//standing.overlays	+= bloodsies
				O.overlays	+= bloodsies

		wear_suit.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		if(wear_suit.clothing_flags & COLORS_OVERLAY)
			O.color = wear_suit.color
		O.pixel_x = species.inventory_offsets["[slot_wear_suit]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_wear_suit]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,SUIT_LAYER)
		//overlays_standing[SUIT_LAYER]	= standing
		update_tail_showing(0)
	else
		//overlays_standing[SUIT_LAYER]	= null
		update_tail_showing(0)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_pockets(var/update_icons=1)
	if(monkeyizing)
		return
	if(l_store)
		l_store.screen_loc = ui_storage1	//TODO
	if(r_store)
		r_store.screen_loc = ui_storage2	//TODO
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_wear_mask(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[FACEMASK_LAYER]
	if( wear_mask && !check_hidden_head_flags(MOUTH) && wear_mask.is_visible())
		var/obj/abstract/Overlays/O = obj_overlays[FACEMASK_LAYER]
		O.color = null
		O.overlays.len = 0
		wear_mask.screen_loc = ui_mask	//TODO
		var/image/standing	= image("icon" = ((wear_mask.icon_override) ? wear_mask.icon_override : 'icons/mob/mask.dmi'), "icon_state" = "[wear_mask.icon_state]")

		var/obj/item/I = wear_mask

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_wear_mask, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.wear_mask_icons && has_icon(S.wear_mask_icons, wear_mask.icon_state))
				standing.icon = S.wear_mask_icons

		if((gender == FEMALE) && (wear_mask.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon,"[wear_mask.icon_state]_f"))
				standing.icon_state = "[wear_mask.icon_state]_f"

		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/image/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]
				O.overlays += dyn_overlay

		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA && wear_mask.blood_DNA.len )
			var/blood_icon_state = "maskblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "maskblood-vox"
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = blood_icon_state)
			bloodsies.color = wear_mask.blood_color
			//standing.overlays	+= bloodsies
			O.overlays += bloodsies

		wear_mask.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		if(I.clothing_flags & COLORS_OVERLAY)
			O.color = I.color
		O.pixel_x = species.inventory_offsets["[slot_wear_mask]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_wear_mask]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,FACEMASK_LAYER)
		//overlays_standing[FACEMASK_LAYER]	= standing
	//else
		//overlays_standing[FACEMASK_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_back(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[BACK_LAYER]
	if(back && back.is_visible())
		back.screen_loc = ui_back	//TODO
		var/image/standing	= image("icon" = ((back.icon_override) ? back.icon_override : 'icons/mob/back.dmi'), "icon_state" = "[back.icon_state]")

		var/obj/item/I = back

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_back, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.back_icons && has_icon(S.back_icons, back.icon_state))
				standing.icon = S.back_icons

		if((gender == FEMALE) && (back.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing.icon, "[back.icon_state]_f"))
				standing.icon_state = "[back.icon_state]_f"

		var/obj/abstract/Overlays/O = obj_overlays[BACK_LAYER]
		O.color = null
		O.icon = standing
		O.icon_state = standing.icon_state
		if(I.clothing_flags & COLORS_OVERLAY)
			O.color = I.color
		O.overlays.len = 0
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/image/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				O.overlays += dyn_overlay
		O.pixel_x = species.inventory_offsets["[slot_back]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_back]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,BACK_LAYER)

		//overlays_standing[BACK_LAYER]	= standing
	//else
		//overlays_standing[BACK_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			update_internals()
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/human/update_inv_handcuffed(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[HANDCUFF_LAYER]
	if(handcuffed && handcuffed.is_visible())
		drop_hands()
		stop_pulling()	//TODO: should be handled elsewhere
		var/obj/abstract/Overlays/O = obj_overlays[HANDCUFF_LAYER]
		O.icon = 'icons/obj/cuffs.dmi'
		O.icon_state = handcuffed.icon_state
		O.pixel_x = species.inventory_offsets["[slot_handcuffed]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_handcuffed]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,HANDCUFF_LAYER)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_mutual_handcuffed(var/update_icons = TRUE)
	if(monkeyizing)
		return
	overlays -= obj_overlays[MUTUALCUFF_LAYER]
	if (mutual_handcuffs && mutual_handcuffs.is_visible())
		stop_pulling()	//TODO: should be handled elsewhere
		var/obj/abstract/Overlays/O = obj_overlays[MUTUALCUFF_LAYER]
		O.icon = 'icons/obj/cuffs.dmi'
		O.icon_state = "singlecuff1"//TODO: procedurally generated single-cuffs
		O.pixel_x = species.inventory_offsets["[slot_handcuffed]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_handcuffed]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,MUTUALCUFF_LAYER)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_legcuffed(var/update_icons=1)
	if(monkeyizing)
		return
	overlays -= obj_overlays[LEGCUFF_LAYER]
	if(legcuffed && legcuffed.is_visible())
		var/obj/abstract/Overlays/O = obj_overlays[LEGCUFF_LAYER]
		O.icon = 'icons/obj/cuffs.dmi'
		O.icon_state = "legcuff1"
		O.pixel_x = species.inventory_offsets["[slot_legcuffed]"]["pixel_x"] * PIXEL_MULTIPLIER
		O.pixel_y = species.inventory_offsets["[slot_legcuffed]"]["pixel_y"] * PIXEL_MULTIPLIER
		obj_to_plane_overlay(O,LEGCUFF_LAYER)
		//overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1")
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"

	//elsek
		//overlays_standing[LEGCUFF_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_hand(index, var/update_icons = 1)
	if(monkeyizing)
		return
	if(!obj_overlays)	//this shouldn't happen, but it does
		return
	var/obj/abstract/Overlays/hand_layer/O = obj_overlays["[HAND_LAYER]-[index]"]
	if(!O) //theoretically, should only be done once per hand
		O = new /obj/abstract/Overlays/hand_layer
		obj_overlays["[HAND_LAYER]-[index]"] = O
	else
		overlays.Remove(O)
		O.overlays.len = 0

	var/obj/item/I = get_held_item_by_index(index)

	if(I && I.is_visible())
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		if(!t_state)
			t_state = I.icon_state

		O.name = "[index]"
		O.icon = t_inhand_state
		O.icon_state = t_state
		O.color = I.color
		O.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
		O.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2
		O.layer = O.layer

		var/list/offsets = get_item_offset_by_index(index)

		O.pixel_x += offsets["x"]
		O.pixel_y += offsets["y"]

		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/image/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[index]"]
			O.overlays.Add(dyn_overlay)
		I.screen_loc = get_held_item_ui_location(index,I)

		if(handcuffed) //why is this here AUGH
			drop_item(I)

		overlays.Add(O)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_r_hand(var/update_icons=1)
	return update_inv_hand(GRASP_RIGHT_HAND, update_icons)

/mob/living/carbon/human/update_inv_l_hand(var/update_icons=1)
	return update_inv_hand(GRASP_LEFT_HAND, update_icons)

/mob/living/carbon/human/proc/update_tail_showing(var/update_icons=1)
	//overlays_standing[TAIL_LAYER] = null
	overlays -= obj_overlays[TAIL_LAYER]
	if(species && species.tail && species.anatomy_flags & HAS_TAIL)
		if(!wear_suit || !is_slot_hidden(wear_suit.body_parts_covered, HIDEJUMPSUIT, 0, wear_suit.body_parts_visible_override))
			var/obj/abstract/Overlays/O = obj_overlays[TAIL_LAYER]
			O.icon = 'icons/effects/species.dmi'
			O.icon_state = "[species.tail]_s"
			obj_to_plane_overlay(O,TAIL_LAYER)
			//if(!old_tail_state) //only update if we didnt show our tail already

				//overlays_standing[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_s")
//				to_chat(src, "update: tail is different")
		//else
			//overlays_standing[TAIL_LAYER] = null

	if(update_icons)
		update_icons()

// Used mostly for creating head items
/mob/living/carbon/human/proc/generate_head_icon()
//gender no longer matters for the mouth, although there should probably be seperate base head icons.
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"

	//base icons
	var/icon/face_lying		= new /icon('icons/mob/hair_styles.dmi',"bald_l")

	if(my_appearance.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[my_appearance.f_style]
		if(facial_hair_style)
			var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
			facial_l.Blend(rgb(my_appearance.r_facial, my_appearance.g_facial, my_appearance.b_facial), ICON_ADD)
			face_lying.Blend(facial_l, ICON_OVERLAY)

	if(my_appearance.h_style)
		var/datum/sprite_accessory/hair_style = hair_styles_list[my_appearance.h_style]
		if(hair_style)
			var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
			hair_l.Blend(rgb(my_appearance.r_hair, my_appearance.g_hair, my_appearance.b_hair), ICON_ADD)
			face_lying.Blend(hair_l, ICON_OVERLAY)

	//Eyes
	// Note: These used to be in update_face(), and the fact they're here will make it difficult to create a disembodied head
	var/icon/eyes_l = new/icon('icons/mob/hair_styles.dmi', "eyes_l")
	eyes_l.Blend(rgb(my_appearance.r_eyes, my_appearance.g_eyes, my_appearance.b_eyes), ICON_ADD)
	face_lying.Blend(eyes_l, ICON_OVERLAY)

	if(lip_style)
		face_lying.Blend(new/icon('icons/mob/hair_styles.dmi', "lips_[lip_style]_l"), ICON_OVERLAY)

	if(eye_style)
		face_lying.Blend(new/icon('icons/mob/hair_styles.dmi', "eyeshadow_[eye_style]_light_l"), ICON_OVERLAY)

	var/image/face_lying_image = new /image(icon = face_lying)
	return face_lying_image

//lower cost way of updating the necessary human icons on equip and unequip
/mob/living/carbon/human/proc/update_hidden_item_icons(var/obj/item/W)
	if(!W || gcDestroyed || monkeyizing)
		return

	if(is_slot_hidden(W.body_parts_covered, (HIDEHEADHAIR), 0, W.body_parts_visible_override) || is_slot_hidden(W.body_parts_covered, (MASKHEADHAIR), 0, W.body_parts_visible_override) || is_slot_hidden(W.body_parts_covered, (HIDEBEARDHAIR), 0, W.body_parts_visible_override))
		update_hair()
	if(is_slot_hidden(W.body_parts_covered, (MOUTH), 0, W.body_parts_visible_override))
		update_inv_wear_mask()
	if(is_slot_hidden(W.body_parts_covered, (HIDEGLOVES), 0, W.body_parts_visible_override))
		update_inv_gloves()
	if(is_slot_hidden(W.body_parts_covered, (HIDESHOES), 0, W.body_parts_visible_override))
		update_inv_shoes()
	if(is_slot_hidden(W.body_parts_covered, (HIDEJUMPSUIT), 0, W.body_parts_visible_override))
		update_inv_w_uniform()
	if(is_slot_hidden(W.body_parts_covered, (HIDEEYES), 0, W.body_parts_visible_override))
		update_inv_glasses()
	if(is_slot_hidden(W.body_parts_covered, (HIDEEARS), 0, W.body_parts_visible_override))
		update_inv_ears()

/proc/is_slot_hidden(var/clothes, var/slot = -1,var/ignore_slot = 0, var/visibility_override = 0)
	if(!clothes)
		return 0
	var/true_body_parts_covered = clothes
	if(slot == -1)
		slot = true_body_parts_covered
	if(true_body_parts_covered & IGNORE_INV)
		true_body_parts_covered = 0
	if(visibility_override & slot)//lets you see things like glasses behind transparent helmets, while still hiding hair or other specific flags.
		return 0
	if((true_body_parts_covered) & ignore_slot)
		true_body_parts_covered ^= ignore_slot
	if((true_body_parts_covered & slot) == slot)
		return 1
	return 0

/mob/living/carbon/human/update_inv_by_slot(var/slot_flags)
	if(slot_flags & SLOT_BACK)
		update_inv_back()
	if(slot_flags & SLOT_MASK)
		update_inv_wear_mask()
	if(slot_flags & SLOT_BELT)
		update_inv_belt()
	if(slot_flags & SLOT_EARS)
		update_inv_ears()
	if(slot_flags & SLOT_EYES)
		update_inv_glasses()
	if(slot_flags & SLOT_GLOVES)
		update_inv_gloves()
	if(slot_flags & SLOT_HEAD)
		update_inv_head()
	if(slot_flags & SLOT_FEET)
		update_inv_shoes()
	if(slot_flags & SLOT_OCLOTHING)
		update_inv_wear_suit()
	if(slot_flags & SLOT_ICLOTHING)
		update_inv_w_uniform()

/mob/living/carbon/human/update_hand_icon(var/obj/abstract/screen/inventory/hand_hud_object)
	hand_hud_object.overlays.len = 0
	if(!can_use_hand_or_stump(hand_hud_object.hand_index))
		var/image/cross = image(icon='icons/mob/screen1_White.dmi', icon_state="x")
		cross.alpha = 122
		hand_hud_object.overlays += cross
	else if (!can_use_hand(hand_hud_object.hand_index))
		var/image/bluecross = image(icon='icons/mob/screen1_White.dmi', icon_state="x2")
		bluecross.alpha = 122
		hand_hud_object.overlays += bluecross
	..()
