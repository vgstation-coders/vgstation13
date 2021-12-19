/obj/item/spooker
	name = "spooker"
	icon = 'icons/spooker.dmi'
	icon_state = "spooker_unused"
	var/

/obj/item/spooker/preattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
