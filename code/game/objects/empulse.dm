/proc/empulse(turf/epicenter, heavy_range, light_range, log=0, var/mob/living/cultist = null)
	if(!epicenter)
		return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(heavy_range > 1)
		if (!cultist)
			var/obj/effect/overlay/pulse = new/obj/effect/overlay ( epicenter )
			pulse.icon = 'icons/effects/effects.dmi'
			pulse.icon_state = "emppulse"
			pulse.name = "emp pulse"
			pulse.anchored = 1
			spawn(20)
				qdel(pulse)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/max_range = max(heavy_range, light_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ([x0],[y0],[z0]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x0];Y=[y0];Z=[z0]'>JMP</A>).")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name].")

	spawn()
		for (var/mob/M in player_list)
			//Double check for client
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && (M_turf.z == epicenter.z || AreConnectedZLevels(M_turf.z,epicenter.z)))
					var/dist = cheap_pythag(M_turf.x - x0, M_turf.y - y0)
					if((dist <= round(heavy_range + world.view - 2, 1)) && (M_turf.z - epicenter.z <= max_range) && (epicenter.z - M_turf.z <= max_range))
						if (cultist)
							M.playsound_local(epicenter, 'sound/effects/bloodboil.ogg', 25, 0)
						else
							M << 'sound/effects/EMPulse.ogg'

		for(var/turf/T in multi_z_spiral_block(epicenter,max_range,0,0))
			CHECK_TICK
			if (cultist)
				spawn(get_dist(T,epicenter))
					var/atom/movable/overlay/animation = anim(target = T,a_icon = 'icons/obj/cult.dmi', flick_anim = "rune_pulse",sleeptime = 15)
					animation.add_particles("Cult Smoke Box")
					sleep(6)
					animation.adjust_particles("spawning",0,"Cult Smoke Box")
			var/dist = cheap_pythag(T.x - x0, T.y - y0)
			if(dist > max_range)
				continue
			var/act = 2
			if(dist <= heavy_range)
				act = 1
			for(var/atom/movable/A in T.contents)
				if (cultist && isliving(A))
					var/mob/living/L = A
					if (iscultist(L))
						continue
					else if (L.client && !L.isDead())
						var/datum/role/cultist/C = cultist.mind.GetRole(CULTIST)
						C.get_devotion(50, DEVOTION_TIER_2, "EMP", L)
				A.emp_act(act)
	return