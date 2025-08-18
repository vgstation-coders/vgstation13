/obj/item/mecha_parts/component
	name = "mecha component"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "component"
	w_class = W_CLASS_GIANT
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	var/component_type = null
	var/obj/mecha/chassis = null
	var/start_damaged = FALSE
	var/emp_resistance = 0	// Amount of emp 'levels' removed.
	var/list/optimal_type = null	// List, if it exists. Exosuits meant to use the component (Unique var changes / effects)
	var/integrity
	var/integrity_danger_mod = 0.5	// Multiplier for comparison to max_integrity before problems start.
	var/max_integrity = 100
	var/step_delay = 20 // Kilograms
	var/relative_size = 30	// Percent chance for the component to be hit.
	var/internal_damage_flag	// If set, the component will toggle the flag on or off if it is destroyed / severely damaged.
	var/can_repair = TRUE
	var/broken_icon
	var/weldbreak_resist = 1
	var/broken = FALSE
	var/always_repair = FALSE

/obj/item/mecha_parts/component/examine(mob/user)
	. = ..()
	var/show_integrity = round(integrity/max_integrity*100, 0.1)
	switch(show_integrity)
		if(85 to 100)
			to_chat(user, "It's fully intact.")
		if(65 to 85)
			to_chat(user, "It's slightly damaged.")
		if(45 to 65)
			to_chat(user, "<span class='notice'>It's badly damaged.</span>")
		if(25 to 45)
			to_chat(user, "<span class='warning'>It's heavily damaged.</span>")
		if(2 to 25)
			to_chat(user, "<span class='warning'><b>It's falling apart.</b></span>")
		if(0 to 1)
			to_chat(user, "<span class='warning'><b>It is completely destroyed.</b></span>")

/obj/item/mecha_parts/component/New()
	. = ..()
	integrity = max_integrity
	if(start_damaged)
		integrity = round(integrity * integrity_danger_mod)

/obj/item/mecha_parts/component/Destroy()
	detach()
	return ..()

/obj/item/mecha_parts/component/proc/TryBreakComponent() // Doesn't actually break the component. // Breaks the component
	if(get_efficiency() <= 0.1)
		if(!broken)
			broken = TRUE
			integrity = 0
			name = "broken " + initial(name)
			desc = "A completely broken mecha component. It appears as though it used to be a [name]."
			icon_state = "[broken_icon]"
			if(!always_repair)
				can_repair = FALSE
			visible_message("<span class='danger'>\The [initial(name)] blows apart!</span>")
			playsound(src, "shatter", 70, 1)
			if(istype(src, /obj/item/mecha_parts/component/hull))
				chassis.CheckEnclosed()
		else
			return

// Damage code.

/obj/item/mecha_parts/component/emp_act(var/severity = 4)
	if(severity + emp_resistance >= 4)
		return
	severity = clamp(severity + emp_resistance, 1, 4)
	take_damage((4 - severity) * round(integrity * 0.1, 0.1))
	TryBreakComponent()

/obj/item/mecha_parts/component/proc/adjust_integrity(var/amt = 0)
	integrity = clamp(integrity + amt, 0, max_integrity)
	return

/obj/item/mecha_parts/component/proc/damage_part(var/dam_amt = 0, var/type = BRUTE)
	if(dam_amt <= 0)
		return FALSE
	adjust_integrity(-1 * dam_amt)
	if(chassis && internal_damage_flag)
		if(get_efficiency() < 0.5)
			chassis.check_for_internal_damage(list(internal_damage_flag), TRUE)
	if(get_efficiency() <= 0.1 && chassis.health > 0)
		TryBreakComponent()
	return TRUE

/obj/item/mecha_parts/component/take_damage()
	if(chassis && chassis.health > 0)
		chassis.CheckEnclosed()
	TryBreakComponent()

/obj/item/mecha_parts/component/proc/get_efficiency()
	var/integ_limit = round(max_integrity * integrity_danger_mod)
	if(integrity < integ_limit)
		var/int_percent = round(integrity / integ_limit, 0.1)
		return int_percent

	return 1

// Attach/Detach code.

/obj/item/mecha_parts/component/proc/attach(var/obj/mecha/target, var/mob/living/user)
	if(target)
		if(!(component_type in target.internal_components))
			if(user)
				to_chat(user, "<span class='notice'>\The [target] doesn't seem to have anywhere to put \the [src].</span>")
			return FALSE
		if(target.internal_components[component_type])
			if(user)
				to_chat(user, "<span class='notice'>\The [target] already has a [component_type] installed!</span>")
			return FALSE
		chassis = target
		if(user)
			user.drop_from_inventory(src)
		forceMove(target)

		if(internal_damage_flag)
			if(integrity > (max_integrity * integrity_danger_mod))
				if(chassis.hasInternalDamage(internal_damage_flag))
					chassis.clearInternalDamage(internal_damage_flag)

			else
				chassis.check_for_internal_damage(list(internal_damage_flag))
		chassis.internal_components[component_type] = src

		if(user)
			chassis.visible_message("<span class='notice'>[user] installs \the [src] in \the [chassis].</span>")
		return TRUE
	return FALSE

/obj/item/mecha_parts/component/proc/detach()
	if(chassis)
		chassis.internal_components[component_type] = null

		if(internal_damage_flag && chassis.hasInternalDamage(internal_damage_flag))	// If the module has been removed, it's kind of unfair to keep it causing problems by being damaged. It's nonfunctional either way.
			chassis.clearInternalDamage(internal_damage_flag)

		forceMove(get_turf(chassis))
	chassis = null
	return TRUE

/*
/obj/item/mecha_parts/component/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/NP = W

		if(integrity < max_integrity)
			while(integrity < max_integrity && NP)
				if(do_after(user, 1 SECOND, src) && NP.use(1))
					adjust_integrity(10)

			return

	return ..()
*/
// Various procs to handle different calls by Exosuits. IE, movement actions, damage actions, etc.

/obj/item/mecha_parts/component/proc/get_step_delay()
	return step_delay

/obj/item/mecha_parts/component/proc/handle_move()
	return
