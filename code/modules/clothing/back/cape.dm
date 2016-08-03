/obj/item/clothing/back/magiccape
	name = "Magical Cape"
	desc = "A cape of distinction commonly worn by alchemists to show off their magical prowess."
	icon = 'icons/obj/clothing/capes.dmi'
	icon_state = "magiccape"
	item_state = "magiccape"

/obj/item/clothing/back/craftingcape
	name = "Crafting Cape"
	desc = "A cape once worn by a tribe of dragon slayers. They spent their days tanning dragon hide and spinning flax."
	icon = 'icons/obj/clothing/capes.dmi'
	icon_state = "craftingcape"
	item_state = "craftingcape"

/obj/item/clothing/back/skillcapebase
	name = "Unadorned Skill Cape"
	desc = "Are you good at anything?"
	icon = 'icons/obj/clothing/capes.dmi'
	icon_state = "unadornedcape"
	item_state = "unadornedcape"
	var/canstage = 1
	var/stage = 0

/obj/item/clothing/back/craftingsigil
	name = "Crafting sigil"
	desc = "An ornate icon of the fourth age."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelhammer_2"

/obj/item/clothing/back/skillcapebase/attackby(obj/item/W,mob/user)
	..()
	if(!canstage)
		to_chat(user, "<span class = 'warning'>\The [W] won't fit on \the [src].</span>")
		return
	if(istype(W,/obj/item/clothing/back/craftingsigil) && !stage)
		stage = 1
		to_chat(user,"<span class='notice'>You add \the [W] to \the [src].</span>")
		qdel(W)
		icon_state = "unfinishedcape"
	if(istype(W,/obj/item/weapon/screwdriver) && stage == 1)
		stage = 2
		to_chat(user,"<span class='notice'>You poke holes through \the [src] using \the [W].</span>")
	if(istype(W,/obj/item/stack/cable_coil) && stage == 2)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount <= 4)
			return
		C.use(5)
		to_chat(user,"<span class='notice'>You thread \the [W] through the holes, completing your skillcape.</span}")
		playsound(user, 'sound/items/Crafting_Level_up.ogg', 50, 1)
		var/obj/craftedcape = new /obj/item/clothing/back/craftingcape
		qdel(src)
		user.put_in_hands(craftedcape)







