/obj/item/device/cloaker
	name = "cloaking device"
	desc = "A device that refracts light around the user, making them blend in with their environment. The illusion is broken if observers get too close. "
	icon_state = "radio_jammer0"	//temp
	flags = FPRINT | TWOHANDABLE | SLOWDOWN_WHEN_CARRIED
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_SYNDICATE + "=4;" + Tc_MAGNETS + "=4"
	flammable = TRUE

	var/enabled = FALSE
	var/datum/component/proximity_monitor/advanced/cloaker/field = null

/obj/item/device/cloaker/update_wield(mob/user)
	..()
	wielded ? turn_on() : turn_off()
	to_chat(user, span_notice("You turn [src] [enabled ? "on":"off"]."))
	if(user)
		user.update_inv_hands()
		if(wielded)
			user.delayNextAttack(10)		// To prevent spam.


/obj/item/device/cloaker/proc/turn_on()
	enabled = TRUE
	setup_field()
	update_icon()

/obj/item/device/cloaker/proc/turn_off()
	QDEL_NULL(field)
	enabled = FALSE
	update_icon()

/obj/item/device/cloaker/update_icon()
	icon_state = "radio_jammer[enabled ? 1 : 0]"


/obj/item/device/cloaker/proc/setup_field()
	if(field)
		QDEL_NULL(field)
	field = add_component(/datum/component/proximity_monitor/advanced/cloaker, src, 1, FALSE)
	field.recalculate_field()



