/mob/living/brain
	var/obj/item/device/mmi/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/datum/dna/stored/stored_dna // dna var for brain. Used to store dna, brain dna is not considered like actual dna, brain.has_dna() returns FALSE.
	stat = DEAD //we start dead by default
	see_invisible = SEE_INVISIBLE_LIVING

/mob/living/brain/Initialize()
	. = ..()
	create_dna(src)
	stored_dna.initialize_dna(random_blood_type())
	if(isturf(loc)) //not spawned in an MMI or brain organ (most likely adminspawned)
		var/obj/item/organ/brain/OB = new(loc) //we create a new brain organ for it.
		OB.brainmob = src
		forceMove(OB)


/mob/living/brain/proc/create_dna()
	stored_dna = new /datum/dna/stored(src)
	if(!stored_dna.species)
		var/rando_race = pick(GLOB.roundstart_races)
		stored_dna.species = new rando_race()

/mob/living/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		if(mind)	//You aren't allowed to return to brains that don't exist
			mind.current = null
		ghostize()		//Ghostize checks for key so nothing else is necessary.
	container = null
	return ..()

/mob/living/brain/update_canmove()
	if(in_contents_of(/obj/mecha))
		canmove = 1
	else
		canmove = 0
	return canmove

/mob/living/brain/ex_act() //you cant blow up brainmobs because it makes transfer_to() freak out when borgs blow up.
	return

/mob/living/brain/blob_act(obj/structure/blob/B)
	return

/mob/living/brain/get_eye_protection()//no eyes
	return 2

/mob/living/brain/get_ear_protection()//no ears
	return 2

/mob/living/brain/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	return // no eyes, no flashing

/mob/living/brain/can_be_revived()
	. = 1
	if(!container || health <= HEALTH_THRESHOLD_DEAD)
		return 0

/mob/living/brain/fully_replace_character_name(oldname,newname)
	..()
	if(stored_dna)
		stored_dna.real_name = real_name

/mob/living/brain/ClickOn(atom/A, params)
	..()
	if(istype(loc, /obj/item/device/mmi))
		var/obj/item/device/mmi/MMI = loc
		var/obj/mecha/M = MMI.mecha
		if((src == MMI.brainmob) && istype(M))
			return M.click_action(A,src,params)

/mob/living/brain/forceMove(atom/destination)
	if(container)
		return container.forceMove(destination)
	else if (istype(loc, /obj/item/organ/brain))
		var/obj/item/organ/brain/B = loc
		B.forceMove(destination)
	else if (istype(destination, /obj/item/organ/brain))
		doMove(destination)
	else if (istype(destination, /obj/item/device/mmi))
		doMove(destination)
	else
		CRASH("Brainmob without a container [src] attempted to move to [destination].")
