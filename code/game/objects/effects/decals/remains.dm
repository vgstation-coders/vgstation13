/obj/effect/decal/remains/cultify()
	return

/obj/effect/decal
	anchored = 1
	gender = PLURAL

	var/being_looted = 0

/obj/effect/decal/attack_hand(mob/user)
	if(being_looted)
		user << "<span class='info'>[src] are already being looted.</span>"
		return

	being_looted = 1

	user.visible_message("")

	if(do_after(user, src, 20)) //Two seconds to loot the remains
		loot()
		return qdel(src)
	else
		being_looted = 0

/obj/effect/decal/proc/loot()
	return

/obj/effect/decal/remains/human
	name = "remains"
	desc = "They look like human remains. They have a strange aura about them."

	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"

/obj/effect/decal/remains/human/loot()
	var/obj/item/stack/animal/dropped_bones = new /obj/item/stack/animal/bones(get_turf(src))
	dropped_bones.animal_type = /mob/living/carbon/human
	dropped_bones.amount = rand(10,16)
	var/obj/item/skull/skull = new /obj/item/skull(get_turf(src))
	skull.animal_type = /mob/living/carbon/human
	skull.name = "human skull"

/obj/effect/decal/remains/xeno
	name = "remains"
	desc = "They look like the remains of something... alien. They have a strange aura about them."

	icon = 'icons/effects/blood.dmi'
	icon_state = "remainsxeno"

/obj/effect/decal/remains/xeno/loot()
	var/obj/item/stack/animal/dropped_bones = new /obj/item/stack/animal/bones(get_turf(src))
	dropped_bones.animal_type = /mob/living/carbon/alien/humanoid
	dropped_bones.amount = rand(12,18)

/obj/effect/decal/remains/robot
	name = "remains"
	desc = "They look like the remains of something mechanical. They have a strange aura about them."

	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"
