/mob/living/silicon/robot/starman
	cell_type = /obj/item/weapon/cell/ultra
	deny_client_move = 1
	anchored = 1
	namepick_uses = 0
	
/mob/living/silicon/robot/starman/wearing_wiz_garb()
	return 1
	
/mob/living/silicon/robot/starman/New()
	..()
	UnlinkSelf()
	laws = new /datum/ai_laws/starman()
	pick_module(STARMAN_MODULE)
	src.add_spell(new /spell/aoe_turf/starman_play_music)
	src.add_spell(new /spell/aoe_turf/starman_brainshock)
	src.add_spell(new /spell/aoe_turf/starman_starstorm)
	src.add_spell(new /spell/aoe_turf/starman_heal)
	src.add_spell(new /spell/targeted/starman_shield)
	src.add_spell(new /spell/targeted/starman_warp)

/mob/living/silicon/robot/starman/updatename(var/prefix)
	
	var/greek_alphabet = list("Alpha", "Beta", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", \
						 "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	custom_name = "[pick("Starman DX","Starman","Starman Ultra")] [pick(greek_alphabet)]"
	..()
	
/mob/living/silicon/robot/starman/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/bullet))
		var/reflectchance = 70 - round(P.damage/3)
		if(prob(reflectchance))
			adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>\The [P.name] gets reflected off \the [src]'s chrome!</span>", \
							"<span class='userdanger'>\The [P.name] gets reflected off \the [src]'s chrome!</span>")

			P.reflected = 1
			P.rebound(src)

			return -1 // complete projectile permutation

	return (..(P))

/mob/living/silicon/robot/starman/emp_act(severity)
	..()
	if(modulelock)
		modulelock_time = min(modulelock_time, 4 SECONDS)

/mob/living/silicon/robot/starman/getarmor()
	return 30

/mob/living/silicon/robot/starman/getarmorabsorb()
	return 10
	
/mob/living/silicon/robot/starman/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force && O.force < 11)
		user.delayNextAttack(8)
		user.visible_message("<span class='danger'>[O] bounces harmlessly off of \the [src].</span>", "<span class='userdanger'>[O] bounces harmlessly off of \the [src].</span>")
	else
		..()	
	
	
	
	
	
/proc/psi_precast(var/mob/user)
	playsound(user, 'sound/effects/psi/psi_precast.ogg', 30, 0, wait = TRUE)
	sleep(3)
		

		


/spell/aoe_turf/starman_play_music
	name = "Telepathic Binaural Attack"
	desc = "Forces the menacing tunes of the Starman into the minds of all your enemies. And you."
	hud_state = "time_future"
	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 10
	var/list/starman_music = list('sound/music/battle_against_a_machine.ogg', 'sound/music/imbossible.ogg')

/spell/aoe_turf/starman_play_music/cast(list/targets, mob/user = user)
	stop_starman_music()
	if(user)
		for(var/mob/M in oviewers(8,user))
			if(M && M.client)
				M << sound(pick(starman_music), repeat = 0, wait = 0, volume = 20, channel = CHANNEL_STARMAN)
		user << sound(pick(starman_music), repeat = 0, wait = 0, volume = 20, channel = CHANNEL_STARMAN)
		
		
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
	

	
	
	
	
	
/spell/aoe_turf/starman_heal
	name = "Psi Lifeup Alpha"
	desc = "Slightly heal yourself."
	hud_state = "psi_lifeup_alpha"
	charge_type = Sp_RECHARGE
	charge_max = 250
	invocation_type = SpI_NONE
	var/heal_amount = 30

/spell/aoe_turf/starman_heal/cast(list/targets, mob/living/user = user)
	spawn(0)
		psi_precast(user)
		if(user.getOxyLoss())
			user.adjustOxyLoss(-heal_amount)
		if(user.getBruteLoss())
			user.heal_organ_damage(heal_amount, 0)
		if(user.getFireLoss())
			user.heal_organ_damage(0, heal_amount)
		if(user.getToxLoss())
			user.adjustToxLoss(-heal_amount)
		var/mob/living/silicon/robot/robot = user
		if(istype(robot))
			for(var/name in robot.components)
				var/datum/robot_component/component = robot.components[name]
				component.heal_damage(30,30)
		user.updatehealth()	
		playsound(user, 'sound/effects/psi/psi_lifeup_alpha.ogg', 15, 0)
		user.visible_message("<span class='danger'>\The [user] envelops himself in a bubble of healing magic!</span>","<span class='notice'>*Bzzt* Restoration successful.</span>")
	

	


	
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
	spawn(0)
		psi_precast(user)
		for(var/atom/target in targets)
			var/turf/floor = get_turf(target)
			if(!floor.density)
				playsound(user, 'sound/effects/psi/psi_shield_alpha.ogg', 35, 0)
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
	charge_max = 1800

	charge_type = Sp_RECHARGE
	invocation_type = SpI_NONE

	duration = 100
	range = 5
	selection_type = "range"
	var/meteor_count = 12

/spell/aoe_turf/starman_starstorm/choose_targets(mob/user = usr)
	return trange(range, get_turf(user)) - trange(2, get_turf(user))

/spell/aoe_turf/starman_starstorm/cast(list/targets, mob/user)
	spawn(0)
		psi_precast(user)
		playsound(user, 'sound/effects/psi/psi_starstorm_omega.ogg', 20, 0)
		var/obj/item/projectile/meteor/new_meteor
		var/turf/spawn_loc
		spawn(2) //Slight delay
			for(var/i = 1 to meteor_count)
				spawn_loc = pick(targets)
				spawn(rand(0,2 SECONDS))
					new_meteor = new /obj/item/projectile/meteor/mini(spawn_loc)
					spawn(rand(3,5))
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
	spawn(0)
		psi_precast(user)
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
	
	
/obj/item/weapon/gun/energy/starman_beam
	name = "Psi Beam Vestibule"
	desc = "Used to channel psionic energy into a deadly form."
	icon_state = "pulse"
	item_state = "gun"
	fire_sound = 'sound/effects/psi/psi_beam.ogg'
	fire_delay = 3 SECONDS
	cell_type = "/obj/item/weapon/cell/infinite"
	projectile_type = "/obj/item/projectile/beam/pulse"
	force = 10
	
/obj/item/device/starman_hailer
	name = "Horror Translucidator"
	desc = "Activate to frighten the carbons with specially-produced sound effects."
	icon_state = "voice0"
	item_state = "flashbang"
	var/list/possible_sounds = list('sound/effects/psi/other/enterbattle_normal.ogg','sound/effects/psi/other/boss_intro.ogg','sound/effects/psi/other/spooky.ogg')
	var/list/sound_volumes = list(40,40,75)
	var/nextuse
	var/cooldown = 6 SECONDS
	
/obj/item/device/starman_hailer/attack_self(mob/user)
	activate(user)

/obj/item/device/starman_hailer/afterattack(atom/target, mob/user)
	activate(user)
	
/obj/item/device/starman_hailer/proc/activate(var/mob/user)
	if(world.time < nextuse)
		return
	if(user)
		var/index = rand(1,possible_sounds.len)
		playsound(user, possible_sounds[index], sound_volumes[index], 1, vary = 0)
		var/list/bystanders = get_hearers_in_view(world.view, user)
		flick_overlay(image('icons/mob/talk.dmi', user, "hail", MOB_LAYER+1), clients_in_moblist(bystanders), 2 SECONDS)
		user.visible_message("<span class='danger'>\The [user] [pick("emits","blares","performs")] a [pick("sickly","frightening","spooky","strange")] [pick("sound","tune","theme")]!</span>")
	nextuse = world.time + cooldown
