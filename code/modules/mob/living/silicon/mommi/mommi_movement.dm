// MoMMIs do spess construction, so shouldn't slip.
/mob/living/silicon/robot/mommi/Process_Spaceslipping(var/prob_slip=5)
	return 0

/mob/living/silicon/robot/mommi/Process_Spacemove()
	if(module)
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(J.allow_thrust(0.01))	return 1
	if(..())	return 1
	return 0