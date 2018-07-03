/** Anvil
	Is treated as an item that can not be picked up, unless you are incredibly strong.

**/

/obj/item/anvil
	name = "anvil"
	desc = "For rounding and crafting objects. Combined with a hammer, you can likely craft some pleasant weapons with this"
	w_class = W_CLASS_GIANT
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "anvil"
	impactsound = 'sound/misc/clang.ogg'
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND
	density = 1
	throwforce = 40

/obj/item/anvil/can_pickup(mob/living/M)
	if(!..())
		return FALSE
	if(M.get_strength() > 2)
		return TRUE

/obj/item/anvil/can_be_pulled(mob/user)
	if(istype(user, /mob/living))
		var/mob/living/L = user
		if(L.get_strength() >= 2)
			return TRUE
	return FALSE

/obj/item/anvil/check_airflow_movable(n)
	if(n > 1000)
		return TRUE
	return FALSE