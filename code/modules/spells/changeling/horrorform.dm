/spell/changeling/horrorform
	name = "Horror Form (30)"
	desc = "We transform into an all-consuming abomination. We are incredibly strong, to the point that we can force open airlocks, and are immune to conventional stuns."
	abbreviation = "HF"
	hud_state = "horrorform"
	spell_flags = NEEDSHUMAN
	max_genedamage = 0
	required_dna = 1
	chemcost = 30
	horrorallowed = 0
	duration = 2 MINUTES
	var/horrorFormMaxHealth = 700

/spell/changeling/horrorform/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) 
		return FALSE
	if(istype(user.loc, /obj/mecha))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE
	if(istype(user.loc, /obj/machinery/atmospherics))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE

/spell/changeling/horrorform/cast(var/list/targets, var/mob/living/carbon/human/user)
	..()
	if (istype(user.loc,/mob))
		to_chat(usr, "<span class='warning'>You can't change right now!</span>")
		return 1
	activate(usr)
	sleep(duration)

/spell/changeling/horrorform/after_cast(list/targets, var/mob/living/carbon/human/user)
	to_chat(usr, "You are feeling weak. Seek somewhere safe.")
	sleep(100)	//10 seconds before deactivate
	deactivate(usr)

	return


/spell/changeling/horrorform/proc/activate(var/mob/living/carbon/human/user)
	//scale health so they don't get free heals all the time
	user.maxHealth = horrorFormMaxHealth
	user.setToxLoss(user.getToxLoss()*horrorFormMaxHealth/100)
	user.adjustBruteLoss(user.getBruteLoss()*horrorFormMaxHealth/100)
	user.setOxyLoss(user.getOxyLoss()*horrorFormMaxHealth/100)
	user.adjustFireLoss(user.getFireLoss()*horrorFormMaxHealth/100)
	user.client.verbs |= user.species.abilities // Force ability equip.
	user.visible_message("<span class = 'danger'>[user] emits a putrid odor as their torso splits open!</span>")
	user.name = "unknown"
	user.real_name = "unknown"
	
	for(var/obj/item/slot in user.get_all_slots())
		user.u_equip(slot, 1)
	user.update_icons()

	user.canmove = 0
	user.delayNextAttack(50)
	user.icon = null
	user.set_species("Horror")
	playsound(user, 'sound/effects/greaterling.ogg', 100, 0, 10)
	user.visible_message("<span class = 'sinister'>A roar pierces the air and makes your blood curdle.</span>", ignore_self = TRUE, range = 10)
	
	user.canmove = 1
	user.delayNextAttack(0)
	user.icon = null
	user.make_changeling()
	
	return

/spell/changeling/horrorform/proc/deactivate(var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	//take random DNA
	var/datum/dna/chosen_dna = changeling.GetDNA(pick(names))
	if(!chosen_dna)
		return

	user.visible_message("<span class='danger'>[user] transforms!</span>")
	user.dna = chosen_dna.Clone()

	user.canmove = 0
	user.icon = null
	user.overlays.len = 0
	user.delayNextAttack(50)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( user, delay_ready_dna=1 )
	O.set_species("Human", 0)
	if (user.dna.GetUIState(DNA_UI_GENDER))
		O.setGender(FEMALE)
	else
		O.setGender(MALE)
	O.update_hair()
	user.transferImplantsTo(O)
	user.transferBorers(O)
	O.dna = user.dna.Clone()
	
	user.dna = null
	O.real_name = chosen_dna.real_name
	O.name = chosen_dna.real_name
	O.flavor_text = chosen_dna.flavor_text

	for(var/obj/item/W in user)
		user.drop_from_inventory(W)
	for(var/obj/T in user)
		qdel(T)
	
	changeling.geneticdamage = 60
	O.forceMove(user.loc)
	O.UpdateAppearance()
	domutcheck(O, null)
	//scale down damage when transforming
	O.setToxLoss(user.getToxLoss()/horrorFormMaxHealth*100)
	O.adjustBruteLoss(user.getBruteLoss()/horrorFormMaxHealth*100)
	O.setOxyLoss(user.getOxyLoss()/horrorFormMaxHealth*100)
	O.adjustFireLoss(user.getFireLoss()/horrorFormMaxHealth*100)
	O.stat = user.stat
	O.delayNextAttack(0)
	user.mind.transfer_to(O)
	O.make_changeling()
	O.changeling_update_languages(changeling.absorbed_languages)
	feedback_add_details("changeling_powers","HF")

	qdel(user)
	
	return