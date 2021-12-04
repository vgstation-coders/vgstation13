/spell/changeling/horrorform
	name = "Horror Form (30)"
	desc = "We transform into an all-consuming abomination. We are incredibly strong, to the point that we can force open airlocks, and are immune to conventional stuns."
	abbreviation = "HF"
	hud_state = "horrorform"

	spell_flags = NEEDSHUMAN

	chemcost = 30
	horrorallowed = 0

/spell/changeling/horrorform/cast(var/list/targets, var/mob/living/carbon/human/user)
	..()
	for(var/obj/item/slot in user.get_all_slots())
		user.u_equip(slot, 1)

	user.maxHealth = 800 /* Gonna need more than one egun to kill one of these bad boys*/
	user.health = 800
	user.set_species("Horror")
	user.client.verbs |= user.species.abilities // Force ability equip.
	user.update_icons()

	user.monkeyizing = 1
	user.canmove = 0
	user.delayNextAttack(50)
	user.icon = null
	user.invisibility = 101

	var/atom/movable/overlay/animation = new /atom/movable/overlay( user.loc )
	user.visible_message("<span class = 'danger'>[user] emits a putrid odor as their torso splits open!</span>")
	world << sound('sound/effects/greaterling.ogg')
	to_chat(world, "<span class = 'sinister'>A roar pierces the air and makes your blood curdle. Uh ouser.</span>")
	animation.icon_state = "m-none"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = user
	flick("h2horror", animation)
	sleep(14*2) // Frames * lag
	qdel(animation)

	user.monkeyizing = 0
	user.canmove = 1
	user.delayNextAttack(0)
	user.icon = null
	user.invisibility = initial(user.invisibility)
	user.make_changeling()

	

