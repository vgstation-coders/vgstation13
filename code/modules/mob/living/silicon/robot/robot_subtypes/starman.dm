/mob/living/silicon/robot/starman
	cell_type = /obj/item/weapon/cell/super
	deny_client_move = 1
	anchored = 1
	
/mob/living/silicon/robot/starman/wearing_wiz_garb()
	return 1
	
/mob/living/silicon/robot/starman/New()
	..()
	UnlinkSelf()
	laws = new /datum/ai_laws/starman()
	pick_module(STARMAN_MODULE)
	set_module_sprites(list("Basic" = "starman"))
	src.add_spell(new /spell/aoe_turf/starman_play_music)
	src.add_spell(new /spell/aoe_turf/starman_brainshock)
	src.add_spell(new /spell/aoe_turf/starman_starstorm)
	src.add_spell(new /spell/targeted/starman_shield)
	src.add_spell(new /spell/targeted/starman_warp)

			
/spell/aoe_turf/starman_play_music
	name = "Telepathic Binaural Attack"
	desc = "Forces the menacing tunes of the Starman into the minds of all your enemies. And you."
	hud_state = "time_future"
	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 10

/spell/aoe_turf/starman_play_music/cast(list/targets, mob/user = user)
	stop_starman_music()
	if(prob(50))
		playsound(get_turf(user), 'sound/music/battle_against_a_machine.ogg', 20, channel = CHANNEL_STARMAN)
	else
		playsound(get_turf(user), 'sound/music/imbossible.ogg', 20, channel = CHANNEL_STARMAN)
		
/proc/stop_starman_music()
	for(var/mob/M in mob_list)
		if(M && M.client)
			M << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_STARMAN)	
		

	
	
	
/spell/targeted/starman_warp
	name = "Warp"
	desc = "Teleport to the targeted location."
	hud_state = "starman_warp"
	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 60
	invocation_type = SpI_NONE
	range = 8
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	selection_type = "range"

/spell/targeted/starman_warp/cast(list/targets, mob/user = user)
	..()
	for(var/atom/target in targets)
		var/turf/floor = get_turf(target)
		if(!floor.density)
			user.icon_state = "starman_phase"
			spawn(0.3 SECONDS)
				do_teleport(user, floor, 0)
				playsound(user, 'sound/effects/phasein.ogg', 25, 0)
				user.visible_message("<span class='danger'>\The [user] warps!</span>","<span class='notice'>*Bzzt* Warp successful.</span>")
				spawn(0.3 SECONDS)
					user.icon_state = "starman"
			return
	playsound(user, 'sound/machines/buzz-sigh.ogg', 25, 0)
	to_chat(user,"<span class='warning'>*Bzzt* Warp failed.</span>")
	



	
/spell/targeted/starman_shield
	name = "Psi Shield Beta"
	desc = "Generates a psionic barrier in the given direction."
	hud_state = "psi_shield_beta"
	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	invocation_type = SpI_NONE
	range = 8
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	selection_type = "range"
	
/spell/targeted/starman_shield/cast(list/targets, mob/user = user)
	..()
	for(var/atom/target in targets)
		var/turf/floor = get_turf(target)
		if(!floor.density)
			playsound(user, 'sound/effects/psi/psi_shield_beta.ogg', 35, 0)
			var/obj/effect/forcefield/starman/barrier = new /obj/effect/forcefield/starman(floor)
			barrier.spread_outward(user)
			user.visible_message("<span class='danger'>\The [user] projects a psionic forcefield!</span>","<span class='notice'>*Whirrr* Projection successful.</span>")
			return
	playsound(user, 'sound/machines/buzz-sigh.ogg', 40, 0)
	to_chat(user,"<span class='warning'>*Click* Projection failed.</span>")		
		

/obj/effect/forcefield/starman
	desc = "It shimmers with reality-bending energy."
	name = "Psionic Barrier"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles_heavy"
	light_color = LIGHT_COLOR_BLUE
	luminosity = 2
	invisibility = 0
	explosion_block = 200
	var/lifespan = 200

/obj/effect/forcefield/starman/New()
	..()
	set_light(2)
	spawn(lifespan)
		qdel(src)
	
/obj/effect/forcefield/starman/proc/spread_outward(var/mob/caster)
	var/cast_direction = get_dir(caster,src)
	var/turf/left = get_step(get_turf(src),turn(cast_direction,-90))
	if(!left.density)
		new /obj/effect/forcefield/starman(left)
	var/turf/right = get_step(get_turf(src),turn(cast_direction,90))
	if(!right.density)
		new /obj/effect/forcefield/starman(right)		
		
		
		
		
		
/spell/aoe_turf/starman_starstorm
	name = "Psi Starstorm Omega"
	desc = "Conjures a psionic starstorm that impacts around you."
	hud_state = "psi_starstorm_omega"
	school = "conjuration"
	charge_max = 1200

	charge_type = Sp_RECHARGE
	invocation_type = SpI_NONE

	duration = 100
	range = 5
	selection_type = "range"
	var/meteor_count = 15

/spell/aoe_turf/starman_starstorm/choose_targets(mob/user = usr)
	return trange(range, get_turf(user)) - trange(2, get_turf(user))

/spell/aoe_turf/starman_starstorm/cast(list/targets, mob/user)
	playsound(user, 'sound/effects/psi/psi_starstorm_omega.ogg', 20, 0)
	var/obj/item/projectile/meteor/new_meteor
	var/turf/spawn_loc
	spawn(6) //Slight delay
		for(var/i = 1 to meteor_count)
			spawn_loc = pick(targets)
			spawn(rand(0,2 SECONDS))
				new_meteor = new /obj/item/projectile/meteor/mini(spawn_loc)
				spawn(rand(1,4))
					new_meteor.to_bump(get_turf(new_meteor))

	user.visible_message("<span class='danger'>\The [user] summons a fearsome starstorm!</span>","<span class='notice'>*Click* Star-matrix realized.</span>")

	..()
	
/obj/item/projectile/meteor/mini
	name = "small meteor"
	desc = "It's a starstorm, baby!"
	icon_state = "small"
	pass_flags = PASSTABLE

/obj/item/projectile/meteor/mini/to_bump(atom/A)
	if(loc == null)
		return

	explosion(get_turf(src), 0, 0, 2, 2) //Small boom.
	qdel(src)	
	
	
	
/spell/aoe_turf/starman_brainshock
	name = "Psi Brainshock Omega"
	desc = "Shocks the minds of all entities around you, causing severe mental distress."
	hud_state = "psi_brainshock_omega"
	school = "conjuration"
	charge_max = 300

	charge_type = Sp_RECHARGE
	invocation_type = SpI_NONE

	duration = 100
	range = 6
	selection_type = "range"
	var/move_with_user = 0

/spell/aoe_turf/starman_brainshock/choose_targets(mob/user = usr)
	return range(range, get_turf(user))

/spell/aoe_turf/starman_brainshock/cast(list/targets, mob/user)
	playsound(user, 'sound/effects/psi/psi_brainshock_omega.ogg', 10, 0)
	
	spawn(6)
		for(var/mob/living/carbon/target in targets)
			target.stuttering += 5
			target.ear_deaf += 1
			target.dizziness += 5
			target.confused +=  5
			target.Jitter(5)		
			target.Knockdown(1)
			target.shakecamera += 1

	user.visible_message("<span class='danger'>\The [user] bends reality in impossible ways!</span>","<span class='notice'>*Beep* Hostile consciousnesses twisted.</span>")

	..()