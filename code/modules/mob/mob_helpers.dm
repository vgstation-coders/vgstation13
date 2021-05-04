/mob/proc/isUnconscious() //Returns 1 if unconscious, dead or faking death
	return stat == UNCONSCIOUS || isDead()

/mob/proc/isDead() //Returns 1 if dead or faking death
	return stat == DEAD || (status_flags & FAKEDEATH)

/mob/proc/isStunned() //Because we have around four slighly different stunned variables for some reason.
	return isUnconscious() || paralysis > 0 || stunned > 0 || knockdown > 0

/mob/proc/incapacitated()
	return isStunned() || restrained()

/mob/proc/get_screen_colour()
	if(!client)
		return 0
	if(M_NOIR in mutations)
		return NOIRMATRIX

/mob/proc/can_wield()
	return 0

/mob/proc/is_fat()
	return 0

mob/proc/isincrit()
	return 0

mob/proc/get_heart()
	return null

/mob/proc/get_lungs()
	return null

/mob/proc/get_liver()
	return null

/mob/proc/get_kidneys()
	return null

/mob/proc/get_appendix()
	return null

mob/proc/remove_internal_organ()
	return null

/mob/proc/get_broken_organs()
	return list()

/mob/proc/get_bleeding_organs()
	return list()

//Helper proc for do_after. Checks if the user is holding 'held_item' in his active arm. Return 0 to stop the do_after
/mob/proc/do_after_hand_check(held_item)
	return (get_active_hand() == held_item)

/mob/dead/observer/get_screen_colour()
	return default_colour_matrix

/mob/living/simple_animal/get_screen_colour()
	. = ..()
	if(.)
		return .
	else if(src.colourmatrix.len)
		return src.colourmatrix

/mob/living/carbon/human/get_screen_colour()
	. = ..()
	if(.)
		return .
	var/obj/item/clothing/glasses/scanner/S = is_wearing_item(/obj/item/clothing/glasses/scanner, slot_glasses)
	if(S && S.on && S.color_matrix)
		return S.color_matrix
	var/datum/organ/internal/eyes/eyes = internal_organs_by_name["eyes"]
	if(eyes && eyes.colourmatrix.len && !(eyes.robotic))
		return eyes.colourmatrix
	else
		return default_colour_matrix

/mob/proc/update_colour(var/time = 50, var/list/colour_to_apply)
	if(!client)
		return
	if(!colour_to_apply)
		colour_to_apply = get_screen_colour()
	if((M_NOIR in mutations) && client)
		client.screen += noir_master
	// We can't compare client.color directly because Byond will force set client.color to null
	// when assigning the default_colour_matrix to it
	var/list/colour_initial = (client.color ? client.color : default_colour_matrix)
	if(colour_initial ~! colour_to_apply)
		client.colour_transition(colour_to_apply,time = time)
/*
/proc/RemoveAllFactionIcons(var/datum/mind/M)
	ticker.mode.update_cult_icons_removed(M)
	ticker.mode.update_rev_icons_removed(M)
	ticker.mode.update_wizard_icons_removed(M)

/proc/ClearRoles(var/datum/mind/M)
	ticker.mode.remove_revolutionary(M)
*/
/proc/isAdminGhost(A)
	if(isobserver(A))
		var/mob/dead/observer/O = A
		if(O.check_rights(R_ADMIN|R_FUN))
			return 1
	return 0

/proc/canGhostRead(var/mob/A, var/obj/target, var/flags=PERMIT_ALL)
	if(isAdminGhost(A))
		return 1
	if(flags & PERMIT_ALL)
		return 1
	return 0

/proc/canGhostWrite(var/mob/A, var/obj/target, var/desc="fucked with", var/flags=0)
	if(flags & PERMIT_ALL)
		if(!target.blessed)
			return 1
	if(isAdminGhost(A))
		if(desc!="")
			add_ghostlogs(A, target, desc, 1)
		return 1
	return 0

/proc/isloyal(A) //Checks to see if the person contains a loyalty implant, then checks that the implant is actually inside of them
	for(var/obj/item/weapon/implant/loyalty/L in A)
		if(L && L.implanted)
			return 1
	return 0

/proc/check_holy(var/mob/A) //checks to see if the tile the mob stands on is holy
	var/turf/T = get_turf(A)
	if(!T)
		return 0
	if(!T.holy)
		return 0
	return 1  //The tile is holy. Beware!

proc/hasorgans(A)
	return ishuman(A)


/proc/check_zone(zone)
	if(!zone)
		return LIMB_CHEST
	switch(zone)
		if("eyes")
			zone = LIMB_HEAD
		if("mouth")
			zone = LIMB_HEAD
/*		if(LIMB_LEFT_HAND)
			zone = LIMB_LEFT_ARM
		if(LIMB_RIGHT_HAND)
			zone = LIMB_RIGHT_ARM
		if(LIMB_LEFT_FOOT)
			zone = LIMB_LEFT_LEG
		if(LIMB_RIGHT_FOOT)
			zone = LIMB_RIGHT_LEG
		if(LIMB_GROIN)
			zone = LIMB_CHEST
*/
	return zone


/proc/ran_zone(zone, probability)
	zone = check_zone(zone)
	if(!probability)
		probability = 90
	if(probability == 100)
		return zone

	if(zone == LIMB_CHEST)
		if(prob(probability))
			return LIMB_CHEST
		var/t = rand(1, 9)
		switch(t)
			if(1 to 3)
				return LIMB_HEAD
			if(4 to 6)
				return LIMB_LEFT_ARM
			if(7 to 9)
				return LIMB_RIGHT_ARM

	if(prob(probability * 0.75))
		return zone
	return LIMB_CHEST

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, var/mob/target, var/miss_chance_mod = 0)
	zone = check_zone(zone)

	// you can only miss if your target is standing and not restrained
	if(!target.locked_to && !target.lying)
		var/miss_chance = 10
		switch(zone)
			if(LIMB_HEAD)
				miss_chance = 40
			if(LIMB_LEFT_LEG)
				miss_chance = 20
			if(LIMB_RIGHT_LEG)
				miss_chance = 20
			if(LIMB_LEFT_ARM)
				miss_chance = 20
			if(LIMB_RIGHT_ARM)
				miss_chance = 20
			if(LIMB_LEFT_HAND)
				miss_chance = 50
			if(LIMB_RIGHT_HAND)
				miss_chance = 50
			if(LIMB_LEFT_FOOT)
				miss_chance = 50
			if(LIMB_RIGHT_FOOT)
				miss_chance = 50
		miss_chance = max(miss_chance + miss_chance_mod, 0)
		if(prob(miss_chance))
			if(prob(70))
				return null
			else
				var/t = rand(1, 10)
				switch(t)
					if(1)
						return LIMB_HEAD
					if(2)
						return LIMB_LEFT_ARM
					if(3)
						return LIMB_RIGHT_ARM
					if(4)
						return LIMB_CHEST
					if(5)
						return LIMB_LEFT_FOOT
					if(6)
						return LIMB_RIGHT_FOOT
					if(7)
						return LIMB_LEFT_HAND
					if(8)
						return LIMB_RIGHT_HAND
					if(9)
						return LIMB_LEFT_LEG
					if(10)
						return LIMB_RIGHT_LEG

	return zone

// adds stars to a text to obfuscate it
// var/n -> text to obfuscate
// var/pr -> percent of the text to obfuscate
// return -> obfuscated text
/proc/stars(n, pr)
	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

proc/slur(phrase)
	var/leng=length(phrase)
	var/counter=length(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,3)==3)
			if(lowertext(newletter)=="o")
				newletter="u"
			if(lowertext(newletter)=="s")
				newletter="ch"
			if(lowertext(newletter)=="a")
				newletter="ah"
			if(lowertext(newletter)=="c")
				newletter="k"
		switch(rand(1,15))
			if(1,3,5,8)
				newletter="[lowertext(newletter)]"
			if(2,4,6,15)
				newletter="[uppertext(newletter)]"
			if(7)
				newletter+="'"
			//if(9,10)	newletter="<b>[newletter]</b>"
			//if(11,12)	newletter="<big>[newletter]</big>"
			//if(13)	newletter="<small>[newletter]</small>"
		newphrase+="[newletter]";counter-=1
	return newphrase

/proc/stutter(n)
	var/te = n
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if (prob(80) && (ckey(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))
			if (prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if (prob(20))
					n_letter = text("[n_letter]-[n_letter]-[n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return copytext(t,1,MAX_MESSAGE_LEN)


proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext

/proc/derpspeech(message, stuttering)
	message = replacetext(message, " am ", " ")
	message = replacetext(message, " is ", " ")
	message = replacetext(message, " are ", " ")
	message = replacetext(message, "you", "u")
	message = replacetext(message, "help", "halp")
	message = replacetext(message, "grief", "griff")
	message = replacetext(message, "space", "spess")
	message = replacetext(message, "carp", "crap")
	message = replacetext(message, "reason", "raisin")
	if(prob(50))
		message = uppertext(message)
		message += "[stutter(pick("!", "!!", "!!!"))]"
	if(!stuttering && prob(15))
		message = stutter(message)
	return message

/proc/shake_camera(mob/M, duration=0, strength=1)
	spawn(1)
		if(!M || !M.client || M.shakecamera)
			return
		var/client/C = M.client
		M.shakecamera = 1

		for (var/x = 1 to duration)
			if(!C)
				M.shakecamera = 0
				return //somebody disconnected while being shaken
			C.pixel_x = WORLD_ICON_SIZE*rand(-strength, strength)
			C.pixel_y = WORLD_ICON_SIZE*rand(-strength, strength)
			sleep(1)

		M.shakecamera = 0
		C.pixel_x = 0
		C.pixel_y = 0

/proc/directional_recoil(mob/M, strength=1, angle = 0)
	if(!M || !M.client)
		return
	var/client/C = M.client
	var/recoil_x = -sin(angle)*4*strength + rand(-strength, strength)
	var/recoil_y = -cos(angle)*4*strength + rand(-strength, strength)
	animate(C, pixel_x=recoil_x, pixel_y=recoil_y, time=1, easing=SINE_EASING|EASE_OUT, flags=ANIMATION_PARALLEL|ANIMATION_RELATIVE)
	sleep(2)
	animate(C, pixel_x=0, pixel_y=0, time=3, easing=SINE_EASING|EASE_IN)


/proc/findname(msg)
	if(!istext(msg))
		msg = "[msg]"
	for(var/mob/M in mob_list)
		if(M.real_name == msg)
			return M
	return 0


/mob/proc/abiotic(var/full_body = 0)
	for(var/obj/item/I in held_items)
		if(I.abstract)
			continue

		return 1

	if(full_body)
		for(var/obj/item/I in get_equipped_items())
			if(I.abstract)
				continue

			return 1

	return 0

//converts intent-strings into numbers and back, refactored by kanef down from switch blocks
/proc/intent_numeric(argument)
	var/list/intents = list(I_HELP,I_DISARM,I_GRAB,I_HURT)
	if(istext(argument))
		for (var/i in intents)
			if i == argument
				return intents.indexOf(argument)
		return 3
	else
		return intents[argument <= 3 && argument >= 0 ? argument : 3]

var/list/zones = list(list(LIMB_LEFT_ARM,LIMB_LEFT_HAND,LIMB_LEFT_LEG,LIMB_LEFT_FOOT),list(LIMB_RIGHT_ARM,LIMB_RIGHT_HAND,LIMB_RIGHT_LEG,LIMB_RIGHT_FOOT),list(TARGET_EYES,LIMB_HEAD,TARGET_MOUTH,LIMB_CHEST,LIMB_GROIN))
/proc/zone_numeric(x,y)
	if(istext(x) && istext(y))
		return
	else if(isnum(x) && isnum(y))
		switch(x)
			if(2)
				return zones[2][y <= 4 && y >= 0 ? y : 4]
			if(1)
				return zones[x <= 1 && x >=0 ? x : 1][y <= 3 && y >= 0 ? y : 3]

//change a mob's act-intent. Input the intent as a string such as I_HELP or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(ishuman(src) || isalienadult(src) || isbrain(src))
		switch(input)
			if(I_HELP,I_DISARM,I_GRAB,I_HURT)
				a_intent = input
			if("right")
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if("left")
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "intent_[a_intent]"

	else if(isrobot(src) || ismonkey(src) || islarva(src))
		switch(input)
			if(I_HELP)
				a_intent = I_HELP
			if(I_HURT)
				a_intent = I_HURT
			if("right","left")
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)
		if(hud_used && hud_used.action_intent)
			if(a_intent == I_HURT)
				hud_used.action_intent.icon_state = "harm"
			else
				hud_used.action_intent.icon_state = "help"

//change a mob's zone_sel. Input the target as a string such as LIMB_HEAD (mouth and eyes do not follow this)
/mob/verb/a_zone_change(input as text)
	set name = "a-zone"
	set hidden = 1
	
	if(zone_sel && zone_sel.selecting)
		var/old_selecting = zone_sel.selecting
		switch(input)
			if (LIMB_RIGHT_FOOT,LIMB_LEFT_FOOT,LIMB_RIGHT_HAND,LIMB_LEFT_HAND,LIMB_RIGHT_ARM,LIMB_LEFT_ARM,LIMB_RIGHT_LEG,LIMB_LEFT_LEG,LIMB_GROIN,LIMB_CHEST,LIMB_HEAD,TARGET_MOUTH,TARGET_EYES)
     			zone_sel.selecting = input
			if ("up")
			if ("down")
			if ("left")
			if ("right")
		if(old_selecting != zone_sel.selecting)
			zone_sel.update_icon()

//For hotkeys

/mob/verb/a_kick()
	set name = "a-kick"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.set_attack_type(ATTACK_KICK)

/mob/verb/a_bite()
	set name = "a-bite"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.set_attack_type(ATTACK_BITE)

proc/is_blind(A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.blinded != null)
			return 1
	return 0

/proc/get_multitool(mob/user as mob)
	// Get tool
	var/obj/item/device/multitool/P
	if(isrobot(user) || ishuman(user))
		P = user.get_active_hand()
	else if(isAI(user))
		var/mob/living/silicon/ai/AI=user
		P = AI.aiMulti
	else if(isAdminGhost(user))
		var/mob/dead/observer/G=user
		P = G.ghostMulti

	if(!istype(P))
		return null
	return P

/proc/broadcast_security_hud_message(var/message, var/broadcast_source)
	broadcast_hud_message(message, broadcast_source, sec_hud_users, /obj/item/clothing/glasses/hud/security)

/proc/broadcast_medical_hud_message(var/message, var/broadcast_source)
	broadcast_hud_message(message, broadcast_source, med_hud_users, /obj/item/clothing/glasses/hud/health)

/proc/broadcast_hud_message(var/message, var/broadcast_source, var/list/targets, var/obj/ic)
	var/biconthing = initial(ic.icon)
	var/biconthingstate = initial(ic.icon_state)
	var/icon/I = new(biconthing, biconthingstate)
	var/turf/sourceturf = get_turf(broadcast_source)
	for(var/mob/M in targets)
		var/turf/targetturf = get_turf(M)
		if((targetturf.z == sourceturf.z))
			M.show_message("<span class='info'>[bicon(I)] [message]</span>", 1)

/mob/proc/get_survive_objective()
	return new /datum/objective/survive

/**
* Honor check
* Returns TRUE if user is BOMBERMAN, HIGHLANDER, NINJA...
* Respects honorable.
*/
/proc/is_honorable(var/mob/living/user, var/honorable = HONORABLE_ALL)
	if(istype(user))
		if(user.mind)
			if(isbomberman(user) && (honorable & HONORABLE_BOMBERMAN))
				return TRUE
			if(ishighlander(user) && (honorable & HONORABLE_HIGHLANDER))
				return TRUE
			if(iscarbon(user) && isninja(user) && (honorable & HONORABLE_NINJA))
				return TRUE
			if((iswizard(user) || isapprentice(user) || ismagician(user)) && (user.flags & HONORABLE_NOGUNALLOWED))
				return TRUE
	return FALSE

// Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic()
// Returns whether the mob can see the specified HUD
/mob/proc/hasHUD(var/hud_kind)
	return FALSE

// Returns a string that provides identification data for this mob
/mob/proc/identification_string()
	return name

/mob/proc/can_be_infected()
	return 0

/mob/proc/remove_confused(var/amt)
	confused = max(0, confused - amt)
	if (confused <= 0)
		confused_intensity = 0
