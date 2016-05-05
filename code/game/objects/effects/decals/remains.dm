/obj/effect/decal/remains/cultify()
	return

/obj/effect/decal/remains/human
	name = "remains"
	desc = "They look like human remains. They have a strange aura about them."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	anchored = 1

/obj/effect/decal/remains/human/attack_hand(mob/user)
	if(icon_state == "remains")
		user.put_in_hands(new /obj/item/weapon/skull(user))
		icon_state = "remains_noskull"

/obj/effect/decal/remains/human/noskull
	icon_state = "remains_noskull"

/obj/item/weapon/skull
	name = "skull"
	desc = "To be or not to be..."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains_skull"
	item_state = "skull"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/remains.dmi', "right_hand" = 'icons/mob/in-hand/right/remains.dmi')
	w_class = 1.0
	force = 5
	throwforce = 10


/obj/structure/skulltest
	name = "skull"
	desc = "To be or not to be..."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains_skull"

/obj/structure/skulltest/A/attack_hand(mob/user)
	animate(src, color = list(list(1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0)), time = 10, loop = -1, easing = SINE_EASING)

/obj/structure/skulltest/B/attack_hand(mob/user)
	animate(src, color = list(1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0), time = 10, loop = -1, easing = SINE_EASING)

/obj/structure/skulltest/C/attack_hand(mob/user)
	animate(src, color = list(list(1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0),list(0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0)), time = 10, loop = -1, easing = SINE_EASING)

/obj/structure/skulltest/D/attack_hand(mob/user)
	animate(src, color = list(list(1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0),list(0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0),list(1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0)), time = 10, loop = -1, easing = SINE_EASING)

/obj/effect/decal/remains/xeno
	name = "remains"
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "remainsxeno"
	anchored = 1

/obj/effect/decal/remains/robot
	name = "remains"
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	gender = PLURAL
	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"
	anchored = 1