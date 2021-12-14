/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	layer = PROJECTILE_LAYER
	damage_type = BURN
	flag = "energy"
	fire_sound = 'sound/weapons/Taser.ogg'
	plane = EFFECTS_PLANE


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 10
	weaken = 10
	stutter = 10
	jittery = 20
	agony = 10
	hitsound = 'sound/weapons/taserhit.ogg'

	// light
	lighting_flags = IS_LIGHT_SOURCE
	light_range = 1
	light_power = 4 // very bright
	light_color = LIGHT_COLOR_YELLOW

/obj/item/projectile/energy/electrode/hit_apply(var/mob/living/X, var/blocked)
	if (ismanifested(X))
		X.visible_message("<span class='danger'>\The [X] seems to completely ignore \the [src] that hit them.</span>","<span class='warning'>You can barely feel at all \the [src]'s electrical discharge.</span>")
		return
	spawn(13)
		X.apply_effects(stun, weaken, blocked = blocked)
	X.apply_effects(stutter = stutter, blocked = blocked, agony = agony)
	X.audible_scream()
	if(X.tazed == 0)
		X.movement_speed_modifier -= 0.75
		spawn(30)
			X.movement_speed_modifier += 0.75
	X.tazed = 1
	spawn(30)
		X.tazed = 0


/*/vg/ EDIT
	agony = 40
	damage_type = HALLOSS
*/
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/tag
	name = "tag electrode"
	icon_state = "sparkblue"
	nodamage = 1
	var/list/enemy_vest_types = list(/obj/item/clothing/suit/tag/redtag)

/obj/item/projectile/energy/tag/on_hit(var/atom/target, var/blocked = 0)
	if(ismob(target))
		var/mob/M = target
		var/obj/item/clothing/suit/tag/target_tag = get_tag_armor(M)
		var/obj/item/clothing/suit/tag/firer_tag = get_tag_armor(firer)
		if(is_type_in_list(target_tag, laser_tag_vests))
			var/datum/laser_tag_game/game = firer_tag.my_laser_tag_game
			if (!game) // No registered game : classic laser tag
				if (!(is_type_in_list(target_tag, enemy_vest_types)))
					return 1
				if(!M.lying) //Kick a man while he's down, will ya
					var/obj/item/weapon/gun/energy/tag/taggun = shot_from
					if(istype(taggun))
						taggun.score()
				M.Knockdown(2)
				M.Stun(2)
			else // We've got a game on the reciever, let's check if we've got a game on the wearer.
				if (!firer_tag || !firer_tag.my_laser_tag_game || (target_tag.my_laser_tag_game != firer_tag.my_laser_tag_game))
					return 1
				if (!target_tag.player || !firer_tag.player)
					CRASH("A suit has a laser tag game registered, but no players attached.")

				var/datum/laser_tag_participant/target_player = target_tag.player
				var/datum/laser_tag_participant/firer_player = firer_tag.player

				if (firer_tag.my_laser_tag_game.mode == LT_MODE_TEAM && !(is_type_in_list(target_tag, enemy_vest_types)))
					return 1
				if(!M.lying) // Not counting scores if the opponent is lying down.
					firer_player.total_hits++
					target_player.total_hit_by++
					target_player.hit_by[firer_player.nametag]++
				var/taggun_index = M.find_held_item_by_type(/obj/item/weapon/gun/energy/tag)
				if (taggun_index)
					var/obj/item/weapon/gun/energy/tag/their_gun = M.held_items[taggun_index]
					their_gun.cooldown(target_tag.my_laser_tag_game.disable_time/2)
				M.Knockdown(target_tag.my_laser_tag_game.stun_time/2)
				M.Stun(target_tag.my_laser_tag_game.stun_time/2)
				var/obj/item/weapon/gun/energy/tag/taggun = shot_from
				if(istype(taggun))
					taggun.score()
	return 1

/obj/item/projectile/energy/tag/blue
	icon_state = "sparkblue"
	enemy_vest_types = list(/obj/item/clothing/suit/tag/redtag)

/obj/item/projectile/energy/tag/red
	icon_state = "sparkred"
	enemy_vest_types = list(/obj/item/clothing/suit/tag/bluetag)



/obj/item/projectile/energy/declone
	name = "decloner bolt"
	icon_state = "declone"
	damage = 12
	nodamage = 0
	damage_type = CLONE
	irradiate = 40
	fire_sound = 'sound/weapons/pulse3.ogg'
	linear_movement = 0

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	stun = 10
	nodamage = 0
	weaken = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "large bolt"
	damage = 20

/obj/item/projectile/energy/plasma
	name = "plasma bolt"
	icon_state = "plasma"
	var/knockdown_chance = 0
	fire_sound = 'sound/weapons/elecfire.ogg'

/obj/item/projectile/energy/plasma/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		L.contaminate()
		if(prob(knockdown_chance))
			if(istype(target, /mob/living/carbon/))
				shake_camera(L, 3, 2)
				L.apply_effect(2, WEAKEN)
				to_chat(L, "<span class = 'alert'> The force of the bolt knocks you off your feet!")
		return 1
	return 0

/obj/item/projectile/energy/plasma/pistol
	damage = 25
	icon_state = "plasma1"
	irradiate = 12

/obj/item/projectile/energy/plasma/light
	damage = 35
	icon_state = "plasma2"
	irradiate = 20
	knockdown_chance = 30

/obj/item/projectile/energy/plasma/rifle
	damage = 50
	icon_state = "plasma3"
	irradiate = 35
	knockdown_chance = 50

/obj/item/projectile/energy/plasma/MP40k
	damage = 35
	eyeblur = 4
	irradiate = 25
	knockdown_chance = 40
	icon_state = "plasma3"

/obj/item/projectile/energy/neurotoxin
	name = "neurotoxin bolt"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/energy/rad
	name = "radiation bolt"
	icon_state = "rad"
	damage = 30
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10
	fire_sound = 'sound/weapons/radgun.ogg'

/obj/item/projectile/energy/rad/on_hit(var/atom/hit)
	if(ishuman(hit))

		var/mob/living/carbon/human/H = hit

		H.generate_name()

		scramble(1, H, 100) // Scramble all UIs
		scramble(null, H, 5) // Scramble SEs, 5% chance for each block

		H.apply_radiation((rand(50, 250)),RAD_EXTERNAL)

/obj/item/projectile/energy/buster
	name = "buster shot"
	icon_state = "buster"
	nodamage = 0
	damage = 20
	damage_type = BURN
	fire_sound = 'sound/weapons/mmlbuster.ogg'

/obj/item/projectile/energy/megabuster
	name = "buster pellet"
	icon_state = "megabuster"
	nodamage = 1
	fire_sound = 'sound/weapons/megabuster.ogg'

/obj/item/projectile/energy/osipr
	name = "dark energy ball"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "dark"
	kill_count = 100
	damage = 50
	stun = 10
	weaken = 10
	stutter = 10
	jittery = 30
	destroy = 0
	bounce_sound = 'sound/weapons/osipr_altbounce.ogg'
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = -1
	phase_type = PROJREACT_OBJS|PROJREACT_MOBS
	penetration = -1
	fire_sound = 'sound/weapons/osipr_altfire.ogg'

/obj/item/projectile/energy/osipr/Destroy()
	var/turf/T = loc
	spark(T, 4, FALSE)
	T.turf_animation('icons/obj/projectiles_impacts.dmi',"dark_explosion",0, 0, 13, 'sound/weapons/osipr_altexplosion.ogg')
	..()

/obj/item/projectile/energy/whammy
	name = "double whammy shot"
	icon_state = "bluelaser_old"
	damage = 30

/obj/item/projectile/energy/electrode/fast
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	projectile_speed = 0.5

/obj/item/projectile/energy/electrode/scatter
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	projectile_speed = 1.3
	var/split = 1

/obj/item/projectile/energy/electrode/scatter/sun
	name = "forbidden sun"
	desc = "What could possibly justify such excessive destructive power? In all likelihood, the madmen never even questioned the need."
	split = 5

/obj/item/projectile/energy/electrode/scatter/New(loc,inheritance=null)
	..()
	if(!isnull(inheritance))
		split = inheritance

/obj/item/projectile/energy/electrode/scatter/OnFired(var/proj_target = original)
	if(split)
		var/vdirs = alldirs.Copy()
		for(var/i = 1 to 2)
			var/obj/item/projectile/energy/electrode/scatter/P = new(get_turf(loc),split-1)
			P.starting = starting
			P.shot_from = shot_from
			P.current = current
			var/turf/T = get_step(proj_target, pick_n_take(vdirs))
			P.OnFired(T)
			P.process()
	..()
