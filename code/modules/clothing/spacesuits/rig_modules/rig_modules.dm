/obj/item/rig_module
	name = "Rig module"
	desc = "A module to be installed onto a rigsuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"

/obj/item/rig_module/proc/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)

/obj/item/rig_module/proc/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)

/obj/item/rig_module/speed_boost
	name = "Rig speed module"
	desc = "Self-lubricating joints allow for ease of movement when walking in a rigsuit."

/obj/item/rig_module/speed_boost/activate(var/mob/user,var/obj/item/clothing/suit/space/rig/R)
	if(R.cell.use(500))
		to_chat(user, "<span class = 'binaryradio'>Speed module engaged.</span>")
		R.slowdown /= 2

/obj/item/rig_module/speed_boost/deactivate(var/mob/user, var/obj/item/clothing/suit/space/rig/R)
	R.slowdown = initial(R.slowdown)