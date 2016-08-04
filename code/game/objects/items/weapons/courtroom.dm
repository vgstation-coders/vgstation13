// Contains:
// Gavel Hammer
// Gavel Block

/obj/item/weapon/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelhammer"
	force = 5
	throwforce = 6
	w_class = W_CLASS_MEDIUM
	attack_verb = list("bashed", "battered", "judged", "whacked")
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 2
	var/canstage = 1
	var/stage = 0

/obj/item/weapon/gavelhammer/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] has sentenced \himself to death with \the [src]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/weapon/gavelblock
	name = "gavel block"
	desc = "Smack it with a gavel hammer when the assistants get rowdy."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelblock"
	force = 2
	throwforce = 2
	w_class = W_CLASS_MEDIUM
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 2
	var/cooldown = 0

/obj/item/weapon/gavelblock/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/gavelhammer))
		if(cooldown < world.time - 8)
			playsound(loc, 'sound/items/gavel.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] strikes \the [src] with \the [I].</span>")
			cooldown = world.time
		return 1
	return ..()

/obj/item/weapon/gavelhammer/attackby(obj/item/W,mob/user)
	..()
	if(!canstage)
		to_chat(user, "<span class = 'warning'>\The [W] won't fit on \the [src].</span>")
		return
	if(istype(W,/obj/item/weapon/chisel) && !stage)
		stage = 1
		to_chat(user,"<span class='notice'>You add \the [W] to \the [src].</span>")
		qdel(W)
		icon_state = "gavelhammer_1"
	if(istype(W,/obj/item/stack/cable_coil) && stage == 1)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount <= 4)
			return
		C.use(5)
		to_chat(user,"<span class='notice'>You finish crafting the sigil.</span>")
		var/obj/craftingsigil = new /obj/item/clothing/back/craftingsigil
		qdel(src)
		user.put_in_hands(craftingsigil)