/obj/item/rig_module
	name = "Rig module"
	desc = "A module to be installed onto a rigsuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	var/mob/living/wearer
	var/obj/item/clothing/suit/space/rig/rig
	var/requires_component = TRUE //This module needs a removable component(helmet,gloves,boot,tank) and should be activated before they're deployed from the suit.
	var/activated = FALSE
	var/active_power_usage = 0 //Energy consumption per tick

/obj/item/rig_module/proc/examine_addition(mob/user)
	return

/obj/item/rig_module/proc/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)//We do not set activated to TRUE in the default activate() proc.
	wearer = user
	rig = R

/obj/item/rig_module/proc/deactivate()
	wearer = null
	rig = null
	activated = FALSE

/obj/item/rig_module/proc/do_process()
	return

/obj/item/rig_module/proc/say_to_wearer(var/string)
	ASSERT(wearer)
	to_chat(wearer, "\The [src] reports: <span class = 'binaryradio'>[string]</span>")

/obj/item/rig_module/speed_boost
	name = "rig speed module"
	desc = "Self-lubricating joints allow for ease of movement when walking in a rigsuit."
	active_power_usage = 10

/obj/item/rig_module/speed_boost/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	..()
	say_to_wearer("Speed module engaged.")
	rig.slowdown = max(1, slowdown/1.25)
	activated = TRUE

/obj/item/rig_module/speed_boost/deactivate()
	rig.slowdown = initial(rig.slowdown)
	..()

/obj/item/rig_module/health_readout
	name = "articulated spine"
	desc = "Lets passers by read your health from a distance"

/obj/item/rig_module/health_readout/examine_addition(mob/user)
	if(wearer)
		to_chat(user, "<span class = 'notice'>The embedded health readout reads: [wearer.isDead()?"0%":"[(wearer.health/wearer.maxHealth)*100]%"]</span>")

/obj/item/rig_module/tank_refiller
	name = "tank pressurizer"
	desc = "When in atmosphere, syphons from the air to refill the tank connected to your internals."
	var/gas_id
	var/amount = 50
	active_power_usage = 50

/obj/item/rig_module/tank_refiller/activate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
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
	if(!wearer || !ishuman(wearer))
		deactivate()
		return

	var/mob/living/carbon/human/H = wearer
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


/obj/item/rig_module/plasma_proof
	name = "plasma-proof sealing authority"
	desc = "Brings the suit it is installed into up to plasma environment standards."

/obj/item/rig_module/plasma_proof/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	..()
	if(rig.cell && rig.cell.use(250))
		say_to_wearer("Plasma seal initialized.")
		rig.clothing_flags |= PLASMAGUARD
		if(rig.H)
			rig.H.clothing_flags |= PLASMAGUARD
		activated = TRUE

/obj/item/rig_module/plasma_proof/deactivate()
	say_to_wearer("Plasma seal disengaged.")
	rig.clothing_flags &= ~PLASMAGUARD
	if(rig.H)
		rig.H.clothing_flags &= ~PLASMAGUARD
	..()

/obj/item/rig_module/muscle_tissue
	name = "artificial muscle tissue"
	desc = "A flexible tissue with a number of sensors stretched between its surface and interior of the suit. When these sensors detected an impact, the artificial muscle reacts instantaneously, contracting and diffusing the damage."
	active_power_usage = 100

/obj/item/rig_module/muscle_tissue/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	..()
	wearer.mutations.Add(M_HULK) //I'M FUCKING INVINCIBLE!
	wearer.update_mutations()
	say_to_wearer("Reactive sensors online.")
	rig.canremove = FALSE
	say_to_wearer("Safety lock enabled.")
	activated = TRUE
	

/obj/item/rig_module/muscle_tissue/deactivate()
	wearer.mutations.Remove(M_HULK)
	wearer.update_mutations()
	say_to_wearer("Reactive sensors offline.")
	rig.canremove = TRUE
	say_to_wearer("Safety lock disabled.")
	..()
