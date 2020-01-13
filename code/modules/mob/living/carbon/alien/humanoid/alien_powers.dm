/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/

/mob/living/carbon/alien/proc/powerc(X, Y)//Y is optional, checks for weed planting. X can be null.
	if(stat)
		to_chat(src, "<span class='alien'>You must be conscious to do this.</span>")
		return FALSE
	else if(X && getPlasma() < X)
		to_chat(src, "<span class='alien'>Not enough plasma stored.</span>")
		return FALSE
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space)))
		to_chat(src, "<span class='alien'>Bad place for a garden!</span>")
		return FALSE
	else
		return TRUE

/spell/aoe_turf/conjure/alienweeds
	name = "Plant Weeds"
	desc = "Plants some alien weeds"
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_weeds"
	override_base = "alien"

	charge_type = Sp_HOLDVAR|Sp_RECHARGE
	holder_var_type = "plasma"
	holder_var_amount = 50
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"
	spell_flags = IGNORESPACE|IGNOREDENSE|NODUPLICATE

	summon_type = list(/obj/effect/alien/weeds/node)
	override_base = "alien"

/*
/mob/living/carbon/alien/humanoid/verb/ActivateHuggers()
	set name = "Activate facehuggers (5)"
	set desc = "Makes all nearby facehuggers activate"
	set category = "Alien"

	if(powerc(5))
		AdjustPlasma(-5)
		for(var/obj/item/clothing/mask/facehugger/F in range(8,user))
			F.GoActive()
		emote("roar")
	return
*/

/spell/targeted/alienwhisper
	name = "Whisper"
	desc = "Whisper to someone"
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_whisper"
	override_base = "alien"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 10
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	range = 7
	spell_flags = WAIT_FOR_CLICK
	var/storedmessage

/spell/targeted/alienwhisper/channel_spell(mob/user = usr, skipcharge = FALSE, force_remove = FALSE)
	if(!..()) //We only make it to this point if we succeeded in channeling or are removing channeling
		return FALSE
	if(user.spell_channeling && !force_remove)
		storedmessage = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(!storedmessage) //They refused to supply a spell channeling
			channel_spell(force_remove = 1)
			return FALSE
	else
		storedmessage = null
	return TRUE

/spell/targeted/alienwhisper/is_valid_target(var/target)
	if(!(spell_flags & INCLUDEUSER) && target == usr)
		return FALSE
	if(get_dist(usr, target) > range) //Shouldn't be necessary but a good check in case of overrides
		return FALSE
	return istype(target, /mob)

/spell/targeted/alienwhisper/cast(var/list/targets, mob/user)
	var/mob/M = targets[1]
	if(!storedmessage) //Compatibility if someone reverts this to SELECTABLE from WAIT_FOR_CLICK
		storedmessage = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(!storedmessage)
			return TRUE
	if(storedmessage)
		var/turf/T = get_turf(user)
		log_say("[key_name(user)] (@[T.x],[T.y],[T.z]) Alien Whisper: [storedmessage]")
		to_chat(M, "<span class='alien'>You hear a strange, alien voice in your head... <em>[storedmessage]</span></em>")
		to_chat(user, "<span class='alien'>You said: [storedmessage] to [M]</span>")

/spell/targeted/alientransferplasma
	name = "Transfer Plasma"
	desc = "Transfer your plasma to another alien"
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_transfer"
	override_base = "alien"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	range = 2
	compatible_mobs = list(/mob/living/carbon/alien)

//Does it take charge before casting? How to transfer to new alien
/spell/targeted/alientransferplasma/cast(var/list/targets, mob/user)
	var/mob/living/carbon/alien/M = targets[1]
	var/amount = input(user, "Amount:", "Transfer Plasma to [M]") as num
	if(amount)
		amount = abs(round(amount))
		holder_var_amount = amount
		if(check_charge(user = user) && get_dist(user, M) <= range) //Since input is a blocking operation
			take_charge(user = user)
			to_chat(M, "<span class='alien'>\The [user] has transfered [amount] plasma to you.</span>")
			to_chat(user, "<span class='alien'>You have trasferred [amount] plasma to [M]</span>")
		else
			to_chat(user, "<span class='alien'>You need to be closer.</span>")
	holder_var_amount = 0

/spell/targeted/projectile/alienneurotoxin
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_neurotoxin"
	override_base = "alien"

	charge_type = Sp_HOLDVAR|Sp_RECHARGE
	holder_var_type = "plasma"
	holder_var_amount = 50
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"
	still_recharging_msg = "<span class='alien'>You must regenerate your neurotoxin stores first.</span>"
	charge_max = 50

	spell_flags = WAIT_FOR_CLICK
	proj_type = /obj/item/projectile/energy/neurotoxin
	cast_sound = 'sound/weapons/pierce.ogg'
	duration = 20
	projectile_speed = 1

/spell/targeted/projectile/alienneurotoxin/is_valid_target(var/target, mob/user)
	if(!(spell_flags & INCLUDEUSER) && target == user)
		return FALSE
	if(get_dist(usr, target) > range)
		return FALSE
	if(isalien(target))
		to_chat(user, "<span class='alien'>Your allies are not valid targets.</span>")
		return FALSE
	return !istype(target,/area)

/spell/targeted/projectile/alienneurotoxin/cast(list/targets, mob/user)
	var/atom/target = targets[1]
	var/turf/U = get_turf(target)
	var/visible_message_target
	if(!istype(target,/mob))
		var/list/nearby_mobs = list()
		for(var/mob/living/M in hearers(1, U))
			if(isalien(M))
				continue
			nearby_mobs += M
		if(nearby_mobs.len)
			visible_message_target = pick(nearby_mobs)
	else
		visible_message_target = target

	if(visible_message_target)
		user.visible_message("<span class='alien'>\The [user] spits neurotoxin at [visible_message_target] !</span>", "<span class='alien'>You spit neurotoxin at [visible_message_target] !</span>")
	else
		user.visible_message("<span class='alien'>\The [user] spits a salvo of neurotoxin !</span>", "<span class='alien'>You spit out neurotoxin !</span>")

	. = ..()

/spell/aoe_turf/conjure/choice/alienresin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_resin"
	override_base = "alien"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 75
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	spell_flags = IGNORESPACE|IGNOREDENSE|NODUPLICATE
	full_list = list("Resin Door" = /obj/machinery/door/mineral/resin,"Resin Wall" = /obj/effect/alien/resin/wall,"Resin Membrane" = /obj/effect/alien/resin/membrane,"Resin Nest" = /obj/structure/bed/nest)

/spell/alienacid
	name = "Corrosive Acid"
	desc = "Drench an object in acid, destroying it over time."
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_acid"
	override_base = "alien"

	spell_flags = WAIT_FOR_CLICK
	charge_type = Sp_HOLDVAR|Sp_RECHARGE
	charge_max = 8 SECONDS
	holder_var_type = "plasma"
	holder_var_amount = 200
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	range = 1

/spell/alienacid/is_valid_target(var/atom/target, mob/user)
	return is_valid_target_to_acid(target,user,range)

/proc/is_valid_target_to_acid(var/atom/target, mob/user,var/range=1)
	if(get_dist(user, target) > range)
		to_chat(user, "<span class='alien'>Target is too far away!</span>")
		return FALSE
	if(target.isacidhardened())
		if(!do_after(user,target,3 SECONDS))
			to_chat(user, "<span class='alien'>You have to stay next to the object to acid it!</span>")
			return FALSE
		return TRUE
	if(!ismob(target) && target.acidable())
		return TRUE
	to_chat(user, "<span class='alien'>You cannot dissolve this object.</span>")
	return FALSE

/spell/alienacid/cast(list/targets, mob/user)
	acidify(targets[1], user)

/mob/living/carbon/alien/humanoid/proc/corrosive_acid(atom/O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = null

	if(ismob(O)) //This sort of thing may be possible by manually calling the verb, not sure
		return

	if(powerc(200))
		if(is_valid_target_to_acid(O, usr))
			acidify(O, usr)
			AdjustPlasma(-200)

/proc/acidify(atom/O, mob/user)
	new /obj/effect/alien/acid(get_turf(O), O)
	user.visible_message("<span class='alien'>\The [user] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")

/spell/aoe_turf/alienregurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach."
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_regurgitate"
	override_base = "alien"

/spell/aoe_turf/alienregurgitate/cast_check(skipcharge = FALSE, mob/user)
	if(!istype(user, /mob/living/carbon/alien/humanoid)) //why do they have this shit anyway
		return FALSE
	return ..()

/spell/aoe_turf/alienregurgitate/cast(list/targets, mob/user)
	var/mob/living/carbon/alien/humanoid/alien = user
	alien.drop_stomach_contents()
	user.visible_message("<span class='alien'>\The [user] hurls out the contents of their stomach!</span>")

///////////////////////////
// QUEEN SPECIFIC SPELLS //
///////////////////////////
/spell/aoe_turf/conjure/alienegg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_egg"
	override_base = "alien"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 75
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	spell_flags = IGNORESPACE|NODUPLICATE

	summon_type = list(/obj/effect/alien/egg)

/spell/aoe_turf/conjure/alienegg/cast(list/targets, mob/user)
	. = ..()
	// TODO on hypothetical xeno role addition
	//if(!.) //Returning 1 if we failed to cast
		//stat_collection.xeno_eggs_laid++

///////////////////////////////////
////////// DRONE BROS /////////////
///////////////////////////////////


/spell/aoe_turf/evolve
	name = "Evolve"
	panel = "Alien"
	user_type = USER_TYPE_XENOMORPH
	hud_state = "alien_evolve"
	override_base = "alien"

	charge_type = Sp_HOLDVAR
	insufficient_holder_msg = "<span class='alien'>You are not ready for this kind of evolution.</span>"

	cast_sound = 'sound/effects/evolve.ogg'
	cast_delay = 50
	use_progress_bar = TRUE

/spell/aoe_turf/evolve/drone
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time."

	holder_var_type = "plasma"
	holder_var_amount = 500

/spell/aoe_turf/evolve/drone/cast_check(skipcharge = FALSE, mob/living/carbon/alien/user)
	if(user.handcuffed || user.locked_to)
		to_chat(user, "<span class='danger'>You cannot evolve while you're restrained!</span>")
		return FALSE
	var/mob/living/carbon/alien/humanoid/queen/Q = locate(/mob/living/carbon/alien/humanoid/queen) in living_mob_list
	if(Q && Q.key)
		to_chat(user, "<span class='notice'>We already have a living queen.</span>")
		return FALSE
	return ..()

/spell/aoe_turf/evolve/drone/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	user.visible_message("<span class='danger'>[user] begins to violently twist and contort!</span>", "<span class='bold alien'>You begin to evolve, stand still for a few moments.</span>")
	return ..()

/spell/aoe_turf/evolve/drone/cast(list/targets, mob/living/carbon/alien/humanoid/user)
	..()
	var/mob/living/carbon/alien/humanoid/queen/new_xeno = new(get_turf(user))
	for(var/datum/language/L in user.languages)
		new_xeno.add_language(L.name)
	user.drop_all()
	user.mind.transfer_to(new_xeno)
	user.transferImplantsTo(new_xeno)
	user.transferBorers(new_xeno)
	qdel(user)

////////////////////////////
//// FOR THE LARVA BROS ////
////////////////////////////

/spell/aoe_turf/evolve/larva
	desc = "Evolve into a fully grown Alien."
	user_type = USER_TYPE_XENOMORPH
	insufficient_holder_msg = "<span class='alien'>You are not fully grown yet.</span>"

	holder_var_type = "growth"
	holder_var_amount = LARVA_GROW_TIME

	var/spawning

/spell/aoe_turf/evolve/larva/cast_check(skipcharge = FALSE, mob/living/carbon/alien/user)
	if(user.handcuffed || user.locked_to)
		to_chat(user, "<span class='danger'>You cannot evolve while you're restrained!</span>")
		return FALSE
	return ..()

/spell/aoe_turf/evolve/larva/spell_do_after(mob/living/carbon/alien/user)
	var/explanation_message = {"<span class='notice'><B>You are growing into a beautiful alien! It is time to choose a caste.</B><br>
	There are three castes to choose from:<br>
	<B>Hunters</B> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.<br>
	<B>Sentinels</B> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.<br>
	<B>Drones</B> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."}
	to_chat(user, explanation_message)
	spawning = input(user, "Please choose which alien caste you shall evolve to.", "Evolving Choice Menu", null) as null|anything in list("Hunter","Sentinel","Drone","Repeat Explanation")
	while(spawning == "Repeat Explanation")
		to_chat(user, explanation_message)
		spawning = input(user, "Please choose which alien caste you shall evolve to.", "Evolving Choice Menu", null) as null|anything in list("Hunter","Sentinel","Drone","Repeat Explanation")
	if(spawning == null)
		return FALSE
	switch(spawning)
		if("Hunter")
			spawning = /mob/living/carbon/alien/humanoid/hunter
		if("Sentinel")
			spawning = /mob/living/carbon/alien/humanoid/sentinel
		if("Drone")
			spawning = /mob/living/carbon/alien/humanoid/drone
	return ..()

/spell/aoe_turf/evolve/larva/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/humanoid/new_xeno = new spawning(get_turf(user))
	for(var/datum/language/L in user.languages)
		new_xeno.add_language(L.name)
	if(user.mind)
		user.mind.transfer_to(new_xeno)
	user.transferImplantsTo(new_xeno)
	user.transferBorers(new_xeno)
	qdel(user)

/spell/aoe_turf/alien_hide
	name = "Hide"
	desc = "Allows you to hide beneath tables or items laid on the ground. Toggle."
	user_type = USER_TYPE_XENOMORPH
	panel = "Alien"
	hud_state = "alien_hide"
	override_base = "alien"

	charge_max = 0

/spell/aoe_turf/alien_hide/cast(list/targets, mob/user)
	if(user.plane != HIDING_MOB_PLANE)
		user.plane = HIDING_MOB_PLANE
		user.visible_message("<span class='danger'>\The [user.name] scurries to the ground !</span>", "<span class='alien'>You are now hiding.</span>")
	else
		user.plane = MOB_PLANE
		user.visible_message("<span class='warning'>\The [user.name] slowly peeks up from the ground...</span>", "<span class='alien'>You have stopped hiding.</span>")

/////////////////////////////////////////////

/*
/mob/living/carbon/alien/humanoid/AltClickOn(var/atom/A)
	if(ismob(A))
		neurotoxin(A)
		return
	. = ..()

/mob/living/carbon/alien/humanoid/CtrlClickOn(var/atom/A)
	if(isalien(A))
		transfer_plasma(A)
		return
	. = ..()
*/
