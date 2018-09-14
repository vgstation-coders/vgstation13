
/datum/cult_ritual//placeholder, this will serve with cult building rituals, and stuff like the new Nar-Sie summoning

/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/health = 50
	var/maxHealth = 50
	var/sound_damaged = null
	var/sound_destroyed = null
	var/conceal_cooldown = 0

/obj/structure/cult/proc/conceal()
	var/obj/structure/cult/concealed/C = new(loc)
	forceMove(C)
	C.held = src
	C.icon_state = icon_state
	anim(location = C.loc,target = C.loc,a_icon = 'icons/obj/cult.dmi', flick_anim = "[icon_state]-conceal")

/obj/structure/cult/proc/reveal()
	conceal_cooldown = 1
	spawn (100)
		if (src && loc)
			conceal_cooldown = 0

/obj/structure/cult/concealed
	density = 0
	anchored = 1
	alpha = 127
	invisibility = INVISIBILITY_OBSERVER
	var/obj/structure/cult/held = null

/obj/structure/cult/concealed/reveal()
	if (held)
		held.forceMove(loc)
		flick("[held.icon_state]-spawn", held)
		held.reveal()
		held = null
	qdel(src)

/obj/structure/cult/concealed/conceal()
	return

/obj/structure/cult/concealed/takeDamage(var/damage)
	return

//if you want indestructible buildings, just make a custom takeDamage() proc
/obj/structure/cult/proc/takeDamage(var/damage)
	health -= damage
	if (health <= 0)
		if (sound_destroyed)
			playsound(get_turf(src), sound_destroyed, 100, 1)
		qdel(src)
	else
		update_icon()

/obj/structure/cult/New()
	..()
	flick("[icon_state]-spawn", src)

/obj/structure/cult/Destroy()
	flick("[icon_state]-break", src)
	..()

//duh
/obj/structure/cult/cultify()
	return

//nuh-uh
/obj/structure/cult/acidable()
	return 0

/obj/structure/cult/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(20)
		if (3)
			takeDamage(4)

/obj/structure/cult/blob_act()
	playsound(get_turf(src), sound_damaged, 75, 1)
	takeDamage(20)

/obj/structure/cult/bullet_act(var/obj/item/projectile/Proj)
	takeDamage(Proj.damage)
	..()

/obj/structure/cult/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(iscarbon(G.affecting))
			MouseDropTo(G.affecting,user)
			returnToPool(W)
	else if (istype(W, /obj/item/weapon))
		if(user.a_intent == I_HURT)
			user.delayNextAttack(8)
			if (sound_damaged)
				playsound(get_turf(src), sound_damaged, 75, 1)
			takeDamage(W.force)
			..()
		else
			MouseDropTo(W,user)


/obj/structure/cult/attack_paw(var/mob/user)
	return attack_hand(user)


/obj/structure/cult/attack_hand(var/mob/living/user)
	if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.visible_message("<span class='danger'>[user.name] kicks \the [src]!</span>", \
							"<span class='danger'>You kick \the [src]!</span>", \
							"You hear stone cracking.")
		takeDamage(user.get_unarmed_damage(src))
		if (sound_damaged)
			playsound(get_turf(src), sound_damaged, 75, 1)
	else if(iscultist(user))
		cultist_act(user)
	else
		noncultist_act(user)

/obj/structure/cult/proc/cultist_act(var/mob/user)
	if(!iscultist(user))//just to be extra safe
		return 0
	return 1

/obj/structure/cult/proc/noncultist_act(var/mob/user)
	if(iscultist(user))//just to be extra safe
		return 0
	to_chat(user,"<span class='sinister'>You feel madness taking its toll, trying to figure out \the [name]'s purpose</span>")
	//might add some hallucinations or brain damage later, checks for cultist chaplains, etc
	return 1



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from the beginning. Trigger progress to ACT I
//      CULT ALTAR       //Allows communication with Nar-Sie for advice and info on the Cult's current objective.
//                       //ACT II : Allows Soulstone crafting, Used to sacrifice the target on the Station
///////////////////////////ACT III : Can plant an empty Soul Blade in it to prompt observers to become the blade's shade


/obj/structure/cult/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "altar"
	health = 100
	maxHealth = 100
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	layer = TABLE_LAYER


/obj/structure/cult/altar/New()
	..()
	var/image/I = image(icon, "altar_overlay")
	I.plane = ABOVE_HUMAN_PLANE
	overlays.Add(I)
	for (var/mob/living/carbon/C in loc)
		Crossed(C)

/obj/structure/cult/altar/update_icon()
	overlays.len = 0
	var/image/I = image(icon, "altar_overlay")
	I.plane = ABOVE_HUMAN_PLANE
	overlays.Add(I)

	if (health < maxHealth/3)
		overlays.Add("altar_damage2")
	else if (health < 2*maxHealth/3)
		overlays.Add("altar_damage1")

//We want people on top of the altar to appear slightly higher
/obj/structure/cult/altar/Crossed(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y += 7 * PIXEL_MULTIPLIER

/obj/structure/cult/altar/Uncrossed(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y -= 7 * PIXEL_MULTIPLIER

//They're basically the height of regular tables
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

/obj/structure/cult/altar/MouseDropTo(var/atom/movable/O, var/mob/user)
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

/obj/structure/cult/altar/conceal()
	for (var/mob/living/carbon/C in loc)
		Uncrossed(C)
	..()

/obj/structure/cult/altar/reveal()
	..()
	for (var/mob/living/carbon/C in loc)
		Crossed(C)

/obj/structure/cult/altar/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return
	var/dat = ""
	switch (menu)
		if ("default")
			dat = {"<body style="color:#FF0000" bgcolor="#110000"><dl>
				  <dt><a href='?src=\ref[src];altar=commune' style="color:#FFFFFF"><b>Commune with Nar-Sie</b></a></dt>
				  <dd>Should you need guidance, Nar-Sie can offer you some tips.</br>
				  The tips can vary depending on the veil's thickness.</dd>"}
			if (veil_thickness >= CULT_ACT_II)
				dat += {"<dt><a href='?src=\ref[src];altar=soulstone' style="color:#FFFFFF"><b>Conjure Soulstone</b></a></dt>
					  <dd>For a tribute of 60u of blood, this altar will conjure a soulstone over 30s.</br>
					  Use them to capture the soul of a dead or critically injured enemy.</dd>"}
			else
				dat += {"<dt><b style="color:#666666">Conjure Soulstone - LOCKED (ACT II)</b></dt>
					  </br>"}
			if (veil_thickness == CULT_ACT_II)
				dat += {"<dt><a href='?src=\ref[src];altar=sacrifice' style="color:#FFFFFF"><b>Offer in Sacrifice</b></a></dt>
					  <dd>The body of the individual designated by Nar-Sie is the key to tear down the veil.</br>
					  Place them on \the [name] first, but be prepared to oppose the crew openly.</dd>"}
			else
				dat += {"<dt><b style="color:#666666">Offer in Sacrifice - LOCKED (ACT II only)</b></dt>
					  </br>"}
			if (veil_thickness >= CULT_ACT_III)
				dat += {"<dt><a href='?src=\ref[src];altar=soulblade' style="color:#FFFFFF"><b>Conjure Soul into Blade</b></a></dt>
					  <dd>Leave a soul blade on \the [name] to imbue it with the souls of the dead from hell.</br>
					  It takes a while, but can be an alternative to capturing a soul by yourself.</dd>"}
			else
				dat += {"<dt><b style="color:#666666">Conjure Soul into Blade - LOCKED (ACT III)</b></dt>
					  </br>"}
			dat += {"</dl></body>"}
		if ("commune")
			dat = {"<body style="color:#FF0000" bgcolor="#110000"><dl><dt>TODO ADD NARSIE TIPS FOR EACH ACTS</dt></dl></body>"}

	user << browse("<TITLE>Cult Altar</TITLE>[dat]", "window=cultaltar;size=565x280")
	onclose(user, "cultaltar")

/obj/structure/cult/altar/Topic(href, href_list)
	switch (href_list["altar"])
		if ("commune")
			cultist_act(usr,"commune")
		if ("soulstone")
			to_chat(usr,"TODO: SPAWN A SOULSTONE")
		if ("sacrifice")
			to_chat(usr,"TODO: SACRIFICE")
		if ("soulblade")
			to_chat(usr,"TODO: IMBUE SOULBLADE")
