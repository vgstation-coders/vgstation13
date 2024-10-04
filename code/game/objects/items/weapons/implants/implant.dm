/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	w_class = W_CLASS_TINY
	_color = "b"
	/// The mob this has been implanted into.
	var/mob/living/imp_in
	var/inserter_name
	/// The limb of the mob this has been implanted into.
	var/datum/organ/external/part
	var/allow_reagents = FALSE
	var/malfunction = NONE

// return FALSE if the implant fails. In this case the implant is NOT consumed.
// If you wish to consume the implant, delete it inside `implanted()` instead.
// return TRUE if the implant succeeds.
// Implement `implanted()` to make something happen once the implant is inserted.
/obj/item/weapon/implant/proc/insert(mob/living/target, target_limb, mob/implanter)
	SHOULD_CALL_PARENT(TRUE)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		to_chat(implanter, "<span class='warning>The implant seems broken. It won't work.</span>")
		return FALSE
	if(ishuman(target))
		var/datum/organ/external/organ = target.get_organ(target_limb)
		if(!organ || organ.gcDestroyed || !organ.is_existing())
			to_chat(implanter, "<span class='warning'>You can't implant that organ.</span>")
			return FALSE
		organ.implants += src
		part = organ
	forceMove(target)
	imp_in = target
	inserter_name = implanter.real_name
	implanted(implanter)
	return TRUE

// Call this to remove the implant. Do not do anything else in order to remove the implant.
// Implement `handle_removal` to make something happen once the implant is removed.
/obj/item/weapon/implant/proc/remove(mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	handle_removal(user)
	if(part)
		part.implants -= src
		part = null
	if(!gcDestroyed)
		forceMove(get_turf(imp_in))
	imp_in = null
	inserter_name = null
	return TRUE

/obj/item/weapon/implant/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/L = W
		if(!L.imp)
			if(!user.is_holding_item(src)) //Implant is not held
				forceMove(L)
				user.show_message("<span class='warning'>You load \the [src] into \the [L].</span>")
				L.imp = src
				L.update()
			else if(user.drop_item(src, get_turf(user))) //Implant is held, try to drop it first
				forceMove(L)
				user.show_message("<span class='warning'>You load \the [src] into \the [L].</span>")
				L.imp = src
				L.update()
			else //super-glued to user's hands
				user.show_message("<span class='warning'>\The [src] is stuck in your hand!</span>")

// Used by the implants that are activated by emotes.
/obj/item/weapon/implant/proc/trigger(emote, mob/source)
	return

// Usually this is the main purpose of the implant.
/obj/item/weapon/implant/proc/activate()

// What does the implant do when it's removed?
/obj/item/weapon/implant/proc/handle_removal(mob/remover)

// What does the implant do upon injection?
/obj/item/weapon/implant/proc/implanted(mob/implanter)

/obj/item/weapon/implant/proc/get_data()
	return "No information available"

/obj/item/weapon/implant/proc/islegal()
	return FALSE

/obj/item/weapon/implant/proc/meltdown()	//breaks it down, making implant unrecongizible
	to_chat(imp_in, "<span class='warning'>You feel something melting inside [part ? "your [part.display_name]" : "you"]!</span>")
	if (part)
		part.take_damage(burn = 15, used_weapon = "Electronics meltdown")
	else
		var/mob/living/M = imp_in
		M.apply_damage(15,BURN)
	name = "melted implant"
	desc = "Charred circuit in melted plastic case. Wonder what that used to be..."
	icon_state = "implant_melted"
	malfunction = IMPLANT_MALFUNCTION_PERMANENT

/obj/item/weapon/implant/proc/makeunusable(var/probability=50)
	if(prob(probability))
		visible_message("<span class='warning'>\The [src] fizzles and sparks!</span>")
		name = "melted " + initial(name)
		desc = "Charred circuit in melted plastic case."
		icon_state = "implant_melted"
		malfunction = IMPLANT_MALFUNCTION_PERMANENT

/obj/item/weapon/implant/Destroy()
	// Super-call before remove(), so that remove() can avoid moving the implant.
	..()
	if(imp_in)
		remove()

