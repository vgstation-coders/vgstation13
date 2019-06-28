/* Disabled for now.
/obj/item/verbs/borer/attached_head/verb/bond_brain()
	set category = "Alien"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.bond_brain()

/obj/item/verbs/borer/attached_head/verb/kill_host()
	set category = "Alien"
	set name = "Kill Host"
	set desc = "Give the host massive brain damage, killing them nearly instantly."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.kill_host()

/obj/item/verbs/borer/attached_head/verb/damage_brain()
	set category = "Alien"
	set name = "Retard Host"
	set desc = "Give the host a bit of brain damage.  Can be healed with alkysine."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.damage_brain()
*/

/obj/item/verbs/borer/attached_head/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.evolve()

/obj/item/verbs/borer/attached_head/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_head/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.abandon_host()

/obj/item/verbs/borer/attached_head/verb/analyze_host()
	set category = "Alien"
	set name = "Analyze Health"
	set desc = "Check your host for damage."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.analyze_host()

/obj/item/verbs/borer/attached_head/night_vision/verb/night_vision()
	set category = "Alien"
	set name = "Night Vision"
	set desc = "Expend chemicals constantly in order to convert visual data from your host's eyes into the infrared spectrum."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.night_vision()

/mob/living/simple_animal/borer/proc/night_vision()
	set category = "Alien"
	set name = "Night Vision"
	set desc = "Expend chemicals constantly in order to convert visual data from your host's eyes into the infrared spectrum."

	if(!check_can_do(0))
		return

	if(channeling && !channeling_night_vision)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to convert the visual data from your host's eyes.")
		channeling = 0
		channeling_night_vision = 0
	else if(chemicals < 5)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		to_chat(src, "You begin to focus your efforts on converting the visual data from your host's eyes into the infrared spectrum.")
		channeling = 1
		channeling_night_vision = 1
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
		host.see_in_dark_override = 8
		host.see_invisible_override = SEE_INVISIBLE_OBSERVER_NOLIGHTING
		spawn()
			var/time_spent_channeling = 0
			while(chemicals >=5 && channeling && channeling_night_vision)
				chemicals -= 5
				time_spent_channeling++
				sleep(10)
			change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = initial(see_in_dark)
			see_invisible = initial(see_invisible)
			host.see_in_dark_override = 0
			host.see_invisible_override = 0
			channeling = 0
			channeling_night_vision = 0
			var/showmessage = 0
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)