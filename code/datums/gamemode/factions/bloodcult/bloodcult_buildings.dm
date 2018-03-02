/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/health = 50
	var/maxHealth = 50

/obj/structure/cult/proc/takeDamage(var/damage)
	health -= damage
	if (health <= 0)
		qdel(src)
	else
		update_icon()

/obj/structure/cult/New()
	..()
	flick("[icon_state]-spawn", src)

/obj/structure/cult/Destroy()
	flick("[icon_state]-break", src)
	..()

/obj/structure/cult/cultify()
	return

/obj/structure/cult/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(20)
		if (3)
			takeDamage(4)

/obj/structure/cult/blob_act()
	playsound(get_turf(src), 'sound/effects/stone_hit.ogg', 75, 1)
	takeDamage(20)

/obj/structure/cult/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "altar"


/obj/structure/cult/altar/New()
	..()
	var/image/I = image(icon, "altar_overlay")
	I.plane = ABOVE_HUMAN_PLANE
	overlays.Add(I)

/obj/structure/cult/altar/update_icon()
	overlays.len = 0
	var/image/I = image(icon, "altar_overlay")
	I.plane = ABOVE_HUMAN_PLANE
	overlays.Add(I)

	if (health < maxHealth/3)
		overlays.Add("altar_damage2")
	else if (health < 2*maxHealth/3)
		overlays.Add("altar_damage1")

/obj/structure/cult/altar/MouseDrop_T(var/atom/movable/O, var/mob/user)
	if (!O.anchored && (istype(O, /obj/item) || user.get_active_hand() == O))
		if(!user.drop_item(O))
			return
	else
		if(!ismob(O))
			return
		if(O.loc == user || !isturf(O.loc) || !isturf(user.loc))
			return
		if(user.incapacitated() || user.lying)
			return
		if(O.anchored || !Adjacent(user) || !user.Adjacent(src))
			return
		if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon))
			return
		if(!user.loc)
			return
		var/mob/living/L = O
		if(!istype(L) || L.locked_to || L == user)
			return

		var/mob/living/carbon/C = O
		C.unlock_from()

		if (ishuman(C))
			C.resting = 1
			C.update_canmove()

		add_fingerprint(C)

	O.forceMove(loc)
	to_chat(user, "<span class='warning'>You move \the [O] on top of \the [src]</span>")

/obj/structure/cult/altar/Crossed(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y += 7 * PIXEL_MULTIPLIER

/obj/structure/cult/altar/Uncrossed(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y -= 7 * PIXEL_MULTIPLIER

/obj/structure/cult/altar/Cross(var/atom/movable/mover, var/turf/target, var/height=1.5, var/air_group = 0)
	if(air_group || (height==0))
		return 1

	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/cult/altar/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype(W, /obj/item/weapon/grab))
		if(iscarbon(W:affecting))
			MouseDrop_T(W:affecting,user)
			returnToPool(W)
	else if (istype(W, /obj/item/weapon))
		if(user.a_intent == I_HURT)
			user.delayNextAttack(8)
			playsound(get_turf(src), 'sound/effects/stone_hit.ogg', 75, 1)
			takeDamage(W.force)
			..()
		else
			MouseDrop_T(W,user)
