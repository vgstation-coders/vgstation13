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

/obj/item/rig_module/speed_boost
	name = "Rig speed module"
	desc = "Self-lubricating joints allow for ease of movement when walking in a rigsuit."

/obj/item/rig_module/speed_boost/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	if(R.cell.use(500))
		to_chat(user, "<span class = 'binaryradio'>Speed module engaged.</span>")
		R.slowdown = max(1, slowdown/1.25)

/obj/item/rig_module/speed_boost/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	R.slowdown = initial(R.slowdown)

/obj/item/rig_module/health_readout
	name = "articulated spine"
	desc = "Lets passers by read your health from a distance"

/obj/item/rig_module/health_readout/examine_addition(mob/user)
	if(wearer)
		to_chat(user, "<span class = 'notice'>The embedded health readout reads: [(wearer.health/wearer.maxHealth)*100]%</span>")

/obj/item/rig_module/tank_refiller
	name = "tank pressurizer"
	desc = "When in atmosphere, syphons from the air to refill the tank connected to your internals."
	var/gas_id

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
		to_chat(user, "<span class = 'binaryradio'>Internals pressurizer online. Syphoning [gas_id] from environment to [H.internal]</span>")
	else
		to_chat(user, "<span class = 'binaryradio'>Internals pressurizer failed to find internals. Aborting.</span>")

/obj/item/rig_module/tank_refiller/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	..()
	if(processing_objects.Find(src))
		processing_objects.Remove(src)

/obj/item/rig_module/tank_refiller/process()
	if(!wearer || !ishuman(wearer))
		processing_objects.Remove(src)

	var/mob/living/carbon/human/H = wearer
	if(!H.internal)
		to_chat(H, "<span class = 'binaryradio'>Internals pressurizer failed to find internals. Aborting.</span>")
		processing_objects.Remove(src)
	else
		var/datum/gas_mixture/M = H.loc.return_air()
		if(M[gas_id] && rig.cell.use(50))
			var/datum/gas_mixture/internals = H.internal.air_contents

			var/pressure_delta = 10*ONE_ATMOSPHERE - internals.pressure
			var/transfer_moles = pressure_delta * internals.volume / (M.temperature * R_IDEAL_GAS_EQUATION)
			if(transfer_moles > 0)
				var/datum/gas_mixture/removed = M.remove(transfer_moles)
				if(!removed)
					return
				var/datum/gas_mixture/to_add = new
				to_add.temperature = removed.temperature
				to_add.adjust_gas(gas_id, removed[gas_id])
				removed.adjust_gas(gas_id, -(removed[gas_id]))
				internals.merge(to_add)
				M.merge(removed)