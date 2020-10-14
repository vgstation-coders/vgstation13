/spell/changeling/horrorform
	name = "Horror Form"
	desc = "We transform into an all-consuming abomination. We are incredibly strong, to the point that we can force open airlocks, and are immune to conventional stuns."
	abbreviation = "HF"

    spell_flags = NEEDSHUMAN

	chemcost = 30
    allowhorror = 0

/spell/changeling/horrorform/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 0

	var/mob/living/carbon/human/H = user

	for(var/obj/item/slot in H.get_all_slots())
		u_equip(slot, 1)

	H.maxHealth = 800 /* Gonna need more than one egun to kill one of these bad boys*/
	H.health = 800
	H.set_species("Horror")
	H.client.verbs |= H.species.abilities // Force ability equip.
	H.update_icons()

	monkeyizing = 1
	canmove = 0
	delayNextAttack(50)
	icon = null
	invisibility = 101

	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	H.visible_message("<span class = 'warning'>[user] emits a putrid odor as their torso splits open!</span>")
	world << sound('sound/effects/greaterling.ogg')
	to_chat(world, "<span class = 'sinister'>A roar pierces the air and makes your blood curdle. Uh oh.</span>")
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = user
	flick("h2horror", animation)
	sleep(14*2) // Frames * lag
	qdel(animation)

	monkeyizing = 0
	canmove = 1
	delayNextAttack(0)
	icon = null
	invisibility = initial(invisibility)

	..()

