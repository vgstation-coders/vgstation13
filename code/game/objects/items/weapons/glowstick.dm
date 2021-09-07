#define GLOW_GREEN "#00FF00"
#define GLOW_RED "#FF0000"
#define GLOW_BLUE "#0000FF"

/obj/item/weapon/glowstick
	name = "green glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is green."
	color = GLOW_GREEN
	icon = 'icons/obj/weapons.dmi'
	icon_state = "glowstick"

	light_color = GLOW_GREEN
	w_class = W_CLASS_SMALL

/obj/item/weapon/glowstick/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] is breaking open \the [src] and eating the liquid inside! It looks like \he's trying to commit suicide!</span>")
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)
	return (SUICIDE_ACT_TOXLOSS)


/obj/item/weapon/glowstick/New()
	. = ..()
	set_light(2, l_color = light_color)

/obj/item/weapon/glowstick/red
	name = "red glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is red."
	color = GLOW_RED

	light_color = GLOW_RED

/obj/item/weapon/glowstick/blue
	name = "blue glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is blue."
	color = GLOW_BLUE

	light_color = GLOW_BLUE

/obj/item/weapon/glowstick/yellow
	name = "yellow glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is yellow."
	color = "#FFFF00"

	light_color = "#FFFF00"

/obj/item/weapon/glowstick/magenta
	name = "magenta glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is magenta."
	color = "#FF00FF"

	light_color = "#FF00FF"

#undef GLOW_GREEN
#undef GLOW_RED
#undef GLOW_BLUE

/obj/item/clothing/accessory/glowstick //Maybe convert the rest over later
	name = "glowstick"
	desc = "A glowstick filled with luminescent liquid. It has a string on it so you can wear it."
	icon_state = "glowstick"
	_color = "glowstick" //for setting accessory states
	color = rgb(255, 255, 255) //for coloring the accessory
	var/cracked

/obj/item/clothing/accessory/glowstick/attack_self(mob/user)
	if(!cracked)
		cracked = TRUE
		to_chat(user, "<span class='notice'>You crack \the [src] and it lights up.")
		set_light(2, l_color = color)

/obj/item/clothing/accessory/glowstick/on_attached(obj/item/clothing/C)
	..()
	if(attached_to)
		attached_to.set_light(2, l_color = color)

/obj/item/clothing/accessory/glowstick/on_removed(mob/user)
	if (attached_to)
		attached_to.kill_light()
	..()

/obj/item/clothing/accessory/glowstick/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] is breaking open \the [src] and eating the liquid inside! It looks like \he's trying to commit suicide!</span>")
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)
	return (SUICIDE_ACT_TOXLOSS)


/obj/item/clothing/accessory/glowstick/phazon
	name = "phazon glowstick"
	desc = "A glowstick filled with phazon material that will change colors upon agitation. It has a string on it so you can wear it."
	origin_tech = Tc_MATERIALS + "=6;" + Tc_ANOMALY + "=2"

/obj/item/clothing/accessory/glowstick/phazon/New()
	..()
	colorchange()

/obj/item/clothing/accessory/glowstick/phazon/proc/colorchange()
	var/r = rand(0, 255)
	var/g = rand(0, 255)
	var/b = rand(0, 255)
	color = rgb(r, g, b)
	set_light(2, l_color = color)
	update_icon()

/obj/item/clothing/accessory/glowstick/phazon/pickup(mob/user)
	user.register_event(/event/face, src, /obj/item/clothing/accessory/glowstick/phazon/proc/colorchange)

/obj/item/clothing/accessory/glowstick/phazon/dropped(mob/user)
	..()
	user.unregister_event(/event/face, src, /obj/item/clothing/accessory/glowstick/phazon/proc/colorchange)

/obj/item/clothing/accessory/glowstick/phazon/attack_self()
	colorchange()

/obj/item/clothing/accessory/glowstick/nanotrasen
	name = "IAA Identifier"
	desc = "Provided to Internal Affairs Agents to allow them to distinguish each other during field operations, it emits a subtle green glow."
	color = rgb(0, 100, 0) //Dark green, this is also pointless because you can't crack it.

/obj/item/clothing/accessory/glowstick/nanotrasen/New()
	..()
	set_light(1, 3, "#006400")

/obj/item/clothing/accessory/glowstick/nanotrasen/attack_self(mob/user)
	return //It automatically glows
