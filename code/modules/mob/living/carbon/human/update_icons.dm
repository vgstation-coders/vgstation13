	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.
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
>	All of these procs update our overlays_standing, and then call update_icons() by default.
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
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed
	var/icon/race_icon
	var/icon/deform_icon
	var/update_overlays = FALSE

/mob/living/carbon/human/proc/QueueUpdateDamageIcon(forced = FALSE)
	if(forced)
		UpdateDamageIcon(TRUE)
		update_overlays = FALSE
		return
	update_overlays = TRUE

//UPDATES OVERLAYS FROM OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
// - you never did, elly1989@rocketmail.com on Jun 13, 2012
/mob/living/carbon/human/update_icons()
	update_hud()		//TODO: remove the need for this
	update_overlays_standing()
	update_transform()
	update_hands_icons()
	update_luminosity()
	if(istype(loc,/obj/structure/inflatable/shelter))
		var/obj/O = loc
		O.update_icon() //Shelters use an overlay of the human inside, so if we change state we want the appearance to reflect that.

/mob/living/carbon/human/proc/update_luminosity()//due to moody lights we might want people to show up in the dark even if they aren't actually emitting light
	luminosity = 0
	for (var/obj/item/I in contents)
		luminosity = max(luminosity, I.luminosity)

/mob/living/carbon/human/proc/update_overlays_standing()
	if(species && species.override_icon)
		species_override_icon()
	else
		icon = stand_icon

/mob/living/carbon/human/proc/species_override_icon()
	//overlays.len = 0
	icon = species.override_icon
	//temporary fix for having mutations on top of overriden icons for like muton, horror, etc
	remove_overlay(MUTANTRACE_LAYER)

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
/mob/living/carbon/human/UpdateDamageIcon(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(DAMAGE_LAYER)
	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/dam_human.dmi', "blank", -DAMAGE_LAYER)
	// blend the individual damage states with our icons
	for(var/datum/organ/external/O in organs)
		if(!(O.status & ORGAN_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00")
				continue
			var/icon/DI = get_damage_icon_part(O.damage_state, O.icon_name, (species.blood_color == DEFAULT_BLOOD ? "" : species.blood_color))
			damage_overlay.overlays += DI
	overlays += overlays_standing[DAMAGE_LAYER] = damage_overlay
	if(update_icons)
		update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(update_icons = TRUE)
	if(monkeyizing)
		return

	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/necrosis_color_mod = rgb(10,50,0)

	var/husk = (M_HUSK in mutations)
	var/fat = (M_FAT in mutations) && (species && species.anatomy_flags & CAN_BE_FAT)
	var/hulk = (M_HULK in mutations) && !ishorrorform(src) && mind.special_role != HIGHLANDER // Part of the species.
	var/skeleton = (M_SKELETON in mutations)

	var/g = "m"
	if(gender == FEMALE)
		g = "f"
	if(species && species.anatomy_flags & HAS_ICON_SKIN_TONE)
		species.updatespeciescolor(src)
	var/datum/organ/external/chest = get_organ(LIMB_CHEST)
	stand_icon = chest.get_icon(g,fat)
	if(!skeleton)
		if(husk)
			stand_icon.ColorTone(husk_color_mod)
		else if(hulk)
			var/list/TONE = ReadRGB(hulk_color_mod)
			stand_icon.MapColors(rgb(TONE[1],0,0),rgb(0,TONE[2],0),rgb(0,0,TONE[3]))

	var/datum/organ/external/head = get_organ(LIMB_HEAD)
	var/has_head = FALSE
	if(head && !(head.status & ORGAN_DESTROYED))
		has_head = TRUE

	for(var/datum/organ/external/part in organs)
		if(!istype(part, /datum/organ/external/chest) && !(part.status & ORGAN_DESTROYED))
			var/icon/temp
			if (istype(part, /datum/organ/external/groin) || istype(part, /datum/organ/external/head))
				temp = part.get_icon(g,fat)
			else if(part.has_fat)
				temp = part.get_icon(isFat = fat)
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
				temp2.Insert(icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(icon(temp,dir=SOUTH),dir=SOUTH)
				if(!(part.icon_position & LEFT))
					temp2.Insert(icon(temp,dir=EAST),dir=EAST)
				if(!(part.icon_position & RIGHT))
					temp2.Insert(icon(temp,dir=WEST),dir=WEST)
				stand_icon.Blend(temp2, ICON_OVERLAY)
				temp2 = new('icons/mob/human.dmi',"blank")
				if(part.icon_position & LEFT)
					temp2.Insert(icon(temp,dir=EAST),dir=EAST)
				if(part.icon_position & RIGHT)
					temp2.Insert(icon(temp,dir=WEST),dir=WEST)
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
				stand_icon.Blend(rgb(-my_appearance.s_tone, -my_appearance.s_tone, -my_appearance.s_tone), ICON_SUBTRACT)

	if(husk)
		var/icon/mask = new(stand_icon)
		var/icon/husk_over = new(race_icon,"overlay_husk")
		mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
		husk_over.Blend(mask, ICON_ADD)
		stand_icon.Blend(husk_over, ICON_OVERLAY)
	if(has_head)
		//Eyes
		if(!skeleton)
			var/icon/eyes = icon('icons/mob/hair_styles.dmi', species.eyes)
			eyes.Blend(rgb(my_appearance.r_eyes, my_appearance.g_eyes, my_appearance.b_eyes), ICON_ADD)
			stand_icon.Blend(eyes, ICON_OVERLAY)


		if (face_style)
			stand_icon.Blend(icon('icons/mob/makeup.dmi', "facepaint_[face_style]_s"), ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(lip_style)
			stand_icon.Blend(icon('icons/mob/makeup.dmi', "lips_[lip_style]_s"), ICON_OVERLAY)

		if(eye_style)
			stand_icon.Blend(icon('icons/mob/makeup.dmi', "eyeshadow_[eye_style]_light_s"), ICON_OVERLAY)


	//Underwear
	var/list/undielist
	if(gender == MALE)
		undielist = underwear_m
	else
		undielist = underwear_f
	if(underwear >0 && underwear <= undielist.len && species.anatomy_flags & HAS_UNDERWEAR)
		if(!fat && !skeleton)
			stand_icon.Blend(icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)
	if(body_alphas.len)
		var/lowest_alpha = get_lowest_body_alpha()
		stand_icon -= rgb(0,0,0,lowest_alpha)
	remove_overlay(LIMBS_LAYER)
	var/datum/organ/external/tail/tail = get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	if(tail && (!(tail.status & ORGAN_DESTROYED) && tail.overlap_overlays))
		overlays += overlays_standing[LIMBS_LAYER] = mutable_appearance(stand_icon, layer = -LIMBS_LAYER)
	update_tail_layer(FALSE)
	if(update_icons)
		update_icons()

//HAIR OVERLAY
/mob/living/carbon/human/update_hair(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(HAIR_LAYER)
	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	if( !head_organ || (head_organ.status & ORGAN_DESTROYED) || head_organ.disfigured)
		if(update_icons)
			update_icons()
		return
	var/list/hair_overlays = list()
	var/hair_suffix = check_hidden_head_flags(MASKHEADHAIR) ? "s2" : "s" // s2 = cropped icon
	if(my_appearance.f_style && !(check_hidden_flags(get_clothing_items(), HIDEBEARDHAIR, force_check = TRUE))) //If the beard is hidden, don't draw it
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[my_appearance.f_style]
		if((facial_hair_style) && (species.name in facial_hair_style.species_allowed))
			var/mutable_appearance/facial_hair_overlay = mutable_appearance(facial_hair_style.icon, "[facial_hair_style.icon_state]_s", -HAIR_LAYER)
			if(facial_hair_style.do_colouration)
				facial_hair_overlay.color = COLOR_MATRIX_ADD(rgb(my_appearance.r_facial, my_appearance.g_facial, my_appearance.b_facial))
			hair_overlays += facial_hair_overlay
	if(my_appearance.h_style && !(check_hidden_flags(get_clothing_items(), HIDEHEADHAIR, force_check = TRUE))) //If the hair is hidden, don't draw it
		var/datum/sprite_accessory/hair_style = hair_styles_list[my_appearance.h_style]
		if((hair_style) && (species.name in hair_style.species_allowed))
			if(isvox(src))
				if(my_appearance.r_hair > 7)
					my_appearance.r_hair = rand(1,7)
			var/mutable_appearance/hair_overlay = mutable_appearance(hair_style.icon, "[hair_style.icon_state][isvox(src) ? "_[my_appearance.r_hair]" : ""]_[hair_suffix]", -HAIR_LAYER)
			if(hair_style.do_colouration)
				hair_overlay.color = COLOR_MATRIX_ADD(rgb(my_appearance.r_hair, my_appearance.g_hair, my_appearance.b_hair))
			if(hair_style.additional_accessories)
				hair_overlay.overlays += mutable_appearance(hair_style.icon, "[hair_style.icon_state]_acc", -HAIR_LAYER)
			hair_overlays += hair_overlay
	if(body_alphas.len)
		for(var/mutable_appearance/overlay_image as anything in hair_overlays)
			overlay_image.alpha = get_lowest_body_alpha()
	overlays += overlays_standing[HAIR_LAYER] = hair_overlays
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_mutations(update_icons = TRUE)
	if(monkeyizing)
		return
	var/fat
	if(M_FAT in mutations)
		fat = "fat"
	remove_overlay(MUTATIONS_LAYER)
	var/list/mutations_overlays = list()
	var/add_image = FALSE
	// DNA2 - Drawing underlays.
	var/g = gender == FEMALE ? "f" : "m"
	for(var/gene_type in active_genes)
		var/datum/dna/gene/gene = dna_genes[gene_type]
		if(!gene.block)
			continue
		var/underlay=gene.OnDrawUnderlays(src,g,fat)
		if(underlay)
			mutations_overlays += mutable_appearance('icons/effects/genetics.dmi', underlay, layer = -MUTATIONS_LAYER)
			add_image = TRUE
	for(var/mut in mutations)
		switch(mut)
			if(M_LASER)
				mutations_overlays += mutable_appearance('icons/effects/genetics.dmi', "lasereyes_s", layer = -MUTATIONS_LAYER)
				add_image = TRUE
	if((M_RESIST_COLD in mutations) && (M_RESIST_HEAT in mutations))
		if(!(species.name == "Vox") && !(species.name == "Skeletal Vox"))
			mutations_overlays	-= mutable_appearance('icons/effects/genetics.dmi', "cold[fat]_s", layer = -MUTATIONS_LAYER)
			mutations_overlays	-= mutable_appearance('icons/effects/genetics.dmi', "fire[fat]_s", layer = -MUTATIONS_LAYER)
			mutations_overlays	+= mutable_appearance('icons/effects/genetics.dmi', "coldfire[fat]_s", layer = -MUTATIONS_LAYER)
		else if((species.name == "Vox") || (species.name == "Skeletal Vox"))
			mutations_overlays -= mutable_appearance('icons/effects/genetics.dmi', "coldvox_s", layer = -MUTATIONS_LAYER)
			mutations_overlays	-= mutable_appearance('icons/effects/genetics.dmi', "firevox_s", layer = -MUTATIONS_LAYER)
			mutations_overlays	+= mutable_appearance('icons/effects/genetics.dmi', "coldfirevox_s", layer = -MUTATIONS_LAYER)

	//Cultist tattoos
	if (iscultist(src))
		var/datum/role/cultist/C = iscultist(src)
		add_image = TRUE
		for (var/T in C.tattoos)
			var/datum/cult_tattoo/tattoo = C.tattoos[T]
			if (tattoo && tattoo.Display())
				var/mutable_appearance/cult_tattoo_overlay = mutable_appearance('icons/mob/cult_tattoos.dmi', tattoo.icon_state, layer = -MUTATIONS_LAYER)
				cult_tattoo_overlay.blend_mode = BLEND_MULTIPLY
				mutations_overlays += cult_tattoo_overlay
	if(add_image)
		overlays += overlays_standing[MUTATIONS_LAYER] = mutations_overlays
	if(update_icons)
		update_icons()

/mob/living/carbon/human/proc/update_mutantrace(update_icons = TRUE)
	if(monkeyizing)
		return
	var/fat
	if( M_FAT in mutations )
		fat = "fat"
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"
//BS12 EDIT
	var/skeleton = (M_SKELETON in mutations)
	if(skeleton)
		race_icon = 'icons/mob/human_races/r_skeleton.dmi'
	else
		//Icon data is kept in species datums within the mob.
		if(species && istype(species, /datum/species))
			species.updatespeciescolor(src)
		race_icon = species.icobase
		deform_icon = species.deform
	remove_overlay(MUTANTRACE_LAYER)

	if(dna)
		switch(dna.mutantrace)
			if("slime","shadow")
				if(species && (!species.override_icon && species.has_mutant_race))
					overlays += overlays_standing[MUTANTRACE_LAYER] = mutable_appearance('icons/effects/genetics.dmi', "[dna.mutantrace][fat]_[gender]_s", -MUTANTRACE_LAYER)

	if(!dna || !(dna.mutantrace in list("golem","metroid")))
		update_body(FALSE)

	update_hair(FALSE)
	if(update_icons)
		update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted(update_icons = TRUE)
	remove_overlay(TARGETED_LAYER)
	if(targeted_by && target_locked)
		overlays += overlays_standing[TARGETED_LAYER] = mutable_appearance(target_locked, "locking", -TARGETED_LAYER)//Does not update to "locked" sprite, need to find a way to get icon_state from an image, or rewrite Targeted() proc
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_fire(update_icons = TRUE)
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays += overlays_standing[FIRE_LAYER] = mutable_appearance(fire_dmi, fire_sprite, -FIRE_LAYER)
	if(update_icons)
		update_icons()

//For legacy support.
/mob/living/carbon/human/regenerate_icons()//Changing the order of those procs doesn't change which layer appears on top! That's what the defines in setup.dm are for.
	..()
	if(monkeyizing)
		return
	update_fire(FALSE)
	update_mutations(FALSE)
	update_mutantrace(FALSE)
	update_inv_w_uniform(FALSE)
	update_inv_gloves(FALSE)
	update_inv_glasses(FALSE)
	update_inv_ears(FALSE)
	update_inv_shoes(FALSE)
	update_inv_s_store(FALSE)
	update_inv_wear_mask(FALSE)
	update_inv_head(FALSE)
	update_inv_belt(FALSE)
	update_inv_back(FALSE)
	update_inv_wear_suit(FALSE)
	update_inv_wear_id(FALSE)
	update_inv_hands(FALSE)
	update_inv_handcuffed(FALSE)
	update_inv_mutual_handcuffed(FALSE)
	update_inv_legcuffed(FALSE)
	update_inv_pockets(FALSE)
	QueueUpdateDamageIcon(TRUE)
	update_icons()
	//Hud Stuff
	update_hud()

//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(UNIFORM_LAYER)
	if(!w_uniform)
		var/list/drop_items = list(r_store, l_store, wear_id)
		if(!isbelt(belt))
			drop_items.Add(belt)
		// Automatically drop anything in store / id if you're not wearing a uniform.	//CHECK IF NECESARRY
		for( var/obj/item/thing in drop_items)						//
			if(thing)																			//
				u_equip(thing, TRUE)																//
				if (client)																		//
					client.screen -= thing														//
																								//
				if (thing)																		//
					thing.forceMove(loc)																//
					//thing.dropped(src)														//
					thing.reset_plane_and_layer()

	else if(w_uniform && !check_hidden_body_flags(HIDEJUMPSUIT) && w_uniform.is_visible())
		w_uniform.screen_loc = ui_iclothing
		var/uniform_icon = w_uniform.icon_override || w_uniform.wear_override || 'icons/mob/uniform.dmi'
		var/mutable_appearance/uniform_overlay = mutable_appearance(uniform_icon, layer = -UNIFORM_LAYER)
		var/t_color = w_uniform._color
		var/is_fat = ((M_FAT in mutations) && (species.anatomy_flags & CAN_BE_FAT)) || species.anatomy_flags & IS_BULKY
		if(t_color)
			uniform_overlay.icon_state = "[t_color]_s"
		if(is_fat)
			if(w_uniform.clothing_flags&ONESIZEFITSALL)
				uniform_overlay.icon = 'icons/mob/uniform_fat.dmi'
			else
				to_chat(src, span_warning("You burst out of \the [w_uniform]!"))
				drop_from_inventory(w_uniform)
				return
		var/obj/item/clothing/under/under_uniform = w_uniform
		if(species.name in under_uniform.species_fit) //Allows clothes to display differently for multiple species
			if(species.uniform_icons && has_icon(species.uniform_icons, "[w_uniform.icon_state]_s"))
				uniform_overlay.icon = species.uniform_icons

		if((gender == FEMALE) && (w_uniform.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(uniform_overlay.icon, "[w_uniform.icon_state]_s_f"))
				uniform_overlay.icon_state = "[w_uniform.icon_state]_s_f"

		if(w_uniform.dynamic_overlay)
			if(w_uniform.dynamic_overlay["[UNIFORM_LAYER]"])
				var/mutable_appearance/dyn_overlay = w_uniform.dynamic_overlay["[UNIFORM_LAYER]"]

				if(is_fat)
					dyn_overlay = replace_overlays_icon(dyn_overlay, 'icons/mob/uniform_fat.dmi')
				else if(species.name in under_uniform.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, species.uniform_icons)

				uniform_overlay.overlays += dyn_overlay

		if(w_uniform.blood_DNA && w_uniform.blood_DNA.len)
			var/blood_icon_state = "uniformblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "uniformblood-vox"
			var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_icon_state)
			bloodsies.color	= w_uniform.blood_color
			uniform_overlay.overlays += bloodsies

		under_uniform.generate_accessory_overlays(uniform_overlay)

		if(w_uniform.clothing_flags & COLORS_OVERLAY)
			uniform_overlay.color = w_uniform.color
		uniform_overlay.pixel_x = species.inventory_offsets["[slot_w_uniform]"]["pixel_x"] * PIXEL_MULTIPLIER
		uniform_overlay.pixel_y = species.inventory_offsets["[slot_w_uniform]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[UNIFORM_LAYER] = uniform_overlay
	update_tail_layer(FALSE)
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_wear_id(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(ID_LAYER)
	if(wear_id)
		wear_id.screen_loc = ui_id	//TODO
		if(w_uniform && w_uniform:displays_id)
			var/obj/item/weapon/card/ID_worn = wear_id
			var/mutable_appearance/id_overlay = mutable_appearance('icons/mob/ids.dmi', ID_worn.icon_state, -ID_LAYER)
			if(species.name in ID_worn.species_fit) //Allows clothes to display differently for multiple species
				if(species.id_icons && has_icon(species.id_icons, ID_worn.icon_state))
					id_overlay.icon = species.uniform_icons
			if((gender == FEMALE) && (ID_worn.clothing_flags & GENDERFIT)) //genderfit
				if(has_icon(id_overlay.icon,"[ID_worn.icon_state]_f"))
					id_overlay.icon_state = "[ID_worn.icon_state]_f"
			if(wear_id.dynamic_overlay)
				if(wear_id.dynamic_overlay["[ID_LAYER]"])
					var/mutable_appearance/dyn_overlay = wear_id.dynamic_overlay["[ID_LAYER]"]

					if(species.name in ID_worn.species_fit)
						dyn_overlay = replace_overlays_icon(dyn_overlay, species.id_icons)

					id_overlay.overlays += dyn_overlay
			id_overlay.pixel_x = species.inventory_offsets["[slot_wear_id]"]["pixel_x"] * PIXEL_MULTIPLIER
			id_overlay.pixel_y = species.inventory_offsets["[slot_wear_id]"]["pixel_y"] * PIXEL_MULTIPLIER
			overlays += overlays_standing[ID_LAYER] = id_overlay
	hud_updateflag |= 1 << ID_HUD
	hud_updateflag |= 1 << WANTED_HUD

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_gloves(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(GLOVES_LAYER)
	var/mutable_appearance/gloves_overlay = mutable_appearance(layer = -GLOVES_LAYER)
	if(gloves && !check_hidden_body_flags(HIDEGLOVES) && gloves.is_visible())

		var/onehandedmask
		if(!has_organ(LIMB_LEFT_HAND))
			onehandedmask = "r"
		else if(!has_organ(LIMB_RIGHT_HAND))
			onehandedmask = "l"

		var/t_state = gloves.item_state || gloves.icon_state
		//inhale
		var/standing_icon_path
		var/standing_icon_state
		if(gloves.wear_override)
			standing_icon_path = gloves.wear_override
		else if(gloves.icon_override)
			standing_icon_path = gloves.icon_override
		else
			standing_icon_path = 'icons/mob/hands.dmi'
			standing_icon_state = "[t_state]"
		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_gloves, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break
		if(S.name in gloves.species_fit) //Allows clothes to display differently for multiple species
			if(S.gloves_icons && has_icon(S.gloves_icons, t_state))
				standing_icon_path = S.gloves_icons
		if((gender == FEMALE) && (gloves.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(standing_icon_path,"[gloves.icon_state]_f"))
				standing_icon_state= "[gloves.icon_state]_f"

		//exhale
		var/icon/standing_icon = icon(standing_icon_path, standing_icon_state)
		if(onehandedmask)
			standing_icon.Blend(icon('icons/mob/hands.dmi', "mask_[onehandedmask]"), ICON_ADD)
		gloves_overlay.icon = standing_icon

		if(gloves.dynamic_overlay)
			if(gloves.dynamic_overlay["[GLOVES_LAYER]"])
				var/mutable_appearance/dyn_overlay = gloves.dynamic_overlay["[GLOVES_LAYER]"]

				if(S.name in gloves.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.gloves_icons)

				gloves_overlay.overlays += dyn_overlay

		if (istype(gloves, /obj/item/clothing/gloves))
			var/obj/item/clothing/gloves/actual_gloves = gloves
			if(actual_gloves.transfer_blood > 0 && actual_gloves.blood_DNA?.len)
				var/blood_icon_state = "bloodyhands"
				switch(get_species())
					if("Vox")
						blood_icon_state = "bloodyhands-vox"
					if("Insectoid")
						blood_icon_state = "bloodyhands-vox"

				var/icon/bloodgloveicon = icon('icons/effects/blood.dmi', blood_icon_state)
				if(onehandedmask)
					bloodgloveicon.Blend(icon('icons/mob/hands.dmi', "mask_[onehandedmask]"), ICON_ADD)
				var/mutable_appearance/bloodsies = mutable_appearance(bloodgloveicon)
				bloodsies.color = actual_gloves.blood_color
				gloves_overlay.overlays += bloodsies
			else
				if (actual_gloves.blood_overlay)
					actual_gloves.overlays.Remove(actual_gloves.blood_overlay)
		gloves.screen_loc = ui_gloves

		gloves.generate_accessory_overlays(gloves_overlay)

		if(gloves.clothing_flags & COLORS_OVERLAY)
			gloves_overlay.color = gloves.color
		gloves_overlay.pixel_x = species.inventory_offsets["[slot_gloves]"]["pixel_x"] * PIXEL_MULTIPLIER
		gloves_overlay.pixel_y = species.inventory_offsets["[slot_gloves]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[GLOVES_LAYER] = gloves_overlay
	else
		if(bloody_hands > 0 && bloody_hands_data?.len)
			var/blood_icon_state = "bloodyhands"
			switch(get_species())
				if("Vox")
					blood_icon_state = "bloodyhands-vox"
				if("Insectoid")
					blood_icon_state = "bloodyhands-vox"
			gloves_overlay.icon = 'icons/effects/blood.dmi'
			gloves_overlay.icon_state = blood_icon_state

			var/onehandedmask
			if(!has_organ(LIMB_LEFT_HAND))
				onehandedmask = "l"
			else if(!has_organ(LIMB_RIGHT_HAND))
				onehandedmask = "r"
			if(onehandedmask)
				var/icon/bloodyhandsicon = icon(gloves_overlay.icon)
				bloodyhandsicon.Blend(icon('icons/mob/hands.dmi', "mask_[onehandedmask]"), ICON_ADD)
				gloves_overlay.icon = bloodyhandsicon

			gloves_overlay.color = bloody_hands_data["blood_colour"]
			overlays += overlays_standing[GLOVES_LAYER] = gloves_overlay
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_glasses(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(GLASSES_LAYER)
	remove_overlay(GLASSES_OVER_HAIR_LAYER)
	if(glasses && !check_hidden_head_flags(HIDEEYES) && glasses.is_visible())
		var/glasses_icon = glasses.wear_override || glasses.icon_override || 'icons/mob/eyes.dmi'
		var/mutable_appearance/glasses_overlay = mutable_appearance(glasses_icon, glasses.icon_state, -GLASSES_LAYER)
		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in glasses.species_fit) //Allows clothes to display differently for multiple species
			if(S.glasses_icons && has_icon(S.glasses_icons, glasses.icon_state))
				glasses_overlay.icon = S.glasses_icons

		if((gender == FEMALE) && (glasses.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(glasses_overlay.icon,"[glasses.icon_state]_f"))
				glasses_overlay.icon_state = "[glasses.icon_state]_f"

		if(glasses.cover_hair)
			var/mutable_appearance/glasses_over_hair_overlay = mutable_appearance(glasses_overlay.icon, glasses_overlay.icon_state, -GLASSES_OVER_HAIR_LAYER)
			if(glasses.clothing_flags & COLORS_OVERLAY)
				glasses_over_hair_overlay.color = glasses.color
			if(glasses.dynamic_overlay)
				if(glasses.dynamic_overlay["[GLASSES_OVER_HAIR_LAYER]"])
					var/mutable_appearance/dyn_overlay = glasses.dynamic_overlay["[GLASSES_OVER_HAIR_LAYER]"]

					if(S.name in glasses.species_fit)
						dyn_overlay = replace_overlays_icon(dyn_overlay, S.glasses_icons)

					glasses_over_hair_overlay.overlays += dyn_overlay
			overlays += overlays_standing[GLASSES_OVER_HAIR_LAYER] = glasses_over_hair_overlay
		else
			if(glasses.clothing_flags & COLORS_OVERLAY)
				glasses_overlay.color = glasses.color
			if(glasses.dynamic_overlay)
				if(glasses.dynamic_overlay["[GLASSES_LAYER]"])
					var/mutable_appearance/dyn_overlay = glasses.dynamic_overlay["[GLASSES_LAYER]"]

					if(S.name in glasses.species_fit)
						dyn_overlay = replace_overlays_icon(dyn_overlay, S.glasses_icons)

					glasses_overlay.overlays += dyn_overlay
			glasses_overlay.pixel_x = species.inventory_offsets["[slot_glasses]"]["pixel_x"] * PIXEL_MULTIPLIER
			glasses_overlay.pixel_y = species.inventory_offsets["[slot_glasses]"]["pixel_y"] * PIXEL_MULTIPLIER
			overlays += overlays_standing[GLASSES_LAYER] = glasses_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_ears(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(EARS_LAYER)
	if(ears && !check_hidden_head_flags(HIDEEARS) && ears.is_visible())
		var/ears_slot_icon = ears.wear_override || ears.icon_override || 'icons/mob/ears.dmi'
		var/mutable_appearance/ears_overlay = mutable_appearance(ears_slot_icon, ears.icon_state, -EARS_LAYER)
		var/obj/item/I = ears
		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.ears_icons && has_icon(S.ears_icons, ears.icon_state))
				ears_overlay.icon = S.ears_icons

		if((gender == FEMALE) && (ears.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(ears_overlay.icon,"[ears.icon_state]_f"))
				ears_overlay.icon_state = "[ears.icon_state]_f"
		if(ears.dynamic_overlay)
			if(ears.dynamic_overlay["[EARS_LAYER]"])
				var/mutable_appearance/dyn_overlay = ears.dynamic_overlay["[EARS_LAYER]"]

				if(S.name in ears.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.ears_icons)

				ears_overlay.overlays += dyn_overlay
		if(I.clothing_flags & COLORS_OVERLAY)
			ears_overlay.color = I.color
		ears_overlay.pixel_x = species.inventory_offsets["[slot_ears]"]["pixel_x"] * PIXEL_MULTIPLIER
		ears_overlay.pixel_y = species.inventory_offsets["[slot_ears]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[EARS_LAYER] = ears_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_shoes(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(SHOES_LAYER)
	if(shoes && !check_hidden_body_flags(HIDESHOES) && shoes.is_visible())
		var/shoes_icon = shoes.wear_override || shoes.icon_override || 'icons/mob/feet.dmi'
		var/mutable_appearance/shoes_overlay = mutable_appearance(shoes_icon, shoes.icon_state, -SHOES_LAYER)
		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_shoes, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in shoes.species_fit) //Allows clothes to display differently for multiple species
			if(S.shoes_icons && has_icon(S.shoes_icons, shoes.icon_state))
				shoes_overlay.icon = S.shoes_icons

		if((gender == FEMALE) && (shoes.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(shoes_overlay.icon,"[shoes.icon_state]_f"))
				shoes_overlay.icon_state = "[shoes.icon_state]_f"

		var/onefootedmask
		if(!has_organ(LIMB_LEFT_FOOT))
			onefootedmask = "r"
		else if(!has_organ(LIMB_RIGHT_FOOT))
			onefootedmask = "l"

		var/speciesname = get_species()
		var/shoeiconpath
		if(onefootedmask)
			var/icon/oneshoeicon = icon(shoes_overlay.icon, shoes_overlay.icon_state)
			switch(speciesname)
				if("Vox")
					shoeiconpath = 'icons/mob/species/vox/shoes.dmi'
				if("Insectoid")
					shoeiconpath = 'icons/mob/species/insectoid/feet.dmi'
				else
					shoeiconpath = 'icons/mob/feet.dmi'

			oneshoeicon.Blend(icon(shoeiconpath, "mask_[onefootedmask]"), ICON_ADD)
			shoes_overlay.icon = oneshoeicon

		if(shoes.clothing_flags & COLORS_OVERLAY)
			shoes_overlay.color = shoes.color
		shoes_overlay.overlays.len = 0
		if(shoes.dynamic_overlay)
			if(shoes.dynamic_overlay["[SHOES_LAYER]"])
				var/mutable_appearance/dyn_overlay = shoes.dynamic_overlay["[SHOES_LAYER]"] //as far as i know no shoes use this, so for now no one-footed stuff here

				if(S.name in shoes.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.shoes_icons)

				shoes_overlay.overlays += dyn_overlay
		if(shoes.blood_DNA && shoes.blood_DNA.len)
			var/blood_icon_state = "shoeblood"
			switch(speciesname)
				if("Vox")
					blood_icon_state = "shoeblood-vox"
				if("Insectoid")
					blood_icon_state = "shoeblood-vox"

			var/icon/shoebloodicon = icon('icons/effects/blood.dmi', blood_icon_state)

			//only show blood on shoe on present foot
			if(onefootedmask)
				shoebloodicon.Blend(icon(shoeiconpath, "mask_[onefootedmask]"), ICON_ADD)

			var/mutable_appearance/bloodsies = mutable_appearance(shoebloodicon)
			bloodsies.color = shoes.blood_color
			shoes_overlay.overlays += bloodsies

		shoes.generate_accessory_overlays(shoes_overlay)

		shoes_overlay.pixel_x = species.inventory_offsets["[slot_shoes]"]["pixel_x"] * PIXEL_MULTIPLIER
		shoes_overlay.pixel_y = species.inventory_offsets["[slot_shoes]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[SHOES_LAYER] = shoes_overlay
	else if (!shoes && !check_hidden_body_flags(HIDESHOES))//for bloody bare feet
		if(feet_blood_DNA && feet_blood_DNA.len)
			var/mutable_appearance/shoes_overlay = mutable_appearance(layer = -SHOES_LAYER, alpha = 1)
			var/blood_icon_state = "shoeblood"
			var/onefootedmask
			if(!has_organ(LIMB_LEFT_FOOT))
				onefootedmask = "r"
			else if(!has_organ(LIMB_RIGHT_FOOT))
				onefootedmask = "l"
			switch(get_species())
				if("Vox")
					blood_icon_state = "shoeblood-vox"
				if("Insectoid")
					blood_icon_state = "shoeblood-vox"

			var/icon/feetbloodicon = icon('icons/effects/blood.dmi', blood_icon_state)

			//only show blood on present foot
			if(feetbloodicon)
				feetbloodicon.Blend(icon('icons/effects/blood.dmi', "mask_[onefootedmask]"), ICON_ADD)

			var/mutable_appearance/bloodsies = mutable_appearance(feetbloodicon)
			bloodsies.color = feet_blood_color
			bloodsies.appearance_flags = RESET_ALPHA

			shoes_overlay.overlays += bloodsies

			shoes_overlay.pixel_x = species.inventory_offsets["[slot_shoes]"]["pixel_x"] * PIXEL_MULTIPLIER
			shoes_overlay.pixel_y = species.inventory_offsets["[slot_shoes]"]["pixel_y"] * PIXEL_MULTIPLIER
			overlays += overlays_standing[SHOES_LAYER] = shoes_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_s_store(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(SUIT_STORE_LAYER)
	if(s_store)
		var/t_state = s_store.item_state || s_store.icon_state
		var/mutable_appearance/suit_store_overlay = mutable_appearance('icons/mob/belt_mirror.dmi', t_state, -SUIT_STORE_LAYER)
		if(s_store.dynamic_overlay)
			if(s_store.dynamic_overlay["[SUIT_STORE_LAYER]"])
				var/mutable_appearance/dyn_overlay = s_store.dynamic_overlay["[SUIT_STORE_LAYER]"]
				suit_store_overlay.overlays += dyn_overlay
		suit_store_overlay.pixel_x = (species.inventory_offsets["[slot_s_store]"]["pixel_x"]) * PIXEL_MULTIPLIER
		suit_store_overlay.pixel_y = (species.inventory_offsets["[slot_s_store]"]["pixel_y"]) * PIXEL_MULTIPLIER
		overlays += overlays_standing[SUIT_STORE_LAYER] = suit_store_overlay
		var/x_pixel_offset = initial(s_store.pixel_x)
		var/y_pixel_offset = initial(s_store.pixel_y)
		s_store.screen_loc = "WEST+2:[(10+x_pixel_offset)*PIXEL_MULTIPLIER],SOUTH:[(5+y_pixel_offset)*PIXEL_MULTIPLIER]"
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_head(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(HEAD_LAYER)
	if(head && head.is_visible())
		head.screen_loc = ui_head		//TODO
		var/hat_icon = head.wear_override || head.icon_override || 'icons/mob/head.dmi'
		var/mutable_appearance/head_overlay = mutable_appearance(hat_icon, head.icon_state, -HEAD_LAYER)
		if(head.wear_override)
			head_overlay.icon = head.wear_override
		var/obj/item/I = head
		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.head_icons && has_icon(S.head_icons, head.icon_state))
				head_overlay.icon = S.head_icons

		if((gender == FEMALE) && (head.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(head_overlay.icon, "[head.icon_state]_f"))
				head_overlay.icon_state = "[head.icon_state]_f"

		if(head.dynamic_overlay)
			if(head.dynamic_overlay["[HEAD_LAYER]"])
				var/mutable_appearance/dyn_overlay = head.dynamic_overlay["[HEAD_LAYER]"]

				if(S.name in I.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.head_icons)

				head_overlay.overlays += dyn_overlay

		if(head.blood_DNA && head.blood_DNA.len)
			var/blood_icon_state = "helmetblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "helmetblood-vox"
			var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_icon_state)
			bloodsies.color = head.blood_color
			head_overlay.overlays += bloodsies

		head.generate_accessory_overlays(head_overlay)

		if(I.clothing_flags & COLORS_OVERLAY)
			head_overlay.color = I.color
		head_overlay.pixel_x = species.inventory_offsets["[slot_head]"]["pixel_x"] * PIXEL_MULTIPLIER
		head_overlay.pixel_y = species.inventory_offsets["[slot_head]"]["pixel_y"] * PIXEL_MULTIPLIER

		if(istype(head,/obj/item/clothing/head))
			var/obj/item/clothing/head/hat = head
			head_overlay.pixel_y += hat.vertical_offset
			var/i = 1
			for(var/obj/item/clothing/head/above = hat.on_top; above; above = above.on_top)
				var/above_hat_icon = above.wear_override || above.icon_override || 'icons/mob/head.dmi'
				var/mutable_appearance/above_hat_overlay = mutable_appearance(above_hat_icon, above.icon_state)
				for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
					if(OE.species)
						S = OE.species
						break

				if(S.name in above.species_fit) //Allows clothes to display differently for multiple species
					if(S.head_icons && has_icon(S.head_icons, above.icon_state))
						above_hat_overlay.icon = S.head_icons

				if((gender == FEMALE) && (above.clothing_flags & GENDERFIT)) //genderfit
					if(has_icon(above_hat_overlay.icon, "[above.icon_state]_f"))
						above_hat_overlay.icon_state = "[above.icon_state]_f"

				above_hat_overlay.pixel_y = (species.inventory_offsets["[slot_head]"]["pixel_y"] + (2 * i)) * PIXEL_MULTIPLIER + hat.vertical_offset
				head_overlay.overlays += above_hat_overlay

				if(above.dynamic_overlay)
					if(above.dynamic_overlay["[HEAD_LAYER]"])
						var/mutable_appearance/dyn_overlay = above.dynamic_overlay["[HEAD_LAYER]"]
						dyn_overlay.pixel_y = (species.inventory_offsets["[slot_head]"]["pixel_y"] + (2 * i)) * PIXEL_MULTIPLIER + hat.vertical_offset

						if(S.name in above.species_fit)
							dyn_overlay = replace_overlays_icon(dyn_overlay, S.head_icons)

						head_overlay.overlays += dyn_overlay

				if(above.blood_DNA && above.blood_DNA.len)
					var/blood_icon_state = "[hat.blood_overlay_type]blood"
					switch(get_species())
						if("Vox")
							blood_icon_state = "[blood_icon_state]-vox"
					var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_icon_state)
					bloodsies.color = above.blood_color
					bloodsies.pixel_y = (species.inventory_offsets["[slot_head]"]["pixel_y"] + (2 * i)) * PIXEL_MULTIPLIER + hat.vertical_offset
					head_overlay.overlays += bloodsies
				//above.generate_accessory_overlays(O)
				i++

		overlays += overlays_standing[HEAD_LAYER] = head_overlay
	update_tail_layer(FALSE)
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_belt(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(BELT_LAYER)
	if(belt && belt.is_visible())
		belt.screen_loc = ui_belt	//TODO
		var/t_state = belt.item_state || belt.icon_state
		var/mutable_appearance/belt_overlay = mutable_appearance(((belt.icon_override) ? belt.icon_override : 'icons/mob/belt.dmi'), "[t_state]", -BELT_LAYER)

		var/obj/item/I = belt

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_belt, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.belt_icons && has_icon(S.belt_icons, t_state))
				belt_overlay.icon = S.belt_icons

		if((gender == FEMALE) && (belt.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(belt_overlay.icon,"[belt.icon_state]_f"))
				belt_overlay.icon_state = "[belt.icon_state]_f"
		if(I.clothing_flags & COLORS_OVERLAY)
			belt_overlay.color = I.color
		if(belt.dynamic_overlay)
			if(belt.dynamic_overlay["[BELT_LAYER]"])
				var/mutable_appearance/dyn_overlay = belt.dynamic_overlay["[BELT_LAYER]"]

				if(S.name in belt.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.belt_icons)

				belt_overlay.overlays += dyn_overlay
		belt_overlay.pixel_x = species.inventory_offsets["[slot_belt]"]["pixel_x"] * PIXEL_MULTIPLIER
		belt_overlay.pixel_y = species.inventory_offsets["[slot_belt]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[BELT_LAYER] = belt_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_wear_suit(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(SUIT_LAYER)
	if(wear_suit && wear_suit.is_visible())	//TODO check this
		wear_suit.screen_loc = ui_oclothing	//TODO
		var/mutable_appearance/suit_overlay = mutable_appearance(((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "[wear_suit.icon_state]", -SUIT_LAYER)
		var/datum/species/SP = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_wear_suit, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				SP = OE.species
				break
		if((((M_FAT in mutations) && (species.anatomy_flags & CAN_BE_FAT)) || (species.anatomy_flags & IS_BULKY)) && !(wear_suit.icon_override))
			if(wear_suit.clothing_flags&ONESIZEFITSALL)
				suit_overlay.icon	= 'icons/mob/suit_fat.dmi'
				if(SP.name in wear_suit.species_fit) //Allows clothes to display differently for multiple species
					if(SP.fat_wear_suit_icons && has_icon(SP.fat_wear_suit_icons, wear_suit.icon_state))
						suit_overlay.icon = SP.wear_suit_icons
				if((gender == FEMALE) && (wear_suit.clothing_flags & GENDERFIT)) //genderfit
					if(has_icon(suit_overlay.icon,"[wear_suit.icon_state]_f"))
						suit_overlay.icon_state = "[wear_suit.icon_state]_f"
			else
				to_chat(src, span_warning("You burst out of \the [wear_suit]!"))
				drop_from_inventory(wear_suit)
		else
			if(SP.name in wear_suit.species_fit) //Allows clothes to display differently for multiple species
				if(SP.wear_suit_icons && has_icon(SP.wear_suit_icons, wear_suit.icon_state))
					suit_overlay.icon = SP.wear_suit_icons
			if((gender == FEMALE) && (wear_suit.clothing_flags & GENDERFIT)) //genderfit
				if(has_icon(suit_overlay.icon,"[wear_suit.icon_state]_f"))
					suit_overlay.icon_state = "[wear_suit.icon_state]_f"

		if(wear_suit.dynamic_overlay)
			if(wear_suit.dynamic_overlay["[SUIT_LAYER]"])
				var/mutable_appearance/dyn_overlay = wear_suit.dynamic_overlay["[SUIT_LAYER]"]

				if((((M_FAT in mutations) && (species.anatomy_flags & CAN_BE_FAT)) || (species.anatomy_flags & IS_BULKY)) && !(wear_suit.icon_override))
					dyn_overlay = replace_overlays_icon(dyn_overlay, 'icons/mob/suit_fat.dmi')
				else if(SP.name in wear_suit.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, SP.wear_suit_icons)

				suit_overlay.overlays += dyn_overlay

		if(istype(wear_suit, /obj/item/clothing/suit/strait_jacket) )
			drop_hands()

		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/C = wear_suit
			if(C.blood_DNA && C.blood_DNA.len)
				var/blood_icon_state = "[C.blood_overlay_type]blood"
				switch(get_species())
					if("Vox")
						blood_icon_state = "[blood_icon_state]-vox"
				var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_icon_state)
				bloodsies.color = wear_suit.blood_color
				suit_overlay.overlays	+= bloodsies

		wear_suit.generate_accessory_overlays(suit_overlay)
		if(wear_suit.clothing_flags & COLORS_OVERLAY)
			suit_overlay.color = wear_suit.color
		suit_overlay.pixel_x = species.inventory_offsets["[slot_wear_suit]"]["pixel_x"] * PIXEL_MULTIPLIER
		suit_overlay.pixel_y = species.inventory_offsets["[slot_wear_suit]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[SUIT_LAYER] = suit_overlay
	update_tail_layer(FALSE)
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_pockets(update_icons = TRUE)
	if(monkeyizing)
		return
	if(l_store)
		l_store.screen_loc = ui_storage1	//TODO
	if(r_store)
		r_store.screen_loc = ui_storage2	//TODO
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_wear_mask(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(FACEMASK_LAYER)
	if(wear_mask && !check_hidden_head_flags(MOUTH) && wear_mask.is_visible())
		wear_mask.screen_loc = ui_mask	//TODO
		var/mutable_appearance/mask_overlay = mutable_appearance(((wear_mask.icon_override) ? wear_mask.icon_override : 'icons/mob/mask.dmi'), "[wear_mask.icon_state]", -FACEMASK_LAYER)
		var/obj/item/I = wear_mask

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_wear_mask, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.wear_mask_icons && has_icon(S.wear_mask_icons, wear_mask.icon_state))
				mask_overlay.icon = S.wear_mask_icons

		if((gender == FEMALE) && (wear_mask.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(mask_overlay.icon,"[wear_mask.icon_state]_f"))
				mask_overlay.icon_state = "[wear_mask.icon_state]_f"

		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/mutable_appearance/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]

				if(S.name in wear_mask.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.wear_mask_icons)

				mask_overlay.overlays += dyn_overlay

		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA && wear_mask.blood_DNA.len )
			var/blood_icon_state = "maskblood"
			switch(get_species())
				if("Vox")
					blood_icon_state = "maskblood-vox"
			var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_icon_state)
			bloodsies.color = wear_mask.blood_color
			mask_overlay.overlays += bloodsies

		wear_mask.generate_accessory_overlays(mask_overlay)

		if(I.clothing_flags & COLORS_OVERLAY)
			mask_overlay.color = I.color
		mask_overlay.pixel_x = species.inventory_offsets["[slot_wear_mask]"]["pixel_x"] * PIXEL_MULTIPLIER
		mask_overlay.pixel_y = species.inventory_offsets["[slot_wear_mask]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[FACEMASK_LAYER] = mask_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_back(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(BACK_LAYER)
	if(back && back.is_visible() && !check_hidden_body_flags(HIDEBACK))
		back.screen_loc = ui_back	//TODO
		var/mutable_appearance/back_overlay	= mutable_appearance(((back.icon_override) ? back.icon_override : 'icons/mob/back.dmi'), "[back.icon_state]", -BACK_LAYER)
		var/obj/item/I = back
		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_back, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.back_icons && has_icon(S.back_icons, back.icon_state))
				back_overlay.icon = S.back_icons

		if((gender == FEMALE) && (back.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(back_overlay.icon, "[back.icon_state]_f"))
				back_overlay.icon_state = "[back.icon_state]_f"

		if(I.clothing_flags & COLORS_OVERLAY)
			back_overlay.color = I.color
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/mutable_appearance/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]

				if(S.name in back.species_fit)
					dyn_overlay = replace_overlays_icon(dyn_overlay, S.back_icons)

				back_overlay.overlays += dyn_overlay
		back_overlay.pixel_x = species.inventory_offsets["[slot_back]"]["pixel_x"] * PIXEL_MULTIPLIER
		back_overlay.pixel_y = species.inventory_offsets["[slot_back]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[BACK_LAYER] = back_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_handcuffed(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed && handcuffed.is_visible())
		drop_hands()
		stop_pulling()	//TODO: should be handled elsewhere
		var/mutable_appearance/handcuff_overlay = mutable_appearance('icons/obj/cuffs.dmi', handcuffed.icon_state, -HANDCUFF_LAYER)
		handcuff_overlay.color = handcuffed.color
		handcuff_overlay.pixel_x = species.inventory_offsets["[slot_handcuffed]"]["pixel_x"] * PIXEL_MULTIPLIER
		handcuff_overlay.pixel_y = species.inventory_offsets["[slot_handcuffed]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[HANDCUFF_LAYER] = handcuff_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_mutual_handcuffed(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(MUTUALCUFF_LAYER)
	if (mutual_handcuffs && mutual_handcuffs.is_visible())
		stop_pulling()	//TODO: should be handled elsewhere
		var/mutable_appearance/mutualcuff_overlay = mutable_appearance('icons/obj/cuffs.dmi', "singlecuff1", -MUTUALCUFF_LAYER)//TODO: procedurally generated single-cuffs
		mutualcuff_overlay.pixel_x = species.inventory_offsets["[slot_handcuffed]"]["pixel_x"] * PIXEL_MULTIPLIER
		mutualcuff_overlay.pixel_y = species.inventory_offsets["[slot_handcuffed]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[MUTUALCUFF_LAYER] = mutualcuff_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_legcuffed(update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed && legcuffed.is_visible())
		var/mutable_appearance/legcuff_overlay = mutable_appearance('icons/obj/cuffs.dmi', "legcuff1", -LEGCUFF_LAYER)
		legcuff_overlay.pixel_x = species.inventory_offsets["[slot_legcuffed]"]["pixel_x"] * PIXEL_MULTIPLIER
		legcuff_overlay.pixel_y = species.inventory_offsets["[slot_legcuffed]"]["pixel_y"] * PIXEL_MULTIPLIER
		overlays += overlays_standing[LEGCUFF_LAYER] = legcuff_overlay
		if(m_intent != "walk")
			m_intent = "walk"
			if(hud_used && hud_used.move_intent)
				hud_used.move_intent.icon_state = "walking"
	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_hand(index, update_icons = TRUE)
	if(monkeyizing)
		return
	remove_overlay("[HAND_LAYER]-[index]")
	var/obj/item/I = get_held_item_by_index(index)
	if(I && I.is_visible())
		var/t_state = I.item_state || I.icon_state
		var/t_inhand_state = I.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		var/mutable_appearance/hand_overlay = mutable_appearance(t_inhand_state, t_state, -HAND_LAYER)
		hand_overlay.color = I.color
		hand_overlay.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
		hand_overlay.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2

		var/list/offsets = get_item_offset_by_index(index)

		hand_overlay.pixel_x += offsets["x"]
		hand_overlay.pixel_y += offsets["y"]

		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/mutable_appearance/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[index]"]
			hand_overlay.overlays += dyn_overlay
		I.screen_loc = get_held_item_ui_location(index,I)
		if(handcuffed) //why is this here AUGH
			drop_item(I)
		overlays += overlays_standing["[HAND_LAYER]-[index]"] = hand_overlay
	if(update_icons)
		update_icons()

/mob/living/carbon/human/proc/update_tail_layer(update_icons = TRUE)
	remove_overlay(TAIL_UNDERLIMBS_LAYER)
	remove_overlay(TAIL_LAYER)
	var/datum/organ/external/tail/tail_organ = get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	if(!tail_organ || (tail_organ.status & ORGAN_DESTROYED))
		return
	if(check_hidden_body_flags(HIDETAIL, force_check = TRUE)|| check_hidden_head_flags(HIDETAIL))
		return
	var/tail_file = tail_organ.tail_icon_file
	var/tail_icon_state = tail_organ.icon_name
	if(!tail_file || !tail_icon_state)
		return
	var/mutable_appearance/tail_overlay = mutable_appearance(tail_file, tail_icon_state, -TAIL_LAYER)
	if(species.anatomy_flags & MULTICOLOR)
		tail_overlay.color = COLOR_MATRIX_ADD(rgb(multicolor_skin_r, multicolor_skin_g, multicolor_skin_b))
	if(tail_organ.overlap_overlays) // Tail is overlapped by limbs, so we need special tail icon generation
		// Gives the underlimbs layer SEW directions since it's overlayed by limbs and just about everything else anyway.
		var/mutable_appearance/tail_underlimbs_overlay = mutable_appearance(tail_file, "[tail_icon_state]_BEHIND", -TAIL_UNDERLIMBS_LAYER)
		if(species.anatomy_flags & MULTICOLOR)
			tail_underlimbs_overlay.color = COLOR_MATRIX_ADD(rgb(multicolor_skin_r, multicolor_skin_g, multicolor_skin_b))
		if(body_alphas.len)
			tail_underlimbs_overlay.alpha = get_lowest_body_alpha()
		overlays += overlays_standing[TAIL_UNDERLIMBS_LAYER] = tail_underlimbs_overlay
		// North direction sprite before passing that to the tail layer that overlays uniforms and such.
		tail_overlay.icon_state = "[tail_icon_state]_FRONT"
	if(body_alphas.len)
		tail_overlay.alpha = get_lowest_body_alpha()
	overlays += overlays_standing[TAIL_LAYER] = tail_overlay
	if(update_icons)
		update_icons()

//lower cost way of updating the necessary human icons on equip and unequip
/mob/living/carbon/human/proc/update_hidden_item_icons(obj/item/W)
	if(!W || gcDestroyed || monkeyizing)
		return

	if(is_slot_hidden(W.body_parts_covered, (HIDEHEADHAIR), FALSE, W.body_parts_visible_override) || is_slot_hidden(W.body_parts_covered, (MASKHEADHAIR), FALSE, W.body_parts_visible_override) || is_slot_hidden(W.body_parts_covered, (HIDEBEARDHAIR), FALSE, W.body_parts_visible_override))
		update_hair()
	if(is_slot_hidden(W.body_parts_covered, (MOUTH), FALSE, W.body_parts_visible_override))
		update_inv_wear_mask()
	if(is_slot_hidden(W.body_parts_covered, (HIDEGLOVES), FALSE, W.body_parts_visible_override))
		update_inv_gloves()
	if(is_slot_hidden(W.body_parts_covered, (HIDESHOES), FALSE, W.body_parts_visible_override))
		update_inv_shoes()
	if(is_slot_hidden(W.body_parts_covered, (HIDEJUMPSUIT), FALSE, W.body_parts_visible_override))
		update_inv_w_uniform()
	if(is_slot_hidden(W.body_parts_covered, (HIDEEYES), FALSE, W.body_parts_visible_override))
		update_inv_glasses()
	if(is_slot_hidden(W.body_parts_covered, (HIDEEARS), FALSE, W.body_parts_visible_override))
		update_inv_ears()
	if(is_slot_hidden(W.body_parts_covered, (HIDEBACK), FALSE, W.body_parts_visible_override))
		update_inv_back()

/proc/is_slot_hidden(clothes, slot = -1, ignore_slot = FALSE, visibility_override = FALSE)
	if(!clothes)
		return FALSE
	var/true_body_parts_covered = clothes
	if(slot == -1)
		slot = true_body_parts_covered
	if(true_body_parts_covered & IGNORE_INV)
		true_body_parts_covered = FALSE
	if(visibility_override & slot)//lets you see things like glasses behind transparent helmets, while still hiding hair or other specific flags.
		return FALSE
	if((true_body_parts_covered) & ignore_slot)
		true_body_parts_covered ^= ignore_slot
	if((true_body_parts_covered & slot) == slot)
		return TRUE
	return FALSE

/mob/living/carbon/human/update_hand_icon(obj/abstract/screen/inventory/hand_hud_object)
	hand_hud_object.overlays.len = 0
	if(!can_use_hand_or_stump(hand_hud_object.hand_index))
		hand_hud_object.overlays += mutable_appearance('icons/mob/screen1_White.dmi', "x", alpha = 122)
	else if (!can_use_hand(hand_hud_object.hand_index))
		hand_hud_object.overlays += mutable_appearance('icons/mob/screen1_White.dmi', "x2", alpha = 122)
	..()
