/mob/living/carbon/human/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	for(var/datum/organ/external/E in src.organs)
		if(istype(E, /datum/organ/external/chest) || istype(E, /datum/organ/external/groin)) //Really bad stuff happens when either get removed
			continue
		//Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			//Override the current limb status and don't cause an explosion
			E.droplimb(1, 1)
	dropBorers()
	var/gib_radius = 0
	if(reagents.has_reagent(LUBE))
		gib_radius = 6 //Your insides are all lubed, so gibs travel much further

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-h", sleeptime = 15)
	hgibs(loc, virus2, dna, species.flesh_color, species.blood_color, gib_radius)
	qdel(src)

/mob/living/carbon/human/dust(var/drop_everything = FALSE)
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dropBorers(1)

	if(istype(src, /mob/living/carbon/human/manifested))
		anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-hm", sleeptime = 15)
	else
		anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h", sleeptime = 15)

	var/datum/organ/external/head_organ = get_organ(LIMB_HEAD)
	if(head_organ.status & ORGAN_DESTROYED)
		new /obj/effect/decal/remains/human/noskull(loc)
	else
		new /obj/effect/decal/remains/human(loc)
	if(drop_everything)
		drop_all()
	qdel(src)

/mob/living/carbon/human/Destroy()
	infected_contact_mobs -= src
	if (pathogen)
		for (var/mob/L in science_goggles_wearers)
			if (L.client)
				L.client.images -= pathogen
		pathogen = null

	if(client && iscultist(src) && veil_thickness > CULT_PROLOGUE)
		var/turf/T = get_turf(src)
		if (T)
			var/mob/living/simple_animal/shade/shade = new (T)
			playsound(T, 'sound/hallucinations/growl1.ogg', 50, 1)
			shade.name = "[real_name] the Shade"
			shade.real_name = "[real_name]"
			mind.transfer_to(shade)
			update_faction_icons()
			to_chat(shade, "<span class='sinister'>Dark energies rip your dying body appart, anchoring your soul inside the form of a Shade. You retain your memories, and devotion to the cult.</span>")

	if(species)
		qdel(species)
		species = null

	if(decapitated)
		decapitated.origin_body = null
		decapitated = null

	if(vessel)
		qdel(vessel)
		vessel = null

	my_appearance = null

	..()

	for(var/obj/abstract/Overlays/O in obj_overlays)
		returnToPool(O)

	obj_overlays = null

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
	if(healths)
		healths.icon_state = "health7"
	dizziness = 0
	remove_jitter()

	//If we have brain worms, dump 'em.
	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if(B && B.controlling)
		to_chat(src, "<span class='danger'>Your host has died.  You reluctantly release control.</span>")
		to_chat(B.host_brain, "<span class='danger'>Just before your body passes, you feel a brief return of sensation.  You are now in control...  And dead.</span>")
		do_release_control(0)

	//Check for heist mode kill count.
	//if(ticker.mode && ( istype( ticker.mode,/datum/game_mode/heist) ) )
		//Check for last assailant's mutantrace.
		/*if( LAssailant && ( istype( LAssailant,/mob/living/carbon/human ) ) )
			var/mob/living/carbon/human/V = LAssailant
			if (V.dna && (V.dna.mutantrace == "vox"))
				*/ //Not currently feasible due to terrible LAssailant tracking.
//		to_chat(world, "Vox kills: [vox_kills]")
		//vox_kills++ //Bad vox. Shouldn't be killing humans.
	if(ishuman(LAssailant))
		var/mob/living/carbon/human/H=LAssailant
		if(H.mind)
			H.mind.kills += "[name] ([ckey])"

	if(!gibbed)
		update_canmove()
	stat = DEAD
	tod = worldtime2text() //Weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
		if(!suiciding) //Cowards don't count
			score["deadcrew"]++ //Someone died at this point, and that's terrible
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		//ticker.mode.check_win() //Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	species.handle_death(src)
	if(become_zombie_after_death && isjusthuman(src)) //2 if they retain their mind, 1 if they don't
		spawn(30 SECONDS)
			if(!gcDestroyed)
				make_zombie(retain_mind = become_zombie_after_death-1)
	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(M_SKELETON in src.mutations)
		return

	if(my_appearance.f_style)
		my_appearance.f_style = "Shaved"
	if(my_appearance.h_style)
		my_appearance.h_style = "Bald"
	update_hair(0)

	mutations.Add(M_SKELETON)
	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	head_organ.disfigure("burn")
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/ChangeToHusk()
	if(M_HUSK in mutations)
		return
	if(my_appearance.f_style)
		my_appearance.f_style = "Shaved" //We only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(my_appearance.h_style)
		my_appearance.h_style = "Bald"
	update_hair(0)

	mutations.Add(M_HUSK)
	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	head_organ.disfigure("brute")
	update_body(0)
	update_mutantrace()
	vessel.remove_reagent(BLOOD,vessel.get_reagent_amount(BLOOD))
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= M_NOCLONE
	return
