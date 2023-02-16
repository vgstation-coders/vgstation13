#define UPGRADE_COOLDOWN	5
#define UPGRADE_KILL_TIMER	100

/obj/item/weapon/grab
	name = "grab"
	flags = NO_ATTACK_MSG
	var/obj/abstract/screen/grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0

	layer = HUD_ABOVE_ITEM_LAYER
	plane = HUD_PLANE
	abstract = 1
	item_state = "nothing"
	w_class = W_CLASS_HUGE

/obj/item/weapon/grab/attack_icon()
	if(affecting)
		return affecting
	..()

/obj/item/weapon/grab/New(atom/loc, mob/living/victim)
	..()
	assailant = loc
	affecting = victim

	if(!victim.can_be_grabbed(assailant))
		qdel(src)
		return
	if(affecting && affecting.anchored)
		qdel(src)
		return

	hud = new /obj/abstract/screen/grab
	hud.icon_state = "reinforce"
	hud.name = "reinforce grab"
	hud.master = src

/obj/item/weapon/grab/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	if(!(giver == assailant) || !giver.Adjacent(affecting) || !receiver.Adjacent(affecting))
		visible_message("<span class='warning'>[giver] tried to pass [affecting] to [receiver] but couldn't.</span>")
		return FALSE
	receiver.grab_mob(affecting)
	return FALSE

/obj/item/weapon/grab/preattack()
	if(!assailant || !affecting)
		return 1 //Cancel attack
	if(!assailant.Adjacent(affecting))
		return 1 //Cancel attack is assailant isn't near affected mob

	return ..()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/toss()
	if(affecting)
		if(affecting.locked_to || !loc.Adjacent(affecting))
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		hud.screen_loc = assailant.get_held_item_ui_location(assailant.is_holding_item(src))


/obj/item/weapon/grab/process()
	if(!confirm())
		return

	if(!assailant)
		affecting = null
		qdel(src)
		return

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1

		for(var/obj/item/weapon/grab/G in assailant.held_items)
			if(G == src)
				continue
			if(G.affecting != affecting)
				allow_upgrade = 0

		if(state == GRAB_AGGRESSIVE)
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if(G == src)
					continue
				if(G.state == GRAB_AGGRESSIVE)
					allow_upgrade = 0
		if(allow_upgrade)
			hud.icon_state = "reinforce"
		else
			hud.icon_state = "!reinforce"
	else
		if(!affecting.locked_to)
			affecting.forceMove(assailant.loc)

	if(state >= GRAB_NECK)
	//	affecting.Stun(5)	//It will hamper your voice, being choked and all.
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		affecting.Stun(5) //Should keep you down unless you get help.
		affecting.Knockdown(5)
		affecting.losebreath = min(affecting.losebreath + 1, 3) //builds up to 3 over a few seconds
		affecting.stuttering = max(affecting.stuttering, 6)
		if(isliving(affecting) && affecting.losebreath >= 3) //if you've been choked for a few seconds
			var/mob/living/L = affecting
			L.silent = max(L.silent, 2)

/obj/item/weapon/grab/attack_self()
	. = ..()
	if(.)
		return
	else if(hud)
		return s_click(hud)


/obj/item/weapon/grab/proc/s_click(obj/abstract/screen/S)
	if(!affecting || !assailant || gcDestroyed)
		return
	if(assailant.attack_delayer.blocked())
		return
	if(state == GRAB_UPGRADING)
		return
	/* This is handled in mob/proc/ClickOn
	if(assailant.next_move > world.time)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	*/
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time
	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>", \
			drugged_message = "<span class='warning'>[assailant] has hugged [affecting] passionately!</span>")
		state = GRAB_AGGRESSIVE
		assailant.delayNextMove(10)
		assailant.delayNextAttack(10)
		hud.icon_state = "!reinforce"
		spawn(10)
			if(!gcDestroyed)
				hud.icon_state = "reinforce"
		icon_state = "grabbed1"
	else
		if(state < GRAB_NECK)
			if(isslime(affecting))
				to_chat(assailant, "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>")
				return
			assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>", \
				drugged_message = "<span class='warning'>[assailant] has reinforced \his hug on [affecting]!</span>")
			state = GRAB_NECK
			icon_state = "grabbed+1"
			if(!affecting.locked_to)
				affecting.forceMove(assailant.loc)
			affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
			assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>"
			log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) grabbed the neck of [affecting.name] ([affecting.ckey])</font>")
			assailant.delayNextMove(10)
			assailant.delayNextAttack(10)
			hud.icon_state = "!reinforce"
			spawn(10)
				if(!gcDestroyed)
					hud.icon_state = "disarm/kill"
					hud.name = "disarm/kill"
		else
			if(state < GRAB_UPGRADING)
				assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>", \
					drugged_message = "<span class='danger'>[assailant] starts to tighten \his hug on [affecting]!</span>")
				hud.icon_state = "disarm/kill1"
				state = GRAB_UPGRADING
				if(do_after(assailant,affecting, UPGRADE_KILL_TIMER))
					if(state == GRAB_KILL)
						return
					if(!assailant || !affecting)
						qdel(src)
						return
					if(!assailant.canmove || assailant.lying)
						qdel(src)
						return
					state = GRAB_KILL
					assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>", \
						drugged_message = "<span class='danger'>[assailant] has tightened \his hug on [affecting]!</span>")
					affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
					assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>"
					log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>")

					assailant.delayNextMove(10)
					assailant.delayNextAttack(10)

					affecting.losebreath += 1
				else
					if(!assailant || !affecting)
						qdel(src)
						return
					assailant.visible_message("<span class='warning'>[assailant] was unable to tighten \his grip on [affecting]'s neck!</span>", \
						drugged_message = "<span class='warning'>[affecting] refused [assailant]'s hug!</span>")
					hud.icon_state = "disarm/kill"
					state = GRAB_NECK


//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		var/can_eat = FALSE
		// Anti-vore act of 2017
		var/just_gib = FALSE
		var/nutriadd = 0
		if(ishuman(user) && (M_FAT in user.mutations) && ismonkey(affecting))
			can_eat = TRUE
			just_gib = TRUE //by order of Chicken
			nutriadd = 100 //TODO: Adjust to fit what they'd get via the old handle_stomach proc
		else if(isalien(user) && iscarbon(affecting))
			can_eat = TRUE
		if(can_eat)
			var/mob/living/carbon/attacker = user
			if(locate(/mob) in attacker.stomach_contents)
				to_chat(attacker, "<span class='warning'>You already have something in your stomach.</span>")
				return
			user.visible_message("<span class='danger'>[user] is attempting to devour [affecting]!</span>", \
				drugged_message="<span class='danger'>[user] is attempting to kiss [affecting]! Ew!</span>")
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting))
					return
			else
				if(!do_mob(user, affecting, 100))
					return
			user.visible_message("<span class='danger'>[user] devours [affecting]!</span>", \
				drugged_message="<span class='danger'>[affecting] vanishes in disgust.</span>")
			if(just_gib)
				affecting.drop_all()
				affecting.gib()
				qdel(affecting)
				attacker.nutrition += nutriadd
			else
				affecting.forceMove(user)
				attacker.stomach_contents.Add(affecting)
			qdel(src)


/obj/item/weapon/grab/dropped()
	qdel(src)

/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	if(hud)
		QDEL_NULL(hud)
	..()

/mob/proc/grab_check(mob/victim)
	if(victim == src || victim.anchored || lying)
		return 1
	return 0
