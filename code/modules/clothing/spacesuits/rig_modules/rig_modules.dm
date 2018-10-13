/obj/item/rig_module
	name = "Rig module"
	desc = "A module to be installed onto a rigsuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	var/mob/living/wearer

/obj/item/rig_module/proc/examine_addition(mob/user)

/obj/item/rig_module/proc/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	wearer = user

/obj/item/rig_module/proc/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	wearer = null

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