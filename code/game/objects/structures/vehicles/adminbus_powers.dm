///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////

//RELEASE PASSENGERS

/obj/structure/bed/chair/vehicle/adminbus/proc/release_passengers(mob/bususer)


	unloading = 1

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			freed(L)
		else if(isbot(A))
			var/obj/machinery/bot/B = A
			B.forceMove(get_step(src,turn(src.dir,-90)))
			B.turn_on()
			B.flags &= ~INVULNERABLE
			B.anchored = 0
			passengers -= B
			update_rearview()
		sleep(3)

	unloading = 0

	return

/obj/structure/bed/chair/vehicle/adminbus/proc/freed(var/mob/living/L)
	L.forceMove(get_step(src, turn(src.dir, -90)))
	L.anchored = 0
	L.flags &= ~INVULNERABLE
	L.captured = 0
	L.pixel_x = 0
	L.pixel_y = 0
	L.update_canmove()
	to_chat(L, "<span class='notice'>Thank you for riding with \the [src], have a secure day.</span>")
	passengers -= L
	update_rearview()

//MOB SPAWNING
/obj/structure/bed/chair/vehicle/adminbus/proc/spawn_mob(mob/bususer,var/mob_type,var/count)
	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/invocnum = min(count, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		switch(mob_type)
			if(1)
				var/mob/living/simple_animal/hostile/retaliate/clown/M = new /mob/living/simple_animal/hostile/retaliate/clown(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#FFC0FF", anim_plane = EFFECTS_PLANE)
			if(2)
				var/mob/living/simple_animal/hostile/carp/M = new /mob/living/simple_animal/hostile/carp(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#C70AF5", anim_plane = EFFECTS_PLANE)
			if(3)
				if(prob(10))
					var/mob/living/simple_animal/hostile/humanoid/russian/M = new /mob/living/simple_animal/hostile/humanoid/russian(T)
					M.faction = "adminbus mob"
					spawned_mobs += M
				else
					var/mob/living/simple_animal/hostile/bear/M = new /mob/living/simple_animal/hostile/bear(T)
					M.faction = "adminbus mob"
					spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#454545", anim_plane = EFFECTS_PLANE)
			if(4)
				var/mob/living/simple_animal/hostile/tree/M = new /mob/living/simple_animal/hostile/tree(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#232B2C", anim_plane = EFFECTS_PLANE)
			if(5)
				var/mob/living/simple_animal/hostile/giant_spider/M = new /mob/living/simple_animal/hostile/giant_spider(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#3B2D1C", anim_plane = EFFECTS_PLANE)
			if(6)
				var/mob/living/simple_animal/hostile/alien/queen/large/M = new /mob/living/simple_animal/hostile/alien/queen/large(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-16,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#525288", anim_plane = EFFECTS_PLANE)
		sleep(5)

/obj/structure/bed/chair/vehicle/adminbus/proc/remove_mobs(mob/bususer)
	for(var/mob/M in spawned_mobs)
		var/xoffset = -WORLD_ICON_SIZE
		if(istype(M,/mob/living/simple_animal/hostile/alien/queen/large))
			xoffset = -WORLD_ICON_SIZE/2
		var/turf/T = get_turf(M)
		if(T)
			T.turf_animation('icons/effects/96x96.dmi',"beamin",xoffset,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)
		qdel(M)
	spawned_mobs.len = 0

//SINGULARITY/NARSIE HOOK&CHAIN

/obj/structure/bed/chair/vehicle/adminbus/proc/capture_singulo(var/obj/machinery/singularity/S)
	for(var/atom/A in hookshot)																//first we remove the hookshot and its chain
		qdel(A)
	hookshot.len = 0

	singulo = S
	S.on_capture()
	var/obj/structure/singulo_chain/parentchain = null
	var/obj/structure/singulo_chain/anchor/A = new /obj/structure/singulo_chain/anchor(loc)	//then we spawn the invisible anchor on top of the bus,
	while(get_dist(A,S) > 0)																//it then travels toward the singulo while creating chains on its path,
		A.forceMove(get_step_towards(A,S))													//and parenting them together
		var/obj/structure/singulo_chain/C = new /obj/structure/singulo_chain(A.loc)
		chain += C
		C.dir = get_dir(src,S)
		if(!parentchain)
			chain_base = C
		else
			parentchain.child = C
		parentchain = C
	if(!parentchain)
		chain_base = A
	else
		parentchain.child = A
	chain += A																				//once the anchor has reached the singulo, it parents itself to the last element in the chain
	A.target = singulo																		//and stays on top of the singulo.

/obj/structure/bed/chair/vehicle/adminbus/proc/throw_hookshot(mob/bususer)


	if(!hook && !singulo)
		return

	if(singulo)
		var/obj/structure/singulo_chain/anchor/A = locate(/obj/structure/singulo_chain/anchor) in chain
		if(A)
			qdel(A)//so we don't drag the singulo back to us along with the rest of the chain.
		singulo.on_release()
		singulo = null
		bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
		while(chain_base)
			var/obj/structure/singulo_chain/C = chain_base
			C.move_child(get_turf(src))
			chain_base = C.child
			qdel(C)
			sleep(2)

		for(var/obj/structure/singulo_chain/N in chain)//Just in case some bits of the chain were detached from the bus for whatever reason
			qdel(N)
		chain.len = 0

		if(!singulo)
			hook = 1
			bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
	else if(hook)
		hook = 0
		bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
		var/obj/structure/hookshot/claw/C = new/obj/structure/hookshot/claw(get_step(src,src.dir))	//First we spawn the claw
		hookshot += C
		C.abus = src

		var/obj/machinery/singularity/S = C.hook_throw(src.dir)							//The claw moves forward, spawning hookshot-chains on its path
		if(S)
			capture_singulo(S)
			bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)														//If the claw hits a singulo, we remove the hookshot-chains and replace them with singulo-chains
		else
			for(var/obj/structure/hookshot/A in hookshot)								//If it doesn't hit anything, all the elements of the chain come back toward the bus,
				spawn()//so they all return at once										//deleting themselves when they reach it.
					A.hook_back()

/////////////////

/obj/structure/bed/chair/vehicle/adminbus/proc/mass_rejuvinate(mob/bususer)
	for(var/mob/living/M in orange(src,3))
		M.revive(1)
		if(M.mind)
			M.mind.suiciding = 0
		to_chat(M, "<span class='notice'>THE ADMINBUS IS LOVE. THE ADMINBUS IS LIFE.</span>")
		sleep(2)
	update_rearview()

/obj/structure/bed/chair/vehicle/adminbus/proc/toggle_lights(mob/bususer,var/lightpower=0)


	if(lightpower == roadlights)
		return
	var/image/roadlights_image = image(icon,"roadlights", ABOVE_LIGHTING_LAYER)
	roadlights_image.plane = ABOVE_LIGHTING_PLANE
	roadlights = lightpower
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_roadlights_low)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_roadlights_mid)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_roadlights_high)
	switch(lightpower)
		if(0)
			lightsource.kill_light()
			if(roadlights == 1 || roadlights == 2)
				overlays["roadlights"] = null
		if(1)
			lightsource.set_light(2)
			if(roadlights == 0)
				overlays["roadlights"] = roadlights_image
		if(2)
			lightsource.set_light(3)
			if(roadlights == 0)
				overlays["roadlights"] = roadlights_image

	update_lightsource()

/obj/structure/bed/chair/vehicle/adminbus/proc/toggle_bumpers(mob/bususer,var/bumperpower=1)


	if(bumperpower == bumpers)
		return

	bumpers = bumperpower
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_bumpers_low)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_bumpers_mid)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_bumpers_high)


/obj/structure/bed/chair/vehicle/adminbus/proc/toggle_door(mob/bususer,var/doorstate=0)


	if(doorstate == door_mode)
		return

	door_mode = doorstate
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_door_closed)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_door_open)
	if (door_mode)
		overlays += image(icon,"opendoor")
	else
		overlays -= image(icon,"opendoor")

/obj/structure/bed/chair/vehicle/adminbus/proc/loadsa_goodies(mob/bususer,var/goodie_type)
	switch(goodie_type)
		if(1)
			visible_message("<span class='notice'>All Access for Everyone!</span>")
		if(2)
			visible_message("<span class='notice'>Loads of Money!</span>")

	var/joy_sound = list('sound/voice/SC4Mayor1.ogg','sound/voice/SC4Mayor2.ogg','sound/voice/SC4Mayor3.ogg')
	playsound(src, pick(joy_sound), 50, 0, 0)
	var/throwzone = list()
	for(var/i=1;i<=5;i++)
		throwzone = list()
		for(var/turf/T in range(src,5))
			throwzone += T
		switch(goodie_type)
			if(1)
				var/obj/item/weapon/card/id/captains_spare/S = new/obj/item/weapon/card/id/captains_spare(src.loc)
				S.throw_at(pick(throwzone),rand(2,5),0)
			if(2)
				var/obj/item/fuckingmoney = null
				fuckingmoney = pick(
				50;/obj/item/weapon/coin/gold,
				50;/obj/item/weapon/coin/silver,
				50;/obj/item/weapon/coin/diamond,
				40;/obj/item/weapon/coin/iron,
				50;/obj/item/weapon/coin/plasma,
				40;/obj/item/weapon/coin/uranium,
				10;/obj/item/weapon/coin/clown,
				50;/obj/item/weapon/coin/phazon,
				30;/obj/item/weapon/coin/adamantine,
				30;/obj/item/weapon/coin/mythril,
				200;/obj/item/weapon/spacecash,
				200;/obj/item/weapon/spacecash/c10,
				200;/obj/item/weapon/spacecash/c100,
				300;/obj/item/weapon/spacecash/c1000
				)
				var/obj/item/C = new fuckingmoney(src.loc)
				C.throw_at(pick(throwzone),rand(2,5),0)

/obj/structure/bed/chair/vehicle/adminbus/proc/give_bombs(mob/bususer)

	var/distributed = 0

	if(is_locking(/datum/locking_category/adminbus))
		var/mob/living/M = get_locked(/datum/locking_category/adminbus)[1]
		if(iscarbon(M))
			for(var/i = 1 to M.held_items.len)
				if(M.held_items[i] == null)
					var/obj/item/cannonball/fuse_bomb/admin/B = new /obj/item/cannonball/fuse_bomb/admin(M)
					spawnedbombs += B
					if(!M.put_in_hands(B))
						qdel(B)

					to_chat(M, "<span class='warning'>Lit and throw!</span>")
					break

	for(var/mob/living/carbon/C in passengers)
		for(var/i = 1 to C.held_items.len)
			if(C.held_items[i] == null)
				var/obj/item/cannonball/fuse_bomb/admin/B = new /obj/item/cannonball/fuse_bomb/admin(C)
				spawnedbombs += B
				if(!C.put_in_hands(B))
					qdel(B)

				to_chat(C, "<span class='warning'>Our benefactors have provided you with a bomb. Lit and throw!</span>")
				distributed++
				break

	update_rearview()
	to_chat(bususer, "[distributed] bombs distributed to passengers.</span>")

/obj/structure/bed/chair/vehicle/adminbus/proc/delete_bombs(mob/bususer)

	if(spawnedbombs.len == 0)
		to_chat(bususer, "No bombs to delete.</span>")
		return

	var/distributed = 0

	for(var/i=spawnedbombs.len;i>0;i--)
		var/obj/item/cannonball/fuse_bomb/B = spawnedbombs[i]
		if(B)
			if(istype(B.loc,/mob/living/carbon))
				var/mob/living/carbon/C = B.loc
				qdel(B)
				C.regenerate_icons()
			else
				qdel(B)
			distributed++
		spawnedbombs -= spawnedbombs[i]

	update_rearview()
	to_chat(bususer, "Deleted all [distributed] bombs.</span>")


/obj/structure/bed/chair/vehicle/adminbus/proc/give_lasers(mob/bususer)

	var/distributed = 0

	if(is_locking(/datum/locking_category/adminbus))
		var/mob/living/M = get_locked(/datum/locking_category/adminbus)[1]
		if(iscarbon(M))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(M)

			if(M.put_in_hands(L))
				spawnedlasers += L
				to_chat(M, "<span class='warning'>Spray and /pray!</span>")
			else
				qdel(L)

	for(var/mob/living/carbon/C in passengers)
		var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(C)

		if(C.put_in_hands(L))
			spawnedlasers += L
			to_chat(C, "<span class='warning'>Our benefactors have provided you with an infinite laser gun. Spray and /pray!</span>")
			distributed++
		else
			qdel(L)

	update_rearview()
	to_chat(bususer, "[distributed] infinite laser guns distributed to passengers.</span>")

/obj/structure/bed/chair/vehicle/adminbus/proc/delete_lasers(mob/bususer)

	if(spawnedlasers.len == 0)
		to_chat(bususer, "No laser guns to delete.</span>")
		return

	var/distributed = 0

	for(var/i=spawnedlasers.len;i>0;i--)
		var/obj/item/weapon/gun/energy/laser/admin/L = spawnedlasers[i]
		if(L)
			if(istype(L.loc,/mob/living/carbon))
				var/mob/living/carbon/C = L.loc
				qdel(L)
				C.regenerate_icons()
			else
				qdel(L)
			distributed++
		spawnedlasers -= spawnedlasers[i]

	update_rearview()
	to_chat(bususer, "Deleted all [distributed] laser guns.</span>")

/obj/structure/bed/chair/vehicle/adminbus/proc/Mass_Repair(mob/bususer,var/turf/centerloc=null,var/repair_range=3)//the proc can be called by others, doing (null, <center of the area you want to repair>, <radius of the area you want to repair>)

	visible_message("<span class='notice'>WE BUILD!</span>")

	if(!centerloc)
		centerloc = src.loc

	for(var/obj/machinery/M in range(centerloc,repair_range))
		if(istype(M,/obj/machinery/door/window))//for some reason it makes the windoors' sprite disapear (until you bump into it)
			continue
		if(istype(M,/obj/machinery/light))
			var/obj/machinery/light/L = M
			L.fix()
			continue
		M.stat = 0
		M.update_icon()

	for(var/turf/T in range(centerloc,repair_range))
		if(istype(T, /turf/space/))
			if(isspace(T.loc))
				continue
			var/obj/item/stack/tile/metal/P = new /obj/item/stack/tile/metal
			P.build(T)
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/floor/F = T
			if(F.broken || F.burnt)
				if(F.is_plating())
					F.icon_state = "plating"
					F.burnt = 0
					F.broken = 0
				else
					F.make_plating()

	for(var/obj/structure/cultgirder/G in range(centerloc,repair_range))
		var/turf/T = get_turf(G)
		T.ChangeTurf(/turf/simulated/wall/cult)
		qdel(G)

	for(var/obj/structure/girder/G in range(centerloc,repair_range))
		var/turf/T = get_turf(G)
		if(istype(G,/obj/structure/girder/reinforced))
			T.ChangeTurf(/turf/simulated/wall/r_wall)
		else
			T.ChangeTurf(/turf/simulated/wall)
		qdel(G)

	for(var/obj/item/weapon/shard/S in range(centerloc,repair_range))
		if(istype(S,/obj/item/weapon/shard/plasma))
			new/obj/item/stack/sheet/glass/plasmaglass(S.loc)
		else
			new/obj/item/stack/sheet/glass/glass(S.loc)
		qdel(S)

/obj/structure/bed/chair/vehicle/adminbus/proc/Teleportation(mob/bususer)


	if(warp.icon_state == "warp_activated")
		return

	warp.icon_state = "warp_activated"

	var/A
	A = input(bususer, "Area to jump to", "Teleportation Warp", A) as null|anything in adminbusteleportlocs
	var/area/thearea = adminbusteleportlocs[A]
	if(!thearea)
		warp.icon_state = ""
		return

	var/list/L = list()

	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		to_chat(bususer, "No area available.")
		warp.icon_state = ""
		return

	var/turf/T1 = get_turf(src)
	var/turf/T2 = pick(L)
	warp.icon_state = ""
	forceMove(T2)
	T1.turf_animation('icons/effects/160x160.dmi',"busteleport",-WORLD_ICON_SIZE*2,-WORLD_ICON_SIZE,MOB_LAYER+1,'sound/effects/busteleport.ogg', anim_plane = EFFECTS_PLANE)
	T2.turf_animation('icons/effects/160x160.dmi',"busteleport",-WORLD_ICON_SIZE*2,-WORLD_ICON_SIZE,MOB_LAYER+1,'sound/effects/busteleport.ogg', anim_plane = EFFECTS_PLANE)

/obj/structure/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Obs(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, "<span class='warning'>There are no passengers to send.</span>")
		return

	if(alert(bususer, "Send all passengers to the thunderdome's spectating area?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/M = A
			freed(M)

/*									//We let the observers keep their belongings
			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.forceMove(M.loc)
					I.reset_plane_and_layer()
					I.dropped(M)
					I.z = map.zCentcomm
					I.y = 68
					I.x = (thunderdomefightercount % 15) + 121

*/

			M.forceMove(pick(tdomeobserve))
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome. Thank you for riding with us and enjoy your games.</span>")

		else if(isbot(A))
			var/obj/machinery/bot/B = A
			B.forceMove(get_step(src,turn(src.dir,-90)))
			B.turn_on()
			B.flags &= ~INVULNERABLE
			B.anchored = 0
			passengers -= B
			B.forceMove(pick(tdomeobserve))

		var/turf/TD = get_turf(A)
		if(TD)
			TD.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',anim_plane = EFFECTS_PLANE)

		sleep(1)

/obj/structure/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Arena(mob/bususer)//this one sends an equal number of fighter to each side.


	if(passengers.len == 0)
		to_chat(bususer, "<span class='warning'>There are no passengers to send.</span>")
		return

	if(alert(bususer, "Split passengers between the two thunderdome teams?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)

	var/alternate = 1

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(alternate)
			join_team(A,"Red")
			alternate = 0
		else
			join_team(A,"Green")
			alternate = 1

	to_chat(bususer, "The passengers' belongings were stored inside the Thunderdome's admin lodge.")

/obj/structure/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Arena_Green(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, "<span class='warning'>There are no passengers to send.</span>")
		return

	if(alert(bususer, "Send all passengers to the thunderdome's Green Team?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		join_team(A,"Green")

	to_chat(bususer, "The passengers' belongings were stored inside the Thunderdome's admin lodge.")

/obj/structure/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Arena_Red(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, "<span class='warning'>There are no passengers to send.</span>")
		return

	if(alert(bususer, "Send all passengers to the thunderdome's Red Team?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		join_team(A,"Red")

	to_chat(bususer, "The passengers' belongings were stored inside the Thunderdome's admin lodge.")

/obj/structure/bed/chair/vehicle/adminbus/proc/join_team(var/atom/A, var/team)
	if(isliving(A))
		var/mob/living/M = A
		freed(M)

		var/obj/item/packobelongings/pack = null

		switch(team)
			if("Green")
				pack = new /obj/item/packobelongings/green(src.loc)
				pack.x = map.tDomeX+2
			if("Red")
				pack = new /obj/item/packobelongings/red(src.loc)
				pack.x = map.tDomeX-2

		pack.z = map.tDomeZ			//the players' belongings are stored there, in the Thunderdome Admin lodge.
		pack.y = map.tDomeY

		pack.name = "[M.real_name]'s belongings"

		for(var/obj/item/I in M)
			if(istype(I,/obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = I
				if(G.prescription)
					continue
			M.u_equip(I)
			if(I)
				I.forceMove(M.loc)
				I.reset_plane_and_layer()
				I.dropped(M)
				I.forceMove(pack)

		var/obj/item/weapon/card/id/thunderdome/ident = null

		switch(team)
			if("Green")
				ident = new /obj/item/weapon/card/id/thunderdome/green(M)
				ident.name = "[M.real_name]'s Thunderdome Green ID"
			if("Red")
				ident = new /obj/item/weapon/card/id/thunderdome/red(M)
				ident.name = "[M.real_name]'s Thunderdome Red ID"

		if(!iscarbon(M))
			qdel(ident)

		switch(team)
			if("Green")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
					H.equip_to_slot_or_del(ident, slot_wear_id)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/green(H), slot_belt)
					H.regenerate_icons()
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					var/obj/item/clothing/monkeyclothes/jumpsuit_green/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_green(K)
					var/obj/item/clothing/monkeyclothes/olduniform = null
					var/obj/item/clothing/monkeyclothes/oldhat = null
					if(K.uniform)
						olduniform = K.uniform
						K.uniform = null
						olduniform.forceMove(pack)
					K.uniform = JS
					K.uniform.forceMove(K)
					if(K.hat)
						oldhat = K.hat
						K.hat = null
						oldhat.forceMove(pack)
					K.put_in_hands(ident)
					K.put_in_hands(new /obj/item/weapon/storage/belt/thunderdome/green(K))
					K.regenerate_icons()

			if("Red")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
					H.equip_to_slot_or_del(ident, slot_wear_id)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/red(H), slot_belt)
					H.regenerate_icons()
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					var/obj/item/clothing/monkeyclothes/jumpsuit_red/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_red(K)
					var/obj/item/clothing/monkeyclothes/olduniform = null
					var/obj/item/clothing/monkeyclothes/oldhat = null
					if(K.uniform)
						olduniform = K.uniform
						K.uniform = null
						olduniform.forceMove(pack)
					K.uniform = JS
					K.uniform.forceMove(K)
					if(K.hat)
						oldhat = K.hat
						K.hat = null
						oldhat.forceMove(pack)
					K.put_in_hands(ident)
					K.put_in_hands(new /obj/item/weapon/storage/belt/thunderdome/red(K))
					K.regenerate_icons()

		if(pack.contents.len == 0)
			qdel(pack)

		switch(team)
			if("Green")
				M.forceMove(pick(tdome1))
			if("Red")
				M.forceMove(pick(tdome2))

		to_chat(M, "<span class='danger'>You have been chosen to fight for the [team] Team. [pick(\
		"The wheel of fate is turning!",\
		"Heaven or Hell!",\
		"Set Spell Card!",\
		"Hologram Summer Again!",\
		"Get ready for the next battle!",\
		"Fight for your life!",\
		)]</span>")

	else if(isbot(A))
		var/obj/machinery/bot/B = A
		B.forceMove(get_step(src,turn(src.dir,-90)))
		B.turn_on()
		B.flags &= ~INVULNERABLE
		B.anchored = 0
		passengers -= B

		switch(team)
			if("Green")
				B.forceMove(pick(tdome1))
			if("Red")
				B.forceMove(pick(tdome2))

	var/turf/T = get_turf(A)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', "#00FF00", anim_plane = EFFECTS_PLANE)

	sleep(1)

/obj/item/packobelongings
	name = "Unknown's belongings"
	desc = "Full of stuff."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "belongings"
	w_class = W_CLASS_MEDIUM

/obj/item/packobelongings/New()
	..()
	src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/obj/item/packobelongings/attack_self(mob/user as mob)
	var/turf/T = get_turf(user)
	for(var/obj/O in src)
		O.forceMove(T)
	qdel(src)

/obj/item/packobelongings/green
	icon_state = "belongings-green"
	desc = "Items belonging to one of the Thunderdome contestants."

/obj/item/packobelongings/red
	icon_state = "belongings-red"
	desc = "Items belonging to one of the Thunderdome contestants."

/obj/structure/bed/chair/vehicle/adminbus/proc/Send_Home(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, "<span class='warning'>There are no passengers to send.</span>")
		return

	if(alert(bususer, "Send all mobs among the passengers back where they first appeared? (Risky: This sends them back where their \"object\" was created. If they were cloned they will teleport back at genetics, If they had their species changed they'll spawn back where it happenned, etc...)", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T1 = get_turf(src)
	if(T1)
		T1.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)

	for(var/mob/M in passengers)
		freed(M)
		M.send_back()

		var/turf/T2 = get_turf(M)
		if(T2)
			T2.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', anim_plane = EFFECTS_PLANE)
/*
/obj/structure/bed/chair/vehicle/adminbus/proc/Make_Antag(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, "<span class='warning'>There are no passengers to make antag.</span>")
		return

	var/list/delays = list("CANCEL", "No Delay", "10 seconds", "30 seconds", "1 minute", "5 minutes", "15 minutes")
	var/delay = input("How much delay before the transformation occurs?", "Antag Madness") in delays

	switch(delay)
		if("CANCEL")
			return
		if("No Delay")
			for(var/mob/M in passengers)
				spawn()
					to_chat(M, "<span class='danger'>YOU JUST REMEMBERED SOMETHING IMPORTANT!</span>")
					sleep(20)
					antag_madness_adminbus(M)
		if("10 seconds")
			antagify_passengers(100)
		if("30 seconds")
			antagify_passengers(300)
		if("1 minute")
			antagify_passengers(600)
		if("5 minutes")
			antagify_passengers(3000)
		if("15 minutes")
			antagify_passengers(9000)


/obj/structure/bed/chair/vehicle/adminbus/proc/antagify_passengers(var/delay)
	for(var/mob/M in passengers)
		spawn()
			Delay_Antag(M, delay)

/obj/structure/bed/chair/vehicle/adminbus/proc/Delay_Antag(var/mob/M,var/delay=100)
	if(!M.mind)
		return
	if(!ishuman(M) && !ismonkey(M))
		return

	to_chat(M, "<span class='rose'>You feel like you forgot something important!</span>")

	sleep(delay/2)

	to_chat(M, "<span class='rose'>You're starting to remember...</span>")

	sleep(delay/2)

	to_chat(M, "<span class='danger'>OH THAT'S RIGHT!</span>")

	sleep(20)

	antag_madness_adminbus(M)
*/
/obj/structure/bed/chair/vehicle/adminbus/proc/Mounted_Jukebox(mob/bususer)
	busjuke.attack_hand(bususer)

/obj/structure/bed/chair/vehicle/adminbus/proc/Adminbus_Deletion(mob/bususer)//make sure to always use this proc when deleting an adminbus
	if(bususer)
		if(alert(bususer, "This will free all passengers, remove any spawned mobs/laserguns/bombs, [singulo ? "free the captured singularity" : ""], and remove all the entities associated with the bus(chains, roadlights, jukebox,...) Are you sure?", "Adminbus Deletion", "Yes", "No") != "Yes")
			return

	qdel(src)//RIP ADMINBUS
