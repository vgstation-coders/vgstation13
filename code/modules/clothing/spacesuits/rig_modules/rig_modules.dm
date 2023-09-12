/obj/item/rig_module
	name = "Rig module"
	desc = "A module to be installed onto a rigsuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	var/obj/item/clothing/suit/space/rig/rig
	var/activated = FALSE
	var/active_power_usage = 0 //Energy consumption per tick

/obj/item/rig_module/Destroy()
	rig = null
	..()

/obj/item/rig_module/proc/can_install(var/obj/item/clothing/suit/space/rig/target)
   return !(locate(type) in target.modules) //by default only allow one module of a type

/obj/item/rig_module/proc/examine_addition(mob/user)
	return

/obj/item/rig_module/emp_act(severity)
	return FALSE

/obj/item/rig_module/proc/check_activate(var/requires_human=FALSE)
	if(!rig || activated)
		return FALSE
	if(requires_human && !ishuman(rig.wearer))
		return FALSE
	return TRUE

/obj/item/rig_module/proc/check_deactivate(var/requires_human=FALSE)
	if(!rig || !activated)
		return FALSE
	if(requires_human && !ishuman(rig.wearer))
		return FALSE
	return TRUE

/obj/item/rig_module/proc/activate()
	activated = TRUE

/obj/item/rig_module/proc/deactivate()
	activated = FALSE

/obj/item/rig_module/proc/do_process()
	return

/obj/item/rig_module/proc/say_to_wearer(var/string)
	if(!rig?.wearer)
		return
	to_chat(rig.wearer, "\The [src] reports: <span class = 'binaryradio'>[string]</span>")

//This gets called when the suit storage cleans a suit containing the module. Hardcode in the suit storage file begone.
/obj/item/rig_module/proc/suit_storage_act()
	return

//Speed boost module
/obj/item/rig_module/speed_boost
	name = "rig speed module"
	desc = "Self-lubricating joints allow for ease of movement when walking in a rigsuit."
	active_power_usage = 10

/obj/item/rig_module/speed_boost/activate()
	if(!check_activate())
		return
	say_to_wearer("Speed module engaged.")
	rig.slowdown = max(1, slowdown/1.25)
	..()

/obj/item/rig_module/speed_boost/deactivate()
	if(!check_deactivate())
		return
	rig.slowdown = initial(rig.slowdown)
	..()


//Health readout module
/obj/item/rig_module/health_readout
	name = "articulated spine"
	desc = "Lets passer-bys read your health from a distance."

/obj/item/rig_module/health_readout/examine_addition(mob/user)
	if(!ishuman(rig.wearer))
		return
	var/mob/living/carbon/human/H = rig.wearer
	to_chat(user, "<span class = 'notice'>The embedded health readout reads: [H.isDead()?"0%":"[(H.health/H.maxHealth)*100]%"]</span>")


//Tank-refiller module
/obj/item/rig_module/tank_refiller
	name = "tank pressurizer"
	desc = "When in atmosphere, syphons from the air to refill the tank connected to your internals."
	var/gas_id
	var/amount = 50
	active_power_usage = 50

/obj/item/rig_module/tank_refiller/activate()
	if(!check_activate(TRUE))
		return
	var/mob/living/carbon/human/H = rig.wearer
	if(H.internal)
		var/datum/organ/internal/lungs/L = H.internal_organs_by_name["lungs"]
		if(L)
			var/datum/lung_gas/metabolizable/M = locate() in L.gasses
			gas_id = M.id
		activated = TRUE
		say_to_wearer("Internals pressurizer online. Syphoning [gas_id] from environment to [H.internal].")
	else
		say_to_wearer("Internals pressurizer failed to find internals. Aborting.")
		deactivate()

/obj/item/rig_module/tank_refiller/do_process()
	if(!ishuman(rig.wearer))
		deactivate()
		return

	var/mob/living/carbon/human/H = rig.wearer
	if(!H.internal)
		say_to_wearer("Internals pressurizer failed to find internals. Aborting.")
		deactivate()
		return
	else
		var/obj/item/weapon/tank/T = H.internal
		var/datum/gas_mixture/internals = T.air_contents
		if(internals.pressure >= 10*ONE_ATMOSPHERE)
			return
		var/datum/gas_mixture/M = H.loc.return_air()
		var/datum/gas_mixture/sample = M.remove_volume(amount) //So we don't just succ the entire room up
		if(sample[gas_id])
			var/pressure_delta = 10*ONE_ATMOSPHERE - internals.pressure //How much pressure we have left to work with
			var/transfer_moles = (pressure_delta/R_IDEAL_GAS_EQUATION/internals.temperature)*internals.volume //How many moles can we transfer?
			transfer_moles = min(sample[gas_id],transfer_moles)
			if(transfer_moles > 0)
				var/datum/gas_mixture/to_add = new
				to_add.temperature = sample.temperature
				to_add.adjust_gas(gas_id, transfer_moles)
				sample.adjust_gas(gas_id, -transfer_moles)
				internals.merge(to_add)
				M.merge(sample)

		//NEED TO GET MAXIMUM AMOUNT OF MOLES WITHOUT GOING OVER 10*ONE_ATMOSPHERE
		//pressure = total_moles * R_IDEAL_GAS_EQUATION * temperature / volume
		//pressure_delta = target_moles * 8.314 * sample_temperature / internals.volume


//Plasmaproof module
/obj/item/rig_module/plasma_proof
	name = "plasma-proof sealing authority"
	desc = "Brings the suit it is installed into up to plasma environment standards."
	active_power_usage = 5

/obj/item/rig_module/plasma_proof/activate()
	if(!check_activate())
		return
	say_to_wearer("Plasma seal initialized.")
	rig.clothing_flags |= PLASMAGUARD
	if(rig.H)
		rig.H.clothing_flags |= PLASMAGUARD
	..()

/obj/item/rig_module/plasma_proof/deactivate()
	if(!check_deactivate())
		return
	say_to_wearer("Plasma seal disengaged.")
	rig.clothing_flags &= ~PLASMAGUARD
	if(rig.H)
		rig.H.clothing_flags &= ~PLASMAGUARD
	..()

/obj/item/rig_module/plasma_proof/can_install(var/obj/item/clothing/suit/space/rig/target)
   if(!..())
      return FALSE
   if(target.clothing_flags & PLASMAGUARD)
      return FALSE
   return TRUE

//Muscle tissue/Hulk module
/obj/item/rig_module/muscle_tissue
	name = "artificial muscle tissue"
	desc = "A flexible tissue with a number of sensors stretched between its surface and interior of the suit. When these sensors detected an impact, the artificial muscle reacts instantaneously, contracting and diffusing the damage."
	active_power_usage = 100

/obj/item/rig_module/muscle_tissue/activate()
	if(!check_activate(TRUE))
		return
	var/mob/living/carbon/human/H = rig.wearer
	H.mutations.Add(M_HULK) //I'M FUCKING INVINCIBLE!
	H.update_mutations()
	say_to_wearer("Reactive sensors online.")
	rig.canremove = FALSE
	say_to_wearer("Safety lock enabled.")
	..()

/obj/item/rig_module/muscle_tissue/deactivate()
	if(!check_deactivate(TRUE))
		return
	var/mob/living/carbon/human/H = rig.wearer
	H.mutations.Remove(M_HULK)
	H.update_mutations()
	say_to_wearer("Reactive sensors offline.")
	rig.canremove = TRUE
	say_to_wearer("Safety lock disabled.")
	..()


//EMP shield module
/obj/item/rig_module/emp_shield
	name = "\improper EMP dissipation module"
	desc = "A bewilderingly complex bundle of optic fibers and silicon photonic circuitry."
	active_power_usage = 1

/obj/item/rig_module/emp_shield/emp_act(severity)
	if(activated && rig?.cell?.use(round(300/severity, 50))) // 300/150/100 cell drain to shield the suit. It might sound bad but at least the suit is keeping itself activated.
		return TRUE
	return FALSE


//Rad shield module
/obj/item/rig_module/rad_shield
	name = "radiation absorption device"
	desc = "Its acronym, R.A.D., and full name both convey the application of this module. By using similar technology as radiation collectors it protects the suit wearer from incoming radiation until its collectors are full. It can be reset by using a suit storage unit's cleaning operation."
	active_power_usage = 1
	var/event_key
	var/initial_suit = 0
	var/initial_helmet = 0
	var/max_capacity = 500 //Just barely over 2 "item touch" worth of rads when standing right next to the shard with a suit with only 10 rad resist. About 5-6 items at 50. Based on in-game tests on Aug. 2020.
	var/current_capacity = 0
	//Warning thresholds, will announce to the user when these thresholds have been surpassed. The compiler shits itself if I put numbers in the variable names and calculations in the variable values, so it's done this way instead.
	var/first_threshold //50% capacity
	var/second_threshold //75% capacity
	var/third_threshold //90% capacity
	var/threshold_announced = 0 //Will record the last threshold surpassed to avoid spam messages. This resets when the RAD is recharged.

/obj/item/rig_module/rad_shield/New()
	..()
	first_threshold = max_capacity * 0.5
	second_threshold = max_capacity * 0.75
	third_threshold = max_capacity * 0.9

/obj/item/rig_module/rad_shield/examine_addition(mob/user)
	var/current_status = round((current_capacity/max_capacity) * 100)
	to_chat(user, "<span class = 'notice'>The embedded [name] capacity readout reads: <font color='[current_status <= 50 ? "green" : (current_status >= 85 ? "red" : "yellow")]'>[current_status]%</font>.</span>")

/obj/item/rig_module/rad_shield/check_activate(requires_human=FALSE)
	if(current_capacity >= max_capacity)
		return FALSE
	. = ..(requires_human)

/obj/item/rig_module/rad_shield/activate()
	if(!check_activate(TRUE))
		return

	if(rig.H)
		initial_helmet = rig.H.armor["rad"]
		rig.H.armor["rad"] = 100
	initial_suit = rig.armor["rad"]
	rig.armor["rad"] = 100

	say_to_wearer("[src] enabled.")
	rig.wearer.register_event(/event/irradiate, src, nameof(src::absorb_rads()))
	..()

/obj/item/rig_module/rad_shield/deactivate()
	if(!check_deactivate())
		return

	if(rig?.H)
		rig.H.armor["rad"] = initial_helmet
	rig?.armor["rad"] = initial_suit

	if(current_capacity >= max_capacity)
		say_to_wearer("[src] disabled. Please cleanse it by sterilizing the suit in a suit storage unit.")
	else
		say_to_wearer("[src] disabled.")
	rig.wearer?.unregister_event(/event/irradiate, src, nameof(src::absorb_rads()))
	..()

/obj/item/rig_module/rad_shield/suit_storage_act()
	current_capacity = initial(current_capacity)
	threshold_announced = initial(threshold_announced)

/obj/item/rig_module/rad_shield/proc/absorb_rads(mob/living/carbon/human/user, rads)
	if(rig?.wearer != user) //Well lad.
		user.unregister_event(/event/irradiate, src, nameof(src::absorb_rads()))
		return

	if(rig.H)
		current_capacity += min(max_capacity, (rads * ((100 - initial_helmet) / 100)))
	current_capacity += min(max_capacity, (rads * ((100 - initial_suit) / 100)))

	if(current_capacity >= third_threshold && threshold_announced < third_threshold)
		say_to_wearer("\The [src] is at 90% capacity. Take precaution.")
		threshold_announced = third_threshold
	if(current_capacity >= second_threshold && threshold_announced < second_threshold)
		say_to_wearer("\The [src] is at 75% capacity.")
		threshold_announced = second_threshold
	if(current_capacity >= first_threshold && threshold_announced < first_threshold)
		say_to_wearer("\The [src] is at 50% capacity.")
		threshold_announced = first_threshold

	if(current_capacity >= max_capacity)
		deactivate()

/obj/item/rig_module/rad_shield/adv
	name = "high capacity radiation absorption device"
	desc = "Its acronym, R.A.D., and full name both convey the application of this module. By using similar technology as radiation collectors, it protects the suit wearer from incoming radiation until its collectors are full. This model features a higher capacity than the basic version. It can be reset by using a suit storage unit's cleaning operation."
	max_capacity = 1600 //About 7-8 "item touches" worth based on the same conditions as the above testing.
