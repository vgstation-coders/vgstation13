
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
	C.pixel_x = pixel_x
	C.pixel_y = pixel_y
	forceMove(C)
	C.held = src
	C.icon = icon
	C.icon_state = icon_state

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
	var/obj/item/weapon/melee/soulblade/blade = null


/obj/structure/cult/altar/New()
	..()
	flick("[icon_state]-spawn", src)
	var/image/I = image(icon, "altar_overlay")
	I.plane = ABOVE_HUMAN_PLANE
	overlays.Add(I)
	for (var/mob/living/carbon/C in loc)
		Crossed(C)


/obj/structure/cult/altar/Destroy()
	if (blade)
		if (loc)
			blade.forceMove(loc)
		else
			qdel(blade)
	blade = null
	flick("[icon_state]-break", src)
	..()

/obj/structure/cult/altar/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/melee/soulblade))
		if (blade)
			to_chat(user,"<span class='warning'>You must remove the blade planted on \the [src] first.</span>")
			return 1
		var/turf/T = get_turf(user)
		playsound(T, 'sound/weapons/bloodyslice.ogg', 50, 1)
		user.drop_item(I, T, 1)
		I.forceMove(src)
		blade = I
		update_icon()
		to_chat(user, "You plant \the [blade] on top of \the [src]</span>")
		return 1
	..()

/obj/structure/cult/altar/update_icon()
	if (blade)
		if (blade.shade)
			icon_state = "altar-soulblade-full"
		else
			icon_state = "altar-soulblade"
	else
		icon_state = "altar"
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
	anim(location = loc,target = loc,a_icon = icon, flick_anim = "[icon_state]-conceal")
	for (var/mob/living/carbon/C in loc)
		Uncrossed(C)
	..()

/obj/structure/cult/altar/reveal()
	flick("[icon_state]-spawn", src)
	..()
	for (var/mob/living/carbon/C in loc)
		Crossed(C)

/obj/structure/cult/altar/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return
	if (blade)
		blade.forceMove(loc)
		blade.attack_hand(user)
		to_chat(user, "You remove \the [blade] from \the [src]</span>")
		blade = null
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		update_icon()
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from Act II, upgrades at each subsequent Act
//      CULT SPIRE       //Can be used by cultists to acquire arcane tattoos. One of each tier.
//                       //
///////////////////////////
var/list/cult_spires = list()

/obj/structure/cult/spire
	name = "spire"
	desc = "A blood-red needle surrounded by dangerous looking...teeth?."
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = ""
	health = 100
	maxHealth = 100
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -4 * PIXEL_MULTIPLIER
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	light_color = "#FF0000"
	var/stage = 1

/obj/structure/cult/spire/New()
	..()
	cult_spires.Add(src)
	set_light(1)
	stage = min(3,max(1,veil_thickness-1))
	flick("spire[stage]-spawn",src)
	spawn(10)
		update_stage()

/obj/structure/cult/spire/Destroy()
	cult_spires.Remove(src)
	..()

/obj/structure/cult/spire/proc/upgrade()
	var/new_stage = min(3,max(1,veil_thickness-1))
	if (new_stage>stage)
		stage = new_stage
		alpha = 255
		overlays.len = 0
		color = null
		flick("spire[new_stage]-morph", src)
		spawn(3)
			update_stage()

/obj/structure/cult/spire/proc/update_stage()
	animate(src, alpha = 128, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)
	animate(alpha = 144, color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)
	animate(alpha = 160, color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)
	animate(alpha = 176, color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(alpha = 192, color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(alpha = 208, color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 224, color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 240, color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 255, color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)
	animate(alpha = 240, color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 224, color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 208, color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 192, color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 176, color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 160, color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 144, color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)
	overlays.len = 0
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"spire[stage]")
	I_base.plane = EFFECTS_PLANE
	I_base.layer = BELOW_PROJECTILE_LAYER
	I_base.appearance_flags |= RESET_COLOR//we don't want the stone to pulse
	var/image/I_spire = image('icons/obj/cult_64x64.dmi',"spire[stage]-light")
	I_spire.plane = LIGHTING_PLANE
	I_spire.layer = NARSIE_GLOW
	overlays += I_base
	overlays += I_spire


/obj/structure/cult/spire/conceal()
	overlays.len = 0
	set_light(0)
	anim(location = loc,target = loc,a_icon = 'icons/obj/cult_64x64.dmi', flick_anim = "spire[stage]-conceal", lay = BELOW_PROJECTILE_LAYER, offX = pixel_x, offY = pixel_y, plane = EFFECTS_PLANE)
	..()
	var/obj/structure/cult/concealed/C = loc
	if (istype(C))
		C.icon_state = "spire[stage]"

/obj/structure/cult/spire/reveal()
	..()
	set_light(1)
	flick("spire[stage]-spawn", src)
	animate(src)
	alpha = 255
	color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0)
	spawn(10)
		update_stage()


/obj/structure/cult/spire/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return

	if (!ishuman(user))
		to_chat(user,"<span class='warning'>Only humans can bear the arcane markings granted by this [src]</span>")
		return

	var/mob/living/carbon/human/H = user
	var/datum/role/cultist/C = H.mind.GetRole(CULTIST)

	var/list/available_tattoos = list("tier1","tier2","tier3")
	for (var/tattoo in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tattoo]
		available_tattoos -= "tier[CT.tier]"

	var/tattoo_tier = 0
	if (available_tattoos.len <= 0)
		to_chat(user,"<span class='warning'>You cannot bear any additional mark.</span>")
		return
	if ("tier1" in available_tattoos)
		tattoo_tier = 1
	else if ("tier2" in available_tattoos)
		tattoo_tier = 2
	else if ("tier3" in available_tattoos)
		tattoo_tier = 3

	if (!tattoo_tier)
		return

	var/list/optionlist = list()
	if (stage >= tattoo_tier)
		for (var/subtype in subtypesof(/datum/cult_tattoo))
			var/datum/cult_tattoo/T = new subtype
			if (T.tier == tattoo_tier)
				optionlist.Add(T.name)
				to_chat(H, "<span class='danger'>[T.name]</span>: [T.desc]")
	else
		to_chat(user,"<span class='warning'>Come back to acquire another mark once your cult is a step closer to its goal.</span>")
		return

	for(var/option in optionlist)
		optionlist[option] = image(icon = 'icons/obj/cult_radial2.dmi', icon_state = "[option]")

	var/tattoo = show_radial_menu(user,loc,optionlist,'icons/obj/cult_radial2.dmi')//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()

	for (var/tat in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tat]
		if (CT.tier == tattoo_tier)//the spire won't let cultists get multiple tattoos of the same tier.
			return

	if (!Adjacent(user))//stay here you bloke!
		return

	for (var/subtype in subtypesof(/datum/cult_tattoo))
		var/datum/cult_tattoo/T = new subtype
		if (T.name == tattoo)
			var/datum/cult_tattoo/new_tattoo = T
			C.tattoos[new_tattoo.name] = new_tattoo

			anim(target = loc, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_send", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
			spawn (3)
				C.update_cult_hud()
				new_tattoo.getTattoo(H)
				anim(target = H, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
				sleep(1)
				H.update_mutations()
				var/atom/movable/overlay/tattoo_markings = anim(target = H, a_icon = 'icons/mob/cult_tattoos.dmi', flick_anim = "[new_tattoo.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
				animate(tattoo_markings, alpha = 0, time = 30)

			available_tattoos -= "tier[new_tattoo.tier]"
			if (available_tattoos.len > 0)
				cultist_act(user)
			break

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from Act II
//      CULT FORGE       //Also a source of heat
//                       //
///////////////////////////


/obj/structure/cult/forge
	name = "forge"
	desc = "A ."
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = ""
	health = 100
	maxHealth = 100
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	light_color = LIGHT_COLOR_ORANGE
	var/heating_power = 40000
	var/set_temperature = 50
	var/mob/forger = null
	var/template = null
	var/timeleft = 0
	var/timetotal = 0
	var/obj/effect/cult_ritual/forge/forging = null
	var/image/progbar = null//progress bar


/obj/structure/cult/forge/New()
	..()
	processing_objects.Add(src)
	set_light(2)
	flick("forge-spawn",src)
	spawn(10)
		setup_overlays()

/obj/structure/cult/forge/Destroy()
	if (forging)
		qdel(forging)
	forging = null
	forger = null
	processing_objects.Remove(src)
	..()

/obj/structure/cult/forge/proc/setup_overlays()
	animate(src, alpha = 255, time = 10, loop = -1)
	animate(alpha = 240, time = 2)
	animate(alpha = 224, time = 2)
	animate(alpha = 208, time = 1.5)
	animate(alpha = 192, time = 1.5)
	animate(alpha = 176, time = 1)
	animate(alpha = 160, time = 1)
	animate(alpha = 144, time = 1)
	animate(alpha = 128, time = 3)
	animate(alpha = 144, time = 1)
	animate(alpha = 160, time = 1)
	animate(alpha = 176, time = 1)
	animate(alpha = 192, time = 1.5)
	animate(alpha = 208, time = 1.5)
	animate(alpha = 224, time = 2)
	animate(alpha = 240, time = 2)
	overlays.len = 0
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"forge")
	I_base.plane = EFFECTS_PLANE
	I_base.layer = BELOW_PROJECTILE_LAYER
	I_base.appearance_flags |= RESET_ALPHA //we don't want the stone to pulse
	var/image/I_lave = image('icons/obj/cult_64x64.dmi',"forge-lightmask")
	I_lave.plane = LIGHTING_PLANE
	I_lave.layer = NARSIE_GLOW
	I_lave.blend_mode = BLEND_ADD
	overlays += I_base
	overlays += I_lave

/obj/structure/cult/forge/process()
	if (isturf(loc))
		var/turf/simulated/L = loc
		if(istype(L))
			L.hotspot_expose(TEMPERATURE_FLAME, 125, surfaces = 1)//we start fires in plasma atmos
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature != set_temperature + T0C)
				var/datum/gas_mixture/removed = env.remove_volume(0.5 * CELL_VOLUME)
				if(removed)
					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity)
						if(removed.temperature < set_temperature + T0C)
							removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000)
				env.merge(removed)
		if(!istype(loc,/turf/space))
			for (var/mob/living/carbon/M in view(src,3))
				M.bodytemperature += (6-round(M.get_cult_power()/30))/((get_dist(src,M)+1))//cult gear reduces the heat buildup
		if (forging)
			if (forger)
				if (!Adjacent(forger))
					if (forger.client)
						forger.client.images -= progbar
					forger = null
					return
				else
					timeleft--
					update_progbar()
					if (timeleft<=0)
						playsound(L, 'sound/effects/forge_over.ogg', 50, 0, -3)
						if (forger.client)
							forger.client.images -= progbar
						qdel(forging)
						forging = null
						var/obj/item/I = new template(L)
						if (istype(I))
							I.plane = EFFECTS_PLANE
							I.layer = PROJECTILE_LAYER
							I.pixel_y = 12
						else
							I.forceMove(get_turf(forger))
						forger = null
						template = null
					else
						playsound(L, 'sound/effects/forge.ogg', 50, 0, -4)
						forging.overlays.len = 0
						var/image/I = image('icons/obj/cult_64x64.dmi',"[forging.icon_state]-mask")
						I.plane = LIGHTING_PLANE
						I.layer = NARSIE_GLOW
						I.blend_mode = BLEND_ADD
						I.alpha = (timeleft/timetotal)*255
						forging.overlays += I



/obj/structure/cult/forge/conceal()
	overlays.len = 0
	set_light(0)
	anim(location = loc,target = loc,a_icon = 'icons/obj/cult_64x64.dmi', flick_anim = "forge-conceal", lay = BELOW_PROJECTILE_LAYER, offX = pixel_x, offY = pixel_y, plane = EFFECTS_PLANE)
	..()
	var/obj/structure/cult/concealed/C = loc
	if (istype(C))
		C.icon_state = "forge"

/obj/structure/cult/forge/reveal()
	..()
	animate(src)
	alpha = 255
	set_light(2)
	flick("forge-spawn", src)
	spawn(10)
		animate(src, alpha = 255, time = 10, loop = -1)
		animate(alpha = 240, time = 2)
		animate(alpha = 224, time = 2)
		animate(alpha = 208, time = 1.5)
		animate(alpha = 192, time = 1.5)
		animate(alpha = 176, time = 1)
		animate(alpha = 160, time = 1)
		animate(alpha = 144, time = 1)
		animate(alpha = 128, time = 3)
		animate(alpha = 144, time = 1)
		animate(alpha = 160, time = 1)
		animate(alpha = 176, time = 1)
		animate(alpha = 192, time = 1.5)
		animate(alpha = 208, time = 1.5)
		animate(alpha = 224, time = 2)
		animate(alpha = 240, time = 2)
		var/image/I_base = image('icons/obj/cult_64x64.dmi',"forge")
		I_base.plane = EFFECTS_PLANE
		I_base.layer = BELOW_PROJECTILE_LAYER
		I_base.appearance_flags |= RESET_ALPHA //we don't want the stone to pulse
		var/image/I_lave = image('icons/obj/cult_64x64.dmi',"forge-lightmask")
		I_lave.plane = LIGHTING_PLANE
		I_lave.layer = NARSIE_GLOW
		I_lave.blend_mode = BLEND_ADD
		overlays += I_base
		overlays += I_lave

/obj/structure/cult/forge/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/fag = I
		fag.light("<span class='notice'>\The [user] lights \the [fag] by bringing its tip close to \the [src]'s molten flow.</span>")
		return 1
	if(istype(I,/obj/item/weapon/talisman) || istype(I,/obj/item/weapon/paper))
		I.ashify_item(user)
		return 1
	..()

/obj/structure/cult/forge/proc/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = src, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.pixel_x = 16 * PIXEL_MULTIPLIER
		progbar.pixel_y = 16 * PIXEL_MULTIPLIER
		progbar.appearance_flags = RESET_ALPHA|RESET_COLOR
		progbar.layer = HUD_ABOVE_ITEM_LAYER
	progbar.icon_state = "prog_bar_[round((100 - min(1, timeleft / timetotal) * 100), 10)]"

/obj/structure/cult/forge/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return

	if (template)
		if (forger)
			if (forger == user)
				to_chat(user, "You are already working at this forge.")
			else
				to_chat(user, "\The [forger] is currently working at this forge already.")
		else
			to_chat(user, "You resume working at the forge.")
			forger = user
			if (forger.client)
				forger.client.images |= progbar
		return

	var/optionlist = list(
		"Forge Blade",
		"Forge Construct Shell",
		"Forge Helmet",
		"Forge Armor"
		)
	for(var/option in optionlist)
		optionlist[option] = image(icon = 'icons/obj/cult_radial.dmi', icon_state = "radial_[option]")

	var/task = show_radial_menu(user,loc,optionlist,'icons/obj/cult_radial.dmi')//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	if (template || !Adjacent(user) || !task )
		return
	var/forge_icon = ""
	switch (task)
		if ("Forge Blade")
			template = /obj/item/weapon/melee/cultblade
			timeleft = 10
			forge_icon = "forge_blade"
		if ("Forge Armor")
			template = /obj/item/clothing/suit/space/cult
			timeleft = 23
			forge_icon = "forge_armor"
		if ("Forge Helmet")
			template = /obj/item/clothing/head/helmet/space/cult
			timeleft = 8
			forge_icon = "forge_helmet"
		if ("Forge Construct Shell")
			template = /obj/structure/constructshell/cult
			timeleft = 25
			forge_icon = "forge_shell"
	timetotal = timeleft
	forger = user
	update_progbar()
	if (forger.client)
		forger.client.images |= progbar
	forging = new (loc,forge_icon)

/obj/effect/cult_ritual/forge
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = ""
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER
	plane = EFFECTS_PLANE
	layer = PROJECTILE_LAYER

/obj/effect/cult_ritual/forge/New(var/turf/loc, var/i_forge="")
	..()
	icon_state = i_forge
	var/image/I = image('icons/obj/cult_64x64.dmi',"[i_forge]-mask")
	I.plane = LIGHTING_PLANE
	I.layer = NARSIE_GLOW
	I.blend_mode = BLEND_ADD
	overlays += I
