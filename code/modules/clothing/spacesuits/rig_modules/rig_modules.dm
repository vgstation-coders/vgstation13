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
		R.slowdown /= 2

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
		to_chat(user, "<span class = 'binaryradio'>Internals pressurizer online.</span>")
		var/datum/organ/internal/lungs/L = H.internal_organs_by_name["lungs"]
		if(L)
			var/datum/lung_gas/metabolizable/M = locate() in L.gasses
			gas_id = M.id
		processing_objects.Add(src)
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
		var/turf/T = get_turf(H)
		if(isspace(T))
			return
		var/datum/gas_mixture/M = T.return_air()
		if(M.gas[gas_id] && M.gas[gas_id] >= 1 && rig.cell.use(50))
			var/datum/gas_mixture/internal = H.internal.return_air()
			var/datum/gas_mixture/sample = M.remove(25)
			var/amount_to_transfer = sample.gas[gas_id]
			if(amount_to_transfer)
				sample.adjust_gas(gas_id, -amount_to_transfer)
				internal.adjust_gas(gas_id, amount_to_transfer)
			M.merge(sample)