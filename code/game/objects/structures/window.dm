//Windows, one of the oldest pieces of code
//Note : You might wonder where full windows are. Full windows are in fullwindow.dm. Now you know
//And knowing is half the battle

#define WINDOWLOOSE 0
#define WINDOWLOOSEFRAME 1
#define WINDOWUNSECUREFRAME 2
#define WINDOWSECURE 3

var/list/one_way_windows

/obj/structure/window
	name = "window"
	desc = "A silicate barrier, used to keep things out and in sight. Fragile."
	icon = 'icons/obj/structures.dmi'
	icon_state = "window"
	density = 1
	layer = SIDE_WINDOW_LAYER
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1
	var/health = 10 //This window is so bad blowing on it would break it, sucks for it
	var/d_state = WINDOWLOOSEFRAME //Normal windows have one step (unanchor), reinforced windows have three
	var/shardtype = /obj/item/weapon/shard
	var/reinforcetype = /obj/item/stack/rods
	sheet_type = /obj/item/stack/sheet/glass/glass //Used for deconstruction
	var/sheetamount = 1 //Number of sheets needed to build this window (determines how much shit is spawned via Destroy())
	var/reinforced = 0 //Used for deconstruction steps
	penetration_dampening = 1
	pass_flags_self = PASSGLASS
	var/obj/abstract/Overlays/damage_overlay
	var/image/oneway_overlay
	var/cracked_base = "crack"

	var/fire_temp_threshold = 800
	var/fire_volume_mod = 100
	var/dmg_threshold = 0 //Minimum amount of item damage to start damaging window

	var/one_way = 0 //If set to 1, it will act as a one-way window.
	var/obj/machinery/smartglass_electronics/smartwindow //holds internal machinery
	var/disperse_coeff = 0.95
	var/is_fulltile = FALSE
/obj/structure/window/New(loc)

	..(loc)
	flow_flags |= ON_BORDER | KEEP_DIR
	setup_border_dummy()

	update_nearby_tiles()
	update_nearby_icons()
	update_icon()
	oneway_overlay = image('icons/obj/structures.dmi', src, "one_way_overlay")
	if(one_way)
		one_way = !one_way
		toggle_one_way()

/obj/structure/window/proc/update_oneway_nearby_clients()
	for(var/client/C in clients)
		if(!istype(C.mob, /mob/dead/observer) && !(M_XRAY in C.mob.mutations))
			if(((x >= (C.mob.x - C.view)) && (x <= (C.mob.x + C.view))) && ((y >= (C.mob.y - C.view)) && (y <= (C.mob.y + C.view))))
				C.update_one_way_windows(view(C.view,C.mob))

/obj/structure/window/projectile_check()
	return PROJREACT_WINDOWS

/obj/structure/window/examine(mob/user)
	..()
	examine_health(user)

/obj/structure/window/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	rotate()

/obj/structure/window/proc/examine_health(mob/user)
	if(!anchored)
		to_chat(user, "It appears to be completely loose and movable.")
	if(smartwindow)
		to_chat(user, "It's NT-15925 SmartGlass™ compliant.")
	if(one_way)
		to_chat(user, "It has a plastic coating.")
	//switch most likely can't take inequalities, so here's that if block
	if(health >= initial(health)) //Sanity
		to_chat(user, "It's in perfect shape without a single scratch.")
	else if(health >= 0.8*initial(health))
		to_chat(user, "It has a few scratches and a small impact.")
	else if(health >= 0.5*initial(health))
		to_chat(user, "It has a few impacts with some cracks running from them.")
	else if(health >= 0.2*initial(health))
		to_chat(user, "It's covered in impact marks and most of the outer layer is cracked.")
	else
		to_chat(user, "It's cracked over multiple layers and has many impact marks.")
	if(reinforced) //Normal windows can be loose or not, reinforced windows are more complex
		switch(d_state)
			if(WINDOWSECURE)
				to_chat(user, "It is firmly secured.")
			if(WINDOWUNSECUREFRAME)
				to_chat(user, "It appears it was unfastened from its frame.")
			if(WINDOWLOOSEFRAME)
				to_chat(user, "It appears to be loose from its frame.")

//Allows us to quickly check if we should break the window, can handle not having an user
/obj/structure/window/proc/healthcheck(var/mob/M, var/sound = 1)


	if(health <= 0)
		if(M) //Did someone pass a mob ? If so, perform a pressure check
			var/pdiff = 0
			if(flow_flags & ON_BORDER)
				pdiff = performWallPressureCheckFromTurfList(list(get_step(loc, dir), loc))
			else
				pdiff = performWallPressureCheck(loc)
			if(pdiff > 0)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] has been destroyed by [M.real_name] ([formatPlayerPanel(M, M.ckey)]) at [formatJumpTo(get_turf(src))]!")
				if(M.ckey) //Only send an admin message if it's an actual players, admins don't need to know what the carps are doing
					message_admins("\The [src] with a pdiff of [pdiff] has been destroyed by [M.real_name] ([formatPlayerPanel(M, M.ckey)]) at [formatJumpTo(get_turf(src))]!")
		shatter()
	else
		if(sound)
			playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		if(!damage_overlay)
			damage_overlay = new(src)
			damage_overlay.icon = icon('icons/obj/structures.dmi')
			damage_overlay.dir = src.dir

		overlays -= damage_overlay

		if(health < initial(health))
			var/damage_fraction = clamp(round((initial(health) - health) / initial(health) * 5) + 1, 1, 5) //gives a number, 1-5, based on damagedness
			damage_overlay.icon_state = "[cracked_base][damage_fraction]"
			overlays += damage_overlay

/obj/structure/window/proc/adjustHealthLoss(var/amount = 0, var/atom/movable/W = null)
	if(amount < dmg_threshold)
		if(W && !istype(W,/obj/item/projectile/fire_breath))
			visible_message("<span class='warning'>\The [W] [pick("bounces","gleams")] off \the [src] harmlessly.</span>")
		return FALSE
	health -= amount
	return TRUE

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)

	adjustHealthLoss(Proj.damage,Proj)
	. = ..()
	healthcheck(Proj.firer)

//This ex_act just removes health to be fully modular with "bomb-proof" windows
/obj/structure/window/ex_act(severity)

	switch(severity)
		if(1.0)
			adjustHealthLoss(rand(100, 150))
			healthcheck()
			return
		if(2.0)
			adjustHealthLoss(rand(20, 50))
			healthcheck()
			return
		if(3.0)
			adjustHealthLoss(rand(5, 15))
			healthcheck()
			return

/obj/structure/window/blob_act()
	anim(target = loc, a_icon = 'icons/mob/blob/blob.dmi', flick_anim = "blob_act", sleeptime = 15, lay = 12)
	adjustHealthLoss(rand(30, 50))
	healthcheck()

/obj/structure/window/kick_act(mob/living/carbon/human/H)
	if(H.locked_to && isobj(H.locked_to) && H.locked_to != src)
		var/obj/O = H.locked_to
		if(O.onBuckledUserKick(H, src))
			return //don't return 1! we will do the normal "touch" action if so!

	playsound(src, 'sound/effects/glassknock.ogg', 100, 1)

	H.do_attack_animation(src, H)
	H.visible_message("<span class='danger'>\The [H] kicks \the [src].</span>", \
	"<span class='danger'>You kick \the [src].</span>")

	var/damage = rand(1,7) * (H.get_strength() - reinforced) //By default, humanoids can't damage windows with kicks. Being strong or a hulk changes that
	var/obj/item/clothing/shoes/S = H.shoes
	if(istype(S))
		damage += S.bonus_kick_damage //Unless they're wearing heavy boots

	if(damage > 0)
		if(!adjustHealthLoss(damage))
			H.visible_message("<span class='danger'>\The [H]'s kick [pick("bounces","gleams")] off \the [src] harmlessly.</span>", \
			"<span class='danger'>Your kick [pick("bounces","gleams")] off \the [src] harmlessly.</span>")
		healthcheck()

/obj/structure/window/Cross(atom/movable/mover, turf/target, height = 0)
	if(locate(/obj/effect/unwall_field) in loc) //Annoying workaround for this
		return TRUE
	if(istype(mover) && mover.checkpass(pass_flags_self))//checking for beam dispersion both in and out, since beams do not trigger Uncross.
		if((get_dir(loc, target) | get_dir(loc, mover)) & (dir | opposite_dirs[dir]))
			dim_beam(mover)
		return TRUE
	if(!density)
		return TRUE
	if(istype(mover))
		return bounds_dist(border_dummy, mover) >= 0
	else if(get_dir(loc, target) == dir)
		return FALSE
	return TRUE

/obj/structure/window/proc/dim_beam(var/obj/item/projectile/beam/B)
	if(istype(B))
		B.damage *= disperse_coeff
		if(B.damage <= 1)
			B.bullet_die()

/obj/structure/window/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is smashing \his head against \the [src]! It looks like \he's trying to commit suicide.</span>")
	attack_generic(user,10)
	return(SUICIDE_ACT_BRUTELOSS)

//Someone threw something at us, please advise
/obj/structure/window/hitby(var/atom/movable/AM)
	. = ..()
	if(.)
		return
	if(ismob(AM))
		var/mob/M = AM //Duh
		if (AM.invisibility < 101)
			visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
			"<span class='danger'>You slam into \the [src].</span>")
		adjustHealthLoss(10,AM) //We estimate just above a slam but under a crush, since mobs can't carry a throwforce variable
		healthcheck(M)
	else if(isobj(AM))
		var/obj/item/I = AM
		if (AM.invisibility < 101)
			visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")
		adjustHealthLoss(I.throwforce,AM)
		healthcheck()

/obj/structure/window/attack_hand(mob/living/user as mob)

	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
		if(!adjustHealthLoss(25))
			user.visible_message("<span class='danger'>[user]'s punch [pick("bounces","gleams")] off \the [src] harmlessly.</span>")
		healthcheck()
		user.delayNextAttack(8)

	//Bang against the window
	else if(user.a_intent == I_HURT)
		user.do_attack_animation(src, user)
		user.delayNextAttack(10)
		playsound(src, 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")

	//Knock against it
	else
		user.delayNextAttack(10)
		playsound(src, 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] knocks on \the [src].</span>", \
		"<span class='notice'>You knock on \the [src].</span>", \
		"You hear knocking.")
	return

/obj/structure/window/attack_paw(mob/user as mob)

	return attack_hand(user)

/obj/structure/window/proc/attack_generic(mob/living/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime

	user.do_attack_animation(src, user)
	user.delayNextAttack(10)
	user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>", \
	"<span class='danger'>You smash into \the [src]!</span>")
	if(!adjustHealthLoss(damage))
		user.visible_message("<span class='danger'>\The [user]'s attack [pick("bounces","gleams")] off \the [src] harmlessly.</span>", \
		"<span class='danger'>Your attack [pick("bounces","gleams")] off \the [src] harmlessly.</span>")
	healthcheck(user)

/obj/structure/window/attack_alien(mob/user as mob)

	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/user as mob)

	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/window/attack_slime(mob/user as mob)

	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15))

/obj/structure/window/proc/toggle_one_way() //Toggle whether a window is a one-way window or not.
	if(!one_way)
		one_way = 1
		if(!one_way_windows)
			one_way_windows = list()
		one_way_windows.Add(src)
		update_oneway_nearby_clients()
		overlays += oneway_overlay
	else
		one_way = 0
		one_way_windows.Remove(src)
		update_oneway_nearby_clients()
		overlays -= oneway_overlay

/obj/structure/window/proc/smart_toggle() //For "smart" windows
	if(opacity)
		animate(src, color="#FFFFFF", time=5)
		set_opacity(0)
	else
		animate(src, color="#222222", time=5)
		set_opacity(1)
	return opacity

/obj/structure/window/attackby(obj/item/weapon/W as obj, mob/living/user as mob)

	if(istype(W, /obj/item/weapon/grab) && Adjacent(user))
		var/obj/item/weapon/grab/G = W
		if(istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/gstate = G.state
			qdel(W)	//Gotta delete it here because if window breaks, it won't get deleted
			user.do_attack_animation(src, W)
			switch(gstate)
				if(GRAB_PASSIVE)
					M.apply_damage(5) //Meh, bit of pain, window is fine, just a shove
					visible_message("<span class='warning'>\The [user] shoves \the [M] into \the [src]!</span>", \
					"<span class='warning'>You shove \the [M] into \the [src]!</span>")
				if(GRAB_AGGRESSIVE)
					M.apply_damage(10) //Nasty, but dazed and concussed at worst
					visible_message("<span class='danger'>\The [user] slams \the [M] into \the [src]!</span>", \
					"<span class='danger'>You slam \the [M] into \the [src]!</span>")
					adjustHealthLoss(5,M)
				if(GRAB_NECK to GRAB_KILL)
					M.Stun(3)
					M.Knockdown(3) //Almost certainly shoved head or face-first, you're going to need a bit for the lights to come back on
					M.apply_damage(20) //That got to fucking hurt, you were basically flung into a window, most likely a shattered one at that
					visible_message("<span class='danger'>\The [user] crushes \the [M] into \the [src]!</span>", \
					"<span class='danger'>You crush \the [M] into \the [src]!</span>")
					adjustHealthLoss(20,M) //Window won't like that
			healthcheck(user)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been window slammed by [user.name] ([user.ckey]) ([gstate]).</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Window slammed [M.name] ([gstate]).</font>")
			msg_admin_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			return

	if(iscrowbar(W) && one_way)
		if(!is_fulltile && get_turf(user) != get_turf(src))
			to_chat(user, "<span class='warning'>You can't pry the sheet of plastic off from this side of \the [src]!</span>")
		else
			to_chat(user, "<span class='notice'>You pry the sheet of plastic off \the [src].</span>")
			toggle_one_way()
			drop_stack(/obj/item/stack/sheet/mineral/plastic, get_turf(user), 1, user)
			return
    /* One-way windows have serious performance issues - N3X
	if(istype(W, /obj/item/stack/sheet/mineral/plastic))
		if(one_way)
			to_chat(user, "<span class='notice'>This window already has one-way tint on it.</span>")
			return
		if(is_fulltile)
			update_nearby_tiles()
			change_dir(turn(get_dir(get_turf(user),get_turf(src)),180))
			if(!test_bitflag(dir))	//if its direction is diagonal
				if(prob(50))
					change_dir(turn(dir,45))
				else
					change_dir(turn(dir,315))
			update_nearby_tiles()
		var/obj/item/stack/sheet/mineral/plastic/P = W
		toggle_one_way()
		P.use(1)
		to_chat(user, "<span class='notice'>You place a sheet of plastic over the window.</span>")
		return
	*/


	if(istype(W, /obj/item/stack/light_w))
		var/obj/item/stack/light_w/LT = W
		if (!anchored)
			to_chat(user, "<span class='notice'>Secure the window before trying this.</span>")
			return 0
		if (smartwindow)
			to_chat(user, "<span class='notice'>This window already has electronics in it.</span>")
			return 0
		LT.use(1)
		to_chat(user, "<span class='notice'>You add some electronics to the window.</span>")
		smartwindow = new /obj/machinery/smartglass_electronics(src)
		smartwindow.Ourwindow = src
		return 1


	if(W.is_multitool(user) && smartwindow)
		smartwindow.update_multitool_menu(user)
		return

	//Start construction and deconstruction, absolute priority over the other object interactions to avoid hitting the window

	if(reinforced) //Steps for all reinforced window types

		switch(d_state)

			if(WINDOWSECURE) //Reinforced, fully secured

				if(W.is_screwdriver(user))
					W.playtoolsound(loc, 75)
					user.visible_message("<span class='warning'>[user] unfastens \the [src] from its frame.</span>", \
					"<span class='notice'>You unfasten \the [src] from its frame.</span>")
					d_state = WINDOWUNSECUREFRAME
					return

			if(WINDOWUNSECUREFRAME)

				if(W.is_screwdriver(user))
					W.playtoolsound(loc, 75)
					user.visible_message("<span class='notice'>[user] fastens \the [src] to its frame.</span>", \
					"<span class='notice'>You fasten \the [src] to its frame.</span>")
					d_state = WINDOWSECURE
					return

				if(iscrowbar(W))
					W.playtoolsound(loc, 75)
					user.visible_message("<span class='warning'>[user] pries \the [src] from its frame.</span>", \
					"<span class='notice'>You pry \the [src] from its frame.</span>")
					d_state = WINDOWLOOSEFRAME
					return

			if(WINDOWLOOSEFRAME)

				if(iscrowbar(W))
					W.playtoolsound(loc, 75)
					user.visible_message("<span class='notice'>[user] pries \the [src] into its frame.</span>", \
					"<span class='notice'>You pry \the [src] into its frame.</span>")
					d_state = WINDOWUNSECUREFRAME
					return

				if(W.is_screwdriver(user))
					W.playtoolsound(loc, 75)
					user.visible_message("<span class='warning'>[user] unfastens \the [src]'s frame from the floor.</span>", \
					"<span class='notice'>You unfasten \the [src]'s frame from the floor.</span>")
					d_state = WINDOWLOOSE
					anchored = 0
					update_nearby_tiles() //Needed if it's a full window, since unanchored windows don't link
					update_nearby_icons()
					update_icon()
					if(smartwindow)
						qdel(smartwindow)
						smartwindow = null
						if (opacity)
							smart_toggle()
						drop_stack(/obj/item/stack/light_w, get_turf(src), 1, user)
					//Perform pressure check since window no longer blocks air
					var/pdiff = 0
					if(flow_flags & ON_BORDER)
						pdiff = performWallPressureCheckFromTurfList(list(get_step(loc, dir), loc))
					else
						pdiff = performWallPressureCheck(loc)
					if(pdiff > 0)
						message_admins("Window with pdiff [pdiff] deanchored by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)]!")
						log_admin("Window with pdiff [pdiff] deanchored by [user.real_name] ([user.ckey]) at [loc]!")
					return

			if(WINDOWLOOSE)

				if(W.is_screwdriver(user))
					W.playtoolsound(loc, 75)
					user.visible_message("<span class='notice'>[user] fastens \the [src]'s frame to the floor.</span>", \
					"<span class='notice'>You fasten \the [src]'s frame to the floor.</span>")
					d_state = WINDOWLOOSEFRAME
					anchored = 1
					update_nearby_tiles() //Ditto above, but in reverse
					update_nearby_icons()
					update_icon()
					if(smartwindow)
						qdel(smartwindow)
						smartwindow = null
						if (opacity)
							smart_toggle()
						drop_stack(/obj/item/stack/light_w, get_turf(src), 1, user)
					return

				if(iswelder(W))
					var/obj/item/tool/weldingtool/WT = W
					user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
						"<span class='notice'>You start disassembling \the [src].</span>")
					if(WT.do_weld(user, src, 40, 1) && d_state == WINDOWLOOSE) //Extra condition needed to avoid cheesing
						WT.playtoolsound(src, 100)
						user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
						"<span class='notice'>You disassemble \the [src].</span>")
						drop_stack(sheet_type, get_turf(src), sheetamount, user)
						qdel(src)
						return
					else
						return

	else if(!reinforced) //Normal window steps

		if(W.is_screwdriver(user))
			W.playtoolsound(loc, 75)
			user.visible_message("<span class='[d_state ? "warning":"notice"]'>[user] [d_state ? "un":""]fastens \the [src].</span>", \
			"<span class='notice'>You [d_state ? "un":""]fasten \the [src].</span>")
			d_state = !d_state
			anchored = !anchored
			update_nearby_tiles() //Ditto above
			update_nearby_icons()
			update_icon()
			return

		if(iswelder(W) && !d_state)
			var/obj/item/tool/weldingtool/WT = W
			user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
				"<span class='notice'>You start disassembling \the [src].</span>")
			if(WT.do_weld(user, src, 40, 0) && d_state == WINDOWLOOSE) //Ditto above
				user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
				"<span class='notice'>You disassemble \the [src].</span>")
				drop_stack(sheet_type, get_turf(src), sheetamount, user)
				qdel(src)
				return

	user.do_attack_animation(src, W)
	if(W.damtype == BRUTE || W.damtype == BURN)
		user.delayNextAttack(10)
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		adjustHealthLoss(W.force,W)
		healthcheck(user)
		return
	else
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()

	return

/obj/structure/window/proc/can_be_reached(mob/user)
	if(!is_fulltile)
		if(get_dir(user, src) & dir)
			for(var/obj/O in loc)
				if(!O.Cross(user, user.loc, 1, 0))
					return 0
	return 1

/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	update_nearby_tiles() //Compel updates before
	change_dir(turn(dir, 90))
	update_nearby_tiles()
	return

/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	update_nearby_tiles() //Compel updates before
	change_dir(turn(dir, 270))
	update_nearby_tiles()
	return

/obj/structure/window/Destroy()
	setDensity(FALSE) //Sanity while we do the rest
	update_nearby_tiles()
	update_nearby_icons()
	if(one_way)
		one_way_windows.Remove(src)
		update_oneway_nearby_clients()
	..()

/obj/structure/window/proc/shatter()
	if(loc)
		playsound(src, "shatter", 70, 1)
	spawnBrokenPieces()
	qdel(src)

/obj/structure/window/proc/spawnBrokenPieces()
	if(shardtype)
		new shardtype(loc, sheetamount)
	if(reinforced)
		new reinforcetype(loc, sheetamount)

/obj/structure/window/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)

	update_nearby_tiles()
	. = ..()
	update_nearby_tiles()

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons(var/turf/T)


	if(!loc)
		return 0
	if(!T)
		T = get_turf(src)

	update_icon()

	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(T,direction))
			W.update_icon()

/obj/structure/window/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0)
	var/turf/T = loc
	..()
	update_nearby_icons(T)
	update_nearby_icons()
	update_nearby_tiles(T)
	update_nearby_tiles()

/obj/structure/window/update_icon()

	return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	if(exposed_temperature > T0C + fire_temp_threshold)
		adjustHealthLoss(round(exposed_volume/fire_volume_mod))
		healthcheck(sound = 0)
	..()

/obj/structure/window/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/structure/window/reinforced/clockwork, BRASS_WINDOW_GLOW)

/obj/structure/window/oneway
	one_way = 1

/obj/structure/window/loose
	anchored = 0
	d_state = 0

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window with a rod matrix. It looks more solid than the average window."
	icon_state = "rwindow"
	sheet_type = /obj/item/stack/sheet/glass/rglass
	health = 40
	d_state = WINDOWSECURE
	reinforced = 1
	penetration_dampening = 3
	disperse_coeff = 0.8
	dmg_threshold = 5

/obj/structure/window/reinforced/oneway
	one_way = 1

/obj/structure/window/reinforced/loose
	anchored = 0
	d_state = 0

/obj/structure/window/plasma

	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheet_type = /obj/item/stack/sheet/glass/plasmaglass
	health = 120
	penetration_dampening = 5

	fire_temp_threshold = 32000
	fire_volume_mod = 1000
	disperse_coeff = 0.75
	dmg_threshold = 10

/obj/structure/window/plasma/oneway
	one_way = 1

/obj/structure/window/plasma/loose
	anchored = 0
	d_state = 0

/obj/structure/window/reinforced/plasma

	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheet_type = /obj/item/stack/sheet/glass/plasmarglass
	health = 160
	penetration_dampening = 7
	disperse_coeff = 0.6
	dmg_threshold = 15

/obj/structure/window/reinforced/plasma/oneway
	one_way = 1

/obj/structure/window/reinforced/plasma/loose
	anchored = 0
	d_state = 0


// Used on Packed ; smartglassified roundstart
// TODO: Remove this snowflake stuff.
/obj/structure/window/reinforced/plasma/interogation_room/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = "InterogationRoomIDTag"

/obj/structure/window/reinforced/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced/tinted

	name = "tinted window"
	desc = "A window with a rod matrix. Its surface is completely tinted, making it opaque. Why not a wall ?"
	icon_state = "twindow"
	opacity = 1
	sheet_type = /obj/item/stack/sheet/glass/rglass //A glass type for this window doesn't seem to exist, so here's to you

/obj/structure/window/reinforced/tinted/frosted

	name = "frosted window"
	desc = "A window with a rod matrix. Its surface is completely tinted, making it opaque, and it's frosty. Why not an ice wall ?"
	icon_state = "fwindow"
	health = 30
	sheet_type = /obj/item/stack/sheet/glass/rglass //Ditto above

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon_state = "clockworkwindow"
	shardtype = null
	sheet_type = /obj/item/stack/sheet/brass
	reinforcetype = /obj/item/stack/sheet/ralloy
	sheetamount = 2
	health = 80

/obj/structure/window/reinforced/clockwork/cultify()
	return

/obj/structure/window/reinforced/clockwork/clockworkify()
	return

/obj/structure/window/reinforced/clockwork/loose
	anchored = 0
	d_state = 0

// Smartglass for mappers, smartglassified on roundstart.
//the id_tag of the actual pane itself is passed to the smartglass electronics on initialization, it's not used for anything else
/obj/structure/window/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/full/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/full/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/reinforced/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/reinforced/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/full/reinforced/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/full/reinforced/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/plasma/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/plasma/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/full/plasma/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/full/plasma/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/reinforced/plasma/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/reinforced/plasma/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/full/reinforced/plasma/smart
	var/id_tag
	var/frequency = 1449

/obj/structure/window/full/reinforced/plasma/smart/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/structure/window/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"health",
		"d_state")

	reset_vars_after_duration(resettable_vars, duration)


#undef WINDOWLOOSE
#undef WINDOWLOOSEFRAME
#undef WINDOWUNSECUREFRAME
#undef WINDOWSECURE
