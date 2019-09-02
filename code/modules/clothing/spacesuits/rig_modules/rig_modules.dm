/obj/item/rig_module
	name = "Rig module"
	desc = "A module to be installed onto a rigsuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	var/mob/living/wearer
	var/obj/item/clothing/suit/space/rig/rig

/obj/item/rig_module/proc/examine_addition(mob/user)

/obj/item/rig_module/proc/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	wearer = user
	rig = R

/obj/item/rig_module/proc/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	wearer = null
	rig = null

/obj/item/rig_module/proc/say_to_wearer(var/string)
	ASSERT(wearer)
	to_chat(wearer, "\The [src] reports: <span class = 'binaryradio'>[string]</span>")

/obj/item/rig_module/speed_boost
	name = "Rig speed module"
	desc = "Self-lubricating joints allow for ease of movement when walking in a rigsuit."

/obj/item/rig_module/speed_boost/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	..()
	if(R.cell.use(500))
		say_to_wearer("Speed module engaged.")
		R.slowdown = max(1, slowdown/1.25)

/obj/item/rig_module/speed_boost/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	..()
	R.slowdown = initial(R.slowdown)

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
		processing_objects.Add(src)
		say_to_wearer("Internals pressurizer online. Syphoning [gas_id] from environment to [H.internal].")
	else
		say_to_wearer("Internals pressurizer failed to find internals. Aborting.")

/obj/item/rig_module/tank_refiller/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	..()
	if(processing_objects.Find(src))
		processing_objects.Remove(src)

/obj/item/rig_module/tank_refiller/process()
	if(!wearer || !ishuman(wearer))
		processing_objects.Remove(src)

	var/mob/living/carbon/human/H = wearer
	if(!H.internal)
		say_to_wearer("Internals pressurizer failed to find internals. Aborting.")
		processing_objects.Remove(src)
	else
		var/obj/item/weapon/tank/T = H.internal
		var/datum/gas_mixture/internals = T.air_contents
		if(internals.pressure >= 10*ONE_ATMOSPHERE)
			return
		var/datum/gas_mixture/M = H.loc.return_air()
		var/datum/gas_mixture/sample = M.remove_volume(amount) //So we don't just succ the entire room up
		if(sample[gas_id] && rig.cell.use(50))
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
	if(R.cell.use(250))
		say_to_wearer("Plasma seal initialized.")
		R.clothing_flags |= PLASMAGUARD
		if(R.H)
			R.H.clothing_flags |= PLASMAGUARD

/obj/item/rig_module/plasma_proof/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	..()
	say_to_wearer("Plasma seal disengaged.")
	R.clothing_flags &= ~PLASMAGUARD
	if(R.H)
		R.H.clothing_flags &= ~PLASMAGUARD