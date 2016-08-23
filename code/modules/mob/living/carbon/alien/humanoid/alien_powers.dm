/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/

/mob/living/carbon/alien/proc/powerc(X, Y)//Y is optional, checks for weed planting. X can be null.
	if(stat)
		to_chat(src, "<span class='alien'>You must be conscious to do this.</span>")
		return 0
	else if(X && getPlasma() < X)
		to_chat(src, "<span class='alien'>Not enough plasma stored.</span>")
		return 0
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space)))
		to_chat(src, "<span class='alien'>Bad place for a garden!</span>")
		return 0
	else
		return 1

/spell/aoe_turf/conjure/alienweeds
	name = "Plant Weeds"
	desc = "Plants some alien weeds"
	panel = "Alien"
	hud_state = "alien_weeds"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 50
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"
	spell_flags = IGNORESPACE|IGNOREDENSE|NODUPLICATE

	summon_type = list(/obj/effect/alien/weeds/node)

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
	panel = "Alien"
	hud_state = "alien_whisper"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 10
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	range = 7
	spell_flags = WAIT_FOR_CLICK
	var/storedmessage

/spell/targeted/alienwhisper/channel_spell(mob/user = usr, skipcharge = 0, force_remove = 0)
	if(!..()) //We only make it to this point if we succeeded in channeling or are removing channeling
		return 0
	if(user.spell_channeling && !force_remove)
		storedmessage = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(!storedmessage) //They refused to supply a spell channeling
			channel_spell(force_remove = 1)
			return 0
	else
		storedmessage = null
	return 1

/spell/targeted/alienwhisper/is_valid_target(var/target)
	if(!(spell_flags & INCLUDEUSER) && target == usr)
		return 0
	if(get_dist(usr, target) > range) //Shouldn't be necessary but a good check in case of overrides
		return 0
	return istype(target, /mob)

/spell/targeted/alienwhisper/cast(var/list/targets, mob/user)
	var/mob/M = targets[1]
	if(!storedmessage) //Compatibility if someone reverts this to SELECTABLE from WAIT_FOR_CLICK
		storedmessage = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(!storedmessage)
			return 1
	if(storedmessage)
		var/turf/T = get_turf(user)
		log_say("[key_name(user)] (@[T.x],[T.y],[T.z]) Alien Whisper: [storedmessage]")
		to_chat(M, "<span class='alien'>You hear a strange, alien voice in your head... <em>[storedmessage]</span></em>")
		to_chat(user, "<span class='alien'>You said: [storedmessage] to [M]</span>")

/spell/targeted/alientransferplasma
	name = "Transfer Plasma"
	desc = "Transfer your plasma to another alien"
	panel = "Alien"
	hud_state = "alien_transfer"

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

/spell/targeted/alienneurotoxin
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	panel = "Alien"
	hud_state = "alien_neurotoxin"

	charge_type = Sp_HOLDVAR|Sp_RECHARGE
	holder_var_type = "plasma"
	holder_var_amount = 50
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"
	still_recharging_msg = "<span class='alien'>You must regenerate your neurotoxin stores first.</span>"
	charge_max = 50

	range = 7
	spell_flags = WAIT_FOR_CLICK

/spell/targeted/alienneurotoxin/is_valid_target(var/target, mob/user)
	if(!(spell_flags & INCLUDEUSER) && target == usr)
		return 0
	if(get_dist(usr, target) > range)
		return 0
	if(isalien(target))
		to_chat(user, "<span class='alien'>Your allies are not valid targets.</span>")
		return 0
	return istype(target, /mob/living)

/spell/targeted/alienneurotoxin/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	playsound(get_turf(user), 'sound/weapons/pierce.ogg', 30, 1)
	user.visible_message("<span class='alien'>\The [user] spits neurotoxin at [target] !</span>", "<span class='alien'>You spit neurotoxin at [target] !</span>")

	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)

	if(!U || !T)
		return
	if(U == T)
		usr.bullet_act(new /obj/item/projectile/energy/neurotoxin(usr.loc)/*, get_organ_target()*/)
		return

	var/obj/item/projectile/energy/neurotoxin/A = new /obj/item/projectile/energy/neurotoxin(usr.loc)
	A.original = target
	A.target = U
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn()
		A.OnFired()
		A.process()

/spell/aoe_turf/conjure/choice/alienresin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	panel = "Alien"
	hud_state = "alien_resin"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 75
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	spell_flags = IGNORESPACE|IGNOREDENSE|NODUPLICATE
	full_list = list("Resin Door" = /obj/machinery/door/mineral/resin,"Resin Wall" = /obj/effect/alien/resin/wall,"Resin Membrane" = /obj/effect/alien/resin/membrane,"Resin Nest" = /obj/structure/bed/nest)

/spell/alienacid
	name = "Corrosive Acid"
	desc = "Drench an object in acid, destroying it over time."
	panel = "Alien"
	hud_state = "alien_acid"

	spell_flags = WAIT_FOR_CLICK
	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 200
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	range = 1

/spell/alienacid/is_valid_target(var/atom/target, mob/user)
	if(get_dist(user, target) > range) //Shouldn't be necessary but a good check in case of overrides
		return 0
	if(!ismob(target) && target.acidable())
		return 1
	to_chat(user, "<span class='alien'>You cannot dissolve this object.</span>")
	return 0

/spell/alienacid/cast(list/targets, mob/user)
	acidify(targets[1], user)

/mob/living/carbon/alien/humanoid/proc/corrosive_acid(atom/O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = null

	if(ismob(O)) //This sort of thing may be possible by manually calling the verb, not sure
		return

	if(powerc(200))
		if(O in oview(1))
			acidify(O, usr)
		else
			to_chat(usr, "<span class='alien'>Target is too far away.</span>")

/proc/acidify(atom/O, mob/user)
	if(O.acidable())
		new /obj/effect/alien/acid(get_turf(O), O)
		user.visible_message("<span class='alien'>\The [usr] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
	else
		to_chat(user, "<span class='alien'>You cannot dissolve this object.</span>")

/spell/aoe_turf/alienregurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach."
	panel = "Alien"
	hud_state = "alien_regurgitate"

/spell/aoe_turf/alienregurgitate/cast_check(skipcharge = 0, mob/user)
	if(!istype(user, /mob/living/carbon/alien/humanoid)) //why do they have this shit anyway
		return 0
	return ..()

/spell/aoe_turf/alienregurgitate/cast(list/targets, mob/user)
	var/mob/living/carbon/alien/humanoid/alien = user
	alien.drop_stomach_contents()
	user.visible_message("<span class='alien'>\The [usr] hurls out the contents of their stomach!</span>")

///////////////////////////
// QUEEN SPECIFIC SPELLS //
///////////////////////////
/spell/aoe_turf/conjure/alienegg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	panel = "Alien"
	hud_state = "alien_egg"

	charge_type = Sp_HOLDVAR
	holder_var_type = "plasma"
	holder_var_amount = 75
	insufficient_holder_msg = "<span class='alien'>Not enough plasma stored.</span>"

	spell_flags = IGNORESPACE|NODUPLICATE

	summon_type = list(/obj/effect/alien/egg)

/spell/aoe_turf/conjure/alienegg/before_cast(list/targets)
	if(locate(/obj/effect/alien/egg) in targets[1])
		to_chat(src, "<span class='warning'>There's already an egg here.</span>")
		return list() //no targets
	return ..()

/spell/aoe_turf/conjure/alienegg/cast(list/targets, mob/user)
	..()
	stat_collection.xeno.eggs_laid++

///////////////////////////////////
////////// DRONE BROS /////////////
///////////////////////////////////


/spell/aoe_turf/evolve
	name = "Evolve"
	panel = "Alien"
	hud_state = "alien_evolve"

	charge_type = Sp_HOLDVAR
	insufficient_holder_msg = "<span class='alien'>You are not ready for this kind of evolution.</span>"

	cast_sound = 'sound/effects/evolve.ogg'
	cast_delay = 50

/spell/aoe_turf/evolve/drone
	desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."

	holder_var_type = "plasma"
	holder_var_amount = 500

/spell/aoe_turf/evolve/drone/cast_check(skipcharge = 0, mob/user)
	var/mob/living/carbon/alien/humanoid/queen/Q = locate(/mob/living/carbon/alien/humanoid/queen) in living_mob_list
	if(Q && Q.key)
		to_chat(user, "<span class='notice'>We already have an alive queen.</span>")
		return 0
	return ..()

/spell/aoe_turf/evolve/drone/cast(list/targets, mob/living/carbon/user)
	..()
	user.visible_message("<span class='alien'>[src] begins to violently twist and contort!</span>", "<span class='alien'>You begin to evolve, stand still for a few moments</span>")
	var/mob/living/carbon/alien/humanoid/queen/new_xeno = new(get_turf(user))
	for(var/datum/language/L in user.languages)
		new_xeno.add_language(L.name)
	user.mind.transfer_to(new_xeno)
	user.transferImplantsTo(new_xeno)
	user.transferBorers(new_xeno)
	qdel(user)

////////////////////////////
//// FOR THE LARVA BROS ////
////////////////////////////

/spell/aoe_turf/evolve/larva
	desc = "Evolve into a fully grown Alien."
	insufficient_holder_msg = "<span class='alien'>You are not fully grown yet.</span>"

	holder_var_type = "growth"
	holder_var_amount = LARVA_GROW_TIME

	var/spawning

/spell/aoe_turf/evolve/larva/before_target(mob/user)
	var/explanation_message = {"<span class='notice'><B>You are growing into a beautiful alien! It is time to choose a caste.</B><br>
	There are three castes to choose from:<br>
	<B>Hunters</B> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.<br>
	<B>Sentinels</B> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.<br>
	<B>Drones</B> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."}
	to_chat(user,explanation_message)
	spawning = input(user, "Please choose which alien caste you shall evolve to.", "Evolving Choice Menu", null) in list("Hunter","Sentinel","Drone","Repeat Explanation")|null
	while(spawning == "Repeat Explanation")
		spawning = input(user, "Please choose which alien caste you shall evolve to.", "Evolving Choice Menu", null) in list("Hunter","Sentinel","Drone","Repeat Explanation")|null
	if(spawning == null)
		return 0
	switch(spawning)
		if("Hunter")
			spawning = /mob/living/carbon/alien/humanoid/hunter
		if("Sentinel")
			spawning = /mob/living/carbon/alien/humanoid/sentinel
		if("Drone")
			spawning = /mob/living/carbon/alien/humanoid/drone
	return 1

/spell/aoe_turf/evolve/larva/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/humanoid/new_xeno = new spawning
	for(var/datum/language/L in user.languages)
		new_xeno.add_language(L.name)
	if(user.mind)
		user.mind.transfer_to(new_xeno)
	user.transferImplantsTo(new_xeno)
	user.transferBorers(new_xeno)
	qdel(user)

/spell/alien_hide
	name = "Hide"
	desc = "Allows you to hide beneath tables or items laid on the ground. Toggle."
	panel = "Alien"
	hud_state = "alien_hide"

	charge_max = 0

/spell/alien_hide/cast(list/targets, mob/user)
	if(user.plane != HIDING_MOB_PLANE)
		user.plane = HIDING_MOB_PLANE
		user.visible_message("<span class='danger'>[src] scurries to the ground !</span>", "<span class='alien'>You are now hiding.</span>")
	else
		user.plane = MOB_PLANE
		user.visible_message("<span class='warning'>[src] slowly peeks up from the ground...</span>", "<span class='alien'>You have stopped hiding.</span>")

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