//**************************************************************
// Defibrillator
//**************************************************************

/obj/item/weapon/melee/defibrillator
	name = "emergency defibrillator"
	desc = "Used to restore fibrillating patients."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "defib_full"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "defib"
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_ELECTRONIC
	flammable = TRUE
	force = 5
	throwforce = 5
	origin_tech = Tc_BIOTECH + "=3"

	var/charges = 10
	var/ready = 0
	var/defib_delay = 30

	var/defib_tool = "paddles"
	var/defib_message_fail_override = null
	var/defib_message_success_override = null

	var/ignores_clothes = FALSE

/obj/item/weapon/melee/defibrillator/New()
	return ..()

/obj/item/weapon/melee/defibrillator/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='warning'>[user] is putting the live [defib_tool] on \his chest! It looks like \he's trying to commit suicide.</span>")
	playsound(src,'sound/items/defib.ogg',50,1)
	return (SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/melee/defibrillator/update_icon()
	icon_state = "defib"
	if(ready)
		icon_state += "paddleout"
	else
		icon_state += "paddlein"
	switch(charges/initial(charges))
		if(0.7 to INFINITY) //Just in case the defib somehow gets more charges than initial
			icon_state += "_full"
		if(0.4 to 0.6)
			icon_state += "_half"
		if(0.01 to 0.3) //Make sure it's really empty dawg
			icon_state += "_low"
		else
			icon_state += "_empty"
	return

/obj/item/weapon/melee/defibrillator/attack_self(mob/user)
	if(charges || ready)
		if(clumsy_check(user) && prob(50) && charges)
			to_chat(user, "<span class='warning'>You touch the [defib_tool] together, shorting the device.</span>")
			spark(src, 5)
			playsound(src,'sound/items/defib.ogg',50,1)
			user.Knockdown(5)
			user.Stun(5)
			var/mob/living/carbon/human/H = user
			if(ishuman(user))
				H.apply_damage(20, BURN)
			charges--
			update_icon()
		else
			ready = !ready
			to_chat(user, "<span class='notice'>You turn [src] [ready? "on and take the [defib_tool] out" : "off and put the [defib_tool] back in"].</span>")
			playsound(src,"sparks",75,1,-1)
			update_icon()
	else
		to_chat(user, "<span class='warning'>[src] is out of charges.</span>")
	add_fingerprint(user)
	return

/obj/item/weapon/melee/defibrillator/update_wield(mob/user)
	..()
	item_state = "fireaxe[wielded ? 1 : 0]"
	force = wielded ? 40 : 10
	if(user)
		user.update_inv_hands()

/obj/item/weapon/melee/defibrillator/emag_act(mob/user)
	emagged = !emagged
	if(emagged)
		to_chat(user, "<span class='warning'>You short out [src]'s safety protocols.</span>")
		overlays += image(icon = icon, icon_state = "defib_emag")
	else
		to_chat(user, "<span class='notice'>You reset [src]'s safety protocols.</span>")
		overlays.len = 0

/obj/item/weapon/melee/defibrillator/attack(mob/M,mob/user)
	if(!ishuman(M))
		to_chat(user, "<span class='warning'>You can't defibrillate [M]. You don't even know where to put the [defib_tool]!</span>")
	else if(!charges)
		to_chat(user, "<span class='warning'>[src] is out of charges.</span>")
	else if(!ready)
		to_chat(user, "<span class='warning'>Take the [defib_tool] out first.</span>")
	else
		var/mob/living/carbon/human/target = M
		if(!(target.stat == 2 || target.stat == DEAD))
			if(emagged)
				shockAttack(target,user)
			else
				to_chat(user, "<span class='warning'>[src] buzzes: Vital signs detected.</span>")
		else
			attemptDefib(target,user)
	return

/obj/item/weapon/melee/defibrillator/proc/shockAttack(mob/living/carbon/human/target,mob/user)
	var/damage = rand(30, 60)
	if (!target.electrocute_act(damage, src, def_zone = LIMB_CHEST))
		return
	var/datum/organ/internal/heart/heart = target.get_heart()
	if(heart)
		heart.damage += rand(5,60)
	target.audible_scream() //If we're going this route, it kinda hurts
	spawn() //Logging
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Shocked [target.name] ([target.ckey]) with an emagged [src.name]</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Shocked by [user.name] ([user.ckey]) with an emagged [src.name]</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) shocked [target.name] ([target.ckey]) with an emagged [src.name]</font>" )
		target.assaulted_by(user)
	playsound(src,'sound/items/defib.ogg',50,1)
	charges--
	update_icon()
	return

/obj/item/weapon/melee/defibrillator/proc/attemptDefib(mob/living/carbon/human/target,mob/user)
	user.visible_message("<span class='notice'>[user] starts setting up the [defib_tool] on [target]'s chest.</span>", \
	"<span class='notice'>You start setting up the [defib_tool] on [target]'s chest</span>")
	if(target.mind && !target.client && target.get_heart() && target.get_organ(LIMB_HEAD) && target.has_brain() && !target.mind.suiciding && target.health+target.getOxyLoss() > config.health_threshold_dead)
		target.ghost_reenter_alert("Someone is about to try to defibrillate your body. Return to it if you want to be resurrected!")
	if(do_after(user,target,defib_delay))
		. = TRUE
		spark(src, 5, FALSE)
		playsound(src,'sound/items/defib.ogg',50,1)
		charges--
		update_icon()
		to_chat(user, "<span class='notice'>You shock [target] with the [defib_tool].</span>")
		var/datum/organ/internal/heart/heart = target.get_heart()
		if(!heart)
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Subject requires a heart.</span>")
			target.apply_damage(rand(1,5),BURN,LIMB_CHEST)
			return
		var/datum/organ/external/head/head = target.get_organ(LIMB_HEAD)
		if(!head || head.status & ORGAN_DESTROYED)
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Severe cranial damage detected.</span>")
			return
		if((M_HUSK in target.mutations) && (M_NOCLONE in target.mutations))
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Irremediable genetic damage detected.</span>")
			return
		if(!target.has_brain())
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. No central nervous system detected.</span>")
			return
		if(!target.has_attached_brain())
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Central nervous system detachment detected.</span>")
			return
		if(target.mind && target.mind.suiciding)
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Unrecoverable nerve trauma detected.</span>") // They suicided so they fried their brain. Space Magic.
			return
		if(!ignores_clothes)
			if(istype(target.wear_suit,/obj/item/clothing/suit/armor) && (target.wear_suit.body_parts_covered & UPPER_TORSO) && prob(95)) //75 ? Let's stay realistic here
				defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>")
				target.apply_damage(rand(1,5),BURN,LIMB_CHEST)
				return
			if(istype(target.w_uniform,/obj/item/clothing/under) && (target.w_uniform.body_parts_covered & UPPER_TORSO) && prob(50))
				defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>")
				target.apply_damage(rand(1,5),BURN,LIMB_CHEST)
				return
		if(target.mind && !target.client) //Let's call up the ghost! Also, bodies with clients only, thank you.
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. [target.ghost_reenter_alert("Someone has tried to defibrillate your body. Return to it if you want to be resurrected!") ? "Vital signs are too weak, please try again in five seconds" : "No brainwaves detected"].</span>")
			return
		target.apply_damage(-target.getOxyLoss(),OXY)
		target.updatehealth()
		target.visible_message("<span class='danger'>[target]'s body convulses a bit.</span>")
		if(target.health > config.health_threshold_dead)
			target.timeofdeath = 0
			defib_message_success(target, "<span class='notice'>[src] beeps: Defibrillation successful.</span>")

			target.resurrect()

			target.tod = null
			target.stat = target.status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
			target.regenerate_icons()
			target.update_canmove()
			target.flash_eyes(visual = 1)
			target.apply_effect(10, EYE_BLUR) //I'll still put this back in to avoid dumb "pounce back up" behavior
			target.apply_effect(10, PARALYZE)
			target.update_canmove()
			has_been_shade.Remove(target.mind)
			to_chat(target, "<span class='notice'>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane.</span>")
		else
			defib_message_fail(target, "<span class='warning'>[src] buzzes: Defibrillation failed. Patient's condition does not allow reviving.</span>")
		return
	// Cancelled the timer early? Required by improvised defib to know if it has to lower its charge.
	return FALSE


/obj/item/weapon/melee/defibrillator/proc/defib_message_fail(mob/living/carbon/human/target, var/message)
	if (defib_message_fail_override)
		message = defib_message_fail_override
	target.visible_message(message)

/obj/item/weapon/melee/defibrillator/proc/defib_message_success(mob/living/carbon/human/target, var/message)
	if (defib_message_success_override)
		message = defib_message_success_override
	target.visible_message(message)

/obj/item/weapon/melee/defibrillator/restock()
	charges = initial(charges)

//**************************************************************
// Improvised Defibrillator (Ghetto Defibrillator)
//**************************************************************

/obj/item/weapon/melee/defibrillator/improvised
	name = "improvised defibrillator"
	desc = "Used to restore fibrillating patients. Or kill them."

	icon = 'icons/obj/weapons.dmi'
	icon_state = "defib_impro"
	item_state = "defib_impro"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')

	defib_tool = "pie tins"
	defib_message_success_override = "<span class='notice'>You can feel a steady heartbeat.</span>"
	defib_message_fail_override = "<span class='notice'>Nothing seems to happen.</span>"

	var/obj/item/weapon/cell/power_supply = null
	var/charge_cost = 2500
	var/defibrillating = FALSE	// Flag used by the defib-spam check. Let's not shock a corpse for hundreds of burn damage.

	defib_delay = 90

/obj/item/weapon/melee/defibrillator/improvised/New()
	verbs -= /obj/item/weapon/melee/defibrillator/improvised/verb/remove_cell

/obj/item/weapon/melee/defibrillator/improvised/examine(var/mob/user)
	. = ..()
	if (power_supply && power_supply.maxcharge != 0)
		to_chat(user, "<span class='info'>The cell's power meter reads [(power_supply.charge / power_supply.maxcharge) * 100]%.</span>")

/obj/item/weapon/melee/defibrillator/improvised/update_icon()
	icon_state = "defib_impro"
	if (power_supply)
		verbs += /obj/item/weapon/melee/defibrillator/improvised/verb/remove_cell
		icon_state += "_ready"
	else
		verbs -= /obj/item/weapon/melee/defibrillator/improvised/verb/remove_cell


/obj/item/weapon/melee/defibrillator/improvised/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/weapon/cell))
		if (power_supply)
			to_chat(user, "<span class='notice'>There is already a cell wired into the assembly.</span>")
			return

		user.drop_item(I)
		I.forceMove(src)
		power_supply = I
		to_chat(user, "<span class='notice'>You wrap the exposed wires around the cell.</span>")
		src.update_icon()

	if (I.is_screwdriver(user))
		if (!power_supply)
			return

		to_chat(user, "<span class='notice'>You carefully remove the cell.</span>")

		power_supply.forceMove(src.loc)
		user.put_in_hands(power_supply)
		src.power_supply = null
		src.update_icon()

/obj/item/weapon/melee/defibrillator/improvised/verb/remove_cell()
	set name = "Remove cell"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/user = loc

	if (!power_supply)
		return

	to_chat(user, "<span class='warning'>You start pulling on the wires around the cell!</span>")

	if (do_after(user, src, 30))
		if (prob(50) && electrocute_mob(user, power_supply, src))
			to_chat(user, "<span class='warning'>You touch an exposed piece of wire!</span>")
			return

		to_chat(user, "<span class='notice'>You remove the cell.</span>")
		power_supply.forceMove(src.loc)
		user.put_in_hands(power_supply)
		src.power_supply = null
		src.update_icon()

/obj/item/weapon/melee/defibrillator/improvised/proc/lower_charge()
	if (!power_supply || power_supply.charge < charge_cost)
		return FALSE
	power_supply.charge -= charge_cost
	return TRUE

/obj/item/weapon/melee/defibrillator/improvised/proc/enough_charge()
	return power_supply && power_supply.charge >= charge_cost

/obj/item/weapon/melee/defibrillator/improvised/attack_self(mob/user)
	return remove_cell()

/obj/item/weapon/melee/defibrillator/improvised/attack(mob/M, mob/user)
	if (defibrillating)
		return
	if (!ishuman(M))
		to_chat(user, "<span class='warning'>You can't defibrillate [M]. You don't even know where to put the [defib_tool]!</span>")
		return
	else if (!power_supply)
		to_chat(user, "<span class='warning'>There's no cell in \the [src].</span>")
		return
	else if (!enough_charge())
		to_chat(user, "<span class='warning'>\The [src] fizzles weakly.</span>")
		return
	else
		spark(src, 5)
		defibrillating = TRUE
		if (attemptDefib(M, user))
			lower_charge()

			var/mob/living/carbon/human/H = user
			electrocute_mob(H, power_supply, src)

			var/mob/living/carbon/human/target = M
			if(ishuman(target))
				target.apply_damage(5, BURN)
		defibrillating = FALSE
	return
